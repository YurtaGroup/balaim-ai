// Sunday Chapter — the weekly narrated letter cron.
//
// Architecture (decided 2026-06-01 by CTO):
// - Hourly UTC scan. Inside the handler we compute which timezones just
//   crossed local Sunday 7pm in the last hour and queue chapters for
//   matching users.
// - Pure function `composeChapter(input) → output` is the migration seam.
//   Sprint 1 (this file) reads observations server-side from Firestore.
//   Sprint 3 (post-E2EE) replaces the cron with a client-triggered call
//   that decrypts locally and posts the same `ChapterInput` to a stateless
//   callable. Compose stays identical.
// - Idempotency via Firestore transaction on doc
//   `users/{uid}/chapters/{weekId}` where weekId = ISO week (e.g. 2026-W23).
//   Duplicate writes are silent no-ops.
// - TTS is gated by OPENAI_API_KEY presence. Sprint 1 ships Claude-only so
//   the dogfood family can review prompt quality before audio cost kicks in.
//   Add OPENAI_API_KEY secret + npm install openai to enable Sprint-1 step 5.
//
// Push notification: fires after the chapter doc reaches status "ready".
// Existing FCM pattern from onNewNotice is the reference.

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import Anthropic from "@anthropic-ai/sdk";
import {
  SUNDAY_CHAPTER_SYSTEM_PROMPT,
  buildSundayChapterUserMessage,
  isApproximateChapter,
  SundayChapterInput,
  SundayChapterOutput,
} from "../ai/personas/sunday_chapter";

const anthropicKey = defineSecret("ANTHROPIC_API_KEY");

// ============================================================
// PURE FUNCTION — the migration seam
// ============================================================
//
// Takes a fully-assembled ChapterInput and returns the narrative.
// Does NOT touch Firestore. Does NOT know about timezones, weekIds,
// or push notifications. Sprint 3 (E2EE) calls this from a client-
// triggered callable with the same input shape.

export async function composeChapter(
  input: SundayChapterInput
): Promise<SundayChapterOutput> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    throw new Error("ANTHROPIC_API_KEY not configured");
  }

  const client = new Anthropic({ apiKey });
  const userMessage = buildSundayChapterUserMessage(input);

  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 300,
    temperature: 0.75,
    system: SUNDAY_CHAPTER_SYSTEM_PROMPT,
    messages: [{ role: "user", content: userMessage }],
  });

  const textBlock = response.content.find((b) => b.type === "text");
  const narrative = textBlock?.text?.trim() ?? "";
  if (!narrative) {
    throw new Error("Claude returned empty narrative");
  }

  return {
    narrative,
    approximate: isApproximateChapter(input),
  };
}

// ============================================================
// HELPERS
// ============================================================

/**
 * ISO 8601 week string, e.g. "2026-W22".
 * Used as the idempotency key on chapter docs.
 */
export function isoWeekKey(date: Date): string {
  const d = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  return `${d.getUTCFullYear()}-W${weekNo.toString().padStart(2, "0")}`;
}

/**
 * Human-readable week label for the prompt, e.g. "May 26 – June 1".
 * Computed from the local week boundaries for the given parent's TZ offset.
 */
function weekLabelForLocale(
  weekStartLocal: Date,
  weekEndLocal: Date,
  locale: "en" | "ru" | "ky"
): string {
  const fmt = new Intl.DateTimeFormat(
    locale === "ky" ? "ky-KG" : locale === "ru" ? "ru-RU" : "en-US",
    { month: "short", day: "numeric" }
  );
  return `${fmt.format(weekStartLocal)} – ${fmt.format(weekEndLocal)}`;
}

/**
 * For a given parent's UTC offset (minutes), compute the [start, end)
 * UTC instants that bound the current local week — Sunday 00:00 local
 * through the following Sunday 00:00 local. We treat the just-ending
 * week as "this Sunday 18:59 local back to last Sunday 00:00 local."
 */
function localWeekWindow(now: Date, offsetMinutes: number): { start: Date; end: Date } {
  const localNow = new Date(now.getTime() + offsetMinutes * 60 * 1000);
  const localDay = localNow.getUTCDay(); // 0 = Sunday
  // Roll back to last Sunday 00:00 local
  const startLocal = new Date(localNow);
  startLocal.setUTCDate(localNow.getUTCDate() - localDay);
  startLocal.setUTCHours(0, 0, 0, 0);
  // End = startLocal + 7d (next Sunday 00:00 local) — but for the chapter
  // we typically run AT Sunday 19:00 local, so the week being summarized
  // is [start, startLocal + 19h].
  const endLocal = new Date(startLocal);
  endLocal.setUTCDate(startLocal.getUTCDate() + 7);
  // Convert local boundaries back to UTC instants by subtracting offset.
  const startUtc = new Date(startLocal.getTime() - offsetMinutes * 60 * 1000);
  const endUtc = new Date(endLocal.getTime() - offsetMinutes * 60 * 1000);
  return { start: startUtc, end: endUtc };
}

/**
 * Returns true if `now` is within the hour where local time
 * just crossed Sunday 19:00 for the given parent's UTC offset.
 * We accept any minute in that local hour to absorb minor cron drift.
 */
function isLocalSundayChapterHour(now: Date, offsetMinutes: number): boolean {
  const localNow = new Date(now.getTime() + offsetMinutes * 60 * 1000);
  return localNow.getUTCDay() === 0 /* Sunday */ && localNow.getUTCHours() === 19;
}

// ============================================================
// DATA ASSEMBLY — Firestore reads (Sprint-1 plaintext path)
// ============================================================
//
// In Sprint 3, these reads happen on the client (decrypted in RAM) and
// the ChapterInput is posted to a stateless callable. The shape of
// ChapterInput is stable across that migration.

async function assembleChapterInput(
  uid: string,
  child: { id: string; name: string; ageMonths: number | null },
  weekStart: Date,
  weekEnd: Date,
  chapterNumber: number,
  locale: "en" | "ru" | "ky"
): Promise<SundayChapterInput> {
  const db = admin.firestore();

  // 1. Observations (newest first, max 10)
  const obsSnap = await db
    .collection(`users/${uid}/observations`)
    .where("createdAt", ">=", weekStart)
    .where("createdAt", "<=", weekEnd)
    .orderBy("createdAt", "desc")
    .limit(10)
    .get();

  const observations = obsSnap.docs
    .map((d) => {
      const data = d.data();
      // Prefer the server-tagged `summary`; fall back to raw `note`.
      const text = (data.summary as string) || (data.note as string) || "";
      return text.trim();
    })
    .filter((t) => t.length > 0);

  // 2. Mood check-ins this week
  const moodSnap = await db
    .collection(`users/${uid}/moodCheckins`)
    .where("createdAt", ">=", weekStart)
    .where("createdAt", "<=", weekEnd)
    .orderBy("createdAt", "asc")
    .get();

  const mood_log = moodSnap.docs.map((d) => {
    const data = d.data();
    return {
      level: (data.level as number) ?? 3,
      note: (data.note as string) || undefined,
    };
  });

  // 3. Milestone moments this week (caption only — no photo data)
  const momentsSnap = await db
    .collection(`users/${uid}/moments`)
    .where("date", ">=", weekStart)
    .where("date", "<=", weekEnd)
    .orderBy("date", "desc")
    .limit(5)
    .get();

  const milestones = momentsSnap.docs
    .map((d) => {
      const data = d.data();
      const caption = (data.caption as string) || "";
      return caption.trim();
    })
    .filter((t) => t.length > 0);

  return {
    child_name: child.name,
    child_age_months: child.ageMonths,
    week_label: weekLabelForLocale(weekStart, new Date(weekEnd.getTime() - 24 * 3600 * 1000 + 19 * 3600 * 1000), locale),
    chapter_number: chapterNumber,
    observations,
    mood_log,
    milestones,
    locale,
  };
}

// ============================================================
// CHAPTER COMPOSITION — the full per-user flow
// ============================================================

export interface GenerateChapterOptions {
  /** If true, regenerate even if a chapter already exists for this week. */
  force?: boolean;
  /** Override the "now" timestamp — for backfill / manual fires. */
  now?: Date;
}

export interface GenerateChapterResult {
  status: "generated" | "skipped_exists" | "skipped_no_child" | "error";
  weekId?: string;
  narrative?: string;
  error?: string;
}

/**
 * Generate one chapter for one parent. Idempotent: a second call for the
 * same parent+week is a silent no-op unless `force: true`.
 */
export async function generateChapterForParent(
  uid: string,
  options: GenerateChapterOptions = {}
): Promise<GenerateChapterResult> {
  const db = admin.firestore();
  const now = options.now ?? new Date();

  // Read user doc — need timezone, selected child, locale, chapter count
  const userDoc = await db.doc(`users/${uid}`).get();
  if (!userDoc.exists) return { status: "skipped_no_child", error: "user_missing" };
  const userData = userDoc.data() ?? {};

  const offsetMinutes = (userData.timezoneOffsetMinutes as number) ?? 0;
  const locale: "en" | "ru" | "ky" = ((userData.localeCode as string) || "en") as "en" | "ru" | "ky";
  const members = ((userData.members as unknown[]) ?? []) as Record<string, unknown>[];
  const children = members.filter((m) => m?.role === "child");
  if (children.length === 0) return { status: "skipped_no_child" };

  // Pick the selected child if it exists; otherwise the first child
  const selectedId = (userData.selectedMemberId as string) || (userData.selectedChildId as string);
  const childRaw =
    children.find((c) => c.id === selectedId) ?? children[0];

  const childId = String(childRaw.id ?? "");
  const childName = String(childRaw.name ?? "your child");
  const childAgeMonths = computeAgeMonths(childRaw);

  // Compute week window in this parent's local TZ
  const { start: weekStart, end: weekEnd } = localWeekWindow(now, offsetMinutes);
  const weekId = isoWeekKey(now);
  const chapterRef = db.doc(`users/${uid}/chapters/${weekId}`);

  // Idempotency check
  if (!options.force) {
    const existing = await chapterRef.get();
    if (existing.exists) {
      return { status: "skipped_exists", weekId };
    }
  }

  // Reserve the slot in a transaction so concurrent fires can't race
  const chapterNumber = ((userData.chapterCount as number) ?? 0) + 1;
  try {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(chapterRef);
      if (snap.exists && !options.force) {
        throw new Error("RACE_LOST"); // someone else got here first
      }
      tx.set(chapterRef, {
        weekId,
        chapterNumber,
        status: "generating",
        childId,
        childName,
        locale,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    });
  } catch (e: unknown) {
    if (e instanceof Error && e.message === "RACE_LOST") {
      return { status: "skipped_exists", weekId };
    }
    throw e;
  }

  try {
    // Assemble + compose
    const input = await assembleChapterInput(
      uid,
      { id: childId, name: childName, ageMonths: childAgeMonths },
      weekStart,
      weekEnd,
      chapterNumber,
      locale
    );
    const { narrative, approximate } = await composeChapter(input);

    // Write narrative + flip status
    await chapterRef.set({
      narrative,
      approximate: approximate ?? false,
      status: "text_ready",
      narrativeAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Bump chapter counter
    await db.doc(`users/${uid}`).set({
      chapterCount: admin.firestore.FieldValue.increment(1),
    }, { merge: true });

    // TTS — gated on OPENAI_API_KEY. Sprint 1 step 5 wires this on.
    // const audioUrl = await synthesizeChapterAudio(narrative, uid, weekId);
    // await chapterRef.set({ audioUrl, status: "ready" }, { merge: true });

    // Sprint 1 ships text-only; mark ready so the card renders it.
    await chapterRef.set({ status: "ready" }, { merge: true });

    // Push notification (placeholder copy — confirm with Designer)
    await sendChapterReadyPush(uid, childName, chapterNumber, locale);

    return { status: "generated", weekId, narrative };
  } catch (e: unknown) {
    const err = e instanceof Error ? e.message : String(e);
    functions.logger.error("[sundayChapter] generation failed", { uid, weekId, err });
    await chapterRef.set({
      status: "error",
      errorMessage: err,
      errorAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    return { status: "error", weekId, error: err };
  }
}

function computeAgeMonths(childRaw: Record<string, unknown>): number | null {
  const birth = childRaw.birthDate as string | undefined;
  if (!birth) return null;
  const birthDate = new Date(birth);
  if (isNaN(birthDate.getTime())) return null;
  const ms = Date.now() - birthDate.getTime();
  const months = Math.floor(ms / (1000 * 60 * 60 * 24 * 30.44));
  return months;
}

async function sendChapterReadyPush(
  uid: string,
  childName: string,
  chapterNumber: number,
  locale: "en" | "ru" | "ky"
): Promise<void> {
  const userDoc = await admin.firestore().doc(`users/${uid}`).get();
  const fcmToken = userDoc.data()?.fcmToken as string | undefined;
  if (!fcmToken) return;

  const title = {
    en: `Chapter ${chapterNumber} is ready`,
    ru: `Глава ${chapterNumber} готова`,
    ky: `${chapterNumber}-баб даяр`,
  }[locale];

  const body = {
    en: `${childName}'s week, in 60 seconds.`,
    ru: `Неделя ${childName} за 60 секунд.`,
    ky: `${childName}нын жумасы — 60 секундда.`,
  }[locale];

  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data: { type: "sunday_chapter" },
    });
  } catch (e) {
    functions.logger.warn("[sundayChapter] push failed", { uid, err: String(e) });
  }
}

// ============================================================
// SCHEDULED HANDLER — runs hourly UTC, targets users at local Sun 19:00
// ============================================================

export const scheduledSundayChapters = onSchedule(
  { schedule: "0 * * * *", timeZone: "UTC", region: "us-central1", secrets: [anthropicKey] },
  async () => {
    const now = new Date();
    const db = admin.firestore();

    // Pull recently-active users (same 14-day window the daily brief uses)
    const cutoff = Date.now() - 14 * 24 * 60 * 60 * 1000;
    const snap = await db
      .collection("users")
      .where("lastSeenAt", ">", new Date(cutoff))
      .get();

    let generated = 0;
    let skipped = 0;
    let errored = 0;

    for (const userDoc of snap.docs) {
      const data = userDoc.data();
      const offsetMinutes = (data.timezoneOffsetMinutes as number) ?? 0;
      if (!isLocalSundayChapterHour(now, offsetMinutes)) continue;

      try {
        const result = await generateChapterForParent(userDoc.id, { now });
        if (result.status === "generated") generated += 1;
        else if (result.status === "error") errored += 1;
        else skipped += 1;
      } catch (e) {
        errored += 1;
        functions.logger.error("[sundayChapter] unhandled error", {
          uid: userDoc.id,
          err: String(e),
        });
      }
    }

    functions.logger.info("[sundayChapter] hourly run complete", {
      generated,
      skipped,
      errored,
      timestamp: now.toISOString(),
    });
  }
);

// ============================================================
// MANUAL TRIGGER — for dogfood review via firebase functions:shell
// ============================================================
//
// Usage in `firebase functions:shell`:
//   generateSundayChapterManual({ uid: "TIMUR_UID", force: true })
//
// Returns the narrative inline so Timur can read it without opening Firestore.

export const generateSundayChapterManual = onCall(
  { region: "us-central1", secrets: [anthropicKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in");
    }
    const callerUid = request.auth.uid;
    const targetUid = String(request.data?.uid ?? callerUid);
    const force = Boolean(request.data?.force ?? false);

    // Only allow targeting other users if caller is the same user
    // (defense-in-depth — manual triggers should never cross-fire).
    if (targetUid !== callerUid) {
      throw new HttpsError("permission-denied", "Can only generate own chapter");
    }

    const result = await generateChapterForParent(targetUid, { force });
    return result;
  }
);

# Sprint 1 Kickoff — Proof of Artifact

**Date:** 2026-06-01
**Sprint duration:** 1 week (target ship: 2026-06-08)
**Sprint goal:** Sunday Chapter ships in TestFlight build N+1, with 3 families having received at least one chapter.

WIP at sprint open: 3/3 (tasks 1.1 + 1.2 + 1.3 in-progress). Queue: 1.4, 1.5, 1.6.

---

## Product Designer — what was decided (task 1.1)

- **Position on Home:** between `QuickLogStrip` and `InvitationCard`. The Chapter synthesizes what Quick Log captured; the Invitation responds to it. That sequencing is the data flywheel made visible.
- **Label:** "Amir's story, week 4" (eyebrow, uppercase, 11px / letter-spacing 1.4). Possessive. Casual. Not "Chapter 4," not "Week 4," not a date.
- **Play affordance:** 64pt coral circle, white solid play icon, no label text. The size IS the CTA.
- **Share affordance:** appears only after first listen, rendered as "Save or share" text row + upload glyph. Native `share_plus` sheet on tap. No coercion, no "share to Instagram" pre-baking.
- **5 states designed in full** with exact copy, sizes, colors, and ASCII mockups: Generating / Ready / Playing / Played-this-week / Error. Error state intentionally has NO retry button — "Next Sunday." closes the loop.
- **Multilingual copy table** delivered for EN / RU / KY.
- **Cuts:** no waveform visualizer, no auto-play, no chapter-count tally, no animations on appearance, no archive UI. All deferred.

Critical file paths to create:
- `lib/features/home/widgets/sunday_chapter_card.dart`
- `lib/features/home/providers/sunday_chapter_provider.dart`
- `lib/features/home/models/sunday_chapter.dart`

Insert site: `lib/features/home/views/home_screen.dart` between `QuickLogStrip` and `InvitationCard`.

---

## CTO — what was decided (tasks 1.2 + 1.3)

### Cron architecture
- **File:** `functions/src/jobs/sunday_chapter.ts` (new `jobs/` directory)
- **Schedule:** hourly UTC cron (`0 * * * *`). Inside, compute which timezones have just crossed local Sunday 7pm. For Sprint 1 dogfood we *could* shortcut with fixed UTC, but building the hourly scan now avoids retrofitting later and unlocks Sprint 6 (birthday cinematics need same TZ logic).
- **Timezone strategy:** add `timezoneId` (IANA string) to `users/{uid}`. Captured on every Flutter cold start via `DateTime.now().timeZoneName`. → **Open question for Timur (Q3 below).**
- **Idempotency:** Firestore transaction on doc `users/{uid}/chapters/{weekId}` where weekId = ISO week (`2026-W23`). Existing doc → silent no-op. No race window.
- **E2EE migration seam:** `composeChapter(input: ChapterInput) → ChapterOutput` is a pure function. Sprint 1 cron calls it server-side. Sprint 3 client decrypts plaintext locally, calls a stateless callable, which calls the same `composeChapter`. **Zero rewrite needed in Sprint 3.**
- **TTS:** OpenAI `tts-1`, voice `alloy` or `nova`. ~$0.014/chapter, ~2-3s latency. Cartesia and ElevenLabs deferred (ElevenLabs is Sprint 7 voice clone choice).
- **Storage:** `chapters/{uid}_{yyyy-Www}/audio.mp3` + `transcript.txt` in Firebase Storage.
- **Push:** FCM via existing `users/{uid}.fcmToken` pattern (mirrors `onNewNotice`).
- **Error handling:** Claude fails → retry once, then suppress. TTS fails → retry once, then text-only chapter card with "audio unavailable." Storage fails → leave status pending, retry next Sunday.

### Cost per parent
- Claude Sonnet: ~$0.006/chapter → $0.31/yr
- OpenAI TTS: ~$0.014/chapter → $0.73/yr
- Storage: ~$0.001/chapter → $0.05/yr
- FCM: $0
- **Total: $1.09/parent/year all-in.** 1.4% of $79 ARPU. Inside budget.

### Chapter persona prompt
First-draft prompt delivered as production-ready `functions/src/ai/personas/sunday_chapter.ts`. Voice: thoughtful friend's letter, not greeting card, not newsletter. 150-word ceiling. References at least 2 specific observations. Acknowledges hard mood-log moments without catastrophizing. No emoji, no marketing language, no medical claims. Closes with a forward-tilting sentence, never a CTA.

Example output from the CTO's spec:
> *This week Amir decided that the kitchen cupboard is actually his. He spent most of Tuesday afternoon moving the tupperware from the bottom shelf to the hallway and back, in an order only he understood. You logged it as "just playing" but the look on his face was not playing — it was work. Wednesday was rough. You checked in at level 2, no note. That's in the record too, because this is the whole year, not just the good parts. By the weekend he was pulling to stand on everything, including the dog, which the dog has opinions about. Fourteen months is a strange place to be — not quite walking, not quite still. Next week he might just tip over into it.*

That's the bar. If 4 out of 5 dogfood chapters don't read at this quality, the prompt needs another pass before we ship.

---

## Open questions for Timur to ratify before implementation begins

| # | Question | CTO's recommendation |
|---|---|---|
| Q1 | Add `OPENAI_API_KEY` as a new Firebase secret? (We currently only have `ANTHROPIC_API_KEY`.) | Yes — OpenAI TTS is the cheapest + warmest option. |
| Q2 | Top-level `chapters/` collection vs subcollection `users/{uid}/chapters/`? | **Subcollection** — consistent with `observations`, `moodCheckins`, `moments`. Chapters never shared upward, so cross-parent queries are unnecessary. |
| Q3 | Add `timezoneId` field to `users/{uid}` via `UserProfileService.updateProfile()` on cold start? | Yes — required for the per-parent-7pm trigger. Low-risk schema add. |
| Q4 | Add `chapterCount` int field on `users/{uid}`, server-incremented per chapter? | Yes — the chapter number ("Chapter 12 of Amir's story") is emotional anchor. Single integer field. |
| Q5 | Push notification copy when chapter is ready? | Placeholder: *"Chapter 4 is ready"* / sub: *"Amir's week, in 60 seconds."* — confirm or rewrite. |

---

## Recommended implementation order (once Timur ratifies)

1. Q1+Q3+Q4 schema work first (low-risk, unblocks everything).
2. Create the persona file `functions/src/ai/personas/sunday_chapter.ts` (paste CTO's draft).
3. Create the cron file `functions/src/jobs/sunday_chapter.ts` — Claude-only path (no TTS yet).
4. Manually invoke via `firebase functions:shell` for Timur's family — read the first text-only chapter. **Stop here for prompt iteration before going further.**
5. Once prompt is at "I'd share this" quality, wire OpenAI TTS.
6. Build the Flutter card per Designer's spec.
7. Wire FCM push.
8. Dogfood for one full week with 3 families.

---

## Top 3 actions for Timur to ratify

1. **Answer Q1–Q5 above.** Ideally in one message: "Q1 yes, Q2 subcollection, Q3 yes, Q4 yes, Q5 use this copy: ..."
2. **Confirm dogfood family list.** Timur's family is one. Need two more Bishkek families for the weekend test. Names?
3. **Approve the recommended implementation order** above, or rearrange.

Once those are answered, implementation begins immediately on the persona file + the cron skeleton.

---

## End-of-day update — 2026-06-01

**Status:** Sprint 1 code-complete + DEPLOYED. Awaiting first chapter narrative for prompt review.

**Shipped today (commit `e9024cb` on `v3-hyperfocus`):**
- ✅ `functions/src/ai/personas/sunday_chapter.ts` — CTO's prompt, EN/RU/KY
- ✅ `functions/src/jobs/sunday_chapter.ts` — hourly cron, pure `composeChapter()` migration seam, idempotent transaction, FCM push
- ✅ Flutter card per Designer spec — 5 states, share via dio+share_plus, inserted into `home_screen.dart` between Quick Log and Mood
- ✅ `users/{uid}.timezoneOffsetMinutes` captured by Flutter on every auth state change
- ✅ `chapters/` subcollection added to `firestore.rules`
- ✅ All ratification questions answered (Q1-Q6) and reflected in code

**Deployed to `balam-ai-2a037`:**
- ✅ Firestore rules
- ✅ `scheduledSundayChapters` (hourly cron — fires every UTC hour, picks parents at local Sun 19:00)
- ✅ `generateSundayChapterManual` (dogfood trigger)

**Open warnings (non-blocking):**
- Node.js 20 runtime deprecated 2026-04-30; decommission 2026-10-30. Upgrade to Node 22 before then.
- `firebase-functions` package is outdated; run `npm install --save firebase-functions@latest` when convenient.

**What's still needed before the first real chapter can render:**

1. **TestFlight build with the auth_service.dart change.** Without it, `timezoneOffsetMinutes` doesn't get written to user docs, so the cron skips everyone. Workaround for the founder: open the running app once with this build to write the field, OR add it to a user doc manually in Firestore Console.
2. **Founder fires the manual trigger** to read the first chapter narrative:
   ```
   firebase functions:shell
   > generateSundayChapterManual({force: true}, {auth: {uid: "TIMUR_UID"}})
   ```
   Read the `narrative` field in the returned object. If it sounds like the CTO's reference example, the prompt ships. If not, send feedback to Claude in tomorrow's session and the prompt gets one more pass.

**Next session opens with:**
- Read first chapter narrative (TIMUR action) → ratify prompt quality
- If ratified: wire OpenAI TTS (`npm install openai` + `firebase functions:secrets:set OPENAI_API_KEY` + uncomment the TTS scaffold in `jobs/sunday_chapter.ts`)
- After TTS: TestFlight build N+1 → dogfood weekend with Izzatillo + Adam
- After Sprint 1 closes: Sprint 2 — onboarding rewrite + Letter-at-18

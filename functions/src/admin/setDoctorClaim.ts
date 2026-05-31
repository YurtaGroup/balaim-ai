import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";

/**
 * Admin-gated callable that onboards a doctor.
 *
 * Effects:
 *   1. Look up the Firebase Auth user by `email`.
 *   2. Assign custom claim `{ doctor: true }` on that user.
 *   3. Write/merge a `doctors/{doctorId}` Firestore record with profile.
 *
 * The doctor must have signed up via the normal email/password flow
 * before being onboarded — Admin SDK does not create accounts here.
 *
 * Caller must be in the ADMIN_EMAILS allowlist (the founder for v1).
 * Defense in depth: even if a malicious caller gets a callable URL,
 * they can't onboard themselves.
 *
 * Idempotent: re-running with the same email updates the existing
 * Firestore record (merge) and re-asserts the claim. Safe to invoke
 * multiple times.
 */

const ADMIN_EMAILS = new Set(["timur.mone@gmail.com"]);

interface DoctorPayload {
  email: string;
  doctorId?: string;
  name: string;
  specialty: string;
  languages?: string[];
  bio?: { en?: string; ru?: string; ky?: string };
  photoUrl?: string | null;
  ratePerConsult: number;
  currency: string;
  region: string;
  active?: boolean;
  acceptingNew?: boolean;
}

export const setDoctorClaim = onCall(
  { region: "us-central1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in");
    }
    const callerEmail = (request.auth.token.email as string | undefined)?.toLowerCase();
    if (!callerEmail || !ADMIN_EMAILS.has(callerEmail)) {
      throw new HttpsError("permission-denied", "Admin access only");
    }

    const payload = request.data as DoctorPayload | undefined;
    if (!payload?.email || !payload?.name || !payload?.specialty) {
      throw new HttpsError(
        "invalid-argument",
        "email, name, and specialty are required"
      );
    }
    if (typeof payload.ratePerConsult !== "number" || payload.ratePerConsult <= 0) {
      throw new HttpsError("invalid-argument", "ratePerConsult must be a positive number");
    }

    // 1. Resolve Firebase Auth user
    let user: admin.auth.UserRecord;
    try {
      user = await admin.auth().getUserByEmail(payload.email);
    } catch (e) {
      throw new HttpsError(
        "not-found",
        `No Firebase Auth user for ${payload.email}. They must sign up first.`
      );
    }

    // 2. Assign custom claim (merge with any existing claims)
    const existingClaims = (user.customClaims ?? {}) as Record<string, unknown>;
    await admin.auth().setCustomUserClaims(user.uid, {
      ...existingClaims,
      doctor: true,
    });

    // 3. Write/merge the Firestore doctor record
    const doctorId = (payload.doctorId ?? slugify(payload.name)).trim();
    if (!doctorId) {
      throw new HttpsError("invalid-argument", "doctorId could not be derived from name");
    }

    await admin.firestore().doc(`doctors/${doctorId}`).set(
      {
        email: payload.email.toLowerCase(),
        uid: user.uid,
        name: payload.name,
        specialty: payload.specialty,
        languages: payload.languages ?? ["en"],
        bio: payload.bio ?? { en: "" },
        photoUrl: payload.photoUrl ?? null,
        ratePerConsult: payload.ratePerConsult,
        currency: payload.currency,
        region: payload.region,
        active: payload.active ?? true,
        acceptingNew: payload.acceptingNew ?? true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    functions.logger.info("[admin] doctor onboarded", {
      doctorId,
      email: payload.email.toLowerCase(),
      caller: callerEmail,
    });

    return { doctorId, uid: user.uid };
  }
);

function slugify(name: string): string {
  return name
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

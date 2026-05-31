import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Firestore trigger: push the other party when a message lands in a
 * consultation thread.
 *
 *   - Parent → Doctor: doctor's phone buzzes with the parent's preview.
 *   - Doctor → Parent: parent's phone buzzes with the doctor's preview.
 *
 * `ai_followup_suggestion` messages are server-appended pills, not
 * conversational content — skip them.
 *
 * FCM tokens live on users/{uid}.fcmToken (already wired by
 * notification_service.dart on first run). The doctor's UID is
 * resolved via doctors/{doctorId}.uid; the parent's UID is on the
 * consultation doc.
 *
 * Mirrors the pattern of `onNewNotice` in functions/src/index.ts —
 * the same `admin.messaging().send(...)` shape, friendly title + body,
 * routing data so the app can deep-link on tap.
 */

interface MessageDoc {
  fromDoctor?: boolean;
  kind?: string;
  text?: string;
  photoUrl?: string | null;
}

interface ConsultationDoc {
  uid?: string;
  parentName?: string;
  doctorId?: string;
  topic?: string;
}

interface DoctorDoc {
  uid?: string;
  name?: string;
}

export const onConsultMessageCreated = functions.firestore
  .document("consultations/{consultId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const consultId = context.params.consultId as string;
    const msg = snap.data() as MessageDoc | undefined;
    if (!msg) return;
    // Skip server-appended AI followup pills — they're not chat.
    if (msg.kind === "ai_followup_suggestion") return;

    const consultSnap = await admin
      .firestore()
      .doc(`consultations/${consultId}`)
      .get();
    const consult = consultSnap.data() as ConsultationDoc | undefined;
    if (!consult) return;

    // Resolve who should be pushed.
    let recipientUid: string | undefined;
    let title: string;
    if (msg.fromDoctor === true) {
      // Doctor replied → push the parent.
      recipientUid = consult.uid;
      const docName = await _resolveDoctorName(consult.doctorId);
      title = docName
        ? `${docName} replied`
        : "Your doctor replied";
    } else {
      // Parent message → push the doctor.
      recipientUid = await _resolveDoctorUid(consult.doctorId);
      title = consult.parentName
        ? `${consult.parentName} sent a message`
        : "New message from a parent";
    }

    if (!recipientUid) return;

    const fcmToken = await _fcmTokenFor(recipientUid);
    if (!fcmToken) return;

    const body = _previewBody(msg);

    try {
      await admin.messaging().send({
        token: fcmToken,
        notification: { title, body },
        data: {
          type: "consult_message",
          consultId,
          fromDoctor: msg.fromDoctor === true ? "1" : "0",
          route: `/consult/${consultId}`,
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      });
    } catch (err) {
      functions.logger.warn("[onConsultMessageCreated] FCM send failed", {
        consultId,
        recipientUid,
        err: String(err),
      });
    }
  });

async function _resolveDoctorUid(
  doctorId: string | undefined
): Promise<string | undefined> {
  if (!doctorId) return undefined;
  try {
    const doc = await admin.firestore().doc(`doctors/${doctorId}`).get();
    return (doc.data() as DoctorDoc | undefined)?.uid;
  } catch {
    return undefined;
  }
}

async function _resolveDoctorName(
  doctorId: string | undefined
): Promise<string | undefined> {
  if (!doctorId) return undefined;
  try {
    const doc = await admin.firestore().doc(`doctors/${doctorId}`).get();
    return (doc.data() as DoctorDoc | undefined)?.name;
  } catch {
    return undefined;
  }
}

async function _fcmTokenFor(uid: string): Promise<string | undefined> {
  try {
    const userDoc = await admin.firestore().doc(`users/${uid}`).get();
    const data = userDoc.data();
    const token = data?.fcmToken;
    return typeof token === "string" && token.length > 0 ? token : undefined;
  } catch {
    return undefined;
  }
}

function _previewBody(msg: MessageDoc): string {
  if (msg.text && msg.text.trim().length > 0) {
    const t = msg.text.trim();
    return t.length > 140 ? `${t.slice(0, 137)}…` : t;
  }
  if (msg.photoUrl) return "📎 Photo";
  return "New message";
}

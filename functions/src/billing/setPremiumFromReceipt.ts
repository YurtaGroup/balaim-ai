import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

/**
 * Premium entitlement setter — the ONLY server-trusted path that
 * writes `users/{uid}.premium`.
 *
 * Why this exists: clients used to write `users/{uid}.premium` directly
 * via PaymentService._syncToFirestore. With the v3 launch-readiness
 * rule update, that path is blocked — otherwise a free user could mint
 * themselves Premium with one Firestore write.
 *
 * What this does:
 *   1. Receives the RevenueCat customer's app user id (== Firebase uid).
 *   2. Calls the RevenueCat REST API as the server, with the secret
 *      key, to fetch authoritative entitlements.
 *   3. If the `premium` entitlement is currently active, writes
 *      premium=true on the user doc. Else premium=false.
 *
 * Pre-launch state: until `REVENUECAT_API_KEY` is bound as a secret,
 * the function returns a soft error and writes nothing — that's safe
 * (free tier stays the default). Wire the key once RevenueCat is
 * configured.
 *
 * Long-term: also wire a RevenueCat webhook (server-to-server) that
 * hits a separate HTTP endpoint and writes the same flag. Both paths
 * = defense in depth; whichever fires first wins.
 */

const revenueCatKey = defineSecret("REVENUECAT_API_KEY");

interface RcSubscriber {
  entitlements?: Record<string, RcEntitlement>;
}

interface RcEntitlement {
  expires_date?: string | null;
  product_identifier?: string;
}

interface RcResponse {
  subscriber?: RcSubscriber;
}

export const setPremiumFromReceipt = onCall(
  { region: "us-central1", secrets: [revenueCatKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in");
    }
    const uid = request.auth.uid;

    const apiKey = process.env.REVENUECAT_API_KEY;
    if (!apiKey) {
      functions.logger.warn(
        "[premium] REVENUECAT_API_KEY not bound — refusing to write premium"
      );
      throw new HttpsError(
        "failed-precondition",
        "Premium verification is not configured yet"
      );
    }

    let active = false;
    let productId: string | null = null;
    try {
      const response = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`,
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            Accept: "application/json",
          },
        }
      );
      if (!response.ok) {
        functions.logger.warn("[premium] RevenueCat API non-ok", {
          status: response.status,
        });
        throw new HttpsError("internal", "Could not verify entitlement");
      }
      const json = (await response.json()) as RcResponse;
      const ent = json?.subscriber?.entitlements?.premium;
      if (ent) {
        const expires = ent.expires_date ? Date.parse(ent.expires_date) : NaN;
        active = !ent.expires_date || (Number.isFinite(expires) && expires > Date.now());
        productId = ent.product_identifier ?? null;
      }
    } catch (e) {
      functions.logger.warn("[premium] RevenueCat verification failed", {
        err: String(e),
      });
      throw new HttpsError("internal", "Could not verify entitlement");
    }

    const update: Record<string, unknown> = {
      premium: active,
    };
    if (active) {
      update.premiumSince = admin.firestore.FieldValue.serverTimestamp();
      if (productId) update.premiumProductId = productId;
    } else {
      update.premiumProductId = admin.firestore.FieldValue.delete();
    }

    await admin
      .firestore()
      .doc(`users/${uid}`)
      .set(update, { merge: true });

    return { premium: active, productId };
  }
);

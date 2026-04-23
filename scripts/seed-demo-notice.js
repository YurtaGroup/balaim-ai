#!/usr/bin/env node
/**
 * Seed a demo "Balam noticed…" notice into Firestore so NoticeCard
 * renders on the simulator without waiting for the scheduled engine.
 *
 * Usage:
 *   node scripts/seed-demo-notice.js <uid> [memberId] [memberName]
 *
 * Example:
 *   node scripts/seed-demo-notice.js abc123XYZ child-demo-1 "Luna"
 *
 * Auth — pick ONE:
 *   (A) gcloud auth application-default login --project balam-ai-2a037
 *   (B) export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
 *
 * Find the uid:
 *   - Firebase Console → Authentication → Users (copy the uid for the
 *     account you're signed into on the simulator)
 *   - OR Firestore Console → users/{uid} doc
 */

const admin = require('../functions/node_modules/firebase-admin');

const [, , uidArg, memberIdArg, memberNameArg] = process.argv;
if (!uidArg) {
  console.error('ERROR: pass uid as first arg.\n');
  console.error('  node scripts/seed-demo-notice.js <uid> [memberId] [memberName]');
  process.exit(1);
}

const uid = uidArg;
const memberId = memberIdArg || 'child-demo-1';
const memberName = memberNameArg || 'Luna';

admin.initializeApp({ projectId: 'balam-ai-2a037' });
const db = admin.firestore();

const notice = {
  memberId,
  memberName,
  milestoneId: 'ped-6mo-well-visit',
  type: 'schedule',
  urgency: 'medium',
  title: {
    en: `${memberName} is due for her 6-month well-visit`,
    ru: `${memberName} пора на осмотр в 6 месяцев`,
    ky: `${memberName} 6 айлык текшерүүгө убакыт болду`,
  },
  body: {
    en:
      `${memberName} is at the 6-month milestone. The AAP recommends a ` +
      `well-baby visit now: growth check, vaccines (DTaP, Hib, PCV, IPV, ` +
      `RV booster), iron screen, and the green light to start solids. ` +
      `Also a good moment to ask about sleep and feeding rhythm.`,
    ru:
      `${memberName} исполнилось 6 месяцев. По рекомендации AAP сейчас ` +
      `плановый осмотр: рост и вес, прививки (АКДС, Hib, PCV, ИПВ, ` +
      `ротавирус — бустер), скрининг на железо и разрешение вводить ` +
      `прикорм. Хороший момент обсудить сон и кормление.`,
    ky:
      `${memberName} 6 айга толду. AAP сунушу боюнча азыр пландуу ` +
      `текшерүү: өсүү, эмдөөлөр (DTaP, Hib, PCV, IPV, ротавирус — ` +
      `бустер), темирге скрининг жана кошумча тамактанууга уруксат. ` +
      `Уйку жана тамактануу ритмин талкуулоого жакшы учур.`,
  },
  action: {
    route: '/professionals',
    label: {
      en: 'Book pediatrician',
      ru: 'Записаться к педиатру',
      ky: 'Педиатрга жазылуу',
    },
  },
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  dismissedAt: null,
  actedAt: null,
};

(async () => {
  const ref = await db
    .collection('notices')
    .doc(uid)
    .collection('items')
    .add(notice);
  console.log(`OK  notices/${uid}/items/${ref.id}`);
  console.log(`    memberId: ${memberId}  memberName: ${memberName}`);
  console.log('    Card should render on Today within a second.');
  process.exit(0);
})().catch((err) => {
  console.error('FAIL', err);
  process.exit(1);
});

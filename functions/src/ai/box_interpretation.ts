// Balam Box — clinical tier classifier.
//
// Takes a single reading event (BP, glucose, dipstick, temperature,
// weight) plus the member's snapshot + 30-day history, and classifies
// it into one of four tiers per the Scope-of-Practice draft (v0.1):
//
//   Green   — normal; log only, no notice
//   Yellow  — notable; autonomous notice, sampled for MD audit
//   Orange  — abnormal; notice + MD co-sign queue (<=24h SLA)
//   Red     — emergency override; notice + immediate UI + MD log
//
// Template-first: copy is trilingual and hard-coded so this ships
// without Anthropic credit and without any Claude call. Claude
// enhancement hooks are stubbed for phase 2; they MUST NOT block
// Green/Red paths even if wired up (clinical-safety rule).
//
// Integration:
// - Writes into the existing `notices/{uid}/items` collection (the
//   engine from build 16), reusing `NoticeDocument` shape so the same
//   NoticeCard + FCM + dismiss flow works unchanged.
// - Writes a parallel record into `clinical_audit/{caseId}` with full
//   input + classification reasoning. This is the defense against any
//   clinical-safety claim and the training corpus for the next model
//   iteration.
// - Red-tier also writes a top-level `emergencies/{emergencyId}` doc
//   so the MD on-call can be paged separately from normal notice
//   delivery.

import * as admin from "firebase-admin";
import { MemberSnapshot, L3 } from "../data/milestones";
import { NoticeDocument } from "./notices";

// ─── Types ───────────────────────────────────────────────────────

export type Tier = "green" | "yellow" | "orange" | "red";

export type ReadingType =
  | "bloodPressure"
  | "bloodGlucose"
  | "dipstick"
  | "temperature"
  | "weight";

export interface BoxReading {
  memberId: string;
  type: ReadingType;
  timestamp: string; // ISO 8601
  // Polymorphic payload — only the relevant subset is populated per type.
  systolic?: number;
  diastolic?: number;
  heartRate?: number;
  glucose?: number; // mg/dL
  fasting?: boolean;
  dipstick?: DipstickReading;
  tempC?: number;
  weightKg?: number;
  // Optional clinical context the client can attach:
  symptoms?: string[]; // e.g. ['chest_pain', 'severe_headache', 'visual_change']
  pregnancyWeek?: number; // if member is pregnant
  note?: string;
}

export interface DipstickReading {
  protein?: DipstickLevel;
  glucose?: DipstickLevel;
  ketones?: DipstickLevel;
  blood?: DipstickLevel;
  leukocytes?: DipstickLevel;
  nitrites?: "positive" | "negative";
  ph?: number;
  specificGravity?: number;
}

// URS-10 strip semi-quant grading. 0 = negative, 1–4 = trace/+/++/+++/++++
export type DipstickLevel = 0 | 1 | 2 | 3 | 4;

export interface ClassificationResult {
  tier: Tier;
  protocolVersion: string;
  ruleId: string;
  reason: L3; // short explanation of WHY this tier — shown to MD on audit, not user
  notice: NoticeDocument | null; // null only when tier === 'green'
  emergency: EmergencyPayload | null; // populated only when tier === 'red'
}

export interface EmergencyPayload {
  memberId: string;
  ruleId: string;
  instruction: L3; // what the user is told to do immediately
  callNumbers: { kg: string; us: string; ru: string };
}

// ─── Entry point ─────────────────────────────────────────────────

const PROTOCOL_VERSION = "sop-v0.1-draft";

/** Classify a single reading event. Pure function — no Firestore I/O.
 * Use `classifyAndRecord` for the side-effectful variant that writes
 * notice + audit + emergency docs. */
export function classifyReading(
  member: MemberSnapshot,
  reading: BoxReading,
  now: Date = new Date()
): ClassificationResult {
  switch (reading.type) {
    case "bloodPressure":
      return classifyBP(member, reading, now);
    case "bloodGlucose":
      return classifyGlucose(member, reading, now);
    case "dipstick":
      return classifyDipstick(member, reading, now);
    case "temperature":
      return classifyTemperature(member, reading, now);
    case "weight":
      // Single-reading weight is always Green on its own — weight trends
      // are handled by runTrendEngineForUser in notices.ts, not here.
      return greenResult(reading, "weight-single-reading", {
        en: "Weight recorded; trend analysis runs nightly.",
        ru: "Вес записан; анализ динамики выполняется еженощно.",
        ky: "Салмак жазылды; динамика анализы түн сайын иштейт.",
      });
    default:
      return greenResult(reading, "unknown-type", {
        en: "Reading type not yet handled.",
        ru: "Тип показания пока не обрабатывается.",
        ky: "Көрсөткүчтүн бул түрү азырынча иштетилбейт.",
      });
  }
}

// ─── Blood pressure ──────────────────────────────────────────────

function classifyBP(
  member: MemberSnapshot,
  r: BoxReading,
  _now: Date
): ClassificationResult {
  const sys = r.systolic ?? 0;
  const dia = r.diastolic ?? 0;
  if (sys === 0 || dia === 0) {
    return greenResult(r, "bp-missing-values", {
      en: "BP reading incomplete.",
      ru: "Неполные показания давления.",
      ky: "Басым көрсөткүчтөрү толук эмес.",
    });
  }

  const pregnant = isPregnant(member, r);
  const hasRedSymptom = (r.symptoms ?? []).some((s) =>
    ["chest_pain", "severe_headache", "visual_change", "numbness", "confusion"].includes(s)
  );

  // Red — hypertensive emergency OR any severe symptom with elevated BP
  if (sys >= 180 || dia >= 120) {
    return redResult(member, r, "bp-hypertensive-emergency", {
      title: {
        en: `${member.name}: blood pressure is at emergency level`,
        ru: `${member.name}: давление на уровне экстренного`,
        ky: `${member.name}: басым өтө жогору, тез жардам керек`,
      },
      body: {
        en: `${sys}/${dia} is a hypertensive emergency range. Go to the nearest emergency room or call 103 right now. Do not wait, do not self-medicate.`,
        ru: `${sys}/${dia} — это уровень гипертонического криза. Езжай в ближайшую больницу или звони 103 прямо сейчас. Не жди, не пей лекарства на авось.`,
        ky: `${sys}/${dia} — гипертониялык криз деңгээли. Эң жакын ооруканага баргыла же азыр эле 103 чакыргыла. Күтпөгүлө, дарыны өз алдыңыздан ичпегиле.`,
      },
      instruction: {
        en: "Call 103 (KG) / 911 (US) / 103 (RU) — go to ER now.",
        ru: "Звони 103 (КР) / 911 (США) / 103 (РФ) — в приёмный покой сейчас.",
        ky: "103 (КР) / 911 (АКШ) / 103 (Орусия) чалгыла — азыр ооруканага.",
      },
      reason: {
        en: `Systolic ${sys} or diastolic ${dia} meets hypertensive-emergency thresholds per SOP v0.1 §4.1.`,
        ru: `Систолическое ${sys} или диастолическое ${dia} соответствует порогу гипертонического криза по SOP v0.1 §4.1.`,
        ky: `Систолалык ${sys} же диастолалык ${dia} SOP v0.1 §4.1 боюнча гипертониялык криз чегине туура келет.`,
      },
    });
  }

  if (hasRedSymptom && (sys >= 140 || dia >= 90)) {
    return redResult(member, r, "bp-elevated-with-red-symptom", {
      title: {
        en: `${member.name}: elevated BP with concerning symptoms`,
        ru: `${member.name}: высокое давление + тревожные симптомы`,
        ky: `${member.name}: жогорку басым + кооптуу белгилер`,
      },
      body: {
        en: `BP ${sys}/${dia} combined with the symptom flagged is an emergency combination. Go to ER or call 103 now.`,
        ru: `Давление ${sys}/${dia} в сочетании с отмеченным симптомом — экстренная ситуация. Звони 103 или в приёмный покой сейчас.`,
        ky: `${sys}/${dia} басымы жана белгиленген симптом чогуу — тез жардам кырдаалы. Азыр 103 чалгыла же ооруканага баргыла.`,
      },
      instruction: {
        en: "Call 103 / 911 — this combination can be stroke or cardiac.",
        ru: "Звони 103 / 911 — такое сочетание может быть инсультом или сердечным.",
        ky: "103 / 911 чалгыла — бул инсульт же жүрөк болушу мүмкүн.",
      },
      reason: {
        en: `Elevated BP ${sys}/${dia} with red-flag symptom per SOP v0.1 §4.1 exception rule.`,
        ru: `Повышенное давление ${sys}/${dia} с красным симптомом по SOP v0.1 §4.1.`,
        ky: `Жогорку басым ${sys}/${dia} кызыл белги менен, SOP v0.1 §4.1.`,
      },
    });
  }

  // Pregnancy — tighter thresholds for preeclampsia concern
  if (pregnant && (sys >= 140 || dia >= 90)) {
    return orangeResult(member, r, "bp-pregnancy-elevated", {
      title: {
        en: `${member.name}: pregnancy BP is elevated`,
        ru: `${member.name}: беременность — давление повышено`,
        ky: `${member.name}: кош бойлуу — басым жогорулаган`,
      },
      body: {
        en: `${sys}/${dia} during pregnancy flags preeclampsia risk. Balam is sending this to the on-call clinician for a same-day review. Please repeat the reading in 15 minutes sitting calmly; also check a urine dipstick if you have one.`,
        ru: `${sys}/${dia} при беременности — риск преэклампсии. Balam передаёт этот случай дежурному врачу для разбора сегодня же. Пожалуйста, через 15 минут повтори замер спокойно сидя; если есть тест-полоска на мочу — проверь и её.`,
        ky: `Кош бойлуулук убагында ${sys}/${dia} — преэклампсия коркунучу. Balam муну бүгүнкү кезекчи дарыгерге жөнөтүп жатат. 15 мүнөттөн кийин тынч отуруп кайра өлчөгүлө; заара тилкеси болсо аны да текшергиле.`,
      },
      reason: {
        en: `Pregnant member with BP ≥140/90 per SOP v0.1 §4.2 preeclampsia screen.`,
        ru: `Беременная с давлением ≥140/90 по SOP v0.1 §4.2 (скрининг преэклампсии).`,
        ky: `Кош бойлуу мүчө, басым ≥140/90, SOP v0.1 §4.2 (преэклампсия скрининги).`,
      },
    });
  }

  // Adult tiers, non-pregnant
  if (sys >= 140 || dia >= 90) {
    return orangeResult(member, r, "bp-stage2", {
      title: {
        en: `${member.name}: blood pressure in Stage 2 range`,
        ru: `${member.name}: давление — 2-я стадия гипертонии`,
        ky: `${member.name}: басым — 2-стадиядагы гипертония`,
      },
      body: {
        en: `A single reading of ${sys}/${dia} is in the Stage 2 hypertension range. This is not an emergency, but it should be reviewed within 24 hours. Repeat twice more today (morning and evening, sitting 5 minutes before the reading) and we'll route the average to Dr. Jane or the on-call clinician.`,
        ru: `Единичный замер ${sys}/${dia} — диапазон 2-й стадии гипертонии. Это не экстренно, но требует разбора в течение 24 часов. Сделай ещё два замера сегодня (утром и вечером, сидя 5 минут перед замером), среднее отправим Джейн или дежурному врачу.`,
        ky: `Бир көрсөткүч ${sys}/${dia} — 2-стадиядагы гипертония чеги. Тез жардам керек эмес, бирок 24 саат ичинде текшерүү керек. Бүгүн дагы эки жолу өлчөгүлө (эртең менен жана кечинде, өлчөөр алдында 5 мүнөт отуруп), орточосун Джейн же кезекчи дарыгерге жөнөтөбүз.`,
      },
      reason: {
        en: `Adult BP ${sys}/${dia} meets Stage 2 hypertension per SOP v0.1 §4.1.`,
        ru: `Взрослое давление ${sys}/${dia} соответствует 2 стадии по SOP v0.1 §4.1.`,
        ky: `Чоң кишинин ${sys}/${dia} басымы SOP v0.1 §4.1 боюнча 2-стадияга туура келет.`,
      },
    });
  }

  if (sys >= 130 || dia >= 80) {
    return yellowResult(member, r, "bp-stage1", {
      title: {
        en: `${member.name}: blood pressure is elevated`,
        ru: `${member.name}: давление повышено`,
        ky: `${member.name}: басым жогорулаган`,
      },
      body: {
        en: `${sys}/${dia} is Stage 1 hypertension range. Not a crisis — common for adults who skipped coffee or slept badly — but worth watching. If three readings this week stay above 130/80, we'll bring a clinician in.`,
        ru: `${sys}/${dia} — это 1-я стадия гипертонии. Не кризис — бывает у взрослых, которые не поспали или пили кофе, — но стоит последить. Если три замера за неделю будут выше 130/80, подключим врача.`,
        ky: `${sys}/${dia} — 1-стадиядагы гипертония. Криз эмес — начар уйку же кофе бузуп коет, — бирок көз салып туруу керек. Ушул жумада үч жолу 130/80төн жогору болсо, дарыгерди кошобуз.`,
      },
      reason: {
        en: `Adult BP ${sys}/${dia} meets Stage 1 threshold per SOP v0.1 §4.1.`,
        ru: `Взрослое давление ${sys}/${dia} — 1 стадия по SOP v0.1 §4.1.`,
        ky: `Чоң кишинин ${sys}/${dia} басымы SOP v0.1 §4.1 боюнча 1-стадия.`,
      },
    });
  }

  return greenResult(r, "bp-normal", {
    en: `BP ${sys}/${dia} is in range.`,
    ru: `Давление ${sys}/${dia} в норме.`,
    ky: `Басым ${sys}/${dia} нормада.`,
  });
}

// ─── Glucose ─────────────────────────────────────────────────────

function classifyGlucose(
  member: MemberSnapshot,
  r: BoxReading,
  _now: Date
): ClassificationResult {
  const g = r.glucose ?? 0;
  if (g === 0) {
    return greenResult(r, "glucose-missing", {
      en: "Glucose reading missing.",
      ru: "Нет значения глюкозы.",
      ky: "Глюкоза көрсөткүчү жок.",
    });
  }
  const diabetic = (member.conditions ?? []).map((c) => c.toLowerCase()).includes("diabetes");
  const hasDKASymptom = (r.symptoms ?? []).some((s) =>
    ["vomiting", "polyuria", "altered_mental_status", "rapid_breathing"].includes(s)
  );

  // Red — DKA screen for diabetics
  if (diabetic && g >= 250 && hasDKASymptom) {
    return redResult(member, r, "glucose-dka-screen", {
      title: {
        en: `${member.name}: possible diabetic emergency`,
        ru: `${member.name}: возможно диабетический криз`,
        ky: `${member.name}: диабеттик криз болушу мүмкүн`,
      },
      body: {
        en: `Glucose ${g} mg/dL with the symptom you logged can be the start of diabetic ketoacidosis. Go to the ER or call 103 now.`,
        ru: `Глюкоза ${g} мг/дл с указанным симптомом может быть началом диабетического кетоацидоза. Срочно в приёмный покой или звони 103.`,
        ky: `Глюкоза ${g} мг/дл жана көрсөтүлгөн симптом диабеттик кетоацидоздун башталышы болушу мүмкүн. Азыр ооруканага же 103 чалгыла.`,
      },
      instruction: {
        en: "Call 103 / 911 — DKA can escalate within hours.",
        ru: "Звони 103 / 911 — ДКА развивается за часы.",
        ky: "103 / 911 чалгыла — ДКА бир нече саатта күчөйт.",
      },
      reason: {
        en: `Diabetic member, glucose ${g} ≥250 + DKA symptom per SOP v0.1 §4.3.`,
        ru: `Больной диабетом, глюкоза ${g} ≥250 + симптом ДКА по SOP v0.1 §4.3.`,
        ky: `Диабет менен мүчө, глюкоза ${g} ≥250 + ДКА белгиси, SOP v0.1 §4.3.`,
      },
    });
  }

  if (g >= 300) {
    return redResult(member, r, "glucose-severe-hyperglycemia", {
      title: {
        en: `${member.name}: blood sugar is dangerously high`,
        ru: `${member.name}: сахар крови опасно высокий`,
        ky: `${member.name}: кандагы кант коркунучтуу деңгээлде`,
      },
      body: {
        en: `${g} mg/dL is severe hyperglycemia. Call 103 or go to the ER now. If the person is diabetic, they may need immediate insulin correction supervised by a clinician.`,
        ru: `${g} мг/дл — тяжёлая гипергликемия. Звони 103 или в приёмный покой сейчас. Если диабетик — может потребоваться коррекция инсулином под контролем врача.`,
        ky: `${g} мг/дл — оор гипергликемия. Азыр 103 чалгыла же ооруканага баргыла. Диабет болсо, дарыгердин көзөмөлүндө шашылыш инсулин керек болушу мүмкүн.`,
      },
      instruction: {
        en: "Call 103 / 911 — severe hyperglycemia.",
        ru: "Звони 103 / 911 — тяжёлая гипергликемия.",
        ky: "103 / 911 чалгыла — оор гипергликемия.",
      },
      reason: {
        en: `Glucose ${g} ≥300 per SOP v0.1 §4.3 Red row.`,
        ru: `Глюкоза ${g} ≥300 по SOP v0.1 §4.3.`,
        ky: `Глюкоза ${g} ≥300, SOP v0.1 §4.3.`,
      },
    });
  }

  // Orange: confirmed diabetic range on a fasting reading
  if (r.fasting === true && g >= 126) {
    return orangeResult(member, r, "glucose-fasting-diabetic", {
      title: {
        en: `${member.name}: fasting glucose in diabetic range`,
        ru: `${member.name}: глюкоза натощак в диабетическом диапазоне`,
        ky: `${member.name}: ачкарын глюкоза диабеттик диапазондо`,
      },
      body: {
        en: `Fasting ${g} mg/dL sits in the diabetes-diagnostic band (≥126). One reading is not a diagnosis — ADA requires two. Balam is queuing this for Dr. Jane (endocrinology) to review. Please repeat tomorrow morning fasting, and bring a lab fasting glucose + HbA1c when you can.`,
        ru: `Натощак ${g} мг/дл — это диабетический диапазон (≥126). Один замер — ещё не диагноз (по ADA нужно два). Balam ставит случай в очередь Джейн (эндокринология). Повтори замер завтра утром натощак, и по возможности сделай анализ глюкозы натощак + HbA1c в лаборатории.`,
        ky: `Ачкарын ${g} мг/дл — диабеттик диапазон (≥126). Бир гана көрсөткүч — диагноз эмес (ADA боюнча экөө керек). Balam муну Джейн (эндокринолог) кезегине коюп жатат. Эртеңки күнү эртең менен ачкарын кайра ченөгүлө, мүмкүнчүлүк болсо лабораторияда глюкоза + HbA1c жасагыла.`,
      },
      reason: {
        en: `Fasting glucose ${g} ≥126 per SOP v0.1 §4.3 Orange row.`,
        ru: `Глюкоза натощак ${g} ≥126 по SOP v0.1 §4.3.`,
        ky: `Ачкарын глюкоза ${g} ≥126, SOP v0.1 §4.3.`,
      },
    });
  }

  // Yellow: prediabetic fasting
  if (r.fasting === true && g >= 100) {
    return yellowResult(member, r, "glucose-fasting-prediabetic", {
      title: {
        en: `${member.name}: fasting glucose in pre-diabetic range`,
        ru: `${member.name}: глюкоза натощак в преддиабетическом диапазоне`,
        ky: `${member.name}: ачкарын глюкоза преддиабеттик диапазондо`,
      },
      body: {
        en: `Fasting ${g} mg/dL is the pre-diabetes band (100–125). This is the window where lifestyle still reverses the trajectory — ~30 min brisk walk/day + cutting sugared drinks moves this reading within weeks. Balam will keep watching.`,
        ru: `Натощак ${g} мг/дл — преддиабетический диапазон (100–125). Это окно, когда образ жизни ещё разворачивает тренд: ~30 мин ходьбы в день и меньше сладких напитков за недели сдвигают цифры. Balam будет следить.`,
        ky: `Ачкарын ${g} мг/дл — преддиабеттик диапазон (100–125). Бул учурда жашоо образы менен трендди өзгөртүүгө болот: күн сайын ~30 мүнөт басуу жана таттуу суусундуктарды кыскартуу бир нече жумада көрсөткүчтү түшүрөт. Balam көзөмөлдөп турат.`,
      },
      reason: {
        en: `Fasting glucose ${g} in 100–125 range per SOP v0.1 §4.3 Yellow row.`,
        ru: `Глюкоза натощак ${g} в диапазоне 100–125, SOP v0.1 §4.3.`,
        ky: `Ачкарын глюкоза ${g} 100–125 диапазонунда, SOP v0.1 §4.3.`,
      },
    });
  }

  return greenResult(r, "glucose-normal", {
    en: `Glucose ${g} mg/dL${r.fasting ? " fasting" : ""} is in range.`,
    ru: `Глюкоза ${g} мг/дл${r.fasting ? " натощак" : ""} в норме.`,
    ky: `Глюкоза ${g} мг/дл${r.fasting ? " ачкарын" : ""} нормада.`,
  });
}

// ─── Urine dipstick ──────────────────────────────────────────────

function classifyDipstick(
  member: MemberSnapshot,
  r: BoxReading,
  _now: Date
): ClassificationResult {
  const d = r.dipstick ?? {};
  const protein = d.protein ?? 0;
  const glucose = d.glucose ?? 0;
  const ketones = d.ketones ?? 0;
  const blood = d.blood ?? 0;
  const leuks = d.leukocytes ?? 0;
  const nitrites = d.nitrites === "positive";
  const pregnant = isPregnant(member, r);
  const diabetic = (member.conditions ?? []).map((c) => c.toLowerCase()).includes("diabetes");

  // Red: preeclampsia combo. Needs BP context — handled inline with
  // BP classifier when combined. Here, ≥3+ proteinuria in pregnancy
  // is the standalone high-concern signal.
  if (pregnant && protein >= 3) {
    return redResult(member, r, "dipstick-pregnancy-heavy-proteinuria", {
      title: {
        en: `${member.name}: heavy protein in urine during pregnancy`,
        ru: `${member.name}: высокий белок в моче при беременности`,
        ky: `${member.name}: кош бойлуу убагында заарада белок көп`,
      },
      body: {
        en: `A 3+ or 4+ protein reading in pregnancy is a strong preeclampsia signal. Check your blood pressure now if you can. Go to OB triage / ER today — this is not something to sleep on.`,
        ru: `Белок 3+/4+ при беременности — сильный сигнал преэклампсии. Если можешь, измерь давление прямо сейчас. Сегодня же в акушерский стационар / приёмный покой — с этим не спят.`,
        ky: `Кош бойлуу учурда белок 3+/4+ — преэклампсиянын күчтүү белгиси. Мүмкүнчүлүк болсо, басымыңызды азыр өлчөгүлө. Бүгүн эле төрөткана / ооруканага баргыла — мындай нерсе менен күтүүгө болбойт.`,
      },
      instruction: {
        en: "Go to OB triage / ER today. Call 103 if also severe headache, RUQ pain, or visual change.",
        ru: "Сегодня в акушерский / приёмный покой. Звони 103 при сильной головной боли, боли справа вверху, нарушении зрения.",
        ky: "Бүгүн төрөткана / ооруканага баргыла. Баш ооруу, оң жогору тарабы ооруу, көрүү бузулушу болсо 103 чалгыла.",
      },
      reason: {
        en: `Pregnancy + proteinuria ≥3+ per SOP v0.1 §4.2 preeclampsia Red row.`,
        ru: `Беременность + белок ≥3+ по SOP v0.1 §4.2 (преэклампсия, красная строка).`,
        ky: `Кош бойлуулук + белок ≥3+, SOP v0.1 §4.2.`,
      },
    });
  }

  // Orange: pregnancy + 1+/2+ protein — preeclampsia screen
  if (pregnant && protein >= 1) {
    return orangeResult(member, r, "dipstick-pregnancy-proteinuria", {
      title: {
        en: `${member.name}: protein detected in pregnancy urine`,
        ru: `${member.name}: белок в моче при беременности`,
        ky: `${member.name}: кош бойлуу убагында заарада белок`,
      },
      body: {
        en: `Protein ${"+".repeat(protein)} in pregnancy needs paired-check with BP. Please take a BP reading now (sitting, 5 min rest) and log it — Balam routes the pair to the on-call OB for a same-day call.`,
        ru: `Белок ${"+".repeat(protein)} при беременности требует парной проверки с давлением. Измерь давление сейчас (сидя, 5 минут отдыха) и сохрани — Balam отправит пару дежурному акушеру сегодня же.`,
        ky: `Кош бойлуу учурда белок ${"+".repeat(protein)} басым менен кошо текшерилиши керек. Азыр басымды өлчөгүлө (5 мүнөт тынч отуруп) жана сактагыла — Balam жуптуу көрсөткүчтү кезекчи акушерге бүгүн эле жөнөтөт.`,
      },
      reason: {
        en: `Pregnancy + proteinuria ${protein}+ per SOP v0.1 §4.2 Orange row.`,
        ru: `Беременность + белок ${protein}+ по SOP v0.1 §4.2.`,
        ky: `Кош бойлуу + белок ${protein}+, SOP v0.1 §4.2.`,
      },
    });
  }

  // Orange: UTI combo (leukocytes + nitrites) — especially in pregnancy
  if (leuks >= 2 && nitrites) {
    const urgencyNote = pregnant
      ? {
          en: "UTIs in pregnancy can escalate to preterm labor or kidney infection. Clinician review today.",
          ru: "Инфекция мочевыводящих при беременности может привести к преждевременным родам или пиелонефриту. Разбор с врачом сегодня.",
          ky: "Кош бойлуулук учурунда заара инфекциясы эрте төрөткө же пиелонефритке алып келиши мүмкүн. Бүгүн дарыгер менен.",
        }
      : {
          en: "Balam queues this for clinician review — untreated UTIs climb to kidney within days.",
          ru: "Balam ставит случай к врачу — без лечения ИМП за дни поднимается к почкам.",
          ky: "Balam муну дарыгердин кезегине коет — дарыланбаса ИМП бир нече күндө бөйрөккө жетет.",
        };
    return orangeResult(member, r, "dipstick-uti-likely", {
      title: {
        en: `${member.name}: urinary infection likely`,
        ru: `${member.name}: вероятна инфекция мочевыводящих`,
        ky: `${member.name}: заара инфекциясы чоң ыктымалдуу`,
      },
      body: urgencyNote,
      reason: {
        en: `Leukocytes ${leuks}+ AND nitrites positive per SOP v0.1 §4.2/§UTI.`,
        ru: `Лейкоциты ${leuks}+ И нитриты положительно, SOP v0.1 §4.2/ИМП.`,
        ky: `Лейкоциттер ${leuks}+ ЖАНА нитриттер оң, SOP v0.1 §4.2/ИМП.`,
      },
    });
  }

  // Orange: diabetic with large ketones + glucose — DKA screen
  if (diabetic && ketones >= 3 && glucose >= 3) {
    return redResult(member, r, "dipstick-diabetic-ketones-glucose", {
      title: {
        en: `${member.name}: ketones + glucose in urine = possible DKA`,
        ru: `${member.name}: кетоны + сахар в моче — возможен ДКА`,
        ky: `${member.name}: заарада кетон + кант — ДКА болушу мүмкүн`,
      },
      body: {
        en: `Large urine ketones combined with glucose, in a diabetic, is a DKA warning. Take a finger-stick glucose reading if you can and go to ER / call 103 now.`,
        ru: `Много кетонов + глюкоза в моче у больного диабетом — предвестник ДКА. Измерь сахар из пальца, если есть, и срочно в приёмный покой / 103.`,
        ky: `Диабет менен оорулууда заарада кетон + кант көп болушу — ДКА белгиси. Мүмкүн болсо, манжадан глюкоза ченеп, азыр ооруканага / 103 чалгыла.`,
      },
      instruction: {
        en: "Call 103 / 911 — DKA window is narrow.",
        ru: "Звони 103 / 911 — окно ДКА узкое.",
        ky: "103 / 911 чалгыла — ДКА терезеси кыска.",
      },
      reason: {
        en: `Diabetic + urine ketones ≥3+ + urine glucose ≥3+ per SOP v0.1 §4.3 Red row.`,
        ru: `Диабет + кетоны ≥3+ + глюкоза ≥3+, SOP v0.1 §4.3.`,
        ky: `Диабет + кетон ≥3+ + кант ≥3+, SOP v0.1 §4.3.`,
      },
    });
  }

  // Yellow: any single non-pregnant abnormal finding at low levels
  if (protein >= 1 || glucose >= 1 || blood >= 1 || leuks >= 1) {
    return yellowResult(member, r, "dipstick-mild-abnormality", {
      title: {
        en: `${member.name}: dipstick shows one mild abnormality`,
        ru: `${member.name}: тест-полоска показывает отклонение`,
        ky: `${member.name}: заара тилкеси бир аздан четтөө көрсөттү`,
      },
      body: {
        en: `One mild finding on its own is usually not meaningful — hydration status, a just-eaten meal, or a period contaminating the sample can cause a trace. Balam will watch and ask you to repeat with a clean morning sample in 48 hours.`,
        ru: `Одно лёгкое отклонение само по себе обычно не значимо: обезвоживание, недавний приём пищи или месячные, попавшие в образец, дают след. Balam последит и попросит повторить чистым утренним образцом через 48 часов.`,
        ky: `Жеке өзүнчө бир эле жеңил четтөө көп учурда маанилүү эмес: суусуздук, жакында жегендик же образецке алардын тийишүүсү — из калтырат. Balam көзөмөлдөп, 48 сааттан кийин таза эртеңки образец менен кайталоону сурайт.`,
      },
      reason: {
        en: `Isolated mild dipstick finding per SOP v0.1 §4.2 Yellow row.`,
        ru: `Изолированное лёгкое отклонение на полоске, SOP v0.1 §4.2.`,
        ky: `Бир гана жеңил четтөө, SOP v0.1 §4.2.`,
      },
    });
  }

  return greenResult(r, "dipstick-normal", {
    en: "Dipstick is clean.",
    ru: "Тест-полоска в норме.",
    ky: "Заара тилкеси таза.",
  });
}

// ─── Temperature ─────────────────────────────────────────────────

function classifyTemperature(
  member: MemberSnapshot,
  r: BoxReading,
  now: Date
): ClassificationResult {
  const t = r.tempC ?? 0;
  if (t === 0) {
    return greenResult(r, "temp-missing", {
      en: "Temperature missing.",
      ru: "Нет значения температуры.",
      ky: "Температура көрсөткүчү жок.",
    });
  }
  const am = ageMonths(member, now);
  const isInfantUnder3Mo = am !== null && am < 3;
  const isToddler = am !== null && am >= 3 && am < 36;

  // Red: infant <3mo + any fever ≥38.0
  if (isInfantUnder3Mo && t >= 38.0) {
    return redResult(member, r, "temp-infant-fever", {
      title: {
        en: `${member.name}: fever in infant under 3 months`,
        ru: `${member.name}: температура у младенца до 3 месяцев`,
        ky: `${member.name}: 3 айга чейинки ымыркайда ысытма`,
      },
      body: {
        en: `A temperature of ${t.toFixed(1)}°C in an infant under 3 months is an automatic ER visit. No exceptions. Every major pediatric society says the same thing — bacterial infections can move fast at this age.`,
        ru: `${t.toFixed(1)}°C у младенца до 3 месяцев — это сразу в приёмный покой. Без исключений. Все крупные педиатрические общества говорят одно и то же: бактериальные инфекции в этом возрасте развиваются быстро.`,
        ky: `3 айга чейинки ымыркайда ${t.toFixed(1)}°C — бул шарт менен ооруканага. Эч кандай эстутту. Бардык чоң педиатрия коомдору бирдей айтат: бул курактагы бактериалдык инфекциялар тез өнүгөт.`,
      },
      instruction: {
        en: "Go to ER now. Do not wait for clinic hours.",
        ru: "Сейчас в приёмный покой. Клиника подождёт.",
        ky: "Азыр ооруканага. Поликлиника күтөт.",
      },
      reason: {
        en: `Infant <3mo with fever ≥38.0°C per SOP v0.1 §4.5 Red row.`,
        ru: `Младенец <3 мес с температурой ≥38.0°C, SOP v0.1 §4.5.`,
        ky: `<3 айлык ымыркай ≥38.0°C, SOP v0.1 §4.5.`,
      },
    });
  }

  if (isToddler && t >= 39.5) {
    return orangeResult(member, r, "temp-toddler-high-fever", {
      title: {
        en: `${member.name}: high fever`,
        ru: `${member.name}: высокая температура`,
        ky: `${member.name}: жогорку ысытма`,
      },
      body: {
        en: `${t.toFixed(1)}°C is a high fever for a small child. Balam is routing this to the on-call pediatrician. In the meantime: a dose of weight-appropriate antipyretic (paracetamol or ibuprofen per last prescription), fluids, monitor for listlessness, non-blanching rash, or fast breathing — any of those → ER now.`,
        ru: `${t.toFixed(1)}°C — высокая температура у малыша. Balam передаёт случай дежурному педиатру. А пока: доза жаропонижающего по весу (парацетамол или ибупрофен по прошлому назначению), пить, следи за вялостью, сыпью, не исчезающей под стеклом, частым дыханием — любое из этого → сейчас в приёмный покой.`,
        ky: `${t.toFixed(1)}°C — кичинекей балдарга жогорку ысытма. Balam кезекчи педиатрга жөнөтүп жатат. Буга чейин: салмакка жараша ысытманы түшүрүүчү доза (мурдагы назначение боюнча парацетамол же ибупрофен), суу, чарчоого, стакан астында жоголбогон бөртпөгө, тез дем алууга көңүл бургула — ушулардын кайсынысы болсо да → азыр ооруканага.`,
      },
      reason: {
        en: `3–36mo child, temp ${t.toFixed(1)}°C ≥39.5 per SOP v0.1 §4.5 Orange row.`,
        ru: `Ребёнок 3–36 мес, температура ${t.toFixed(1)}°C ≥39.5, SOP v0.1 §4.5.`,
        ky: `3–36 айлык бала, ${t.toFixed(1)}°C ≥39.5, SOP v0.1 §4.5.`,
      },
    });
  }

  if (isToddler && t >= 38.0) {
    return yellowResult(member, r, "temp-toddler-fever", {
      title: {
        en: `${member.name}: low-grade fever`,
        ru: `${member.name}: субфебрильная температура`,
        ky: `${member.name}: субфебрильдик температура`,
      },
      body: {
        en: `${t.toFixed(1)}°C is manageable at home for now. Offer fluids, a light blanket, check again in 4 hours. Escalate if temp climbs above 39.5°C, lasts >72 hours, or any red-flag symptom appears.`,
        ru: `${t.toFixed(1)}°C дома пока справляемся. Больше пить, лёгкое одеяло, пересмотр через 4 часа. Эскалируй, если температура выше 39.5°C, держится >72 часов или появились тревожные симптомы.`,
        ky: `${t.toFixed(1)}°C — үйдө дагы байкап туруусак болот. Көп суу, жука жуурканча, 4 сааттан кийин кайра өлчөгүлө. Температура 39.5°C жогоруласа, 72 сааттан көп созулса же кооптуу белги пайда болсо — эскалация.`,
      },
      reason: {
        en: `3–36mo child, temp ${t.toFixed(1)}°C in 38.0–38.9 band per SOP v0.1 §4.5 Yellow row.`,
        ru: `Ребёнок 3–36 мес, температура ${t.toFixed(1)}°C (38.0–38.9), SOP v0.1 §4.5.`,
        ky: `3–36 айлык бала, ${t.toFixed(1)}°C (38.0–38.9), SOP v0.1 §4.5.`,
      },
    });
  }

  // Adults: simple rule
  if (!isInfantUnder3Mo && !isToddler && t >= 39.5) {
    return orangeResult(member, r, "temp-adult-high-fever", {
      title: {
        en: `${member.name}: high fever`,
        ru: `${member.name}: высокая температура`,
        ky: `${member.name}: жогорку ысытма`,
      },
      body: {
        en: `${t.toFixed(1)}°C in an adult warrants a clinician check, especially if paired with severe headache, stiff neck, shortness of breath, or confusion. Balam is queuing the on-call.`,
        ru: `${t.toFixed(1)}°C у взрослого требует врачебного осмотра — особенно при сильной головной боли, ригидности шеи, одышке или спутанности. Balam ставит в очередь.`,
        ky: `Чоң кишиде ${t.toFixed(1)}°C — дарыгер текшерүүсү керек, өзгөчө катуу баш ооруу, мойнунун катуулугу, дем алуунун кыйынчылыгы же аң-сезимдин булгануусу болсо. Balam кезекке коюп жатат.`,
      },
      reason: {
        en: `Adult temp ${t.toFixed(1)}°C ≥39.5 per SOP v0.1 §4.5 (adult extension).`,
        ru: `Взрослый, температура ${t.toFixed(1)}°C ≥39.5, SOP v0.1 §4.5.`,
        ky: `Чоң киши, ${t.toFixed(1)}°C ≥39.5, SOP v0.1 §4.5.`,
      },
    });
  }

  return greenResult(r, "temp-normal", {
    en: `Temperature ${t.toFixed(1)}°C is in range.`,
    ru: `Температура ${t.toFixed(1)}°C в норме.`,
    ky: `Температура ${t.toFixed(1)}°C нормада.`,
  });
}

// ─── Result builders ─────────────────────────────────────────────

function greenResult(reading: BoxReading, ruleId: string, reason: L3): ClassificationResult {
  return {
    tier: "green",
    protocolVersion: PROTOCOL_VERSION,
    ruleId,
    reason,
    notice: null,
    emergency: null,
  };
}

function yellowResult(
  member: MemberSnapshot,
  _reading: BoxReading,
  ruleId: string,
  copy: { title: L3; body: L3; reason: L3 }
): ClassificationResult {
  return {
    tier: "yellow",
    protocolVersion: PROTOCOL_VERSION,
    ruleId,
    reason: copy.reason,
    notice: buildNotice(member, ruleId, copy, "low"),
    emergency: null,
  };
}

function orangeResult(
  member: MemberSnapshot,
  _reading: BoxReading,
  ruleId: string,
  copy: { title: L3; body: L3; reason: L3 }
): ClassificationResult {
  return {
    tier: "orange",
    protocolVersion: PROTOCOL_VERSION,
    ruleId,
    reason: copy.reason,
    notice: buildNotice(member, ruleId, copy, "medium"),
    emergency: null,
  };
}

function redResult(
  member: MemberSnapshot,
  _reading: BoxReading,
  ruleId: string,
  copy: { title: L3; body: L3; instruction: L3; reason: L3 }
): ClassificationResult {
  return {
    tier: "red",
    protocolVersion: PROTOCOL_VERSION,
    ruleId,
    reason: copy.reason,
    notice: buildNotice(member, ruleId, { title: copy.title, body: copy.body }, "high"),
    emergency: {
      memberId: member.id,
      ruleId,
      instruction: copy.instruction,
      callNumbers: { kg: "103", us: "911", ru: "103" },
    },
  };
}

function buildNotice(
  member: MemberSnapshot,
  ruleId: string,
  copy: { title: L3; body: L3 },
  urgency: "low" | "medium" | "high"
): NoticeDocument {
  return {
    memberId: member.id,
    memberName: member.name,
    milestoneId: `box-${ruleId}`,
    type: "trend",
    urgency,
    title: copy.title,
    body: copy.body,
    action: {
      route: urgency === "high" ? "/emergency" : "/professionals",
      label:
        urgency === "high"
          ? {
              en: "See emergency steps",
              ru: "Срочные действия",
              ky: "Шашылыш кадамдар",
            }
          : {
              en: "Talk to a clinician",
              ru: "Консультация врача",
              ky: "Дарыгер менен кеңеш",
            },
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

// ─── Helpers ─────────────────────────────────────────────────────

function ageMonths(m: MemberSnapshot, now: Date): number | null {
  if (!m.birthDate) return null;
  const bd = new Date(m.birthDate);
  return (now.getTime() - bd.getTime()) / (1000 * 60 * 60 * 24 * 30.44);
}

function isPregnant(member: MemberSnapshot, reading: BoxReading): boolean {
  if (typeof reading.pregnancyWeek === "number" && reading.pregnancyWeek > 0) return true;
  const conds = (member.conditions ?? []).map((c) => c.toLowerCase());
  return conds.includes("pregnant") || conds.includes("pregnancy");
}

// ─── Side-effectful variant ──────────────────────────────────────

/** Classify and write notice + audit + (if red) emergency document. */
export async function classifyAndRecord(
  uid: string,
  member: MemberSnapshot,
  reading: BoxReading,
  now: Date = new Date()
): Promise<ClassificationResult & { noticeId?: string; auditId?: string; emergencyId?: string }> {
  const result = classifyReading(member, reading, now);
  const db = admin.firestore();

  // Clinical audit is written for every non-green case. Green readings
  // are in the member's tracking log already; no duplicate audit.
  let auditId: string | undefined;
  if (result.tier !== "green") {
    const auditRef = db.collection("clinical_audit").doc();
    auditId = auditRef.id;
    await auditRef.set({
      uid,
      memberId: member.id,
      memberSnapshot: member,
      reading,
      tier: result.tier,
      ruleId: result.ruleId,
      protocolVersion: result.protocolVersion,
      reason: result.reason,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      mdReviewerId: null,
      mdReviewedAt: null,
      mdEdit: null,
    });
  }

  let noticeId: string | undefined;
  if (result.notice) {
    const noticeRef = db.collection(`notices/${uid}/items`).doc();
    noticeId = noticeRef.id;
    await noticeRef.set(result.notice);
  }

  let emergencyId: string | undefined;
  if (result.emergency) {
    const emRef = db.collection("emergencies").doc();
    emergencyId = emRef.id;
    await emRef.set({
      uid,
      ...result.emergency,
      auditId,
      noticeId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      ackAt: null,
    });
  }

  return { ...result, noticeId, auditId, emergencyId };
}

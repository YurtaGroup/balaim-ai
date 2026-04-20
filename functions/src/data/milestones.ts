// Hardcoded preventive-care schedule table. Drives Engine 1 of
// "The App That Notices". Pediatric items are AAP-aligned (with minor
// Central Asian pediatric calendar adjustments); adult items follow
// USPSTF + ADA + AHA screening recommendations.
//
// All copy is trilingual and serves as the FALLBACK when Anthropic
// credit is unavailable — the schedule engine can ship end-to-end
// without any Claude call at all. Claude is used only to *enhance*
// copy with per-member personalization when credit is available.

export type Locale = "en" | "ru" | "ky";

export interface L3 {
  en: string;
  ru: string;
  ky: string;
}

export type MemberRole =
  | "self"
  | "child"
  | "partner"
  | "mother"
  | "father"
  | "grandmother"
  | "grandfather"
  | "sibling"
  | "uncleAunt"
  | "other";

export interface MemberSnapshot {
  id: string;
  name: string;
  role: MemberRole;
  birthDate?: string; // ISO 8601 date
  conditions?: string[];
  gender?: string;
}

export interface MilestoneAction {
  /** Route inside the Flutter app to deeplink when user taps the action. */
  route: string;
  label: L3;
}

export type MilestoneUrgency = "low" | "medium" | "high";

export interface Milestone {
  /** Unique stable id. Used for Firestore lastFired bookkeeping. */
  id: string;

  /** Predicate that decides whether this milestone is currently due for the
   * given member. Must be deterministic and cheap. */
  applies: (m: MemberSnapshot, now: Date) => boolean;

  urgency: MilestoneUrgency;

  /** How often this milestone re-fires after first firing. `null` = fires
   * once per member ever. A number means re-fire every N days (e.g. the
   * diabetic A1c every 180). */
  repeatIntervalDays: number | null;

  title: L3;
  body: L3;
  action: MilestoneAction;

  /** Optional hint passed into Claude's system prompt for personalization.
   * Never shown to the user verbatim. */
  claudeContextHint?: string;
}

// ─── Helpers ──────────────────────────────────────────────────────

function ageYears(m: MemberSnapshot, now: Date): number | null {
  if (!m.birthDate) return null;
  const bd = new Date(m.birthDate);
  return (now.getTime() - bd.getTime()) / (1000 * 60 * 60 * 24 * 365.25);
}

function ageMonths(m: MemberSnapshot, now: Date): number | null {
  if (!m.birthDate) return null;
  const bd = new Date(m.birthDate);
  return (now.getTime() - bd.getTime()) / (1000 * 60 * 60 * 24 * 30.44);
}

/** Pediatric milestone matches when the child has just passed the target
 * age (within a 30-day window, so the milestone fires once and is marked
 * once per member by the notices engine's dedup). */
function atAgeMonths(target: number, tolerance = 30) {
  return (m: MemberSnapshot, now: Date) => {
    if (m.role !== "child") return false;
    const am = ageMonths(m, now);
    if (am == null) return false;
    return am >= target && am <= target + tolerance / 30.44;
  };
}

function isAdult(m: MemberSnapshot, now: Date): boolean {
  if (m.role === "child") return false;
  const ay = ageYears(m, now);
  return ay == null || ay >= 16; // treat unknown-age non-child members as adult
}

function hasCondition(m: MemberSnapshot, cond: string): boolean {
  return !!m.conditions?.some((c) => c.toLowerCase().includes(cond));
}

// ─── Pediatric schedule ───────────────────────────────────────────

const PEDIATRIC: Milestone[] = [
  {
    id: "ped-2mo-well-baby",
    applies: atAgeMonths(2),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "2-month well-baby visit",
      ru: "Осмотр в 2 месяца",
      ky: "2 айлык текшерүү",
    },
    body: {
      en: "Around 2 months is the first scheduled pediatric visit after the newborn period. Standard: weight + length check, head circumference, reflexes, and the first round of vaccines (DTaP, IPV, Hib, hepatitis B, PCV13, rotavirus).",
      ru: "В 2 месяца — первый плановый педиатрический осмотр после периода новорождённости. Стандартно: вес, рост, окружность головы, рефлексы и первая серия прививок (АКДС, ИПВ, Hib, гепатит В, ПКВ13, ротавирус).",
      ky: "2 айда — жаңы төрөлгөн мезгилден кийинки биринчи пландуу педиатриялык текшерүү. Стандарт: салмак, узундук, баш чекитинин өлчөмү, рефлекстер жана биринчи эмдөө топтому (АКДС, ИПВ, Hib, гепатит В, ПКВ13, ротавирус).",
    },
    action: {
      route: "/professionals",
      label: { en: "Find a pediatrician", ru: "Найти педиатра", ky: "Педиатр табуу" },
    },
  },

  {
    id: "ped-6mo-iron-solids",
    applies: atAgeMonths(6),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "6-month checkup + iron screen",
      ru: "Осмотр в 6 месяцев + скрининг железа",
      ky: "6 айлык текшерүү + темир анализи",
    },
    body: {
      en: "Standard at 6 months: well-baby exam, 2nd-round vaccines, iron-panel screen (breastfed babies are at risk), and guidance on starting solids. If feeding feels stuck or weight gain is slow, bring it up — most things are fixable if caught now.",
      ru: "В 6 месяцев стандартно: плановый осмотр, вторая серия прививок, анализ на железо (у детей на ГВ есть риск анемии), и консультация по введению прикорма. Если с кормлением проблемы или прибавка в весе медленная — обсудите сейчас, большинство ситуаций решается.",
      ky: "6 айда стандарт: пландуу текшерүү, экинчи эмдөө топтому, темирге анализ (эмчек эмген балдарда анемия коркунучу бар), жана кошумча тамак киргизүү боюнча кеңеш. Тамактандыруу менен кыйынчылыктар болсо же салмак жай өссө — азыр талкуулаңыз.",
    },
    action: {
      route: "/professionals",
      label: { en: "Book a consult", ru: "Записаться на консультацию", ky: "Кеңешке жазылуу" },
    },
  },

  {
    id: "ped-9mo-well-dental",
    applies: atAgeMonths(9),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "9-month check + first dental",
      ru: "9 месяцев: осмотр + первый поход к стоматологу",
      ky: "9 айлык: текшерүү + биринчи тиш доктору",
    },
    body: {
      en: "At 9 months a well-visit covers development (sitting, crawling, first sounds), iron and lead screening if indicated, and a first dental visit is recommended within the next 3 months — even before the full front teeth are in. Ask about fluoride water.",
      ru: "В 9 месяцев — плановый осмотр: развитие (сидит, ползает, первые звуки), повторный скрининг железа по показаниям, и в ближайшие 3 месяца — первый визит к стоматологу (до прорезывания всех передних зубов). Уточните про фторирование воды.",
      ky: "9 айда — пландуу текшерүү: өнүгүү (олтурат, сойлойт, биринчи үндөр), керек болсо темир кайталоо, жана кийинки 3 айдын ичинде — биринчи тиш доктору (алдыңкы тиштердин баары чыккыча). Суудагы фтор жөнүндө сураңыз.",
    },
    action: {
      route: "/professionals",
      label: { en: "Book a pediatrician", ru: "Записаться к педиатру", ky: "Педиатрга жазылуу" },
    },
  },

  {
    id: "ped-12mo-cbc",
    applies: atAgeMonths(12),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "1-year: MMR + first CBC",
      ru: "1 год: MMR + первый общий анализ крови",
      ky: "1 жаш: MMR + биринчи жалпы кан анализи",
    },
    body: {
      en: "Around the 1-year birthday: the MMR vaccine, varicella, hepatitis A start, and typically the first full CBC to check hemoglobin and iron stores. Anemia risk peaks around this age — worth running even if baby looks well.",
      ru: "Около 1 года: MMR (корь-краснуха-паротит), ветряная оспа, начало серии гепатита А, и обычно первый развернутый общий анализ крови (гемоглобин, запасы железа). Риск анемии максимальный в этом возрасте — стоит сдать, даже если всё хорошо.",
      ky: "1 жаш курагында: MMR (кызамык-краснуха-паротит), чечек, гепатит А биринчи дозасы, жана адатта биринчи толук жалпы кан анализи (гемоглобин, темир запасы). Анемиянын коркунучу ушул куракта эң жогору — баары жакшы окшосо да анализ тапшырыңыз.",
    },
    action: {
      route: "/lab",
      label: { en: "View lab results", ru: "Результаты анализов", ky: "Анализ жыйынтыктары" },
    },
  },

  {
    id: "ped-18mo-mchat",
    applies: atAgeMonths(18),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "18-month check + autism screen",
      ru: "18 месяцев: осмотр + скрининг на аутизм",
      ky: "18 ай: текшерүү + аутизм скринингиси",
    },
    body: {
      en: "The 18-month well-visit includes a standardized autism screen (M-CHAT-R). Not because you're worried — it's standard, non-invasive, and best caught early if anything comes up. Also: typical language check (should be 5–20 spoken words), walking quality, and the first iron recheck in a year.",
      ru: "Осмотр в 18 месяцев включает стандартизованный скрининг на аутизм (M-CHAT-R). Это не потому что есть повод — это стандартная практика, неинвазивная, и если что-то выявится, лучше рано. Ещё: проверка речи (обычно 5–20 слов), качество ходьбы, повторный анализ на железо.",
      ky: "18 айлык текшерүү аутизм боюнча стандарттуу скринингди камтыйт (M-CHAT-R). Тынчсыздануу эмес — бул адаттагы иш, ооруксуз, жана эрте байкалса жакшы. Мындан тышкары: сүйлөө текшерүүсү (адатта 5–20 сөз), басуунун сапаты, темирдин кайталама анализи.",
    },
    action: {
      route: "/professionals",
      label: { en: "Book a pediatrician", ru: "Записаться к педиатру", ky: "Педиатрга жазылуу" },
    },
  },

  {
    id: "ped-2.5y-dev-screen",
    applies: atAgeMonths(30),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "2.5-year developmental check",
      ru: "Плановый осмотр в 2,5 года",
      ky: "2,5 жаштагы өнүгүү текшерүүсү",
    },
    body: {
      en: "At 2.5 years the checkup focuses on: hearing (often the first formal test), vision, language (usually 200+ words and two-word sentences), social development, and a dental cleaning. Non-invasive, about 30 minutes with a pediatrician, and this is where things like mild hearing issues first get caught.",
      ru: "В 2,5 года на осмотре: слух (часто первый формальный тест), зрение, речь (обычно 200+ слов и двухсловные фразы), социальное развитие, и профессиональная чистка зубов. Ничего неприятного, около 30 минут у педиатра — именно в этом возрасте впервые обнаруживаются лёгкие проблемы со слухом.",
      ky: "2,5 жашта текшерүүдө: угуу (көбүнчө биринчи расмий тест), көз көрүү, сүйлөө (адатта 200+ сөз жана эки сөздүк сүйлөмдөр), социалдык өнүгүү, жана тиш тазалоо. Оор нерсе жок, педиатр менен 30 мүнөт — эреже катары ушул куракта жеңил угуу көйгөйлөрү биринчи жолу байкалат.",
    },
    claudeContextHint: "Pediatric 2.5-year check. Mention hearing + vision + language specifically.",
    action: {
      route: "/professionals",
      label: { en: "Book a consult", ru: "Записаться", ky: "Жазылуу" },
    },
  },

  {
    id: "ped-3y-behavior",
    applies: atAgeMonths(36),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "3-year well visit",
      ru: "Плановый осмотр в 3 года",
      ky: "3 жаштагы пландуу текшерүү",
    },
    body: {
      en: "At 3 years: blood pressure is measured for the first time as standard, vision and hearing rechecked, and the conversation shifts toward sleep patterns, toilet-training, behavior, and what pre-school / kindergarten readiness looks like.",
      ru: "В 3 года: впервые измеряется артериальное давление как часть стандартного осмотра, повторяют зрение и слух, и разговор с врачом смещается к режиму сна, приучению к горшку, поведению и готовности к детскому саду.",
      ky: "3 жашта: биринчи жолу артериалдык басым ченелет стандарт катары, көз көрүү жана угуу кайталанат, жана дарыгер менен сүйлөшүү уйку режимине, горшокко үйрөнүүгө, жүрүм-турумга жана бала бакчага даярдыкка өтөт.",
    },
    action: {
      route: "/professionals",
      label: { en: "Book a pediatrician", ru: "Записаться к педиатру", ky: "Педиатрга жазылуу" },
    },
  },

  {
    id: "ped-5y-school-physical",
    applies: atAgeMonths(60),
    urgency: "low",
    repeatIntervalDays: null,
    title: {
      en: "5-year school physical",
      ru: "Медосмотр перед школой в 5 лет",
      ky: "Мектеп алдындагы 5 жаштагы медосмотр",
    },
    body: {
      en: "Pre-school physical: full vision chart, audiometry, height/weight percentile, BP, booster vaccines (DTaP, IPV, MMR2, varicella2), and a short conversation about sleep, diet, and screen time.",
      ru: "Медосмотр перед школой: таблица Сивцева для зрения, аудиометрия, перцентиль роста/веса, давление, ревакцинация (АКДС, ИПВ, MMR2, ветрянка2), и короткий разговор о сне, питании и экранном времени.",
      ky: "Мектеп алдындагы медосмотр: көз көрүү таблицасы, аудиометрия, бой/салмак перцентили, басым, кайталама эмдөө (АКДС, ИПВ, MMR2, чечек2), жана уйку, тамактануу, экранда өткөн убакыт жөнүндө кыска сүйлөшүү.",
    },
    action: {
      route: "/professionals",
      label: { en: "Book a consult", ru: "Записаться", ky: "Жазылуу" },
    },
  },
];

// ─── Adult schedule ───────────────────────────────────────────────

const ADULT: Milestone[] = [
  {
    id: "adult-diabetic-a1c",
    applies: (m, now) => isAdult(m, now) && hasCondition(m, "diabet"),
    urgency: "medium",
    repeatIntervalDays: 180,
    title: {
      en: "Time for an A1c",
      ru: "Пора сдать HbA1c",
      ky: "HbA1c тапшыруу убакыты",
    },
    body: {
      en: "For anyone managing diabetes, HbA1c every 6 months is the standard of care — it shows the 3-month blood-sugar average, not just today's snapshot. If it's trending in the wrong direction, adjustments are most effective caught early.",
      ru: "Для всех, кто живёт с диабетом, HbA1c раз в 6 месяцев — стандарт. Анализ показывает средний уровень сахара за 3 месяца, а не только сегодняшний снимок. Если тренд неблагоприятный — коррекция эффективнее всего на ранней стадии.",
      ky: "Диабет менен жашаган ар бир адам үчүн HbA1c 6 ай сайын — стандарт. Бул анализ 3 айдын ичиндеги орточо сахарды көрсөтөт, бүгүнкү сүрөттү эмес. Тренд жаман болсо — эрте коррекция эң натыйжалуу.",
    },
    claudeContextHint: "Endocrinology-relevant. Mention Jane Mone NP (endocrinology, trilingual) as in-app consult option.",
    action: {
      route: "/professionals",
      label: { en: "Consult an endocrinologist", ru: "Консультация эндокринолога", ky: "Эндокринолог менен кеңеш" },
    },
  },

  {
    id: "adult-annual-bp",
    applies: (m, now) => isAdult(m, now),
    urgency: "low",
    repeatIntervalDays: 180,
    title: {
      en: "Time for a BP check",
      ru: "Пора проверить давление",
      ky: "Басым ченөөнүн убакыты",
    },
    body: {
      en: "Blood pressure is a number that quietly climbs for years before you notice. Every 6 months is a reasonable cadence for any adult; every 3 months if over 50, already medicated, or with a family history of heart disease or stroke.",
      ru: "Артериальное давление — показатель, который тихо растёт годами до того, как это заметишь. Раз в 6 месяцев — разумно для любого взрослого; раз в 3 месяца — если старше 50, уже на препаратах, или есть семейная история ССЗ или инсульта.",
      ky: "Артериалдык басым — көз көрбөгөн жылдар бою өсүп турган көрсөткүч. 6 ай сайын — ар бир чоң киши үчүн жетиштүү; 3 ай сайын — 50дөн өткөн, дары ичип жүргөн, же үй-бүлөсүндө жүрөк-кан тамыр ооруусу болгон адамдар үчүн.",
    },
    action: {
      route: "/my-child", // Log Vitals UI lives under My Family currently
      label: { en: "Log a reading", ru: "Записать показания", ky: "Көрсөткүчтү жазуу" },
    },
  },

  {
    id: "adult-annual-physical",
    applies: (m, now) => isAdult(m, now),
    urgency: "low",
    repeatIntervalDays: 365,
    title: {
      en: "Time for an annual physical",
      ru: "Пора пройти ежегодный осмотр",
      ky: "Жылдык медосмотр убакыты",
    },
    body: {
      en: "A yearly check-in with a general practitioner — weight, BP, a basic blood panel, and a 10-minute conversation — catches more silent conditions than any single test on its own. If there's no GP in the picture, this is a good time to pick one.",
      ru: "Ежегодный осмотр у терапевта — вес, давление, базовая кровь, 10-минутный разговор — выявляет больше скрытых состояний, чем любой отдельный анализ. Если семейного врача нет — сейчас хорошее время выбрать.",
      ky: "Терапевт менен жылдык текшерүү — салмак, басым, негизги кан анализи, 10 мүнөттүк сүйлөшүү — өзүнчө анализге караганда көбүрөөк жашыруун абалды аныктайт. Үй-бүлөлүк дарыгер жок болсо — азыр тандай турган жакшы убак.",
    },
    action: {
      route: "/professionals",
      label: { en: "Find a GP", ru: "Найти терапевта", ky: "Терапевт табуу" },
    },
  },

  {
    id: "adult-45plus-diabetes-screen",
    applies: (m, now) => {
      const ay = ageYears(m, now);
      return isAdult(m, now) && ay != null && ay >= 45 && !hasCondition(m, "diabet");
    },
    urgency: "medium",
    repeatIntervalDays: 365 * 3,
    title: {
      en: "Diabetes screening is due",
      ru: "Пора скрининг на диабет",
      ky: "Диабет скринингинин убакыты",
    },
    body: {
      en: "After 45, a fasting glucose or HbA1c every 3 years is the screening standard for anyone without a diabetes diagnosis. Type 2 often has zero symptoms for years; this catches it.",
      ru: "После 45 лет глюкоза натощак или HbA1c раз в 3 года — стандарт скрининга для людей без диагноза диабет. Диабет 2 типа может годами не давать симптомов; этот тест его находит.",
      ky: "45 жаштан кийин ачкарын глюкоза же HbA1c 3 жыл сайын — диабет диагнозу жок адамдар үчүн стандарттуу скрининг. 2-типтеги диабет жылдар бою симптомсуз болот; бул тест аны табат.",
    },
    action: {
      route: "/professionals",
      label: { en: "Book a consult", ru: "Записаться", ky: "Жазылуу" },
    },
  },

  {
    id: "adult-40plus-lipid",
    applies: (m, now) => {
      const ay = ageYears(m, now);
      return isAdult(m, now) && ay != null && ay >= 40;
    },
    urgency: "low",
    repeatIntervalDays: 365 * 5,
    title: {
      en: "Lipid panel is due",
      ru: "Пора сдать липидный профиль",
      ky: "Липиддик профиль тапшыруу убакыты",
    },
    body: {
      en: "A full lipid panel (total cholesterol, LDL, HDL, triglycerides) every 5 years after 40 is the baseline. More often if numbers were borderline last time, or if there's cardiovascular risk in the family.",
      ru: "Полный липидный профиль (общий холестерин, ЛПНП, ЛПВП, триглицериды) раз в 5 лет после 40 — базовый стандарт. Чаще — если в прошлый раз были пограничные значения, или в семье есть сердечно-сосудистые заболевания.",
      ky: "Толук липиддик профиль (жалпы холестерин, ЛПНП, ЛПВП, триглицериддер) 40 жаштан кийин 5 жыл сайын — базалык стандарт. Көбүрөөк — эгерде акыркы жолу чектик маанилер болсо же үй-бүлөдө жүрөк-кан тамыр ооруулары болсо.",
    },
    action: {
      route: "/professionals",
      label: { en: "Book a consult", ru: "Записаться", ky: "Жазылуу" },
    },
  },
];

export const ALL_MILESTONES: Milestone[] = [...PEDIATRIC, ...ADULT];

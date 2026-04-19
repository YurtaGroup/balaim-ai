import 'package:flutter/material.dart';
import '../../../core/l10n/content_localizations.dart';
import '../services/ai_service.dart';

/// A realistic example exchange — question + Balam's answer — bundled with
/// the app so testers can browse what the AI is capable of without burning
/// Anthropic credit on every demo.
///
/// Triage is captured where relevant so the banner UI shows up on the
/// preview exactly the way it would after a live Claude call.
class DemoConversation {
  final String id;
  final IconData icon;
  final L3 title;
  final L3 question;
  final L3 answer;
  final Triage? triage;

  const DemoConversation({
    required this.id,
    required this.icon,
    required this.title,
    required this.question,
    required this.answer,
    this.triage,
  });
}

const demoConversations = <DemoConversation>[
  // 1. Baby sleep regression — classic 3am concern
  DemoConversation(
    id: 'baby-sleep-regression',
    icon: Icons.nightlight_round,
    title: L3(
      en: "Baby won't sleep",
      ru: 'Малыш не спит',
      ky: 'Бөбөк уктабайт',
    ),
    question: L3(
      en: "My 4-month-old was sleeping 6 hours straight and now wakes every 90 minutes. Is something wrong?",
      ru: 'Моему малышу 4 месяца, он спал по 6 часов, а сейчас просыпается каждые 90 минут. Что-то не так?',
      ky: 'Балама 4 ай, мурда 6 саат катары менен уктаар эле, азыр ар 90 мүнөт сайын ойгонот. Бир жамандык барбы?',
    ),
    answer: L3(
      en: "You're right in the middle of the 4-month sleep regression — it's one of the most disorienting ones because it's actually a permanent change in sleep architecture, not a phase. Your baby's brain is reorganizing how it cycles through sleep stages. It will level out over 2-3 weeks.\n\nWhat helps: keep the same wind-down routine every night (dim lights 30 min before bed, one feed, one song), and resist the urge to create new sleep associations (rocking to sleep every time) that you'll have to undo later.",
      ru: 'Ты прямо в разгаре регрессии сна 4-го месяца — одной из самых дезориентирующих, потому что это на самом деле постоянное изменение архитектуры сна, а не просто этап. Мозг ребёнка перестраивает циклы сна. Всё выровняется за 2-3 недели.\n\nЧто помогает: одинаковый ритуал перед сном каждый вечер (приглушённый свет за 30 минут, одно кормление, одна песенка), и не создавай новых сонных ассоциаций (укачивать до засыпания каждый раз), от которых потом придётся отучать.',
      ky: 'Сиз азыр 4 айлык уйку регрессиясынын ортосундасыз — бул эң адаштыргыч учурлардын бири, анткени бул чыныгы уйку архитектурасындагы туруктуу өзгөрүү, этап эмес. Баланын мээси уйкунун этаптарын кайра тартипке салып жатат. 2-3 жумада кайра тынчыйт.\n\nЖардам берет: ар кечте бирдей уктоого даярдык (30 мүнөт мурда жарыкты азайтып, бир тамак, бир ыр), жана жаңы уйку байланыштарын (ар жолу термеп уктатуу) жаратпаңыз — кийин токтотуу керек болот.',
    ),
    triage: Triage(urgency: TriageUrgency.low, reason: 'Expected developmental regression'),
  ),

  // 2. Fever — classic "is this normal" 3am panic
  DemoConversation(
    id: 'baby-fever',
    icon: Icons.thermostat,
    title: L3(
      en: 'Baby has a fever',
      ru: 'У малыша температура',
      ky: 'Бөбөктүн ысытмасы бар',
    ),
    question: L3(
      en: "My 3-month-old has a 38.5°C fever. It just started 20 minutes ago. Should I go to the ER?",
      ru: 'У моего 3-месячного малыша температура 38.5°C. Началась 20 минут назад. Ехать в скорую?',
      ky: 'Менин 3 айлык баламдын ысытмасы 38.5°C. 20 мүнөт мурда башталды. Тез жардамга баруу керекпи?',
    ),
    answer: L3(
      en: "At 3 months old, any fever of 38.0°C or above needs a doctor's eyes the same day — the immune system is still too young to handle many infections safely at home.\n\nCall your pediatrician now, or if it's after-hours, head to an urgent-care or ER that sees infants. While you get ready: keep the baby lightly dressed, offer extra feeds to prevent dehydration, and count wet diapers (should be at least 6 a day). Don't give fever medication without a doctor's OK for this age.",
      ru: 'В 3 месяца любая температура от 38.0°C требует осмотра врача в тот же день — иммунная система ещё слишком молодая, чтобы справляться со многими инфекциями дома.\n\nПозвони педиатру сейчас, если время нерабочее — в скорую или неотложку, которая принимает младенцев. Пока собираешься: одень малыша полегче, предлагай чаще грудь/смесь чтобы не было обезвоживания, считай мокрые подгузники (минимум 6 в день). Не давай жаропонижающее в этом возрасте без разрешения врача.',
      ky: '3 айлык балада 38.0°C жана андан жогору ысытма ошол эле күнү дарыгер көрүүсүн талап кылат — иммундук система үйдө көп инфекцияларды коркунучсуз жеңе алгыдай эмес.\n\nАзыр педиатрга чалыңыз, же иш убагы эмес болсо, ымыркайды кабыл алган тез жардамга же тез жардам борборуна барыңыз. Даярданып жатканда: баланы жеңил кийинтиңиз, суусуздуктан сактоо үчүн көбүрөөк тамак бериңиз, нымдуу жөргөктөрдү санаңыз (күнүнө эң аз дегенде 6). Бул куракта дарыгердин уруксатысыз ысытманы түшүрүүчү дары бербеңиз.',
    ),
    triage: Triage(urgency: TriageUrgency.high, reason: 'Fever in infant under 3 months requires same-day evaluation'),
  ),

  // 3. Adult glucose — THE use case for this pivot
  DemoConversation(
    id: 'adult-glucose',
    icon: Icons.bloodtype,
    title: L3(
      en: 'Dad\'s glucose is high',
      ru: 'У папы высокий сахар',
      ky: 'Атамдын канындагы шекер жогору',
    ),
    question: L3(
      en: "Dad's fasting glucose came back as 220. He's 62 and hasn't been diagnosed with anything. How worried should I be?",
      ru: 'У папы натощак глюкоза 220. Ему 62, диагноза нет. Насколько это серьёзно?',
      ky: 'Атамдын ачкарын канындагы шекери 220. Ал 62 жашта, эч нерсе менен ооруп жүргөн жок. Канчалык кооптуу?',
    ),
    answer: L3(
      en: "A fasting glucose of 220 is solidly in the diabetic range (126 or above is the clinical threshold, and 220 is roughly 75% above it). This is serious, but not a panic situation if he's otherwise feeling OK.\n\nThe right next step is an endocrinology consult within the next week — they'll want an HbA1c test to see the 3-month average, not just today's snapshot. In the app you can start a consult with Jane Mone NP (endocrinology, trilingual) from the Doctors tab — she's exactly the right specialist for this.\n\nIn the meantime: no sugary drinks, smaller portions of carbs, a 20-minute walk after each meal. Don't start or stop any medication without a doctor.",
      ru: 'Глюкоза натощак 220 — это уверенно диабетический диапазон (126 и выше — клинический порог, а 220 примерно на 75% выше него). Это серьёзно, но не повод для паники, если он чувствует себя нормально.\n\nСледующий шаг — консультация эндокринолога в ближайшую неделю. Попросят сдать HbA1c (средний показатель за 3 месяца), не только сегодняшний снимок. В приложении можно начать консультацию с медсестрой-практиком Джейн Мон (эндокринология, трёхязычная) во вкладке Врачи — она подходит именно для этого.\n\nА пока: никаких сладких напитков, уменьшить порции углеводов, 20 минут ходьбы после каждого приёма пищи. Не начинай и не отменяй никакие лекарства без врача.',
      ky: 'Ачкарын глюкозасы 220 — бул диабеттик диапазон (126 жана жогору — клиникалык чек, 220 андан 75% жогору). Бул олуттуу, бирок ал жакшы сезип жатса, үрөй учурар эмес.\n\nКийинки кадам — жума ичинде эндокринолог менен кеңешүү. Алар HbA1c тестин (3 айдын орточо көрсөткүчү) талап кылышат. Колдонмодо «Дарыгерлер» бөлүмүндө Джейн Мон NP (эндокринология, үч тилде) менен кеңеш баштай аласыз — бул үчүн так ушул адис.\n\nАзырынча: таттуу суусундук жок, углеводдордун бөлүктөрүн кичирейтүү, ар бир тамактын артынан 20 мүнөт басуу. Дарыгерсиз эч кандай дары баштабаңыз, токтотпоңуз.',
    ),
    triage: Triage(urgency: TriageUrgency.high, reason: 'Fasting glucose in diabetic range'),
  ),

  // 4. Toddler speech concern
  DemoConversation(
    id: 'toddler-speech',
    icon: Icons.record_voice_over,
    title: L3(
      en: 'Toddler not talking yet',
      ru: 'Малыш пока не говорит',
      ky: 'Бөбөк сүйлөй элек',
    ),
    question: L3(
      en: "My son is 22 months and only says 'mama' and 'no'. My mother-in-law keeps saying he's slow. Is he?",
      ru: 'Сыну 22 месяца, говорит только «мама» и «нет». Свекровь говорит, что он отстаёт. Это так?',
      ky: 'Уулум 22 айлык, бирок «апа» жана «жок» дегенди гана айтат. Кайненем кечигип жатат дейт. Чынбы?',
    ),
    answer: L3(
      en: "At 22 months, the typical range is 20-50 spoken words and the beginning of two-word combinations. Two words is below that range, which is worth paying attention to but doesn't on its own mean anything serious — he may simply be a late talker (often runs in families).\n\nThe most productive step is a speech-language evaluation. In Bishkek you can self-refer; no pediatrician gatekeeper. What they'll check: does he understand much more than he says? (comprehension often outruns speech by months and that's reassuring.) Does he point, follow two-step instructions, make eye contact, respond to his name? If yes to those, you're probably looking at a late talker who will catch up.\n\nAnd — your mother-in-law is wrong to frame it as 'slow'. It's information, not a verdict.",
      ru: 'В 22 месяца типичный диапазон — 20-50 слов и начало двухсловных сочетаний. Два слова — ниже этого, за этим стоит понаблюдать, но само по себе это не диагноз — возможно, он просто поздно начинает говорить (часто в семьях это наследственное).\n\nПродуктивный шаг — оценка логопеда. В Бишкеке можно записаться самостоятельно. Они проверят: понимает ли он гораздо больше, чем говорит? (понимание часто опережает речь на месяцы — и это хороший знак). Показывает ли пальцем, выполняет ли двухшаговые просьбы, смотрит ли в глаза, откликается ли на имя? Если да — скорее всего это поздний говорун, который догонит.\n\nИ — свекровь не права, говоря «отстаёт». Это информация, а не приговор.',
      ky: '22 айлык курагында адатта 20-50 сөз айтып, эки сөздүк айкаштарды баштайт. Эки сөз — андан төмөн, буга көңүл бурсаңыз болот, бирок өзүнөн-өзү олуттуу нерсени билдирбейт — ал жөн гана кеч сүйлөгөнү мүмкүн (көп учурда үй-бүлөдөн өтөт).\n\nЭң пайдалуу кадам — логопед баалоосу. Бишкекте педиатрдан жөнөтмө албай эле, өзүңүз жазылсаңыз болот. Алар текшерет: ал айткан сөздөргө караганда көп түшүнөбү? (түшүнүү көп учурда сүйлөөдөн айлар мурда — бул жакшы белги). Манжасы менен көрсөтөбү, эки кадамдуу көрсөтмөлөрдү аткарабы, көзгө карайбы, атын уккандан жооп беребей? Ушуга ооба болсо — болжол менен кеч сүйлөгөн бала, жетишет.\n\nЖана — кайненеңиз «кечигет» деп айтууга акысы жок. Бул маалымат, өкүм эмес.',
    ),
    triage: Triage(urgency: TriageUrgency.medium, reason: 'Below typical vocabulary range; evaluation warranted'),
  ),

  // 5. Adult blood pressure
  DemoConversation(
    id: 'adult-bp',
    icon: Icons.favorite,
    title: L3(
      en: 'Grandma\'s BP is 160/95',
      ru: 'У бабушки давление 160/95',
      ky: 'Таянемдин басымы 160/95',
    ),
    question: L3(
      en: "Grandma is 74. Her BP has been hovering around 160/95 for three mornings in a row. She already takes losartan. Should we increase it?",
      ru: 'Бабушке 74. Давление уже три утра подряд держится около 160/95. Она принимает лозартан. Увеличить дозу?',
      ky: 'Таянем 74 жашта. Басымы үч эртеден бери 160/95 тегерегинде. Ал лозартан ичип жатат. Дозаны көбөйтөбүзбү?',
    ),
    answer: L3(
      en: "160/95 is Stage 2 hypertension — above the goal range for someone on treatment, and three mornings in a row tells us it's not a one-off. But do not change her losartan dose on your own; that's a conversation her prescriber needs to have.\n\nThe right next move: call her doctor this week (not the ER — no symptoms). They'll either bump the losartan, add a second agent (often a thiazide diuretic at her age), or want a 24-hour monitor to rule out white-coat effect.\n\nBefore the call, helpful data to bring: her last 7 mornings of readings, her current medication list with doses, whether she's been eating more salt recently, and whether she's been sleeping less. That's what will drive the doctor's decision, not the number alone.",
      ru: '160/95 — это гипертония 2 стадии, выше целевого диапазона для человека на лечении, и три утра подряд — это не случайность. Но не меняй дозу лозартана сама — это решение врача.\n\nПравильный следующий шаг: позвонить её врачу на этой неделе (не скорая, нет симптомов). Они либо поднимут лозартан, либо добавят второй препарат (часто тиазидный диуретик в её возрасте), либо назначат суточный мониторинг, чтобы исключить эффект белого халата.\n\nПеред звонком полезные данные: замеры за последние 7 утра, текущий список лекарств с дозами, больше ли она ест соли в последнее время, меньше ли спит. Именно это будет влиять на решение врача, а не одна цифра.',
      ky: '160/95 — бул 2-стадиядагы гипертония, дарыланып жаткан адам үчүн максаттуу диапазондон жогору, үч эрте катары менен — кокустук эмес. Бирок лозартандын дозасын өзүнөн-өзү өзгөртпөңүз; бул дарыгердин чечими.\n\nКийинки туура кадам: ушул жума ичинде анын дарыгерине чалуу (тез жардам эмес — симптом жок). Алар: лозартанды көтөрүшөт, экинчи препарат кошушат (көбүнчө анын куракта тиазиддик диуретик), же ак халат таасирин жокко чыгаруу үчүн 24 сааттык мониторинг колдонушат.\n\nЧалуудан мурда алып келүүгө пайдалуу маалыматтар: акыркы 7 эртеңки сыяктуу, азыркы дарылар тизмеси менен дозалары, акыркы убакта туз көп жейби, аз уктайбы. Мына ушул дарыгердин чечимине таасир этет, жалгыз сан эмес.',
    ),
    triage: Triage(urgency: TriageUrgency.medium, reason: 'Stage 2 hypertension on treatment, persistent 3+ days'),
  ),

  // 6. Am I doing OK — emotional
  DemoConversation(
    id: 'mom-emotional',
    icon: Icons.favorite_border,
    title: L3(
      en: 'Am I doing OK?',
      ru: 'Я справляюсь?',
      ky: 'Мен жакшы аткарып жатамбы?',
    ),
    question: L3(
      en: "I haven't slept more than 3 hours straight in 8 weeks. I love my baby but I'm crying every day and I don't feel like myself. Is this postpartum depression?",
      ru: 'Я не сплю больше 3 часов подряд уже 8 недель. Я люблю своего малыша, но плачу каждый день и не узнаю себя. Это послеродовая депрессия?',
      ky: 'Мен 8 жумадан бери катары менен 3 сааттан ашык укталбайм. Баламды жакшы көрөм, бирок күндө ыйлап жатам жана өзүмдү таба албай жатам. Бул төрөттөн кийинки депрессиябы?',
    ),
    answer: L3(
      en: "What you're describing — persistent tearfulness, not feeling like yourself, for more than 2 weeks — is past the window of normal baby-blues and fits the pattern of postpartum depression. It is common (1 in 7 mothers) and it is treatable, and none of it means you are failing.\n\nThe most helpful next step is a conversation with an OB/GYN or a perinatal mental-health professional this week. In the app, you can start that from the Doctors tab. Effective treatments range from talk therapy (often enough by itself for mild-to-moderate PPD) to short-term medication that is compatible with breastfeeding.\n\nWhile you wait for the appointment: if you ever have thoughts of harming yourself or the baby, that is an emergency — call 112 or go to the nearest ER. Otherwise: ask one specific person for one specific thing today (a meal, an hour to sleep, someone holding the baby while you shower). You are allowed to need help.",
      ru: 'То, что ты описываешь — плач, ощущение «я не узнаю себя» больше 2 недель — это уже за рамками нормального baby-blues и подходит под послеродовую депрессию. Это часто (1 из 7 матерей) и это лечится, и это не значит, что ты плохая мать.\n\nПолезный следующий шаг — разговор с гинекологом или перинатальным психологом на этой неделе. В приложении можно начать из вкладки Врачи. Эффективные варианты: от разговорной терапии (часто её одной хватает при лёгкой и средней степени) до краткосрочных препаратов, совместимых с грудным вскармливанием.\n\nПока ждёшь встречи: если появляются мысли причинить вред себе или ребёнку — это срочно, звони 103 или в ближайшую скорую. Иначе: попроси одного конкретного человека об одной конкретной вещи сегодня (еда, час сна, кто-то подержит ребёнка пока ты в душе). Тебе можно нуждаться в помощи.',
      ky: 'Сиз айтып жаткан нерсе — туруктуу көз жашыңыз, өзүңүздү таппай жатканыңыз 2 жумадан ашык — бул кадимки төрөттөн кийинки көңүлдүн бузулуу терезесинен чыгып, төрөттөн кийинки депрессиянын үлгүсүнө туура келет. Бул жайылган (7 энеден 1-ден), дарыланат, жана сиз алсыз экениңизди билдирбейт.\n\nЭң пайдалуу кийинки кадам — ушул жумада акушер-гинеколог же перинаталдык психолог менен сүйлөшүү. Колдонмодон «Дарыгерлер» бөлүмүнөн баштасаңыз болот. Натыйжалуу дарылоо: сүйлөшүү терапиясы (жеңил жана орто даражадагы учурда жетиштүү) жана эмчек эмизүүгө туура келген кыска мөөнөттүү дарылар.\n\nЖолугушууну күтүп жатканда: өзүңүзгө же балага зыян келтирүү тууралуу ойлор пайда болсо — бул тез жардам кырдаал, 103кө чалыңыз же жакынкы тез жардамга барыңыз. Болбосо: бүгүн бир аныкталган адамдан бир аныкталган нерсе сурап алыңыз (тамак, уктаганга бир саат, сиз душка кирип жатканда баланы кармаган). Жардамга муктаж болууга укугуңуз бар.',
    ),
    triage: Triage(urgency: TriageUrgency.high, reason: 'Symptoms consistent with postpartum depression; same-week consult warranted'),
  ),
];

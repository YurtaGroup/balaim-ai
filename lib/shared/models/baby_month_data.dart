import '../../core/l10n/content_localizations.dart';

/// Month-by-month baby development data (0-24 months)
/// Content reviewed against AAP, WHO, and CDC developmental guidelines
class BabyMonthData {
  final int month;
  final L3 title;
  final String emoji;
  final double avgWeightKgBoy;
  final double avgWeightKgGirl;
  final double avgHeightCmBoy;
  final double avgHeightCmGirl;
  final L3 physicalDevelopment;
  final L3 cognitiveDevelopment;
  final L3 socialEmotional;
  final L3 languageDevelopment;
  final List<MilestoneItem> milestones;
  final List<L3> activities;
  final SleepGuide sleep;
  final FeedingGuide feeding;
  final List<L3> redFlags;
  final List<L3> parentTips;
  final HealthCheckup? checkup;

  const BabyMonthData({
    required this.month,
    required this.title,
    required this.emoji,
    required this.avgWeightKgBoy,
    required this.avgWeightKgGirl,
    required this.avgHeightCmBoy,
    required this.avgHeightCmGirl,
    required this.physicalDevelopment,
    required this.cognitiveDevelopment,
    required this.socialEmotional,
    required this.languageDevelopment,
    required this.milestones,
    required this.activities,
    required this.sleep,
    required this.feeding,
    required this.redFlags,
    required this.parentTips,
    this.checkup,
  });

  L3 get ageLabel {
    if (month == 0) return const L3(en: 'Newborn', ru: 'Новорождённый', ky: 'Жаңы төрөлгөн');
    if (month == 1) return const L3(en: '1 Month', ru: '1 месяц', ky: '1 ай');
    if (month < 12) return L3(en: '$month Months', ru: '$month мес.', ky: '$month ай');
    if (month == 12) return const L3(en: '1 Year', ru: '1 год', ky: '1 жыл');
    if (month == 24) return const L3(en: '2 Years', ru: '2 года', ky: '2 жыл');
    return L3(en: '$month Months', ru: '$month мес.', ky: '$month ай');
  }

  static BabyMonthData getMonth(int month) {
    final clamped = month.clamp(0, 24);
    if (_monthData.containsKey(clamped)) return _monthData[clamped]!;
    // Find closest lower month with data
    final keys = _monthData.keys.toList()..sort();
    int closest = keys.first;
    for (final k in keys) {
      if (k <= clamped) closest = k;
    }
    return _monthData[closest]!;
  }

  static List<BabyMonthData> getAllMonths() {
    return _monthData.values.toList()..sort((a, b) => a.month.compareTo(b.month));
  }

  static final Map<int, BabyMonthData> _monthData = {
    // =========================================================
    // NEWBORN (0-1 month)
    // =========================================================
    0: BabyMonthData(
      month: 0,
      title: const L3(en: 'Hello, World', ru: 'Привет, мир', ky: 'Салам, дүйнө'),
      emoji: '👶',
      avgWeightKgBoy: 3.3,
      avgWeightKgGirl: 3.2,
      avgHeightCmBoy: 49.9,
      avgHeightCmGirl: 49.1,
      physicalDevelopment: const L3(
        en: 'Your newborn has natural reflexes: rooting (turning toward touch on cheek), sucking, grasping (curling fingers around yours), and the startle (Moro) reflex. Their vision is blurry — they can only focus 20-30cm away, perfect for seeing your face during feeding. Head control is minimal; always support their neck.',
        ru: 'У новорождённого есть естественные рефлексы: поисковый (поворот к прикосновению на щеке), сосательный, хватательный (сжимает ваш палец) и рефлекс Моро (вздрагивание). Зрение размытое — фокусируется только на расстоянии 20-30 см, идеально для вашего лица во время кормления. Контроль головы минимален — всегда поддерживайте шею.',
        ky: 'Жаңы төрөлгөн баланын табигый рефлекстери бар: издөө (бетине тийгенде бурулуу), соруу, кармоо (манжаңызды кысуу) жана Моро рефлекси (чочуу). Көрүүсү бүдөмүк — 20-30 см аралыкка гана көңүл бурат, тамактандырууда жүзүңүздү көрүү үчүн идеалдуу. Баш контролу аз — моюнун дайыма колдоңуз.',
      ),
      cognitiveDevelopment: const L3(
        en: 'Baby recognizes your voice from the womb and prefers it over all other sounds. They can distinguish between light and dark, and are drawn to high-contrast patterns. Their brain is forming 1 million neural connections per second.',
        ru: 'Малыш узнаёт ваш голос ещё с утробы и предпочитает его всем другим звукам. Различает свет и темноту, привлекают контрастные узоры. Мозг формирует 1 миллион нейронных связей в секунду.',
        ky: 'Бала жатындан бери үнүңүздү тааныйт жана башка үндөрдөн артык көрөт. Жарык менен караңгыны айырмалайт, контрасттуу үлгүлөр кызыктырат. Мээси секундасына 1 миллион нейрон байланыш түзөт.',
      ),
      socialEmotional: const L3(
        en: 'Bonding begins immediately through skin-to-skin contact. Baby finds comfort in your heartbeat, warmth, and smell. Crying is their only communication tool — they are not manipulating you. Respond to every cry; you cannot spoil a newborn.',
        ru: 'Привязанность начинается сразу через контакт «кожа к коже». Малыш находит утешение в вашем сердцебиении, тепле и запахе. Плач — единственный инструмент общения, а не манипуляция. Отвечайте на каждый плач — новорождённого невозможно избаловать.',
        ky: 'Байланыш «тери терини тийүү» аркылуу дароо башталат. Бала жүрөк кагышыңыздан, жылуулугуңуздан жана жытыңыздан жыргал табат. Ыйлоо — алардын жалгыз баарлашуу куралы, манипуляция эмес. Ар бир ыйлоого жооп бериңиз — жаңы төрөлгөн баланы эркелетип бузуу мүмкүн эмес.',
      ),
      languageDevelopment: const L3(
        en: 'Baby communicates through crying (hunger, discomfort, tiredness have different cries — you\'ll learn to distinguish them). They are actively listening and absorbing language patterns. Talk, sing, and narrate your day to them.',
        ru: 'Малыш общается через плач (голод, дискомфорт, усталость — разный плач, вы научитесь их различать). Активно слушает и впитывает речевые паттерны. Разговаривайте, пойте и рассказывайте о своём дне.',
        ky: 'Бала ыйлоо аркылуу баарлашат (ачкачылык, ыңгайсыздык, чарчоо — ар кандай ыйлоо, аларды айырмалоону үйрөнөсүз). Жигердүү угуп, тил үлгүлөрүн сиңирүүдө. Сүйлөшүңүз, ырдаңыз, күнүңүз жөнүндө айтып бериңиз.',
      ),
      milestones: [
        MilestoneItem(const L3(en: 'Lifts head briefly during tummy time', ru: 'Ненадолго поднимает голову на животике', ky: 'Ичке жатканда башын кыска убакытка көтөрөт'), MilestoneCategory.motor),
        MilestoneItem(const L3(en: 'Focuses on faces 20-30cm away', ru: 'Фокусируется на лицах на расстоянии 20-30 см', ky: '20-30 см аралыктагы жүздөргө көңүл бурат'), MilestoneCategory.cognitive),
        MilestoneItem(const L3(en: 'Responds to loud sounds (startle)', ru: 'Реагирует на громкие звуки (вздрагивает)', ky: 'Катуу үндөргө жооп берет (чочуйт)'), MilestoneCategory.sensory),
        MilestoneItem(const L3(en: 'Brings hands to face', ru: 'Подносит руки к лицу', ky: 'Колдорун жүзүнө алып келет'), MilestoneCategory.motor),
        MilestoneItem(const L3(en: 'Recognizes parent\'s voice', ru: 'Узнаёт голос родителя', ky: 'Ата-энесинин үнүн тааныйт'), MilestoneCategory.social),
        MilestoneItem(const L3(en: 'Strong grasp reflex', ru: 'Сильный хватательный рефлекс', ky: 'Күчтүү кармоо рефлекси'), MilestoneCategory.motor),
      ],
      activities: const [
        L3(en: 'Skin-to-skin contact (kangaroo care) — 1+ hours daily', ru: 'Контакт «кожа к коже» (метод кенгуру) — 1+ час в день', ky: '«Тери терини тийүү» (кенгуру ыкмасы) — күнүнө 1+ саат'),
        L3(en: 'Tummy time: Start with 1-2 minutes, 2-3 times per day on your chest', ru: 'Время на животике: начните с 1-2 минут, 2-3 раза в день на вашей груди', ky: 'Ичке жатуу убактысы: көкүрөгүңүздө күнүнө 2-3 жолу 1-2 мүнөт'),
        L3(en: 'Black and white contrast cards held 20-30cm from face', ru: 'Чёрно-белые контрастные карточки на расстоянии 20-30 см от лица', ky: 'Ак-кара контрасттуу карталар жүзүнөн 20-30 см аралыкта'),
        L3(en: 'Gentle talking and singing — narrate everything you do', ru: 'Тихий разговор и пение — рассказывайте обо всём, что делаете', ky: 'Жумшак сүйлөшүү жана ырдоо — эмне кылганыңызды айтып бериңиз'),
        L3(en: 'Gentle massage after bath — improves bonding and digestion', ru: 'Нежный массаж после купания — улучшает привязанность и пищеварение', ky: 'Жуунгандан кийин жумшак массаж — байланышты жана ашатууну жакшыртат'),
        L3(en: 'Eye contact during feeding — this builds secure attachment', ru: 'Зрительный контакт во время кормления — формирует надёжную привязанность', ky: 'Тамактандырууда көз контактысы — ишенимдүү байланышты түзөт'),
      ],
      sleep: const SleepGuide(
        totalHours: '14-17',
        pattern: L3(en: 'No day/night rhythm yet. Sleeps in 2-4 hour stretches around the clock.', ru: 'Ритм дня/ночи ещё не сформирован. Спит по 2-4 часа круглосуточно.', ky: 'Күн/түн ритми азырынча жок. Бүт сутка бою 2-4 сааттан уктайт.'),
        tips: [
          L3(en: 'Always place on back to sleep (reduces SIDS risk by 50%)', ru: 'Всегда кладите на спину (снижает риск СВДС на 50%)', ky: 'Дайыма аркасына жаткырыңыз (СВДС коркунучун 50% азайтат)'),
          L3(en: 'Firm, flat surface with no blankets, pillows, or toys', ru: 'Твёрдая ровная поверхность без одеял, подушек и игрушек', ky: 'Жууркан, жаздык жана оюнчуксуз бекем, тегиз бет'),
          L3(en: 'Room-sharing (not bed-sharing) for the first 6 months', ru: 'Совместная комната (не кровать) первые 6 месяцев', ky: 'Алгачкы 6 ай бөлмөнү бөлүшүү (төшөктү эмес)'),
          L3(en: 'Swaddling helps mimic the womb — arms snug, hips loose', ru: 'Пеленание имитирует матку — руки плотно, бёдра свободно', ky: 'Ороо жатынды туурайт — колдор тыгыз, жамбаштар эркин'),
          L3(en: 'White noise mimics womb sounds and helps them settle', ru: 'Белый шум имитирует звуки матки и помогает успокоиться', ky: 'Ак ызы жатын үндөрүн туурайт жана тынчтанууга жардам берет'),
          L3(en: 'Day/night confusion is normal — expose to daylight during awake times', ru: 'Путаница дня/ночи нормальна — показывайте дневной свет во время бодрствования', ky: 'Күн/түн чаташуусу кадимки нерсе — ойгоо учурда күн жарыгына чыгарыңыз'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk or formula exclusively', ru: 'Только грудное молоко или смесь', ky: 'Эмчек сүтү же смесь гана'),
        frequency: L3(en: 'Every 2-3 hours (8-12 times per day)', ru: 'Каждые 2-3 часа (8-12 раз в день)', ky: 'Ар 2-3 саат сайын (күнүнө 8-12 жолу)'),
        amount: L3(en: '30-90ml per feeding, increasing gradually', ru: '30-90 мл за кормление, постепенно увеличивая', ky: 'Тамактандырууга 30-90 мл, акырындык менен көбөйтүү'),
        tips: [
          L3(en: 'Colostrum (first milk) is liquid gold — rich in antibodies', ru: 'Молозиво (первое молоко) — жидкое золото, богатое антителами', ky: 'Уузсүт (биринчи сүт) — антиденелерге бай суюк алтын'),
          L3(en: 'Feed on demand, not on a schedule', ru: 'Кормите по требованию, а не по расписанию', ky: 'Талабы боюнча тамактандырыңыз, графикке эмес'),
          L3(en: 'Watch for hunger cues: rooting, lip smacking, hand to mouth', ru: 'Следите за признаками голода: поисковый рефлекс, причмокивание, рука ко рту', ky: 'Ачкачылык белгилерин байкаңыз: издөө, эрин шылдырлатуу, колун оозуна алуу'),
          L3(en: 'Breastfed babies typically feed more frequently than formula-fed', ru: 'Дети на грудном вскармливании обычно едят чаще, чем на смеси', ky: 'Эмчек эмген балдар көбүнчө смесьдегилерге караганда көп тамактанышат'),
          L3(en: 'Expect to lose 5-10% of birth weight — they regain it by day 10-14', ru: 'Нормально потерять 5-10% веса при рождении — восстанавливается к 10-14 дню', ky: 'Төрөлгөн салмагынын 5-10% жоготуу кадимки — 10-14 күнгө калыбына келет'),
          L3(en: 'Wet diapers: at least 6 per day by day 5 = adequate feeding', ru: 'Мокрые подгузники: минимум 6 в день к 5-му дню = достаточное питание', ky: 'Нымдуу бадана: 5-күнгө карата күнүнө кеминде 6 = жетиштүү тамактандыруу'),
        ],
      ),
      redFlags: const [
        L3(en: 'Not feeding well or refusing to eat', ru: 'Плохо ест или отказывается от еды', ky: 'Жакшы тамактанбайт же тамак жеюүдөн баш тартат'),
        L3(en: 'Fewer than 6 wet diapers per day after day 5', ru: 'Менее 6 мокрых подгузников в день после 5-го дня', ky: '5-күндөн кийин күнүнө 6дан аз нымдуу бадана'),
        L3(en: 'Yellow skin or eyes that worsen (jaundice)', ru: 'Жёлтая кожа или глаза, которые ухудшаются (желтуха)', ky: 'Нашатырланган сары тери же көздөр (сарыктоо)'),
        L3(en: 'Rectal temperature above 38°C (100.4°F) — go to ER immediately', ru: 'Ректальная температура выше 38°C — немедленно в скорую', ky: 'Ректалдык температура 38°C жогору — дароо тез жардамга'),
        L3(en: 'Difficulty breathing or blue-tinged lips', ru: 'Затруднённое дыхание или синеватые губы', ky: 'Дем алуу кыйынчылыгы же көгүлтүр эриндер'),
        L3(en: 'Excessive sleepiness — cannot wake for feedings', ru: 'Чрезмерная сонливость — не просыпается для кормления', ky: 'Ашыкча уйкучулдук — тамактандырууга ойгото албайсыз'),
        L3(en: 'No startle response to loud sounds', ru: 'Нет рефлекса вздрагивания на громкие звуки', ky: 'Катуу үндөргө чочуу рефлекси жок'),
      ],
      parentTips: const [
        L3(en: 'Sleep when baby sleeps — seriously, do it', ru: 'Спите, когда спит малыш — серьёзно, делайте это', ky: 'Бала уктаганда уктаңыз — чын эле, ушундай кылыңыз'),
        L3(en: 'Accept help from everyone who offers', ru: 'Принимайте помощь от всех, кто предлагает', ky: 'Жардам сунуштагандардын бардыгынан кабыл алыңыз'),
        L3(en: 'Postpartum mood changes are normal — but talk to your doctor if sadness persists beyond 2 weeks', ru: 'Послеродовые перепады настроения нормальны — но обратитесь к врачу, если грусть длится более 2 недель', ky: 'Төрөттөн кийинки маанай өзгөрүүлөрү кадимки — бирок кайгы 2 жумадан ашса дарыгерге кайрылыңыз'),
        L3(en: 'Your partner needs bonding time too — skin-to-skin, diaper changes, bath time', ru: 'Вашему партнёру тоже нужно время для привязанности — контакт кожа к коже, смена подгузников, купание', ky: 'Жубайыңызга да байланыш убактысы керек — тери тийүү, бадана алмаштыруу, жуунуу'),
        L3(en: 'Take photos every day — they change faster than you think', ru: 'Фотографируйте каждый день — они меняются быстрее, чем вы думаете', ky: 'Күн сайын сүрөткө тартыңыз — сиз ойлогондон тезирээк өзгөрүшөт'),
        L3(en: 'You are not failing. This is hard. You are doing amazing.', ru: 'Вы не терпите неудачу. Это трудно. Вы делаете невероятную работу.', ky: 'Сиз жеңилбей жатасыз. Бул оор. Сиз укмуштуу иш кылып жатасыз.'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '3-5 days after birth', ru: '3-5 дней после рождения', ky: 'Төрөлгөндөн 3-5 күн кийин'),
        vaccines: [L3(en: 'Hepatitis B (first dose, usually given at hospital)', ru: 'Гепатит B (первая доза, обычно в роддоме)', ky: 'Гепатит B (биринчи доза, көбүнчө ооруканада)')],
        screenings: [
          L3(en: 'Newborn metabolic screening', ru: 'Метаболический скрининг новорождённого', ky: 'Жаңы төрөлгөн баланын метаболикалык скрининги'),
          L3(en: 'Hearing test', ru: 'Проверка слуха', ky: 'Угуу текшерүүсү'),
          L3(en: 'Jaundice check', ru: 'Проверка на желтуху', ky: 'Сарыктоо текшерүүсү'),
          L3(en: 'Weight check', ru: 'Проверка веса', ky: 'Салмак текшерүүсү'),
        ],
      ),
    ),

    // =========================================================
    // 1 MONTH
    // =========================================================
    1: BabyMonthData(
      month: 1,
      title: const L3(en: 'Finding Focus', ru: 'Учимся фокусироваться', ky: 'Көңүл бурууну үйрөнүү'),
      emoji: '👀',
      avgWeightKgBoy: 4.5,
      avgWeightKgGirl: 4.2,
      avgHeightCmBoy: 54.7,
      avgHeightCmGirl: 53.7,
      physicalDevelopment:
          L3(
        en: 'Neck muscles are getting stronger. During tummy time, baby can briefly lift their head  45 degrees. Movements are still mostly reflexive but becoming more purposeful.  They may start to uncurl from the fetal position.',
        ru: 'Neck muscles are getting stronger. During tummy time, baby can briefly lift their head  45 degrees. Movements are still mostly reflexive but becoming more purposeful.  They may start to uncurl from the fetal position.',
        ky: 'Neck muscles are getting stronger. During tummy time, baby can briefly lift their head  45 degrees. Movements are still mostly reflexive but becoming more purposeful.  They may start to uncurl from the fetal position.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Visual tracking is developing — baby can follow a slowly moving object with their eyes.  They prefer faces over objects and can see bold patterns. Hearing is well-developed;  they turn toward familiar sounds.',
        ru: 'Visual tracking is developing — baby can follow a slowly moving object with their eyes.  They prefer faces over objects and can see bold patterns. Hearing is well-developed;  they turn toward familiar sounds.',
        ky: 'Visual tracking is developing — baby can follow a slowly moving object with their eyes.  They prefer faces over objects and can see bold patterns. Hearing is well-developed;  they turn toward familiar sounds.',
      ),
      socialEmotional:
          L3(
        en: 'The first real social smile typically appears between 4-6 weeks — and it will melt your heart.  Baby is learning to self-soothe by sucking on hands. They show clear preference for parents over strangers.',
        ru: 'The first real social smile typically appears between 4-6 weeks — and it will melt your heart.  Baby is learning to self-soothe by sucking on hands. They show clear preference for parents over strangers.',
        ky: 'The first real social smile typically appears between 4-6 weeks — and it will melt your heart.  Baby is learning to self-soothe by sucking on hands. They show clear preference for parents over strangers.',
      ),
      languageDevelopment:
          L3(
        en: 'Cooing begins — soft vowel sounds like "ooh" and "aah."  Baby is starting to make sounds other than crying.  They listen intently when you talk and may move their mouth as if trying to respond.',
        ru: 'Cooing begins — soft vowel sounds like "ooh" and "aah."  Baby is starting to make sounds other than crying.  They listen intently when you talk and may move their mouth as if trying to respond.',
        ky: 'Cooing begins — soft vowel sounds like "ooh" and "aah."  Baby is starting to make sounds other than crying.  They listen intently when you talk and may move their mouth as if trying to respond.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Lifts head 45° during tummy time', ru: 'Lifts head 45° during tummy time', ky: 'Lifts head 45° during tummy time'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Follows objects with eyes (tracking)', ru: 'Follows objects with eyes (tracking)', ky: 'Follows objects with eyes (tracking)'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'First social smile (4-6 weeks)', ru: 'First social smile (4-6 weeks)', ky: 'First social smile (4-6 weeks)'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Coos and makes "ooh/aah" sounds', ru: 'Coos and makes "ooh/aah" sounds', ky: 'Coos and makes "ooh/aah" sounds'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Brings hands to mouth', ru: 'Brings hands to mouth', ky: 'Brings hands to mouth'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Recognizes parent from across the room', ru: 'Recognizes parent from across the room', ky: 'Recognizes parent from across the room'), MilestoneCategory.cognitive),
      ],
      activities: [
        L3(en: 'Tummy time: Work up to 10 minutes total per day in short sessions', ru: 'Tummy time: Work up to 10 minutes total per day in short sessions', ky: 'Tummy time: Work up to 10 minutes total per day in short sessions'),
        L3(en: 'Face-to-face time — make exaggerated expressions, baby will try to imitate', ru: 'Face-to-face time — make exaggerated expressions, baby will try to imitate', ky: 'Face-to-face time — make exaggerated expressions, baby will try to imitate'),
        L3(en: 'Slowly move a rattle or toy side to side for visual tracking', ru: 'Slowly move a rattle or toy side to side for visual tracking', ky: 'Slowly move a rattle or toy side to side for visual tracking'),
        L3(en: 'Read aloud — rhythm and tone matter more than words at this age', ru: 'Read aloud — rhythm and tone matter more than words at this age', ky: 'Read aloud — rhythm and tone matter more than words at this age'),
        L3(en: 'Carry baby facing outward briefly to explore the world', ru: 'Carry baby facing outward briefly to explore the world', ky: 'Carry baby facing outward briefly to explore the world'),
        L3(en: 'Play gentle peek-a-boo (early version — just covering and revealing your face)', ru: 'Play gentle peek-a-boo (early version — just covering and revealing your face)', ky: 'Play gentle peek-a-boo (early version — just covering and revealing your face)'),
      ],
      sleep: const SleepGuide(
        totalHours: '14-17 hours',
        pattern: L3(en: 'Starting to have slightly longer sleep stretches at night (3-4 hours). Still no fixed schedule.', ru: 'Starting to have slightly longer sleep stretches at night (3-4 hours). Still no fixed schedule.', ky: 'Starting to have slightly longer sleep stretches at night (3-4 hours). Still no fixed schedule.'),
        tips: [
          L3(en: 'Begin differentiating day and night — bright and active during day, dim and quiet at night', ru: 'Begin differentiating day and night — bright and active during day, dim and quiet at night', ky: 'Begin differentiating day and night — bright and active during day, dim and quiet at night'),
          L3(en: 'Start a simple bedtime routine: dim lights, warm bath, feeding, lullaby', ru: 'Start a simple bedtime routine: dim lights, warm bath, feeding, lullaby', ky: 'Start a simple bedtime routine: dim lights, warm bath, feeding, lullaby'),
          L3(en: 'Put baby down drowsy but awake to start learning self-settling', ru: 'Put baby down drowsy but awake to start learning self-settling', ky: 'Put baby down drowsy but awake to start learning self-settling'),
          L3(en: 'Swaddling still very helpful', ru: 'Swaddling still very helpful', ky: 'Swaddling still very helpful'),
          L3(en: 'Cluster feeding in the evening is normal — it helps build milk supply', ru: 'Cluster feeding in the evening is normal — it helps build milk supply', ky: 'Cluster feeding in the evening is normal — it helps build milk supply'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk or formula exclusively', ru: 'Breast milk or formula exclusively', ky: 'Breast milk or formula exclusively'),
        frequency: L3(en: 'Every 2-3 hours (still 8-12 times per day)', ru: 'Every 2-3 hours (still 8-12 times per day)', ky: 'Every 2-3 hours (still 8-12 times per day)'),
        amount: L3(en: '60-120ml per feeding', ru: '60-120ml per feeding', ky: '60-120ml per feeding'),
        tips: [
          L3(en: 'Growth spurt around 3 weeks — baby may feed more frequently for 2-3 days', ru: 'Growth spurt around 3 weeks — baby may feed more frequently for 2-3 days', ky: 'Growth spurt around 3 weeks — baby may feed more frequently for 2-3 days'),
          L3(en: 'This is not a sign of low supply — more frequent feeding increases supply', ru: 'This is not a sign of low supply — more frequent feeding increases supply', ky: 'This is not a sign of low supply — more frequent feeding increases supply'),
          L3(en: 'Spit-up is normal if baby is gaining weight and seems comfortable', ru: 'Spit-up is normal if baby is gaining weight and seems comfortable', ky: 'Spit-up is normal if baby is gaining weight and seems comfortable'),
          L3(en: 'Burp during and after feedings to reduce gas', ru: 'Burp during and after feedings to reduce gas', ky: 'Burp during and after feedings to reduce gas'),
        ],
      ),
      redFlags: [
        L3(en: 'No response to loud sounds', ru: 'No response to loud sounds', ky: 'No response to loud sounds'),
        L3(en: 'Does not focus on or follow objects with eyes', ru: 'Does not focus on or follow objects with eyes', ky: 'Does not focus on or follow objects with eyes'),
        L3(en: 'No social smile by 8 weeks', ru: 'No social smile by 8 weeks', ky: 'No social smile by 8 weeks'),
        L3(en: 'Does not bring hands to mouth', ru: 'Does not bring hands to mouth', ky: 'Does not bring hands to mouth'),
        L3(en: 'Seems very stiff or very floppy', ru: 'Seems very stiff or very floppy', ky: 'Seems very stiff or very floppy'),
        L3(en: 'One eye turns in or out consistently', ru: 'One eye turns in or out consistently', ky: 'One eye turns in or out consistently'),
      ],
      parentTips: [
        L3(en: 'That first smile is real — not gas. Celebrate it!', ru: 'That first smile is real — not gas. Celebrate it!', ky: 'That first smile is real — not gas. Celebrate it!'),
        L3(en: 'Establish a simple routine (not a rigid schedule) — feed, play, sleep', ru: 'Establish a simple routine (not a rigid schedule) — feed, play, sleep', ky: 'Establish a simple routine (not a rigid schedule) — feed, play, sleep'),
        L3(en: 'Get outside daily — fresh air is good for both of you', ru: 'Get outside daily — fresh air is good for both of you', ky: 'Get outside daily — fresh air is good for both of you'),
        L3(en: 'Date night can be 30 minutes on the couch together after baby sleeps', ru: 'Date night can be 30 minutes on the couch together after baby sleeps', ky: 'Date night can be 30 minutes on the couch together after baby sleeps'),
        L3(en: 'Document the small moments — first smile, first coo, first outfit', ru: 'Document the small moments — first smile, first coo, first outfit', ky: 'Document the small moments — first smile, first coo, first outfit'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '1 month well-visit', ru: '1 month well-visit', ky: '1 month well-visit'),
        vaccines: [L3(en: 'Hepatitis B (second dose if not given earlier)', ru: 'Hepatitis B (second dose if not given earlier)', ky: 'Hepatitis B (second dose if not given earlier)')],
        screenings: [L3(en: 'Growth and weight check', ru: 'Growth and weight check', ky: 'Growth and weight check'), L3(en: 'Head circumference', ru: 'Head circumference', ky: 'Head circumference'), L3(en: 'Reflexes assessment', ru: 'Reflexes assessment', ky: 'Reflexes assessment')],
      ),
    ),

    // =========================================================
    // 2 MONTHS
    // =========================================================
    2: BabyMonthData(
      month: 2,
      title: const L3(en: 'Smiles & Sounds', ru: 'Улыбки и звуки', ky: 'Жылмаюулар жана үндөр'),
      emoji: '😊',
      avgWeightKgBoy: 5.6,
      avgWeightKgGirl: 5.1,
      avgHeightCmBoy: 58.4,
      avgHeightCmGirl: 57.1,
      physicalDevelopment:
          L3(
        en: 'Head control is improving significantly. Baby can hold head up at 45° during tummy time  for extended periods. They\'re discovering their hands — watching them, bringing them together.  May begin to bat at objects dangling overhead.',
        ru: 'Head control is improving significantly. Baby can hold head up at 45° during tummy time  for extended periods. They\'re discovering their hands — watching them, bringing them together.  May begin to bat at objects dangling overhead.',
        ky: 'Head control is improving significantly. Baby can hold head up at 45° during tummy time  for extended periods. They\'re discovering their hands — watching them, bringing them together.  May begin to bat at objects dangling overhead.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Baby can now see color and is attracted to bright objects. They recognize familiar people  from further away. Cause-and-effect learning begins — they notice that crying brings you,  or that kicking makes a mobile move.',
        ru: 'Baby can now see color and is attracted to bright objects. They recognize familiar people  from further away. Cause-and-effect learning begins — they notice that crying brings you,  or that kicking makes a mobile move.',
        ky: 'Baby can now see color and is attracted to bright objects. They recognize familiar people  from further away. Cause-and-effect learning begins — they notice that crying brings you,  or that kicking makes a mobile move.',
      ),
      socialEmotional:
          L3(
        en: 'Social smiling is well-established now — baby smiles in response to your smile.  They may coo when you talk to them, creating their first "conversations."  Baby begins to show excitement when they see you.',
        ru: 'Social smiling is well-established now — baby smiles in response to your smile.  They may coo when you talk to them, creating their first "conversations."  Baby begins to show excitement when they see you.',
        ky: 'Social smiling is well-established now — baby smiles in response to your smile.  They may coo when you talk to them, creating their first "conversations."  Baby begins to show excitement when they see you.',
      ),
      languageDevelopment:
          L3(
        en: 'Cooing is more frequent and varied. Baby experiments with vowel sounds and occasionally  squeals with delight. They listen carefully and may quiet down when you speak.  First proto-conversations: you talk, baby coos back, you respond.',
        ru: 'Cooing is more frequent and varied. Baby experiments with vowel sounds and occasionally  squeals with delight. They listen carefully and may quiet down when you speak.  First proto-conversations: you talk, baby coos back, you respond.',
        ky: 'Cooing is more frequent and varied. Baby experiments with vowel sounds and occasionally  squeals with delight. They listen carefully and may quiet down when you speak.  First proto-conversations: you talk, baby coos back, you respond.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Holds head at 45° steadily during tummy time', ru: 'Holds head at 45° steadily during tummy time', ky: 'Holds head at 45° steadily during tummy time'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Smiles responsively at people', ru: 'Smiles responsively at people', ky: 'Smiles responsively at people'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Follows objects 180° with eyes', ru: 'Follows objects 180° with eyes', ky: 'Follows objects 180° with eyes'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Coos and makes vowel sounds', ru: 'Coos and makes vowel sounds', ky: 'Coos and makes vowel sounds'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Discovers hands — watches and clasps them', ru: 'Discovers hands — watches and clasps them', ky: 'Discovers hands — watches and clasps them'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Briefly holds a rattle placed in hand', ru: 'Briefly holds a rattle placed in hand', ky: 'Briefly holds a rattle placed in hand'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Begins to self-soothe (sucking on fist)', ru: 'Begins to self-soothe (sucking on fist)', ky: 'Begins to self-soothe (sucking on fist)'), MilestoneCategory.social),
      ],
      activities: [
        L3(en: 'Tummy time: 15-20 minutes total daily — use a rolled towel under chest for support', ru: 'Tummy time: 15-20 minutes total daily — use a rolled towel under chest for support', ky: 'Tummy time: 15-20 minutes total daily — use a rolled towel under chest for support'),
        L3(en: 'Play gym / activity mat with dangling toys overhead', ru: 'Play gym / activity mat with dangling toys overhead', ky: 'Play gym / activity mat with dangling toys overhead'),
        L3(en: 'Mirror play — babies love looking at faces, even their own', ru: 'Mirror play — babies love looking at faces, even their own', ky: 'Mirror play — babies love looking at faces, even their own'),
        L3(en: 'Sing songs with hand motions (Itsy Bitsy Spider, Pat-a-cake)', ru: 'Sing songs with hand motions (Itsy Bitsy Spider, Pat-a-cake)', ky: 'Sing songs with hand motions (Itsy Bitsy Spider, Pat-a-cake)'),
        L3(en: 'Gently bicycle baby\'s legs — helps with gas and builds awareness', ru: 'Gently bicycle baby\'s legs — helps with gas and builds awareness', ky: 'Gently bicycle baby\'s legs — helps with gas and builds awareness'),
        L3(en: 'Narrate your daily activities in a warm, animated voice', ru: 'Narrate your daily activities in a warm, animated voice', ky: 'Narrate your daily activities in a warm, animated voice'),
        L3(en: 'Hold colorful toys and slowly move them for tracking practice', ru: 'Hold colorful toys and slowly move them for tracking practice', ky: 'Hold colorful toys and slowly move them for tracking practice'),
      ],
      sleep: const SleepGuide(
        totalHours: '14-17 hours',
        pattern: L3(en: 'May start sleeping one 4-6 hour stretch at night. 3-4 naps during the day.', ru: 'May start sleeping one 4-6 hour stretch at night. 3-4 naps during the day.', ky: 'May start sleeping one 4-6 hour stretch at night. 3-4 naps during the day.'),
        tips: [
          L3(en: 'Bedtime routine becomes very important now — consistency is key', ru: 'Bedtime routine becomes very important now — consistency is key', ky: 'Bedtime routine becomes very important now — consistency is key'),
          L3(en: 'Drowsy but awake is the goal for bedtime', ru: 'Drowsy but awake is the goal for bedtime', ky: 'Drowsy but awake is the goal for bedtime'),
          L3(en: 'Day naps can still be anywhere (carrier, stroller, crib)', ru: 'Day naps can still be anywhere (carrier, stroller, crib)', ky: 'Day naps can still be anywhere (carrier, stroller, crib)'),
          L3(en: 'Don\'t let daytime naps exceed 2 hours — protect nighttime sleep', ru: 'Don\'t let daytime naps exceed 2 hours — protect nighttime sleep', ky: 'Don\'t let daytime naps exceed 2 hours — protect nighttime sleep'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk or formula exclusively', ru: 'Breast milk or formula exclusively', ky: 'Breast milk or formula exclusively'),
        frequency: L3(en: 'Every 3-4 hours (6-8 times per day)', ru: 'Every 3-4 hours (6-8 times per day)', ky: 'Every 3-4 hours (6-8 times per day)'),
        amount: L3(en: '120-150ml per feeding', ru: '120-150ml per feeding', ky: '120-150ml per feeding'),
        tips: [
          L3(en: 'Growth spurt around 6 weeks — increased feeding is normal', ru: 'Growth spurt around 6 weeks — increased feeding is normal', ky: 'Growth spurt around 6 weeks — increased feeding is normal'),
          L3(en: 'Baby becomes more efficient at feeding — sessions may get shorter', ru: 'Baby becomes more efficient at feeding — sessions may get shorter', ky: 'Baby becomes more efficient at feeding — sessions may get shorter'),
          L3(en: 'If breastfeeding, this is often when it "clicks" and gets easier', ru: 'If breastfeeding, this is often when it "clicks" and gets easier', ky: 'If breastfeeding, this is often when it "clicks" and gets easier'),
          L3(en: 'No water, juice, or solids yet', ru: 'No water, juice, or solids yet', ky: 'No water, juice, or solids yet'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not respond to loud sounds', ru: 'Does not respond to loud sounds', ky: 'Does not respond to loud sounds'),
        L3(en: 'Does not follow moving objects with eyes', ru: 'Does not follow moving objects with eyes', ky: 'Does not follow moving objects with eyes'),
        L3(en: 'Does not smile at people', ru: 'Does not smile at people', ky: 'Does not smile at people'),
        L3(en: 'Does not bring hands to mouth', ru: 'Does not bring hands to mouth', ky: 'Does not bring hands to mouth'),
        L3(en: 'Cannot hold head up when lying on stomach', ru: 'Cannot hold head up when lying on stomach', ky: 'Cannot hold head up when lying on stomach'),
      ],
      parentTips: [
        L3(en: 'This is often called the "reward phase" — baby is more interactive and smiley', ru: 'This is often called the "reward phase" — baby is more interactive and smiley', ky: 'This is often called the "reward phase" — baby is more interactive and smiley'),
        L3(en: 'Take a CPR class if you haven\'t already', ru: 'Take a CPR class if you haven\'t already', ky: 'Take a CPR class if you haven\'t already'),
        L3(en: 'Start thinking about childcare options if returning to work', ru: 'Start thinking about childcare options if returning to work', ky: 'Start thinking about childcare options if returning to work'),
        L3(en: 'Your body is still healing — be patient with yourself', ru: 'Your body is still healing — be patient with yourself', ky: 'Your body is still healing — be patient with yourself'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '2 month well-visit', ru: '2 month well-visit', ky: '2 month well-visit'),
        vaccines: [
          L3(en: 'DTaP (diphtheria, tetanus, pertussis) — dose 1', ru: 'DTaP (diphtheria, tetanus, pertussis) — dose 1', ky: 'DTaP (diphtheria, tetanus, pertussis) — dose 1'),
          L3(en: 'IPV (polio) — dose 1', ru: 'IPV (polio) — dose 1', ky: 'IPV (polio) — dose 1'),
          L3(en: 'Hib (Haemophilus influenzae) — dose 1', ru: 'Hib (Haemophilus influenzae) — dose 1', ky: 'Hib (Haemophilus influenzae) — dose 1'),
          L3(en: 'PCV13 (pneumococcal) — dose 1', ru: 'PCV13 (pneumococcal) — dose 1', ky: 'PCV13 (pneumococcal) — dose 1'),
          L3(en: 'Rotavirus — dose 1 (oral)', ru: 'Rotavirus — dose 1 (oral)', ky: 'Rotavirus — dose 1 (oral)'),
          L3(en: 'Hepatitis B — dose 2 (if not already given)', ru: 'Hepatitis B — dose 2 (if not already given)', ky: 'Hepatitis B — dose 2 (if not already given)'),
        ],
        screenings: [L3(en: 'Growth assessment', ru: 'Growth assessment', ky: 'Growth assessment'), L3(en: 'Developmental screening', ru: 'Developmental screening', ky: 'Developmental screening')],
      ),
    ),

    // =========================================================
    // 3 MONTHS
    // =========================================================
    3: BabyMonthData(
      month: 3,
      title: const L3(en: 'Reaching Out', ru: 'Тянемся к миру', ky: 'Дүйнөгө жетүү'),
      emoji: '🤲',
      avgWeightKgBoy: 6.4,
      avgWeightKgGirl: 5.8,
      avgHeightCmBoy: 61.4,
      avgHeightCmGirl: 59.8,
      physicalDevelopment:
          L3(
        en: 'Head control is strong — baby holds head steady when held upright. During tummy time,  they push up on forearms (mini push-up). Reaching for objects becomes intentional.  They can open and close hands deliberately. The startle reflex is fading.',
        ru: 'Head control is strong — baby holds head steady when held upright. During tummy time,  they push up on forearms (mini push-up). Reaching for objects becomes intentional.  They can open and close hands deliberately. The startle reflex is fading.',
        ky: 'Head control is strong — baby holds head steady when held upright. During tummy time,  they push up on forearms (mini push-up). Reaching for objects becomes intentional.  They can open and close hands deliberately. The startle reflex is fading.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Baby recognizes familiar objects and reaches for them. They study their own hands intently.  Memory is developing — they anticipate routines (getting excited when they see the bottle or breast).  Object tracking is smooth and coordinated.',
        ru: 'Baby recognizes familiar objects and reaches for them. They study their own hands intently.  Memory is developing — they anticipate routines (getting excited when they see the bottle or breast).  Object tracking is smooth and coordinated.',
        ky: 'Baby recognizes familiar objects and reaches for them. They study their own hands intently.  Memory is developing — they anticipate routines (getting excited when they see the bottle or breast).  Object tracking is smooth and coordinated.',
      ),
      socialEmotional:
          L3(
        en: 'Baby laughs out loud for the first time! They are becoming a social butterfly — smiling at everyone,  cooing in conversation, and showing displeasure when play stops. They can imitate some facial expressions.',
        ru: 'Baby laughs out loud for the first time! They are becoming a social butterfly — smiling at everyone,  cooing in conversation, and showing displeasure when play stops. They can imitate some facial expressions.',
        ky: 'Baby laughs out loud for the first time! They are becoming a social butterfly — smiling at everyone,  cooing in conversation, and showing displeasure when play stops. They can imitate some facial expressions.',
      ),
      languageDevelopment:
          L3(
        en: 'Babbling begins with consonant-vowel combinations: "goo," "gah," "bah."  Baby "talks" when you talk and takes turns in vocal exchanges.  They may squeal, growl, and blow raspberries experimenting with their voice.',
        ru: 'Babbling begins with consonant-vowel combinations: "goo," "gah," "bah."  Baby "talks" when you talk and takes turns in vocal exchanges.  They may squeal, growl, and blow raspberries experimenting with their voice.',
        ky: 'Babbling begins with consonant-vowel combinations: "goo," "gah," "bah."  Baby "talks" when you talk and takes turns in vocal exchanges.  They may squeal, growl, and blow raspberries experimenting with their voice.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Holds head steady when upright', ru: 'Holds head steady when upright', ky: 'Holds head steady when upright'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Pushes up on forearms during tummy time', ru: 'Pushes up on forearms during tummy time', ky: 'Pushes up on forearms during tummy time'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Reaches for and bats at objects', ru: 'Reaches for and bats at objects', ky: 'Reaches for and bats at objects'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Laughs out loud', ru: 'Laughs out loud', ky: 'Laughs out loud'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Babbles with consonant sounds', ru: 'Babbles with consonant sounds', ky: 'Babbles with consonant sounds'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Opens and closes hands deliberately', ru: 'Opens and closes hands deliberately', ky: 'Opens and closes hands deliberately'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Bears some weight on legs when held standing', ru: 'Bears some weight on legs when held standing', ky: 'Bears some weight on legs when held standing'), MilestoneCategory.motor),
      ],
      activities: [
        L3(en: 'Tummy time: 20-30 minutes daily — they may start to enjoy it now', ru: 'Tummy time: 20-30 minutes daily — they may start to enjoy it now', ky: 'Tummy time: 20-30 minutes daily — they may start to enjoy it now'),
        L3(en: 'Offer toys to reach for and grasp — soft rattles, crinkle toys', ru: 'Offer toys to reach for and grasp — soft rattles, crinkle toys', ky: 'Offer toys to reach for and grasp — soft rattles, crinkle toys'),
        L3(en: 'Play peek-a-boo — early understanding of object permanence', ru: 'Play peek-a-boo — early understanding of object permanence', ky: 'Play peek-a-boo — early understanding of object permanence'),
        L3(en: 'Dance together while holding baby — they love rhythm and movement', ru: 'Dance together while holding baby — they love rhythm and movement', ky: 'Dance together while holding baby — they love rhythm and movement'),
        L3(en: 'Water play during bath — let them splash with hands', ru: 'Water play during bath — let them splash with hands', ky: 'Water play during bath — let them splash with hands'),
        L3(en: 'Read board books with bold, simple images', ru: 'Read board books with bold, simple images', ky: 'Read board books with bold, simple images'),
        L3(en: 'Let them feel different textures: smooth, rough, soft, bumpy', ru: 'Let them feel different textures: smooth, rough, soft, bumpy', ky: 'Let them feel different textures: smooth, rough, soft, bumpy'),
      ],
      sleep: const SleepGuide(
        totalHours: '14-16 hours',
        pattern: L3(en: '6-8 hours at night (some babies!), 3 naps during the day. Circadian rhythm is developing.', ru: '6-8 hours at night (some babies!), 3 naps during the day. Circadian rhythm is developing.', ky: '6-8 hours at night (some babies!), 3 naps during the day. Circadian rhythm is developing.'),
        tips: [
          L3(en: 'The 3-month sleep regression is common — hang in there', ru: 'The 3-month sleep regression is common — hang in there', ky: 'The 3-month sleep regression is common — hang in there'),
          L3(en: 'Consistent wake-up time helps regulate the body clock', ru: 'Consistent wake-up time helps regulate the body clock', ky: 'Consistent wake-up time helps regulate the body clock'),
          L3(en: 'Start transitioning out of the swaddle if baby is rolling', ru: 'Start transitioning out of the swaddle if baby is rolling', ky: 'Start transitioning out of the swaddle if baby is rolling'),
          L3(en: 'Dark room + white noise + consistent routine = better sleep', ru: 'Dark room + white noise + consistent routine = better sleep', ky: 'Dark room + white noise + consistent routine = better sleep'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk or formula exclusively', ru: 'Breast milk or formula exclusively', ky: 'Breast milk or formula exclusively'),
        frequency: L3(en: 'Every 3-4 hours', ru: 'Every 3-4 hours', ky: 'Every 3-4 hours'),
        amount: L3(en: '150-180ml per feeding', ru: '150-180ml per feeding', ky: '150-180ml per feeding'),
        tips: [
          L3(en: 'Baby is more distracted during feeding — find a quiet spot', ru: 'Baby is more distracted during feeding — find a quiet spot', ky: 'Baby is more distracted during feeding — find a quiet spot'),
          L3(en: '3-month growth spurt may increase hunger temporarily', ru: '3-month growth spurt may increase hunger temporarily', ky: '3-month growth spurt may increase hunger temporarily'),
          L3(en: 'Still no solids — despite what grandma says!', ru: 'Still no solids — despite what grandma says!', ky: 'Still no solids — despite what grandma says!'),
          L3(en: 'If pumping, this is when you may start building a freezer stash', ru: 'If pumping, this is when you may start building a freezer stash', ky: 'If pumping, this is when you may start building a freezer stash'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not follow moving objects with eyes', ru: 'Does not follow moving objects with eyes', ky: 'Does not follow moving objects with eyes'),
        L3(en: 'Does not grasp or hold objects', ru: 'Does not grasp or hold objects', ky: 'Does not grasp or hold objects'),
        L3(en: 'Does not smile at people', ru: 'Does not smile at people', ky: 'Does not smile at people'),
        L3(en: 'Cannot support head well', ru: 'Cannot support head well', ky: 'Cannot support head well'),
        L3(en: 'Does not babble or make sounds', ru: 'Does not babble or make sounds', ky: 'Does not babble or make sounds'),
        L3(en: 'Does not respond to you or seems uninterested in people', ru: 'Does not respond to you or seems uninterested in people', ky: 'Does not respond to you or seems uninterested in people'),
      ],
      parentTips: [
        L3(en: 'This is often when parents feel they\'re "getting the hang of it"', ru: 'This is often when parents feel they\'re "getting the hang of it"', ky: 'This is often when parents feel they\'re "getting the hang of it"'),
        L3(en: 'Baby may start to resist naps — they don\'t want to miss anything!', ru: 'Baby may start to resist naps — they don\'t want to miss anything!', ky: 'Baby may start to resist naps — they don\'t want to miss anything!'),
        L3(en: 'Start a "first year" photo book while memories are fresh', ru: 'Start a "first year" photo book while memories are fresh', ky: 'Start a "first year" photo book while memories are fresh'),
        L3(en: 'Connect with other parents — isolation is the enemy of new parenthood', ru: 'Connect with other parents — isolation is the enemy of new parenthood', ky: 'Connect with other parents — isolation is the enemy of new parenthood'),
      ],
    ),

    // =========================================================
    // 4 MONTHS
    // =========================================================
    4: BabyMonthData(
      month: 4,
      title: const L3(en: 'The Grabber', ru: 'Маленький хватайка', ky: 'Кичинекей кармагыч'),
      emoji: '✊',
      avgWeightKgBoy: 7.0,
      avgWeightKgGirl: 6.4,
      avgHeightCmBoy: 63.9,
      avgHeightCmGirl: 62.1,
      physicalDevelopment:
          L3(
        en: 'Baby grabs everything and brings it to their mouth — this is how they learn about objects.  They can roll from tummy to back. During tummy time, they push up high on extended arms.  They may start to reach across their body (crossing midline — an important milestone).',
        ru: 'Baby grabs everything and brings it to their mouth — this is how they learn about objects.  They can roll from tummy to back. During tummy time, they push up high on extended arms.  They may start to reach across their body (crossing midline — an important milestone).',
        ky: 'Baby grabs everything and brings it to their mouth — this is how they learn about objects.  They can roll from tummy to back. During tummy time, they push up high on extended arms.  They may start to reach across their body (crossing midline — an important milestone).',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Cause and effect is clicking — baby shakes a rattle on purpose to hear the sound.  They look for partially hidden objects. Memory is improving; they remember routines and people.',
        ru: 'Cause and effect is clicking — baby shakes a rattle on purpose to hear the sound.  They look for partially hidden objects. Memory is improving; they remember routines and people.',
        ky: 'Cause and effect is clicking — baby shakes a rattle on purpose to hear the sound.  They look for partially hidden objects. Memory is improving; they remember routines and people.',
      ),
      socialEmotional:
          L3(
        en: 'Baby initiates social interaction — smiling at you to get you to play.  They show preferences for certain toys and people. Stranger awareness may begin (not full anxiety yet).',
        ru: 'Baby initiates social interaction — smiling at you to get you to play.  They show preferences for certain toys and people. Stranger awareness may begin (not full anxiety yet).',
        ky: 'Baby initiates social interaction — smiling at you to get you to play.  They show preferences for certain toys and people. Stranger awareness may begin (not full anxiety yet).',
      ),
      languageDevelopment:
          L3(
        en: 'Babbling is becoming more complex — strings of sounds "ba-ba-ba" or "ma-ma-ma" (not meaningful yet).  Baby responds to their name by turning. They change volume and pitch experimentally.',
        ru: 'Babbling is becoming more complex — strings of sounds "ba-ba-ba" or "ma-ma-ma" (not meaningful yet).  Baby responds to their name by turning. They change volume and pitch experimentally.',
        ky: 'Babbling is becoming more complex — strings of sounds "ba-ba-ba" or "ma-ma-ma" (not meaningful yet).  Baby responds to their name by turning. They change volume and pitch experimentally.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Rolls tummy to back', ru: 'Rolls tummy to back', ky: 'Rolls tummy to back'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Reaches for objects with one hand', ru: 'Reaches for objects with one hand', ky: 'Reaches for objects with one hand'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Brings objects to mouth to explore', ru: 'Brings objects to mouth to explore', ky: 'Brings objects to mouth to explore'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Pushes up on extended arms during tummy time', ru: 'Pushes up on extended arms during tummy time', ky: 'Pushes up on extended arms during tummy time'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Responds to name', ru: 'Responds to name', ky: 'Responds to name'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Babbles chains of consonants', ru: 'Babbles chains of consonants', ky: 'Babbles chains of consonants'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Bears full weight on legs when held standing', ru: 'Bears full weight on legs when held standing', ky: 'Bears full weight on legs when held standing'), MilestoneCategory.motor),
      ],
      activities: [
        L3(en: 'Offer toys of different shapes and textures to grab and mouth', ru: 'Offer toys of different shapes and textures to grab and mouth', ky: 'Offer toys of different shapes and textures to grab and mouth'),
        L3(en: 'Play "airplane" — lift baby in the air (strengthens core)', ru: 'Play "airplane" — lift baby in the air (strengthens core)', ky: 'Play "airplane" — lift baby in the air (strengthens core)'),
        L3(en: 'Roll a ball toward baby during tummy time', ru: 'Roll a ball toward baby during tummy time', ky: 'Roll a ball toward baby during tummy time'),
        L3(en: 'Sing action songs — "If You\'re Happy and You Know It"', ru: 'Sing action songs — "If You\'re Happy and You Know It"', ky: 'Sing action songs — "If You\'re Happy and You Know It"'),
        L3(en: 'Let baby explore safe objects from the kitchen (wooden spoon, silicone cup)', ru: 'Let baby explore safe objects from the kitchen (wooden spoon, silicone cup)', ky: 'Let baby explore safe objects from the kitchen (wooden spoon, silicone cup)'),
        L3(en: 'Blow raspberries on their belly — they\'ll love it', ru: 'Blow raspberries on their belly — they\'ll love it', ky: 'Blow raspberries on their belly — they\'ll love it'),
        L3(en: 'Start reading books with simple repetitive text', ru: 'Start reading books with simple repetitive text', ky: 'Start reading books with simple repetitive text'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-16 hours',
        pattern: L3(en: '10-12 hours at night (with 1-2 feedings), 2-3 naps.', ru: '10-12 hours at night (with 1-2 feedings), 2-3 naps.', ky: '10-12 hours at night (with 1-2 feedings), 2-3 naps.'),
        tips: [
          L3(en: 'The 4-month sleep regression is REAL — sleep cycles are maturing', ru: 'The 4-month sleep regression is REAL — sleep cycles are maturing', ky: 'The 4-month sleep regression is REAL — sleep cycles are maturing'),
          L3(en: 'This is a good time to consider gentle sleep training if needed', ru: 'This is a good time to consider gentle sleep training if needed', ky: 'This is a good time to consider gentle sleep training if needed'),
          L3(en: 'Stop swaddling — baby needs arms free for rolling safety', ru: 'Stop swaddling — baby needs arms free for rolling safety', ky: 'Stop swaddling — baby needs arms free for rolling safety'),
          L3(en: 'Consistent nap times help (roughly 9am, 12pm, 3pm)', ru: 'Consistent nap times help (roughly 9am, 12pm, 3pm)', ky: 'Consistent nap times help (roughly 9am, 12pm, 3pm)'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk or formula exclusively', ru: 'Breast milk or formula exclusively', ky: 'Breast milk or formula exclusively'),
        frequency: L3(en: 'Every 3-4 hours, 5-6 times per day', ru: 'Every 3-4 hours, 5-6 times per day', ky: 'Every 3-4 hours, 5-6 times per day'),
        amount: L3(en: '150-210ml per feeding', ru: '150-210ml per feeding', ky: '150-210ml per feeding'),
        tips: [
          L3(en: 'Baby may show interest in your food — but 4 months is too early for solids', ru: 'Baby may show interest in your food — but 4 months is too early for solids', ky: 'Baby may show interest in your food — but 4 months is too early for solids'),
          L3(en: 'Wait until 6 months for solids (WHO recommendation)', ru: 'Wait until 6 months for solids (WHO recommendation)', ky: 'Wait until 6 months for solids (WHO recommendation)'),
          L3(en: 'Some pediatricians approve solids at 4-5 months — follow your doctor\'s guidance', ru: 'Some pediatricians approve solids at 4-5 months — follow your doctor\'s guidance', ky: 'Some pediatricians approve solids at 4-5 months — follow your doctor\'s guidance'),
          L3(en: 'Signs of readiness: sits with support, good head control, tongue-thrust reflex gone', ru: 'Signs of readiness: sits with support, good head control, tongue-thrust reflex gone', ky: 'Signs of readiness: sits with support, good head control, tongue-thrust reflex gone'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not reach for or hold objects', ru: 'Does not reach for or hold objects', ky: 'Does not reach for or hold objects'),
        L3(en: 'Does not roll in any direction', ru: 'Does not roll in any direction', ky: 'Does not roll in any direction'),
        L3(en: 'Does not respond to sounds or name', ru: 'Does not respond to sounds or name', ky: 'Does not respond to sounds or name'),
        L3(en: 'Does not babble', ru: 'Does not babble', ky: 'Does not babble'),
        L3(en: 'Does not push up during tummy time', ru: 'Does not push up during tummy time', ky: 'Does not push up during tummy time'),
        L3(en: 'Shows no interest in people', ru: 'Shows no interest in people', ky: 'Shows no interest in people'),
      ],
      parentTips: [
        L3(en: 'Babyproof NOW — crawling comes sooner than you think', ru: 'Babyproof NOW — crawling comes sooner than you think', ky: 'Babyproof NOW — crawling comes sooner than you think'),
        L3(en: 'Mouth everything? That\'s normal. Keep small objects away', ru: 'Mouth everything? That\'s normal. Keep small objects away', ky: 'Mouth everything? That\'s normal. Keep small objects away'),
        L3(en: 'The 4-month sleep regression will pass. You will survive it.', ru: 'The 4-month sleep regression will pass. You will survive it.', ky: 'The 4-month sleep regression will pass. You will survive it.'),
        L3(en: 'This is a great age for family photos — baby is expressive and alert', ru: 'This is a great age for family photos — baby is expressive and alert', ky: 'This is a great age for family photos — baby is expressive and alert'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '4 month well-visit', ru: '4 month well-visit', ky: '4 month well-visit'),
        vaccines: [
          L3(en: 'DTaP — dose 2', ru: 'DTaP — dose 2', ky: 'DTaP — dose 2'),
          L3(en: 'IPV — dose 2', ru: 'IPV — dose 2', ky: 'IPV — dose 2'),
          L3(en: 'Hib — dose 2', ru: 'Hib — dose 2', ky: 'Hib — dose 2'),
          L3(en: 'PCV13 — dose 2', ru: 'PCV13 — dose 2', ky: 'PCV13 — dose 2'),
          L3(en: 'Rotavirus — dose 2', ru: 'Rotavirus — dose 2', ky: 'Rotavirus — dose 2'),
        ],
        screenings: [L3(en: 'Growth assessment', ru: 'Growth assessment', ky: 'Growth assessment'), L3(en: 'Developmental screening', ru: 'Developmental screening', ky: 'Developmental screening'), L3(en: 'Vision check', ru: 'Vision check', ky: 'Vision check')],
      ),
    ),

    // =========================================================
    // 6 MONTHS
    // =========================================================
    6: BabyMonthData(
      month: 6,
      title: const L3(en: 'Food Explorer', ru: 'Исследователь еды', ky: 'Тамак изилдөөчү'),
      emoji: '🥄',
      avgWeightKgBoy: 7.9,
      avgWeightKgGirl: 7.3,
      avgHeightCmBoy: 67.6,
      avgHeightCmGirl: 65.7,
      physicalDevelopment:
          L3(
        en: 'Baby sits with minimal support (tripod sitting — using hands for balance).  They roll both directions easily. Transfers objects between hands.  May start rocking on hands and knees — pre-crawling! Pincer grasp is emerging (thumb and finger).',
        ru: 'Baby sits with minimal support (tripod sitting — using hands for balance).  They roll both directions easily. Transfers objects between hands.  May start rocking on hands and knees — pre-crawling! Pincer grasp is emerging (thumb and finger).',
        ky: 'Baby sits with minimal support (tripod sitting — using hands for balance).  They roll both directions easily. Transfers objects between hands.  May start rocking on hands and knees — pre-crawling! Pincer grasp is emerging (thumb and finger).',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Object permanence is developing — baby looks for a dropped toy.  They understand cause and effect well (drop a spoon, you pick it up — repeat 100 times).  Baby explores everything by mouthing, shaking, banging, and dropping.',
        ru: 'Object permanence is developing — baby looks for a dropped toy.  They understand cause and effect well (drop a spoon, you pick it up — repeat 100 times).  Baby explores everything by mouthing, shaking, banging, and dropping.',
        ky: 'Object permanence is developing — baby looks for a dropped toy.  They understand cause and effect well (drop a spoon, you pick it up — repeat 100 times).  Baby explores everything by mouthing, shaking, banging, and dropping.',
      ),
      socialEmotional:
          L3(
        en: 'Stranger anxiety begins — baby may cry with unfamiliar people. This is healthy attachment, not regression.  They show affection by reaching for you, patting your face, leaning in for "hugs."  Separation anxiety may start.',
        ru: 'Stranger anxiety begins — baby may cry with unfamiliar people. This is healthy attachment, not regression.  They show affection by reaching for you, patting your face, leaning in for "hugs."  Separation anxiety may start.',
        ky: 'Stranger anxiety begins — baby may cry with unfamiliar people. This is healthy attachment, not regression.  They show affection by reaching for you, patting your face, leaning in for "hugs."  Separation anxiety may start.',
      ),
      languageDevelopment:
          L3(
        en: 'Babbling includes distinct syllables: "ba," "da," "ma," "ga."  Baby understands tone — they know when you\'re happy, upset, or asking a question.  They may respond to "no" (briefly). First gestures may emerge.',
        ru: 'Babbling includes distinct syllables: "ba," "da," "ma," "ga."  Baby understands tone — they know when you\'re happy, upset, or asking a question.  They may respond to "no" (briefly). First gestures may emerge.',
        ky: 'Babbling includes distinct syllables: "ba," "da," "ma," "ga."  Baby understands tone — they know when you\'re happy, upset, or asking a question.  They may respond to "no" (briefly). First gestures may emerge.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Sits with minimal support', ru: 'Sits with minimal support', ky: 'Sits with minimal support'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Rolls both ways easily', ru: 'Rolls both ways easily', ky: 'Rolls both ways easily'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Transfers objects between hands', ru: 'Transfers objects between hands', ky: 'Transfers objects between hands'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Babbles distinct syllables', ru: 'Babbles distinct syllables', ky: 'Babbles distinct syllables'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Looks for dropped objects', ru: 'Looks for dropped objects', ky: 'Looks for dropped objects'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Shows stranger anxiety', ru: 'Shows stranger anxiety', ky: 'Shows stranger anxiety'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Begins to eat solid foods', ru: 'Begins to eat solid foods', ky: 'Begins to eat solid foods'), MilestoneCategory.feeding),
        MilestoneItem(L3(en: 'Rakes small objects with whole hand', ru: 'Rakes small objects with whole hand', ky: 'Rakes small objects with whole hand'), MilestoneCategory.motor),
      ],
      activities: [
        L3(en: 'Introduce solid foods! Start with single-ingredient purees or baby-led weaning', ru: 'Introduce solid foods! Start with single-ingredient purees or baby-led weaning', ky: 'Introduce solid foods! Start with single-ingredient purees or baby-led weaning'),
        L3(en: 'Let baby explore food textures — messy meals are learning meals', ru: 'Let baby explore food textures — messy meals are learning meals', ky: 'Let baby explore food textures — messy meals are learning meals'),
        L3(en: 'Play "where did it go?" — hide a toy under a cloth', ru: 'Play "where did it go?" — hide a toy under a cloth', ky: 'Play "where did it go?" — hide a toy under a cloth'),
        L3(en: 'Offer stacking cups, blocks, and nesting toys', ru: 'Offer stacking cups, blocks, and nesting toys', ky: 'Offer stacking cups, blocks, and nesting toys'),
        L3(en: 'Encourage sitting practice on soft surfaces with pillows around', ru: 'Encourage sitting practice on soft surfaces with pillows around', ky: 'Encourage sitting practice on soft surfaces with pillows around'),
        L3(en: 'Play music and clap hands together — baby may start clapping', ru: 'Play music and clap hands together — baby may start clapping', ky: 'Play music and clap hands together — baby may start clapping'),
        L3(en: 'Water play with cups and pouring in the bath', ru: 'Water play with cups and pouring in the bath', ky: 'Water play with cups and pouring in the bath'),
        L3(en: 'Read interactive books (lift-the-flap, touch-and-feel)', ru: 'Read interactive books (lift-the-flap, touch-and-feel)', ky: 'Read interactive books (lift-the-flap, touch-and-feel)'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-15 hours',
        pattern: L3(en: '10-11 hours at night, 2-3 naps during the day. Many babies can sleep through the night.', ru: '10-11 hours at night, 2-3 naps during the day. Many babies can sleep through the night.', ky: '10-11 hours at night, 2-3 naps during the day. Many babies can sleep through the night.'),
        tips: [
          L3(en: 'Most babies are ready for sleep training by 6 months if needed', ru: 'Most babies are ready for sleep training by 6 months if needed', ky: 'Most babies are ready for sleep training by 6 months if needed'),
          L3(en: 'Night feedings may still be 0-1 times', ru: 'Night feedings may still be 0-1 times', ky: 'Night feedings may still be 0-1 times'),
          L3(en: 'Transitioning to 2 naps often happens around 6-7 months', ru: 'Transitioning to 2 naps often happens around 6-7 months', ky: 'Transitioning to 2 naps often happens around 6-7 months'),
          L3(en: 'Teething can disrupt sleep temporarily', ru: 'Teething can disrupt sleep temporarily', ky: 'Teething can disrupt sleep temporarily'),
          L3(en: 'Consistent bedtime between 6-8 PM works for most babies', ru: 'Consistent bedtime between 6-8 PM works for most babies', ky: 'Consistent bedtime between 6-8 PM works for most babies'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk/formula + introduction of solid foods', ru: 'Breast milk/formula + introduction of solid foods', ky: 'Breast milk/formula + introduction of solid foods'),
        frequency: L3(en: 'Milk: 4-5 times per day. Solids: 1-2 times per day to start.', ru: 'Milk: 4-5 times per day. Solids: 1-2 times per day to start.', ky: 'Milk: 4-5 times per day. Solids: 1-2 times per day to start.'),
        amount: L3(en: 'Milk: 180-240ml per feeding. Solids: 1-2 tablespoons per sitting.', ru: 'Milk: 180-240ml per feeding. Solids: 1-2 tablespoons per sitting.', ky: 'Milk: 180-240ml per feeding. Solids: 1-2 tablespoons per sitting.'),
        tips: [
          L3(en: 'Start with iron-rich foods: iron-fortified cereal, pureed meats, lentils', ru: 'Start with iron-rich foods: iron-fortified cereal, pureed meats, lentils', ky: 'Start with iron-rich foods: iron-fortified cereal, pureed meats, lentils'),
          L3(en: 'Introduce one new food every 3 days to watch for allergies', ru: 'Introduce one new food every 3 days to watch for allergies', ky: 'Introduce one new food every 3 days to watch for allergies'),
          L3(en: 'Early allergen introduction (peanut, egg, dairy) reduces allergy risk', ru: 'Early allergen introduction (peanut, egg, dairy) reduces allergy risk', ky: 'Early allergen introduction (peanut, egg, dairy) reduces allergy risk'),
          L3(en: 'Offer water in a sippy cup with meals', ru: 'Offer water in a sippy cup with meals', ky: 'Offer water in a sippy cup with meals'),
          L3(en: 'Food before 1 is for fun — milk is still the primary nutrition', ru: 'Food before 1 is for fun — milk is still the primary nutrition', ky: 'Food before 1 is for fun — milk is still the primary nutrition'),
          L3(en: 'Let baby self-feed when possible (banana, avocado strips, soft cooked veggies)', ru: 'Let baby self-feed when possible (banana, avocado strips, soft cooked veggies)', ky: 'Let baby self-feed when possible (banana, avocado strips, soft cooked veggies)'),
          L3(en: 'Never force feed — let baby decide how much to eat', ru: 'Never force feed — let baby decide how much to eat', ky: 'Never force feed — let baby decide how much to eat'),
        ],
      ),
      redFlags: [
        L3(en: 'Cannot sit with support', ru: 'Cannot sit with support', ky: 'Cannot sit with support'),
        L3(en: 'Does not reach for objects', ru: 'Does not reach for objects', ky: 'Does not reach for objects'),
        L3(en: 'Does not respond to sounds or own name', ru: 'Does not respond to sounds or own name', ky: 'Does not respond to sounds or own name'),
        L3(en: 'Does not show affection to familiar people', ru: 'Does not show affection to familiar people', ky: 'Does not show affection to familiar people'),
        L3(en: 'Does not babble', ru: 'Does not babble', ky: 'Does not babble'),
        L3(en: 'Does not roll in either direction', ru: 'Does not roll in either direction', ky: 'Does not roll in either direction'),
        L3(en: 'Seems very stiff or very floppy', ru: 'Seems very stiff or very floppy', ky: 'Seems very stiff or very floppy'),
      ],
      parentTips: [
        L3(en: 'Starting solids is exciting but messy — embrace the chaos', ru: 'Starting solids is exciting but messy — embrace the chaos', ky: 'Starting solids is exciting but messy — embrace the chaos'),
        L3(en: 'A splat mat under the high chair saves your sanity', ru: 'A splat mat under the high chair saves your sanity', ky: 'A splat mat under the high chair saves your sanity'),
        L3(en: 'Stranger anxiety means your baby has a secure attachment — that\'s a WIN', ru: 'Stranger anxiety means your baby has a secure attachment — that\'s a WIN', ky: 'Stranger anxiety means your baby has a secure attachment — that\'s a WIN'),
        L3(en: 'Baby might have a favorite parent right now — the other parent shouldn\'t take it personally', ru: 'Baby might have a favorite parent right now — the other parent shouldn\'t take it personally', ky: 'Baby might have a favorite parent right now — the other parent shouldn\'t take it personally'),
        L3(en: 'Crawl-proofing: get on your hands and knees and look for hazards at baby level', ru: 'Crawl-proofing: get on your hands and knees and look for hazards at baby level', ky: 'Crawl-proofing: get on your hands and knees and look for hazards at baby level'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '6 month well-visit', ru: '6 month well-visit', ky: '6 month well-visit'),
        vaccines: [
          L3(en: 'DTaP — dose 3', ru: 'DTaP — dose 3', ky: 'DTaP — dose 3'),
          L3(en: 'PCV13 — dose 3', ru: 'PCV13 — dose 3', ky: 'PCV13 — dose 3'),
          L3(en: 'Rotavirus — dose 3 (if applicable)', ru: 'Rotavirus — dose 3 (if applicable)', ky: 'Rotavirus — dose 3 (if applicable)'),
          L3(en: 'Influenza (flu) — first dose (seasonal)', ru: 'Influenza (flu) — first dose (seasonal)', ky: 'Influenza (flu) — first dose (seasonal)'),
          L3(en: 'Hepatitis B — dose 3 (if not completed)', ru: 'Hepatitis B — dose 3 (if not completed)', ky: 'Hepatitis B — dose 3 (if not completed)'),
        ],
        screenings: [L3(en: 'Growth and development', ru: 'Growth and development', ky: 'Growth and development'), L3(en: 'Hemoglobin/iron screening', ru: 'Hemoglobin/iron screening', ky: 'Hemoglobin/iron screening'), L3(en: 'Dental assessment', ru: 'Dental assessment', ky: 'Dental assessment')],
      ),
    ),

    // =========================================================
    // 9 MONTHS
    // =========================================================
    9: BabyMonthData(
      month: 9,
      title: const L3(en: 'On the Move', ru: 'В движении', ky: 'Кыймылда'),
      emoji: '🏃',
      avgWeightKgBoy: 8.9,
      avgWeightKgGirl: 8.2,
      avgHeightCmBoy: 72.0,
      avgHeightCmGirl: 70.1,
      physicalDevelopment:
          L3(
        en: 'Crawling is in full swing (or army crawling, bottom scooting — all normal variants).  Baby pulls to stand holding furniture. They sit independently with confidence.  Pincer grasp (thumb and index finger) is developing — they can pick up small pieces of food.',
        ru: 'Crawling is in full swing (or army crawling, bottom scooting — all normal variants).  Baby pulls to stand holding furniture. They sit independently with confidence.  Pincer grasp (thumb and index finger) is developing — they can pick up small pieces of food.',
        ky: 'Crawling is in full swing (or army crawling, bottom scooting — all normal variants).  Baby pulls to stand holding furniture. They sit independently with confidence.  Pincer grasp (thumb and index finger) is developing — they can pick up small pieces of food.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Object permanence is established — baby knows hidden objects still exist and will look for them.  They understand simple words: "no," "bye-bye," "milk."  Problem-solving emerges: they figure out how to get a toy that\'s out of reach.',
        ru: 'Object permanence is established — baby knows hidden objects still exist and will look for them.  They understand simple words: "no," "bye-bye," "milk."  Problem-solving emerges: they figure out how to get a toy that\'s out of reach.',
        ky: 'Object permanence is established — baby knows hidden objects still exist and will look for them.  They understand simple words: "no," "bye-bye," "milk."  Problem-solving emerges: they figure out how to get a toy that\'s out of reach.',
      ),
      socialEmotional:
          L3(
        en: 'Separation anxiety peaks. Baby may cry when you leave the room.  They play social games: peek-a-boo, pat-a-cake, waving bye-bye.  They may cling to a comfort object (blanket, stuffed animal).',
        ru: 'Separation anxiety peaks. Baby may cry when you leave the room.  They play social games: peek-a-boo, pat-a-cake, waving bye-bye.  They may cling to a comfort object (blanket, stuffed animal).',
        ky: 'Separation anxiety peaks. Baby may cry when you leave the room.  They play social games: peek-a-boo, pat-a-cake, waving bye-bye.  They may cling to a comfort object (blanket, stuffed animal).',
      ),
      languageDevelopment:
          L3(
        en: 'Babbling sounds more like real language with rhythm and intonation.  "Mama" and "dada" may emerge (often used nonspecifically at first).  Baby understands 10-20 words even if they can\'t say them. Points at things they want.',
        ru: 'Babbling sounds more like real language with rhythm and intonation.  "Mama" and "dada" may emerge (often used nonspecifically at first).  Baby understands 10-20 words even if they can\'t say them. Points at things they want.',
        ky: 'Babbling sounds more like real language with rhythm and intonation.  "Mama" and "dada" may emerge (often used nonspecifically at first).  Baby understands 10-20 words even if they can\'t say them. Points at things they want.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Crawls (any style)', ru: 'Crawls (any style)', ky: 'Crawls (any style)'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Pulls to standing', ru: 'Pulls to standing', ky: 'Pulls to standing'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Sits independently without support', ru: 'Sits independently without support', ky: 'Sits independently without support'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Pincer grasp developing', ru: 'Pincer grasp developing', ky: 'Pincer grasp developing'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Says "mama" or "dada" (nonspecific)', ru: 'Says "mama" or "dada" (nonspecific)', ky: 'Says "mama" or "dada" (nonspecific)'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Understands "no"', ru: 'Understands "no"', ky: 'Understands "no"'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Waves bye-bye', ru: 'Waves bye-bye', ky: 'Waves bye-bye'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Plays peek-a-boo', ru: 'Plays peek-a-boo', ky: 'Plays peek-a-boo'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Points at objects', ru: 'Points at objects', ky: 'Points at objects'), MilestoneCategory.language),
      ],
      activities: [
        L3(en: 'Set up safe spaces for crawling exploration — obstacle courses with cushions', ru: 'Set up safe spaces for crawling exploration — obstacle courses with cushions', ky: 'Set up safe spaces for crawling exploration — obstacle courses with cushions'),
        L3(en: 'Play "chase" while baby crawls — they\'ll squeal with excitement', ru: 'Play "chase" while baby crawls — they\'ll squeal with excitement', ky: 'Play "chase" while baby crawls — they\'ll squeal with excitement'),
        L3(en: 'Offer finger foods to practice pincer grasp: small pieces of banana, peas, cheerios', ru: 'Offer finger foods to practice pincer grasp: small pieces of banana, peas, cheerios', ky: 'Offer finger foods to practice pincer grasp: small pieces of banana, peas, cheerios'),
        L3(en: 'Stack blocks and let baby knock them down (they\'ll want to repeat it endlessly)', ru: 'Stack blocks and let baby knock them down (they\'ll want to repeat it endlessly)', ky: 'Stack blocks and let baby knock them down (they\'ll want to repeat it endlessly)'),
        L3(en: 'Name everything: "That\'s a dog! The dog says woof!"', ru: 'Name everything: "That\'s a dog! The dog says woof!"', ky: 'Name everything: "That\'s a dog! The dog says woof!"'),
        L3(en: 'Play with balls — roll back and forth, early turn-taking', ru: 'Play with balls — roll back and forth, early turn-taking', ky: 'Play with balls — roll back and forth, early turn-taking'),
        L3(en: 'Let baby open and close containers with lids', ru: 'Let baby open and close containers with lids', ky: 'Let baby open and close containers with lids'),
        L3(en: 'Sing "The Wheels on the Bus" with hand motions', ru: 'Sing "The Wheels on the Bus" with hand motions', ky: 'Sing "The Wheels on the Bus" with hand motions'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: L3(en: '10-12 hours at night, 2 naps (morning and afternoon).', ru: '10-12 hours at night, 2 naps (morning and afternoon).', ky: '10-12 hours at night, 2 naps (morning and afternoon).'),
        tips: [
          L3(en: 'Separation anxiety can cause nighttime waking — be consistent', ru: 'Separation anxiety can cause nighttime waking — be consistent', ky: 'Separation anxiety can cause nighttime waking — be consistent'),
          L3(en: 'Many babies drop to 2 naps around 8-9 months', ru: 'Many babies drop to 2 naps around 8-9 months', ky: 'Many babies drop to 2 naps around 8-9 months'),
          L3(en: 'Standing in the crib is a new skill — practice during the day so it\'s less exciting at night', ru: 'Standing in the crib is a new skill — practice during the day so it\'s less exciting at night', ky: 'Standing in the crib is a new skill — practice during the day so it\'s less exciting at night'),
          L3(en: 'Comfort objects are OK now (small lovey blanket)', ru: 'Comfort objects are OK now (small lovey blanket)', ky: 'Comfort objects are OK now (small lovey blanket)'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk/formula + expanding solid food variety', ru: 'Breast milk/formula + expanding solid food variety', ky: 'Breast milk/formula + expanding solid food variety'),
        frequency: L3(en: 'Milk: 3-4 times per day. Solids: 3 meals per day.', ru: 'Milk: 3-4 times per day. Solids: 3 meals per day.', ky: 'Milk: 3-4 times per day. Solids: 3 meals per day.'),
        amount: L3(en: 'Milk: 180-240ml. Solids: increasing to several tablespoons per meal.', ru: 'Milk: 180-240ml. Solids: increasing to several tablespoons per meal.', ky: 'Milk: 180-240ml. Solids: increasing to several tablespoons per meal.'),
        tips: [
          L3(en: 'Offer a wide variety of textures — soft chunks, mashed, finger foods', ru: 'Offer a wide variety of textures — soft chunks, mashed, finger foods', ky: 'Offer a wide variety of textures — soft chunks, mashed, finger foods'),
          L3(en: 'Baby should be eating most food groups now', ru: 'Baby should be eating most food groups now', ky: 'Baby should be eating most food groups now'),
          L3(en: 'Encourage self-feeding with fingers and beginner spoons', ru: 'Encourage self-feeding with fingers and beginner spoons', ky: 'Encourage self-feeding with fingers and beginner spoons'),
          L3(en: 'Offer a cup (open or 360) — start reducing bottles', ru: 'Offer a cup (open or 360) — start reducing bottles', ky: 'Offer a cup (open or 360) — start reducing bottles'),
          L3(en: 'No honey until 12 months (botulism risk)', ru: 'No honey until 12 months (botulism risk)', ky: 'No honey until 12 months (botulism risk)'),
          L3(en: 'No cow\'s milk as main drink until 12 months', ru: 'No cow\'s milk as main drink until 12 months', ky: 'No cow\'s milk as main drink until 12 months'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not sit independently', ru: 'Does not sit independently', ky: 'Does not sit independently'),
        L3(en: 'Does not bear weight on legs when held standing', ru: 'Does not bear weight on legs when held standing', ky: 'Does not bear weight on legs when held standing'),
        L3(en: 'Does not babble ("mama," "baba," "dada")', ru: 'Does not babble ("mama," "baba," "dada")', ky: 'Does not babble ("mama," "baba," "dada")'),
        L3(en: 'Does not respond to own name', ru: 'Does not respond to own name', ky: 'Does not respond to own name'),
        L3(en: 'Does not recognize familiar people', ru: 'Does not recognize familiar people', ky: 'Does not recognize familiar people'),
        L3(en: 'Does not look where you point', ru: 'Does not look where you point', ky: 'Does not look where you point'),
        L3(en: 'Does not transfer objects between hands', ru: 'Does not transfer objects between hands', ky: 'Does not transfer objects between hands'),
      ],
      parentTips: [
        L3(en: 'Baby is mobile — your house will never be the same. Embrace it.', ru: 'Baby is mobile — your house will never be the same. Embrace it.', ky: 'Baby is mobile — your house will never be the same. Embrace it.'),
        L3(en: 'Separation anxiety is NOT a behavior problem — it\'s healthy development', ru: 'Separation anxiety is NOT a behavior problem — it\'s healthy development', ky: 'Separation anxiety is NOT a behavior problem — it\'s healthy development'),
        L3(en: 'Say bye-bye confidently and briefly. Don\'t sneak out — it makes anxiety worse', ru: 'Say bye-bye confidently and briefly. Don\'t sneak out — it makes anxiety worse', ky: 'Say bye-bye confidently and briefly. Don\'t sneak out — it makes anxiety worse'),
        L3(en: 'This is the golden age of baby giggles. Soak it in.', ru: 'This is the golden age of baby giggles. Soak it in.', ky: 'This is the golden age of baby giggles. Soak it in.'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '9 month well-visit', ru: '9 month well-visit', ky: '9 month well-visit'),
        vaccines: [L3(en: 'Hepatitis B — dose 3 (if not completed)', ru: 'Hepatitis B — dose 3 (if not completed)', ky: 'Hepatitis B — dose 3 (if not completed)'), L3(en: 'Influenza — dose 2 (seasonal)', ru: 'Influenza — dose 2 (seasonal)', ky: 'Influenza — dose 2 (seasonal)')],
        screenings: [L3(en: 'Developmental screening (ASQ)', ru: 'Developmental screening (ASQ)', ky: 'Developmental screening (ASQ)'), L3(en: 'Growth assessment', ru: 'Growth assessment', ky: 'Growth assessment'), L3(en: 'Iron/lead screening', ru: 'Iron/lead screening', ky: 'Iron/lead screening')],
      ),
    ),

    // =========================================================
    // 12 MONTHS — HAPPY BIRTHDAY!
    // =========================================================
    12: BabyMonthData(
      month: 12,
      title: const L3(en: 'Happy First Birthday!', ru: 'С первым днём рождения!', ky: 'Биринчи туулган күнүңүз менен!'),
      emoji: '🎂',
      avgWeightKgBoy: 9.6,
      avgWeightKgGirl: 8.9,
      avgHeightCmBoy: 75.7,
      avgHeightCmGirl: 74.0,
      physicalDevelopment:
          L3(
        en: 'Many babies take their first independent steps around 12 months (9-15 months is normal range).  They cruise along furniture confidently. Fine motor skills are advancing — they can stack 2 blocks,  turn pages of a board book, and use a pincer grasp precisely.',
        ru: 'Many babies take their first independent steps around 12 months (9-15 months is normal range).  They cruise along furniture confidently. Fine motor skills are advancing — they can stack 2 blocks,  turn pages of a board book, and use a pincer grasp precisely.',
        ky: 'Many babies take their first independent steps around 12 months (9-15 months is normal range).  They cruise along furniture confidently. Fine motor skills are advancing — they can stack 2 blocks,  turn pages of a board book, and use a pincer grasp precisely.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Baby understands simple instructions: "Give me the ball," "Where\'s your shoe?"  They imitate actions they\'ve seen: talking on a phone, brushing hair.  Symbolic play begins — using a banana as a phone. Trial and error learning is active.',
        ru: 'Baby understands simple instructions: "Give me the ball," "Where\'s your shoe?"  They imitate actions they\'ve seen: talking on a phone, brushing hair.  Symbolic play begins — using a banana as a phone. Trial and error learning is active.',
        ky: 'Baby understands simple instructions: "Give me the ball," "Where\'s your shoe?"  They imitate actions they\'ve seen: talking on a phone, brushing hair.  Symbolic play begins — using a banana as a phone. Trial and error learning is active.',
      ),
      socialEmotional:
          L3(
        en: 'Baby shows strong preferences for certain people and toys. They test boundaries — dropping food,  banging things — not to be naughty, but to understand the world.  They look to you for reactions (social referencing): "Is this safe? Should I be scared?"',
        ru: 'Baby shows strong preferences for certain people and toys. They test boundaries — dropping food,  banging things — not to be naughty, but to understand the world.  They look to you for reactions (social referencing): "Is this safe? Should I be scared?"',
        ky: 'Baby shows strong preferences for certain people and toys. They test boundaries — dropping food,  banging things — not to be naughty, but to understand the world.  They look to you for reactions (social referencing): "Is this safe? Should I be scared?"',
      ),
      languageDevelopment:
          L3(
        en: 'First real words emerge! Most babies have 1-5 words used consistently and meaningfully.  "Mama," "dada," "ball," "more," "no" are common first words.  Baby understands 50+ words. They follow simple directions.',
        ru: 'First real words emerge! Most babies have 1-5 words used consistently and meaningfully.  "Mama," "dada," "ball," "more," "no" are common first words.  Baby understands 50+ words. They follow simple directions.',
        ky: 'First real words emerge! Most babies have 1-5 words used consistently and meaningfully.  "Mama," "dada," "ball," "more," "no" are common first words.  Baby understands 50+ words. They follow simple directions.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Stands independently', ru: 'Stands independently', ky: 'Stands independently'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Takes first steps (9-15 months range is normal)', ru: 'Takes first steps (9-15 months range is normal)', ky: 'Takes first steps (9-15 months range is normal)'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Says 1-5 words with meaning', ru: 'Says 1-5 words with meaning', ky: 'Says 1-5 words with meaning'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Understands simple instructions', ru: 'Understands simple instructions', ky: 'Understands simple instructions'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Uses pincer grasp precisely', ru: 'Uses pincer grasp precisely', ky: 'Uses pincer grasp precisely'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Imitates actions (phone to ear, brushing hair)', ru: 'Imitates actions (phone to ear, brushing hair)', ky: 'Imitates actions (phone to ear, brushing hair)'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Waves, claps, points with purpose', ru: 'Waves, claps, points with purpose', ky: 'Waves, claps, points with purpose'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Drinks from a cup with help', ru: 'Drinks from a cup with help', ky: 'Drinks from a cup with help'), MilestoneCategory.feeding),
        MilestoneItem(L3(en: 'Shows separation anxiety with specific caregivers', ru: 'Shows separation anxiety with specific caregivers', ky: 'Shows separation anxiety with specific caregivers'), MilestoneCategory.social),
      ],
      activities: [
        L3(en: 'Encourage walking — hold both hands, then one hand, then let go briefly', ru: 'Encourage walking — hold both hands, then one hand, then let go briefly', ky: 'Encourage walking — hold both hands, then one hand, then let go briefly'),
        L3(en: 'Push toys (toy shopping cart, push walker) build confidence for walking', ru: 'Push toys (toy shopping cart, push walker) build confidence for walking', ky: 'Push toys (toy shopping cart, push walker) build confidence for walking'),
        L3(en: 'Shape sorters and simple puzzles (2-3 pieces)', ru: 'Shape sorters and simple puzzles (2-3 pieces)', ky: 'Shape sorters and simple puzzles (2-3 pieces)'),
        L3(en: 'Pretend play: toy kitchen, phone, baby doll', ru: 'Pretend play: toy kitchen, phone, baby doll', ky: 'Pretend play: toy kitchen, phone, baby doll'),
        L3(en: 'Play "go find the ___!" — builds vocabulary and comprehension', ru: 'Play "go find the ___!" — builds vocabulary and comprehension', ky: 'Play "go find the ___!" — builds vocabulary and comprehension'),
        L3(en: 'Dance parties! Toddlers love music with a strong beat', ru: 'Dance parties! Toddlers love music with a strong beat', ky: 'Dance parties! Toddlers love music with a strong beat'),
        L3(en: 'Outdoor exploration: park, sandbox, nature walks', ru: 'Outdoor exploration: park, sandbox, nature walks', ky: 'Outdoor exploration: park, sandbox, nature walks'),
        L3(en: 'Crayons and large paper — first marks are a huge milestone', ru: 'Crayons and large paper — first marks are a huge milestone', ky: 'Crayons and large paper — first marks are a huge milestone'),
        L3(en: 'Stack and knock down blocks endlessly', ru: 'Stack and knock down blocks endlessly', ky: 'Stack and knock down blocks endlessly'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: L3(en: '10-12 hours at night, 1-2 naps. Many start transitioning to 1 nap.', ru: '10-12 hours at night, 1-2 naps. Many start transitioning to 1 nap.', ky: '10-12 hours at night, 1-2 naps. Many start transitioning to 1 nap.'),
        tips: [
          L3(en: 'The 12-month sleep regression often coincides with first steps and first words', ru: 'The 12-month sleep regression often coincides with first steps and first words', ky: 'The 12-month sleep regression often coincides with first steps and first words'),
          L3(en: 'Resist dropping to 1 nap too early — most toddlers need 2 naps until 14-18 months', ru: 'Resist dropping to 1 nap too early — most toddlers need 2 naps until 14-18 months', ky: 'Resist dropping to 1 nap too early — most toddlers need 2 naps until 14-18 months'),
          L3(en: 'Bedtime resistance may increase — toddlers FOMO is real', ru: 'Bedtime resistance may increase — toddlers FOMO is real', ky: 'Bedtime resistance may increase — toddlers FOMO is real'),
          L3(en: 'A consistent, boring bedtime routine is your best friend', ru: 'A consistent, boring bedtime routine is your best friend', ky: 'A consistent, boring bedtime routine is your best friend'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Transition to whole cow\'s milk + table foods', ru: 'Transition to whole cow\'s milk + table foods', ky: 'Transition to whole cow\'s milk + table foods'),
        frequency: L3(en: '3 meals + 2-3 snacks per day. Milk: 3 cups per day.', ru: '3 meals + 2-3 snacks per day. Milk: 3 cups per day.', ky: '3 meals + 2-3 snacks per day. Milk: 3 cups per day.'),
        amount: L3(en: 'Milk: 360-480ml total per day (no more). Balanced meals.', ru: 'Milk: 360-480ml total per day (no more). Balanced meals.', ky: 'Milk: 360-480ml total per day (no more). Balanced meals.'),
        tips: [
          L3(en: 'Switch from formula to whole cow\'s milk (or continue breastfeeding)', ru: 'Switch from formula to whole cow\'s milk (or continue breastfeeding)', ky: 'Switch from formula to whole cow\'s milk (or continue breastfeeding)'),
          L3(en: 'Limit milk to 480ml/day — too much blocks iron absorption', ru: 'Limit milk to 480ml/day — too much blocks iron absorption', ky: 'Limit milk to 480ml/day — too much blocks iron absorption'),
          L3(en: 'Wean from the bottle by 12-15 months — use cups', ru: 'Wean from the bottle by 12-15 months — use cups', ky: 'Wean from the bottle by 12-15 months — use cups'),
          L3(en: 'Baby should eat what the family eats (with age-appropriate modifications)', ru: 'Baby should eat what the family eats (with age-appropriate modifications)', ky: 'Baby should eat what the family eats (with age-appropriate modifications)'),
          L3(en: 'Picky eating often starts now — keep offering variety without pressure', ru: 'Picky eating often starts now — keep offering variety without pressure', ky: 'Picky eating often starts now — keep offering variety without pressure'),
          L3(en: 'Division of responsibility: you decide WHAT and WHEN, baby decides IF and HOW MUCH', ru: 'Division of responsibility: you decide WHAT and WHEN, baby decides IF and HOW MUCH', ky: 'Division of responsibility: you decide WHAT and WHEN, baby decides IF and HOW MUCH'),
          L3(en: 'Cut round foods (grapes, cherry tomatoes, hot dogs) lengthwise to prevent choking', ru: 'Cut round foods (grapes, cherry tomatoes, hot dogs) lengthwise to prevent choking', ky: 'Cut round foods (grapes, cherry tomatoes, hot dogs) lengthwise to prevent choking'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not stand with support', ru: 'Does not stand with support', ky: 'Does not stand with support'),
        L3(en: 'Does not use any words', ru: 'Does not use any words', ky: 'Does not use any words'),
        L3(en: 'Does not point to objects or pictures', ru: 'Does not point to objects or pictures', ky: 'Does not point to objects or pictures'),
        L3(en: 'Does not wave or use gestures', ru: 'Does not wave or use gestures', ky: 'Does not wave or use gestures'),
        L3(en: 'Loses skills they previously had', ru: 'Loses skills they previously had', ky: 'Loses skills they previously had'),
        L3(en: 'Does not look where you point', ru: 'Does not look where you point', ky: 'Does not look where you point'),
        L3(en: 'Does not search for hidden objects', ru: 'Does not search for hidden objects', ky: 'Does not search for hidden objects'),
      ],
      parentTips: [
        L3(en: 'Happy birthday to your baby — and to you as a parent! You made it through year one.', ru: 'Happy birthday to your baby — and to you as a parent! You made it through year one.', ky: 'Happy birthday to your baby — and to you as a parent! You made it through year one.'),
        L3(en: 'Don\'t compare walking timelines. 9-15 months is the normal range.', ru: 'Don\'t compare walking timelines. 9-15 months is the normal range.', ky: 'Don\'t compare walking timelines. 9-15 months is the normal range.'),
        L3(en: 'The toddler phase is wild but so rewarding. Buckle up!', ru: 'The toddler phase is wild but so rewarding. Buckle up!', ky: 'The toddler phase is wild but so rewarding. Buckle up!'),
        L3(en: 'Start saying "You did it!" more than "Good job!" — process over praise', ru: 'Start saying "You did it!" more than "Good job!" — process over praise', ky: 'Start saying "You did it!" more than "Good job!" — process over praise'),
        L3(en: 'Celebrate this milestone — you transformed a helpless newborn into a walking, talking human', ru: 'Celebrate this milestone — you transformed a helpless newborn into a walking, talking human', ky: 'Celebrate this milestone — you transformed a helpless newborn into a walking, talking human'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '12 month well-visit', ru: '12 month well-visit', ky: '12 month well-visit'),
        vaccines: [
          L3(en: 'MMR (measles, mumps, rubella) — dose 1', ru: 'MMR (measles, mumps, rubella) — dose 1', ky: 'MMR (measles, mumps, rubella) — dose 1'),
          L3(en: 'Varicella (chickenpox) — dose 1', ru: 'Varicella (chickenpox) — dose 1', ky: 'Varicella (chickenpox) — dose 1'),
          L3(en: 'Hepatitis A — dose 1', ru: 'Hepatitis A — dose 1', ky: 'Hepatitis A — dose 1'),
          L3(en: 'PCV13 — booster', ru: 'PCV13 — booster', ky: 'PCV13 — booster'),
        ],
        screenings: [L3(en: 'Developmental screening', ru: 'Developmental screening', ky: 'Developmental screening'), L3(en: 'Autism screening (M-CHAT)', ru: 'Autism screening (M-CHAT)', ky: 'Autism screening (M-CHAT)'), L3(en: 'Growth assessment', ru: 'Growth assessment', ky: 'Growth assessment'), L3(en: 'Lead screening', ru: 'Lead screening', ky: 'Lead screening')],
      ),
    ),

    // =========================================================
    // 15 MONTHS
    // =========================================================
    15: BabyMonthData(
      month: 15,
      title: const L3(en: 'The Explorer', ru: 'Исследователь', ky: 'Изилдөөчү'),
      emoji: '🌍',
      avgWeightKgBoy: 10.3,
      avgWeightKgGirl: 9.6,
      avgHeightCmBoy: 79.1,
      avgHeightCmGirl: 77.5,
      physicalDevelopment:
          L3(
        en: 'Walking is becoming more stable and confident. Toddler may start running (a wobbly fast walk).  They can squat to pick up objects and stand back up. Climbing stairs with help begins.  They stack 2-4 blocks and turn book pages.',
        ru: 'Walking is becoming more stable and confident. Toddler may start running (a wobbly fast walk).  They can squat to pick up objects and stand back up. Climbing stairs with help begins.  They stack 2-4 blocks and turn book pages.',
        ky: 'Walking is becoming more stable and confident. Toddler may start running (a wobbly fast walk).  They can squat to pick up objects and stand back up. Climbing stairs with help begins.  They stack 2-4 blocks and turn book pages.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Toddler understands simple concepts: "in," "out," "up," "more."  They can point to body parts when asked. Problem-solving is improving —  they\'ll try different approaches to get what they want.',
        ru: 'Toddler understands simple concepts: "in," "out," "up," "more."  They can point to body parts when asked. Problem-solving is improving —  they\'ll try different approaches to get what they want.',
        ky: 'Toddler understands simple concepts: "in," "out," "up," "more."  They can point to body parts when asked. Problem-solving is improving —  they\'ll try different approaches to get what they want.',
      ),
      socialEmotional:
          L3(
        en: 'Tantrums begin! Big emotions, small vocabulary = frustration. This is 100% developmentally normal.  Toddler wants to do things independently. They show empathy — may hug a crying friend.  Parallel play (playing alongside, not with) other children.',
        ru: 'Tantrums begin! Big emotions, small vocabulary = frustration. This is 100% developmentally normal.  Toddler wants to do things independently. They show empathy — may hug a crying friend.  Parallel play (playing alongside, not with) other children.',
        ky: 'Tantrums begin! Big emotions, small vocabulary = frustration. This is 100% developmentally normal.  Toddler wants to do things independently. They show empathy — may hug a crying friend.  Parallel play (playing alongside, not with) other children.',
      ),
      languageDevelopment:
          L3(
        en: 'Vocabulary is growing: 5-10 words used consistently.  Toddler uses gestures combined with words. They understand far more than they can say.  Follow simple commands: "Give me the cup," "Where\'s daddy?"',
        ru: 'Vocabulary is growing: 5-10 words used consistently.  Toddler uses gestures combined with words. They understand far more than they can say.  Follow simple commands: "Give me the cup," "Where\'s daddy?"',
        ky: 'Vocabulary is growing: 5-10 words used consistently.  Toddler uses gestures combined with words. They understand far more than they can say.  Follow simple commands: "Give me the cup," "Where\'s daddy?"',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Walks well independently', ru: 'Walks well independently', ky: 'Walks well independently'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Squats and stands back up', ru: 'Squats and stands back up', ky: 'Squats and stands back up'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Stacks 2-4 blocks', ru: 'Stacks 2-4 blocks', ky: 'Stacks 2-4 blocks'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 5-10 words', ru: 'Uses 5-10 words', ky: 'Uses 5-10 words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Points to body parts when named', ru: 'Points to body parts when named', ky: 'Points to body parts when named'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Follows simple instructions', ru: 'Follows simple instructions', ky: 'Follows simple instructions'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Shows empathy toward others', ru: 'Shows empathy toward others', ky: 'Shows empathy toward others'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Attempts to use spoon/fork', ru: 'Attempts to use spoon/fork', ky: 'Attempts to use spoon/fork'), MilestoneCategory.feeding),
      ],
      activities: [
        L3(en: 'Outdoor play every day — playground, nature walks, sandbox', ru: 'Outdoor play every day — playground, nature walks, sandbox', ky: 'Outdoor play every day — playground, nature walks, sandbox'),
        L3(en: 'Ball play: kicking, throwing (overhand), rolling', ru: 'Ball play: kicking, throwing (overhand), rolling', ky: 'Ball play: kicking, throwing (overhand), rolling'),
        L3(en: 'Simple art: finger painting, crayon scribbling, play dough', ru: 'Simple art: finger painting, crayon scribbling, play dough', ky: 'Simple art: finger painting, crayon scribbling, play dough'),
        L3(en: 'Stacking and nesting toys, simple puzzles', ru: 'Stacking and nesting toys, simple puzzles', ky: 'Stacking and nesting toys, simple puzzles'),
        L3(en: 'Name body parts while getting dressed: "Where\'s your nose?"', ru: 'Name body parts while getting dressed: "Where\'s your nose?"', ky: 'Name body parts while getting dressed: "Where\'s your nose?"'),
        L3(en: 'Let toddler "help" with simple tasks: wiping, putting things in bins', ru: 'Let toddler "help" with simple tasks: wiping, putting things in bins', ky: 'Let toddler "help" with simple tasks: wiping, putting things in bins'),
        L3(en: 'Pretend play with toy animals, cars, dolls', ru: 'Pretend play with toy animals, cars, dolls', ky: 'Pretend play with toy animals, cars, dolls'),
        L3(en: 'Read, read, read — ask "where\'s the cat?" for interactive reading', ru: 'Read, read, read — ask "where\'s the cat?" for interactive reading', ky: 'Read, read, read — ask "where\'s the cat?" for interactive reading'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: L3(en: '10-12 hours at night, transitioning from 2 naps to 1 afternoon nap.', ru: '10-12 hours at night, transitioning from 2 naps to 1 afternoon nap.', ky: '10-12 hours at night, transitioning from 2 naps to 1 afternoon nap.'),
        tips: [
          L3(en: 'The 2-to-1 nap transition takes 2-4 weeks — expect some cranky days', ru: 'The 2-to-1 nap transition takes 2-4 weeks — expect some cranky days', ky: 'The 2-to-1 nap transition takes 2-4 weeks — expect some cranky days'),
          L3(en: 'If 1 nap, aim for 12:30-1:00 PM start, 2-2.5 hours long', ru: 'If 1 nap, aim for 12:30-1:00 PM start, 2-2.5 hours long', ky: 'If 1 nap, aim for 12:30-1:00 PM start, 2-2.5 hours long'),
          L3(en: 'Bedtime may need to move earlier temporarily during nap transition', ru: 'Bedtime may need to move earlier temporarily during nap transition', ky: 'Bedtime may need to move earlier temporarily during nap transition'),
          L3(en: 'Consistent routine matters more than ever with an opinionated toddler', ru: 'Consistent routine matters more than ever with an opinionated toddler', ky: 'Consistent routine matters more than ever with an opinionated toddler'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Table foods + whole milk (or continued breastfeeding)', ru: 'Table foods + whole milk (or continued breastfeeding)', ky: 'Table foods + whole milk (or continued breastfeeding)'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Milk: max 480ml/day. Varied diet.', ru: 'Milk: max 480ml/day. Varied diet.', ky: 'Milk: max 480ml/day. Varied diet.'),
        tips: [
          L3(en: 'Picky eating peaks between 15-24 months — this is normal', ru: 'Picky eating peaks between 15-24 months — this is normal', ky: 'Picky eating peaks between 15-24 months — this is normal'),
          L3(en: 'It can take 15-20 exposures before a child accepts a new food', ru: 'It can take 15-20 exposures before a child accepts a new food', ky: 'It can take 15-20 exposures before a child accepts a new food'),
          L3(en: 'Don\'t give up! Keep offering without pressure', ru: 'Don\'t give up! Keep offering without pressure', ky: 'Don\'t give up! Keep offering without pressure'),
          L3(en: 'Eat together as a family when possible — modeling is powerful', ru: 'Eat together as a family when possible — modeling is powerful', ky: 'Eat together as a family when possible — modeling is powerful'),
          L3(en: 'Toddler portion = roughly 1/4 of an adult portion', ru: 'Toddler portion = roughly 1/4 of an adult portion', ky: 'Toddler portion = roughly 1/4 of an adult portion'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not walk independently', ru: 'Does not walk independently', ky: 'Does not walk independently'),
        L3(en: 'Does not use at least 3 words', ru: 'Does not use at least 3 words', ky: 'Does not use at least 3 words'),
        L3(en: 'Does not point to show things', ru: 'Does not point to show things', ky: 'Does not point to show things'),
        L3(en: 'Does not follow simple instructions', ru: 'Does not follow simple instructions', ky: 'Does not follow simple instructions'),
        L3(en: 'Loses previously acquired skills', ru: 'Loses previously acquired skills', ky: 'Loses previously acquired skills'),
        L3(en: 'Does not imitate others', ru: 'Does not imitate others', ky: 'Does not imitate others'),
      ],
      parentTips: [
        L3(en: 'Tantrums are not personal. Stay calm. You are the rock.', ru: 'Tantrums are not personal. Stay calm. You are the rock.', ky: 'Tantrums are not personal. Stay calm. You are the rock.'),
        L3(en: 'Offer choices: "Red shirt or blue shirt?" — it reduces power struggles', ru: 'Offer choices: "Red shirt or blue shirt?" — it reduces power struggles', ky: 'Offer choices: "Red shirt or blue shirt?" — it reduces power struggles'),
        L3(en: 'Name their emotions: "You\'re frustrated because..." — builds emotional vocabulary', ru: 'Name their emotions: "You\'re frustrated because..." — builds emotional vocabulary', ky: 'Name their emotions: "You\'re frustrated because..." — builds emotional vocabulary'),
        L3(en: 'Toddler-proofing is a continuous process — they find new dangers weekly', ru: 'Toddler-proofing is a continuous process — they find new dangers weekly', ky: 'Toddler-proofing is a continuous process — they find new dangers weekly'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '15 month well-visit', ru: '15 month well-visit', ky: '15 month well-visit'),
        vaccines: [L3(en: 'DTaP — booster (dose 4)', ru: 'DTaP — booster (dose 4)', ky: 'DTaP — booster (dose 4)'), L3(en: 'Hib — booster', ru: 'Hib — booster', ky: 'Hib — booster')],
        screenings: [L3(en: 'Developmental screening', ru: 'Developmental screening', ky: 'Developmental screening'), L3(en: 'Growth assessment', ru: 'Growth assessment', ky: 'Growth assessment')],
      ),
    ),

    // =========================================================
    // 18 MONTHS
    // =========================================================
    18: BabyMonthData(
      month: 18,
      title: const L3(en: 'The Talker', ru: 'Болтун', ky: 'Сүйлөгүч'),
      emoji: '🗣️',
      avgWeightKgBoy: 10.9,
      avgWeightKgGirl: 10.2,
      avgHeightCmBoy: 82.3,
      avgHeightCmGirl: 80.7,
      physicalDevelopment:
          L3(
        en: 'Walking is confident; running begins. Toddler can walk up stairs holding your hand.  They kick a ball forward. Fine motor skills allow them to stack 4+ blocks,  scribble with crayons, and turn single pages of a book.',
        ru: 'Walking is confident; running begins. Toddler can walk up stairs holding your hand.  They kick a ball forward. Fine motor skills allow them to stack 4+ blocks,  scribble with crayons, and turn single pages of a book.',
        ky: 'Walking is confident; running begins. Toddler can walk up stairs holding your hand.  They kick a ball forward. Fine motor skills allow them to stack 4+ blocks,  scribble with crayons, and turn single pages of a book.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Symbolic thinking explodes — a box becomes a car, a stick becomes a sword.  Toddler can sort shapes and colors. They understand "mine" (the beginning of ownership).  Memory is strong — they remember where things are kept and routines in detail.',
        ru: 'Symbolic thinking explodes — a box becomes a car, a stick becomes a sword.  Toddler can sort shapes and colors. They understand "mine" (the beginning of ownership).  Memory is strong — they remember where things are kept and routines in detail.',
        ky: 'Symbolic thinking explodes — a box becomes a car, a stick becomes a sword.  Toddler can sort shapes and colors. They understand "mine" (the beginning of ownership).  Memory is strong — they remember where things are kept and routines in detail.',
      ),
      socialEmotional:
          L3(
        en: 'The word "NO!" becomes a favorite. Autonomy is the driving force.  Toddler shows pride when they accomplish something and frustration when they can\'t.  They may hit, bite, or throw things — not out of malice, but out of overwhelming emotions.',
        ru: 'The word "NO!" becomes a favorite. Autonomy is the driving force.  Toddler shows pride when they accomplish something and frustration when they can\'t.  They may hit, bite, or throw things — not out of malice, but out of overwhelming emotions.',
        ky: 'The word "NO!" becomes a favorite. Autonomy is the driving force.  Toddler shows pride when they accomplish something and frustration when they can\'t.  They may hit, bite, or throw things — not out of malice, but out of overwhelming emotions.',
      ),
      languageDevelopment:
          L3(
        en: 'Vocabulary explosion begins! Toddler knows 20-50 words and is learning new ones daily.  They start combining 2 words: "more milk," "daddy go," "big dog."  They can point to pictures in books when you name them.',
        ru: 'Vocabulary explosion begins! Toddler knows 20-50 words and is learning new ones daily.  They start combining 2 words: "more milk," "daddy go," "big dog."  They can point to pictures in books when you name them.',
        ky: 'Vocabulary explosion begins! Toddler knows 20-50 words and is learning new ones daily.  They start combining 2 words: "more milk," "daddy go," "big dog."  They can point to pictures in books when you name them.',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Runs (wobbly but intentional)', ru: 'Runs (wobbly but intentional)', ky: 'Runs (wobbly but intentional)'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Kicks a ball forward', ru: 'Kicks a ball forward', ky: 'Kicks a ball forward'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Walks up stairs with hand held', ru: 'Walks up stairs with hand held', ky: 'Walks up stairs with hand held'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 20-50 words', ru: 'Uses 20-50 words', ky: 'Uses 20-50 words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Combines 2 words together', ru: 'Combines 2 words together', ky: 'Combines 2 words together'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Points to pictures in books', ru: 'Points to pictures in books', ky: 'Points to pictures in books'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Pretend play (feeding a doll, driving a car)', ru: 'Pretend play (feeding a doll, driving a car)', ky: 'Pretend play (feeding a doll, driving a car)'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Sorts shapes or colors', ru: 'Sorts shapes or colors', ky: 'Sorts shapes or colors'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Shows defiance — says "no!"', ru: 'Shows defiance — says "no!"', ky: 'Shows defiance — says "no!"'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Uses spoon and fork with some spilling', ru: 'Uses spoon and fork with some spilling', ky: 'Uses spoon and fork with some spilling'), MilestoneCategory.feeding),
      ],
      activities: [
        L3(en: 'Pretend play: toy kitchen, doctor kit, shopping, cleaning', ru: 'Pretend play: toy kitchen, doctor kit, shopping, cleaning', ky: 'Pretend play: toy kitchen, doctor kit, shopping, cleaning'),
        L3(en: 'Simple shape sorters and chunky puzzles (4-6 pieces)', ru: 'Simple shape sorters and chunky puzzles (4-6 pieces)', ky: 'Simple shape sorters and chunky puzzles (4-6 pieces)'),
        L3(en: 'Arts and crafts: stamp pads, dot markers, stickers, play dough', ru: 'Arts and crafts: stamp pads, dot markers, stickers, play dough', ky: 'Arts and crafts: stamp pads, dot markers, stickers, play dough'),
        L3(en: 'Outdoor: climbing structures, tricycle (push with feet), sandbox', ru: 'Outdoor: climbing structures, tricycle (push with feet), sandbox', ky: 'Outdoor: climbing structures, tricycle (push with feet), sandbox'),
        L3(en: 'Music: rhythm instruments (drums, maracas, tambourine)', ru: 'Music: rhythm instruments (drums, maracas, tambourine)', ky: 'Music: rhythm instruments (drums, maracas, tambourine)'),
        L3(en: 'Sorting games: by color, shape, or size', ru: 'Sorting games: by color, shape, or size', ky: 'Sorting games: by color, shape, or size'),
        L3(en: 'Build towers and let toddler knock them down', ru: 'Build towers and let toddler knock them down', ky: 'Build towers and let toddler knock them down'),
        L3(en: 'Ask "what\'s this?" while reading — let them point and name', ru: 'Ask "what\'s this?" while reading — let them point and name', ky: 'Ask "what\'s this?" while reading — let them point and name'),
        L3(en: 'Simple chores: putting toys in a bin, wiping surfaces', ru: 'Simple chores: putting toys in a bin, wiping surfaces', ky: 'Simple chores: putting toys in a bin, wiping surfaces'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-12 hours at night, 1 nap (1.5-3 hours).', ru: '10-12 hours at night, 1 nap (1.5-3 hours).', ky: '10-12 hours at night, 1 nap (1.5-3 hours).'),
        tips: [
          L3(en: 'The 18-month sleep regression is often the toughest — caused by language explosion + autonomy', ru: 'The 18-month sleep regression is often the toughest — caused by language explosion + autonomy', ky: 'The 18-month sleep regression is often the toughest — caused by language explosion + autonomy'),
          L3(en: 'Toddler may start climbing out of the crib — consider safety before switching to a bed', ru: 'Toddler may start climbing out of the crib — consider safety before switching to a bed', ky: 'Toddler may start climbing out of the crib — consider safety before switching to a bed'),
          L3(en: 'Bedtime stalling tactics begin: "one more book," "water," "potty"', ru: 'Bedtime stalling tactics begin: "one more book," "water," "potty"', ky: 'Bedtime stalling tactics begin: "one more book," "water," "potty"'),
          L3(en: 'Set clear, kind limits: "Two books, one song, then sleep"', ru: 'Set clear, kind limits: "Two books, one song, then sleep"', ky: 'Set clear, kind limits: "Two books, one song, then sleep"'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods + whole milk (or continued breastfeeding)', ru: 'Family foods + whole milk (or continued breastfeeding)', ky: 'Family foods + whole milk (or continued breastfeeding)'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Milk: 360-480ml. Varied diet including all food groups.', ru: 'Milk: 360-480ml. Varied diet including all food groups.', ky: 'Milk: 360-480ml. Varied diet including all food groups.'),
        tips: [
          L3(en: 'Let toddler self-feed as much as possible — even if it\'s messy', ru: 'Let toddler self-feed as much as possible — even if it\'s messy', ky: 'Let toddler self-feed as much as possible — even if it\'s messy'),
          L3(en: 'Serve deconstructed meals — toddlers like to see individual ingredients', ru: 'Serve deconstructed meals — toddlers like to see individual ingredients', ky: 'Serve deconstructed meals — toddlers like to see individual ingredients'),
          L3(en: 'Don\'t short-order cook. Offer what the family eats + 1-2 safe foods', ru: 'Don\'t short-order cook. Offer what the family eats + 1-2 safe foods', ky: 'Don\'t short-order cook. Offer what the family eats + 1-2 safe foods'),
          L3(en: 'Dips make everything more appealing: hummus, yogurt, guacamole', ru: 'Dips make everything more appealing: hummus, yogurt, guacamole', ky: 'Dips make everything more appealing: hummus, yogurt, guacamole'),
          L3(en: 'Smoothies are great for hiding vegetables', ru: 'Smoothies are great for hiding vegetables', ky: 'Smoothies are great for hiding vegetables'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not use at least 10 words', ru: 'Does not use at least 10 words', ky: 'Does not use at least 10 words'),
        L3(en: 'Does not walk well', ru: 'Does not walk well', ky: 'Does not walk well'),
        L3(en: 'Does not point to show you things', ru: 'Does not point to show you things', ky: 'Does not point to show you things'),
        L3(en: 'Does not copy others', ru: 'Does not copy others', ky: 'Does not copy others'),
        L3(en: 'Does not gain new words', ru: 'Does not gain new words', ky: 'Does not gain new words'),
        L3(en: 'Does not notice when a caregiver leaves or returns', ru: 'Does not notice when a caregiver leaves or returns', ky: 'Does not notice when a caregiver leaves or returns'),
        L3(en: 'Loses skills they used to have', ru: 'Loses skills they used to have', ky: 'Loses skills they used to have'),
      ],
      parentTips: [
        L3(en: 'The "terrible twos" often start at 18 months. It\'s really the "terrific toddler brain explosion"', ru: 'The "terrible twos" often start at 18 months. It\'s really the "terrific toddler brain explosion"', ky: 'The "terrible twos" often start at 18 months. It\'s really the "terrific toddler brain explosion"'),
        L3(en: 'Give transition warnings: "5 more minutes, then we leave the park"', ru: 'Give transition warnings: "5 more minutes, then we leave the park"', ky: 'Give transition warnings: "5 more minutes, then we leave the park"'),
        L3(en: 'Validate emotions first, redirect behavior second', ru: 'Validate emotions first, redirect behavior second', ky: 'Validate emotions first, redirect behavior second'),
        L3(en: '"I see you\'re angry. I won\'t let you hit. You can stomp your feet."', ru: '"I see you\'re angry. I won\'t let you hit. You can stomp your feet."', ky: '"I see you\'re angry. I won\'t let you hit. You can stomp your feet."'),
        L3(en: 'This is one of the most exhausting AND most magical ages', ru: 'This is one of the most exhausting AND most magical ages', ky: 'This is one of the most exhausting AND most magical ages'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '18 month well-visit', ru: '18 month well-visit', ky: '18 month well-visit'),
        vaccines: [L3(en: 'Hepatitis A — dose 2', ru: 'Hepatitis A — dose 2', ky: 'Hepatitis A — dose 2')],
        screenings: [L3(en: 'Autism screening (M-CHAT-R) — very important at this age', ru: 'Autism screening (M-CHAT-R) — very important at this age', ky: 'Autism screening (M-CHAT-R) — very important at this age'), L3(en: 'Developmental screening', ru: 'Developmental screening', ky: 'Developmental screening'), L3(en: 'Growth assessment', ru: 'Growth assessment', ky: 'Growth assessment')],
      ),
    ),

    // =========================================================
    // 24 MONTHS — HAPPY SECOND BIRTHDAY!
    // =========================================================
    24: BabyMonthData(
      month: 24,
      title: const L3(en: 'Two Years of Wonder', ru: 'Два года чудес', ky: 'Эки жыл керемет'),
      emoji: '🎉',
      avgWeightKgBoy: 12.2,
      avgWeightKgGirl: 11.5,
      avgHeightCmBoy: 87.8,
      avgHeightCmGirl: 86.4,
      physicalDevelopment:
          L3(
        en: 'Running is confident. Toddler can jump with both feet off the ground.  They walk up and down stairs holding a railing. They can kick a ball with aim.  Fine motor: draws lines and circles, stacks 6+ blocks, turns doorknobs, unscrews lids.',
        ru: 'Running is confident. Toddler can jump with both feet off the ground.  They walk up and down stairs holding a railing. They can kick a ball with aim.  Fine motor: draws lines and circles, stacks 6+ blocks, turns doorknobs, unscrews lids.',
        ky: 'Running is confident. Toddler can jump with both feet off the ground.  They walk up and down stairs holding a railing. They can kick a ball with aim.  Fine motor: draws lines and circles, stacks 6+ blocks, turns doorknobs, unscrews lids.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Imagination is in full bloom — elaborate pretend play with storylines.  Toddler can complete simple puzzles (4-6 pieces). They understand concepts like "big/small,"  "in/out," "hot/cold." They can sort by shape and color. Memory is excellent.',
        ru: 'Imagination is in full bloom — elaborate pretend play with storylines.  Toddler can complete simple puzzles (4-6 pieces). They understand concepts like "big/small,"  "in/out," "hot/cold." They can sort by shape and color. Memory is excellent.',
        ky: 'Imagination is in full bloom — elaborate pretend play with storylines.  Toddler can complete simple puzzles (4-6 pieces). They understand concepts like "big/small,"  "in/out," "hot/cold." They can sort by shape and color. Memory is excellent.',
      ),
      socialEmotional:
          L3(
        en: 'Toddler is developing a sense of self — they recognize themselves in the mirror and photos.  They play alongside other children and may start sharing (briefly).  Emotions are BIG but they\'re learning to regulate with your help.  Defiance is a sign of healthy independence, not bad behavior.',
        ru: 'Toddler is developing a sense of self — they recognize themselves in the mirror and photos.  They play alongside other children and may start sharing (briefly).  Emotions are BIG but they\'re learning to regulate with your help.  Defiance is a sign of healthy independence, not bad behavior.',
        ky: 'Toddler is developing a sense of self — they recognize themselves in the mirror and photos.  They play alongside other children and may start sharing (briefly).  Emotions are BIG but they\'re learning to regulate with your help.  Defiance is a sign of healthy independence, not bad behavior.',
      ),
      languageDevelopment:
          L3(
        en: 'Vocabulary is 200-300+ words. Toddler uses 2-3 word sentences regularly:  "I want milk," "Daddy go work," "More apple please."  They ask "What\'s that?" constantly. Strangers can understand about 50% of speech.  They start using pronouns: "I," "me," "you."',
        ru: 'Vocabulary is 200-300+ words. Toddler uses 2-3 word sentences regularly:  "I want milk," "Daddy go work," "More apple please."  They ask "What\'s that?" constantly. Strangers can understand about 50% of speech.  They start using pronouns: "I," "me," "you."',
        ky: 'Vocabulary is 200-300+ words. Toddler uses 2-3 word sentences regularly:  "I want milk," "Daddy go work," "More apple please."  They ask "What\'s that?" constantly. Strangers can understand about 50% of speech.  They start using pronouns: "I," "me," "you."',
      ),
      milestones: [
        MilestoneItem(L3(en: 'Runs confidently', ru: 'Runs confidently', ky: 'Runs confidently'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Jumps with both feet', ru: 'Jumps with both feet', ky: 'Jumps with both feet'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Walks up and down stairs', ru: 'Walks up and down stairs', ky: 'Walks up and down stairs'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 200-300+ words', ru: 'Uses 200-300+ words', ky: 'Uses 200-300+ words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Speaks in 2-3 word sentences', ru: 'Speaks in 2-3 word sentences', ky: 'Speaks in 2-3 word sentences'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Follows 2-step instructions', ru: 'Follows 2-step instructions', ky: 'Follows 2-step instructions'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Engages in pretend play with storylines', ru: 'Engages in pretend play with storylines', ky: 'Engages in pretend play with storylines'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Sorts shapes and colors', ru: 'Sorts shapes and colors', ky: 'Sorts shapes and colors'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Shows interest in other children', ru: 'Shows interest in other children', ky: 'Shows interest in other children'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Expresses many emotions', ru: 'Expresses many emotions', ky: 'Expresses many emotions'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'May show readiness for potty training', ru: 'May show readiness for potty training', ky: 'May show readiness for potty training'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Draws lines and circles', ru: 'Draws lines and circles', ky: 'Draws lines and circles'), MilestoneCategory.motor),
      ],
      activities: [
        L3(en: 'Elaborate pretend play: store, restaurant, school, doctor, construction', ru: 'Elaborate pretend play: store, restaurant, school, doctor, construction', ky: 'Elaborate pretend play: store, restaurant, school, doctor, construction'),
        L3(en: 'Puzzles: 4-12 pieces, matching games, memory games', ru: 'Puzzles: 4-12 pieces, matching games, memory games', ky: 'Puzzles: 4-12 pieces, matching games, memory games'),
        L3(en: 'Arts: painting, collage, stickers, play dough with tools', ru: 'Arts: painting, collage, stickers, play dough with tools', ky: 'Arts: painting, collage, stickers, play dough with tools'),
        L3(en: 'Physical: playground climbing, tricycle, balance beam, ball games', ru: 'Physical: playground climbing, tricycle, balance beam, ball games', ky: 'Physical: playground climbing, tricycle, balance beam, ball games'),
        L3(en: 'Building: larger block structures, train tracks, simple LEGO DUPLO', ru: 'Building: larger block structures, train tracks, simple LEGO DUPLO', ky: 'Building: larger block structures, train tracks, simple LEGO DUPLO'),
        L3(en: 'Nature exploration: bugs, leaves, rocks, puddles, gardening', ru: 'Nature exploration: bugs, leaves, rocks, puddles, gardening', ky: 'Nature exploration: bugs, leaves, rocks, puddles, gardening'),
        L3(en: 'Social play: playdates with 1-2 other toddlers', ru: 'Social play: playdates with 1-2 other toddlers', ky: 'Social play: playdates with 1-2 other toddlers'),
        L3(en: 'Reading: ask "what happened?" and "how does the bear feel?"', ru: 'Reading: ask "what happened?" and "how does the bear feel?"', ky: 'Reading: ask "what happened?" and "how does the bear feel?"'),
        L3(en: 'Simple counting in daily life: "1, 2, 3 bananas!"', ru: 'Simple counting in daily life: "1, 2, 3 bananas!"', ky: 'Simple counting in daily life: "1, 2, 3 bananas!"'),
        L3(en: 'Singing: ABCs, counting songs, action songs', ru: 'Singing: ABCs, counting songs, action songs', ky: 'Singing: ABCs, counting songs, action songs'),
        L3(en: 'Early potty introduction if showing readiness signs', ru: 'Early potty introduction if showing readiness signs', ky: 'Early potty introduction if showing readiness signs'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-12 hours at night, 1 nap (1-2.5 hours). Some start resisting the nap.', ru: '10-12 hours at night, 1 nap (1-2.5 hours). Some start resisting the nap.', ky: '10-12 hours at night, 1 nap (1-2.5 hours). Some start resisting the nap.'),
        tips: [
          L3(en: 'Keep the nap! Most 2-year-olds still need it even if they resist', ru: 'Keep the nap! Most 2-year-olds still need it even if they resist', ky: 'Keep the nap! Most 2-year-olds still need it even if they resist'),
          L3(en: 'If nap is a battle, try "quiet time" in the crib/room for 1 hour minimum', ru: 'If nap is a battle, try "quiet time" in the crib/room for 1 hour minimum', ky: 'If nap is a battle, try "quiet time" in the crib/room for 1 hour minimum'),
          L3(en: 'The 2-year sleep regression is often tied to new skills (talking, climbing, potty)', ru: 'The 2-year sleep regression is often tied to new skills (talking, climbing, potty)', ky: 'The 2-year sleep regression is often tied to new skills (talking, climbing, potty)'),
          L3(en: 'If transitioning to a toddler bed, keep the routine exactly the same', ru: 'If transitioning to a toddler bed, keep the routine exactly the same', ky: 'If transitioning to a toddler bed, keep the routine exactly the same'),
          L3(en: 'Bedtime: consistent, boring, and non-negotiable. "Two books, one song, goodnight."', ru: 'Bedtime: consistent, boring, and non-negotiable. "Two books, one song, goodnight."', ky: 'Bedtime: consistent, boring, and non-negotiable. "Two books, one song, goodnight."'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods + milk (whole or 2%)', ru: 'Family foods + milk (whole or 2%)', ky: 'Family foods + milk (whole or 2%)'),
        frequency: L3(en: '3 meals + 2 snacks per day', ru: '3 meals + 2 snacks per day', ky: '3 meals + 2 snacks per day'),
        amount: L3(en: 'Milk: 360-480ml/day max. Balanced varied diet.', ru: 'Milk: 360-480ml/day max. Balanced varied diet.', ky: 'Milk: 360-480ml/day max. Balanced varied diet.'),
        tips: [
          L3(en: 'Toddlers are the pickiest eaters — this is developmentally normal', ru: 'Toddlers are the pickiest eaters — this is developmentally normal', ky: 'Toddlers are the pickiest eaters — this is developmentally normal'),
          L3(en: 'Keep offering rejected foods without pressure — 15-20 exposures!', ru: 'Keep offering rejected foods without pressure — 15-20 exposures!', ky: 'Keep offering rejected foods without pressure — 15-20 exposures!'),
          L3(en: 'Involve toddler in meal prep: stirring, washing vegetables, choosing fruit', ru: 'Involve toddler in meal prep: stirring, washing vegetables, choosing fruit', ky: 'Involve toddler in meal prep: stirring, washing vegetables, choosing fruit'),
          L3(en: 'Family meals matter — eat together as often as possible', ru: 'Family meals matter — eat together as often as possible', ky: 'Family meals matter — eat together as often as possible'),
          L3(en: 'Switch from whole milk to 2% after age 2', ru: 'Switch from whole milk to 2% after age 2', ky: 'Switch from whole milk to 2% after age 2'),
          L3(en: 'Limit juice to 120ml/day (or skip it entirely)', ru: 'Limit juice to 120ml/day (or skip it entirely)', ky: 'Limit juice to 120ml/day (or skip it entirely)'),
          L3(en: 'Model healthy eating — they watch everything you do', ru: 'Model healthy eating — they watch everything you do', ky: 'Model healthy eating — they watch everything you do'),
          L3(en: 'May be ready for potty training — watch for signs of readiness', ru: 'May be ready for potty training — watch for signs of readiness', ky: 'May be ready for potty training — watch for signs of readiness'),
        ],
      ),
      redFlags: [
        L3(en: 'Does not use 2-word phrases', ru: 'Does not use 2-word phrases', ky: 'Does not use 2-word phrases'),
        L3(en: 'Does not use at least 50 words', ru: 'Does not use at least 50 words', ky: 'Does not use at least 50 words'),
        L3(en: 'Does not follow simple instructions', ru: 'Does not follow simple instructions', ky: 'Does not follow simple instructions'),
        L3(en: 'Does not walk steadily', ru: 'Does not walk steadily', ky: 'Does not walk steadily'),
        L3(en: 'Does not copy actions or words', ru: 'Does not copy actions or words', ky: 'Does not copy actions or words'),
        L3(en: 'Loses skills they had before', ru: 'Loses skills they had before', ky: 'Loses skills they had before'),
        L3(en: 'Does not show interest in other children', ru: 'Does not show interest in other children', ky: 'Does not show interest in other children'),
        L3(en: 'Does not point to things in a book', ru: 'Does not point to things in a book', ky: 'Does not point to things in a book'),
        L3(en: 'Does not know what common objects are for (phone, brush, spoon)', ru: 'Does not know what common objects are for (phone, brush, spoon)', ky: 'Does not know what common objects are for (phone, brush, spoon)'),
      ],
      parentTips: [
        L3(en: 'Happy birthday to your toddler! You survived the first two years. You\'re a champion.', ru: 'Happy birthday to your toddler! You survived the first two years. You\'re a champion.', ky: 'Happy birthday to your toddler! You survived the first two years. You\'re a champion.'),
        L3(en: 'The "terrible twos" are really about a developing brain that wants independence but lacks impulse control', ru: 'The "terrible twos" are really about a developing brain that wants independence but lacks impulse control', ky: 'The "terrible twos" are really about a developing brain that wants independence but lacks impulse control'),
        L3(en: 'Give yourself grace — parenting a toddler is relentless. Ask for help.', ru: 'Give yourself grace — parenting a toddler is relentless. Ask for help.', ky: 'Give yourself grace — parenting a toddler is relentless. Ask for help.'),
        L3(en: 'Start thinking about preschool readiness: social skills, following routines, self-help skills', ru: 'Start thinking about preschool readiness: social skills, following routines, self-help skills', ky: 'Start thinking about preschool readiness: social skills, following routines, self-help skills'),
        L3(en: 'They learn more from watching you than from anything you teach them directly', ru: 'They learn more from watching you than from anything you teach them directly', ky: 'They learn more from watching you than from anything you teach them directly'),
        L3(en: 'Document their wild sentences — you\'ll want to remember "I want moon" and "More happy please"', ru: 'Document their wild sentences — you\'ll want to remember "I want moon" and "More happy please"', ky: 'Document their wild sentences — you\'ll want to remember "I want moon" and "More happy please"'),
        L3(en: 'You are raising the next generation of leaders. Every hug, every boundary, every bedtime story matters.', ru: 'You are raising the next generation of leaders. Every hug, every boundary, every bedtime story matters.', ky: 'You are raising the next generation of leaders. Every hug, every boundary, every bedtime story matters.'),
      ],
      checkup: const HealthCheckup(
        timing: L3(en: '24 month (2 year) well-visit', ru: '24 month (2 year) well-visit', ky: '24 month (2 year) well-visit'),
        vaccines: [L3(en: 'DTaP — dose 5 (4-6 years)', ru: 'DTaP — dose 5 (4-6 years)', ky: 'DTaP — dose 5 (4-6 years)'), L3(en: 'Hepatitis A — dose 2 (if not completed)', ru: 'Hepatitis A — dose 2 (if not completed)', ky: 'Hepatitis A — dose 2 (if not completed)')],
        screenings: [
          L3(en: 'Autism screening (M-CHAT-R) — second screening', ru: 'Autism screening (M-CHAT-R) — second screening', ky: 'Autism screening (M-CHAT-R) — second screening'),
          L3(en: 'Developmental screening', ru: 'Developmental screening', ky: 'Developmental screening'),
          L3(en: 'Growth assessment and BMI', ru: 'Growth assessment and BMI', ky: 'Growth assessment and BMI'),
          L3(en: 'Dental referral if not already seeing a dentist', ru: 'Dental referral if not already seeing a dentist', ky: 'Dental referral if not already seeing a dentist'),
          L3(en: 'Vision screening', ru: 'Vision screening', ky: 'Vision screening'),
          L3(en: 'Lead screening', ru: 'Lead screening', ky: 'Lead screening'),
        ],
      ),
    ),

    // =====================================================
    // INFANCY fill-ins (5, 7, 8, 10, 11 months)
    // =====================================================
    5: BabyMonthData(
      month: 5,
      title: const L3(en: 'Rolling & Grabbing', ru: 'Переворачиваемся и хватаем', ky: 'Оодарылуу жана кармоо'),
      emoji: '🤸',
      avgWeightKgBoy: 7.5,
      avgWeightKgGirl: 6.9,
      avgHeightCmBoy: 65.9,
      avgHeightCmGirl: 64.0,
      physicalDevelopment:
          L3(
        en: 'Baby rolls both ways. Head control is excellent. They may sit with lots of support. Reaching and grabbing everything is their new superpower.',
        ru: 'Baby rolls both ways. Head control is excellent. They may sit with lots of support. Reaching and grabbing everything is their new superpower.',
        ky: 'Baby rolls both ways. Head control is excellent. They may sit with lots of support. Reaching and grabbing everything is their new superpower.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Recognizes their name. Understands object permanence partially. Shows curiosity about surroundings. May start to anticipate feedings/routines.',
        ru: 'Recognizes their name. Understands object permanence partially. Shows curiosity about surroundings. May start to anticipate feedings/routines.',
        ky: 'Recognizes their name. Understands object permanence partially. Shows curiosity about surroundings. May start to anticipate feedings/routines.',
      ),
      socialEmotional:
          L3(
        en: 'Laughs and squeals. Knows familiar faces. May show stranger awareness starting. Wants attention and social interaction constantly.',
        ru: 'Laughs and squeals. Knows familiar faces. May show stranger awareness starting. Wants attention and social interaction constantly.',
        ky: 'Laughs and squeals. Knows familiar faces. May show stranger awareness starting. Wants attention and social interaction constantly.',
      ),
      languageDevelopment:
          L3(
        en: 'Babbles with more consonants ("ba," "da," "ga"). Squeals in delight. Responds to your tone. Blows raspberries.',
        ru: 'Babbles with more consonants ("ba," "da," "ga"). Squeals in delight. Responds to your tone. Blows raspberries.',
        ky: 'Babbles with more consonants ("ba," "da," "ga"). Squeals in delight. Responds to your tone. Blows raspberries.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Rolls both directions consistently', ru: 'Rolls both directions consistently', ky: 'Rolls both directions consistently'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Reaches accurately for objects', ru: 'Reaches accurately for objects', ky: 'Reaches accurately for objects'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Brings everything to mouth', ru: 'Brings everything to mouth', ky: 'Brings everything to mouth'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Responds to own name', ru: 'Responds to own name', ky: 'Responds to own name'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Laughs out loud', ru: 'Laughs out loud', ky: 'Laughs out loud'), MilestoneCategory.social),
      ],
      activities: const [
        L3(en: 'Supervised tummy time with toys just out of reach', ru: 'Supervised tummy time with toys just out of reach', ky: 'Supervised tummy time with toys just out of reach'),
        L3(en: 'High-contrast books and mirror play', ru: 'High-contrast books and mirror play', ky: 'High-contrast books and mirror play'),
        L3(en: 'Rattles and sensory toys to explore textures', ru: 'Rattles and sensory toys to explore textures', ky: 'Rattles and sensory toys to explore textures'),
        L3(en: 'Sing songs with hand motions', ru: 'Sing songs with hand motions', ky: 'Sing songs with hand motions'),
        L3(en: 'Read aloud daily — even if it\'s the same book', ru: 'Read aloud daily — even if it\'s the same book', ky: 'Read aloud daily — even if it\'s the same book'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-16 hours',
        pattern: L3(en: '10-11h at night with 1-2 wakes. 3 naps (morning, midday, late afternoon).', ru: '10-11h at night with 1-2 wakes. 3 naps (morning, midday, late afternoon).', ky: '10-11h at night with 1-2 wakes. 3 naps (morning, midday, late afternoon).'),
        tips: [
          L3(en: '4-month sleep regression may continue or resolve', ru: '4-month sleep regression may continue or resolve', ky: '4-month sleep regression may continue or resolve'),
          L3(en: 'Start introducing a gentle bedtime routine', ru: 'Start introducing a gentle bedtime routine', ky: 'Start introducing a gentle bedtime routine'),
          L3(en: 'Dark room, white noise, consistent wind-down helps', ru: 'Dark room, white noise, consistent wind-down helps', ky: 'Dark room, white noise, consistent wind-down helps'),
          L3(en: 'Some babies sleep through the night, many don\'t — both are normal', ru: 'Some babies sleep through the night, many don\'t — both are normal', ky: 'Some babies sleep through the night, many don\'t — both are normal'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Breast milk or formula still primary', ru: 'Breast milk or formula still primary', ky: 'Breast milk or formula still primary'),
        frequency: L3(en: '5-6 feeds per day', ru: '5-6 feeds per day', ky: '5-6 feeds per day'),
        amount: L3(en: '180-240ml per bottle feed', ru: '180-240ml per bottle feed', ky: '180-240ml per bottle feed'),
        tips: [
          L3(en: 'Most babies NOT ready for solids until 6 months', ru: 'Most babies NOT ready for solids until 6 months', ky: 'Most babies NOT ready for solids until 6 months'),
          L3(en: 'Watch for readiness signs: sits with support, interested in food', ru: 'Watch for readiness signs: sits with support, interested in food', ky: 'Watch for readiness signs: sits with support, interested in food'),
          L3(en: 'No water before 6 months (except tiny sips for teething)', ru: 'No water before 6 months (except tiny sips for teething)', ky: 'No water before 6 months (except tiny sips for teething)'),
          L3(en: 'Solids before 6 months can displace vital milk calories', ru: 'Solids before 6 months can displace vital milk calories', ky: 'Solids before 6 months can displace vital milk calories'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not roll in either direction', ru: 'Does not roll in either direction', ky: 'Does not roll in either direction'),
        L3(en: 'Does not smile or laugh', ru: 'Does not smile or laugh', ky: 'Does not smile or laugh'),
        L3(en: 'Does not hold head up during tummy time', ru: 'Does not hold head up during tummy time', ky: 'Does not hold head up during tummy time'),
        L3(en: 'Does not reach for objects', ru: 'Does not reach for objects', ky: 'Does not reach for objects'),
        L3(en: 'Does not babble or make sounds', ru: 'Does not babble or make sounds', ky: 'Does not babble or make sounds'),
      ],
      parentTips: const [
        L3(en: 'Prep your kitchen for starting solids soon', ru: 'Prep your kitchen for starting solids soon', ky: 'Prep your kitchen for starting solids soon'),
        L3(en: 'Research baby-led weaning vs purees (both are valid)', ru: 'Research baby-led weaning vs purees (both are valid)', ky: 'Research baby-led weaning vs purees (both are valid)'),
        L3(en: 'High chair time to practice sitting', ru: 'High chair time to practice sitting', ky: 'High chair time to practice sitting'),
        L3(en: 'Your baby is paying attention to everything you do', ru: 'Your baby is paying attention to everything you do', ky: 'Your baby is paying attention to everything you do'),
      ],
    ),

    7: BabyMonthData(
      month: 7,
      title: const L3(en: 'Sitting & Exploring', ru: 'Сидим и исследуем', ky: 'Отуруу жана изилдөө'),
      emoji: '🪑',
      avgWeightKgBoy: 8.3,
      avgWeightKgGirl: 7.6,
      avgHeightCmBoy: 69.2,
      avgHeightCmGirl: 67.3,
      physicalDevelopment: const L3(
        en: 'Sits independently without hands for support. May rock on hands and knees (pre-crawl). Can pass objects from one hand to the other. Pincer grasp developing.',
        ru: 'Сидит самостоятельно без опоры на руки. Может раскачиваться на четвереньках (подготовка к ползанию). Перекладывает предметы из руки в руку. Пинцетный захват развивается.',
        ky: 'Колдоруна таянбай өз алдынча отурат. Колу менен тизесинде тепренип баштайт (эмгектөөгө даярдык). Буюмдарды бир колдон экинчисине өткөрөт. Чымчуу кармоо өнүгүүдө.',
      ),
      cognitiveDevelopment: const L3(
        en: 'Strong sense of object permanence. Looks for dropped items. Explores objects with all senses. Understands simple cause and effect.',
        ru: 'Устойчивое понимание постоянства объектов. Ищет упавшие предметы. Исследует предметы всеми органами чувств. Понимает простую причинно-следственную связь.',
        ky: 'Объекттин туруктуулугун жакшы түшүнөт. Түшүрүлгөн буюмдарды издейт. Буюмдарды бардык сезим органдары менен изилдейт. Жөнөкөй себеп-натыйжа байланышын түшүнөт.',
      ),
      socialEmotional: const L3(
        en: 'Clear stranger anxiety. Prefers primary caregivers. Enjoys peek-a-boo. May have favorite toys or comfort items.',
        ru: 'Выраженная боязнь чужих. Предпочитает основных воспитателей. Любит «ку-ку». Может иметь любимые игрушки или предметы для утешения.',
        ky: 'Бөтөн адамдардан коркуу айкын. Негизги тарбиячыларды артык көрөт. «Баа-баа» оюнун жакшы көрөт. Сүйүктүү оюнчуктары же жубаткыч буюмдары болушу мүмкүн.',
      ),
      languageDevelopment: const L3(
        en: 'Babbles with variety. May imitate speech sounds. Responds to "no" (sometimes). Turns head to follow voices.',
        ru: 'Разнообразный лепет. Может подражать звукам речи. Реагирует на «нет» (иногда). Поворачивает голову на голоса.',
        ky: 'Ар түрдүү тилдешүү. Сүйлөө үндөрүнө туурашы мүмкүн. «Жок» деген сөзгө жооп берет (кээде). Үндөрдү ээрчип башын буруйт.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Sits without support', ru: 'Сидит без поддержки', ky: 'Колдоосуз отурат'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Transfers objects hand to hand', ru: 'Перекладывает предметы из руки в руку', ky: 'Буюмдарды колдон колго өткөрөт'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Babbles with variety', ru: 'Разнообразный лепет', ky: 'Ар түрдүү тилдешүү'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Looks for dropped objects', ru: 'Ищет упавшие предметы', ky: 'Түшүп кеткен буюмдарды издейт'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Shows stranger anxiety', ru: 'Боится незнакомцев', ky: 'Бөтөн адамдардан коркот'), MilestoneCategory.social),
      ],
      activities: const [
        L3(en: 'Sitting play with lots of toys within reach', ru: 'Игра сидя с множеством игрушек в пределах досягаемости', ky: 'Кол жеткен жерде көп оюнчук менен отуруп ойноо'),
        L3(en: 'Simple games: peek-a-boo, pat-a-cake', ru: 'Простые игры: «ку-ку», «ладушки»', ky: 'Жөнөкөй оюндар: «баа-баа», «алакан»'),
        L3(en: 'Safe exploration zone on floor', ru: 'Безопасная зона для исследования на полу', ky: 'Жерде коопсуз изилдөө аймагы'),
        L3(en: 'Finger foods to practice grasping (avoid choking hazards)', ru: 'Еда для пальцев для тренировки захвата (избегайте риска удушья)', ky: 'Кармоону машыктыруу үчүн манжа тамактар (тумчулуу коркунучунан сактаныңыз)'),
        L3(en: 'Name body parts daily', ru: 'Ежедневно называйте части тела', ky: 'Күн сайын дене мүчөлөрүн атаңыз'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-15 hours',
        pattern: L3(en: '10-12h at night, 2-3 naps. Many babies drop to 2 naps this month.', ru: '10-12ч ночью, 2-3 дневных сна. Многие дети переходят на 2 сна в этом месяце.', ky: 'Түнкүсүн 10-12с, 2-3 күндүзгү уйку. Көп балдар бул айда 2 уйкуга өтүшөт.'),
        tips: [
          L3(en: 'Nap transition period — expect some crankiness', ru: 'Переходный период сна — ожидайте капризы', ky: 'Уйку өтмө мезгили — кыжырлануу күтүңүз'),
          L3(en: 'Separation anxiety may disrupt sleep', ru: 'Тревога разлуки может нарушить сон', ky: 'Ажыроо тынчсыздыгы уйкуну бузушу мүмкүн'),
          L3(en: 'Keep consistent bedtime routine', ru: 'Соблюдайте постоянный ритуал перед сном', ky: 'Уйку алдындагы тартипти сактаңыз'),
          L3(en: 'Brief crying is OK at bedtime', ru: 'Короткий плач перед сном — это нормально', ky: 'Уктар алдында кыска ыйлоо — бул нормалдуу'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Milk + solid foods 1-2x daily', ru: 'Молоко + прикорм 1-2 раза в день', ky: 'Сүт + кошумча тамак күнүнө 1-2 жолу'),
        frequency: L3(en: '4-5 milk feeds + 1-2 meals', ru: '4-5 молочных кормлений + 1-2 приёма пищи', ky: '4-5 сүт тамактандыруу + 1-2 тамак'),
        amount: L3(en: '180-240ml milk, 1-4 tablespoons solids', ru: '180-240 мл молока, 1-4 столовые ложки прикорма', ky: '180-240 мл сүт, 1-4 чоң кашык кошумча тамак'),
        tips: [
          L3(en: 'Introduce new foods one at a time', ru: 'Вводите новые продукты по одному', ky: 'Жаңы тамактарды бирден киргизиңиз'),
          L3(en: 'Offer iron-rich foods daily', ru: 'Предлагайте продукты, богатые железом, ежедневно', ky: 'Темирге бай тамактарды күн сайын сунуштаңыз'),
          L3(en: 'Watch for allergic reactions', ru: 'Следите за аллергическими реакциями', ky: 'Аллергиялык реакцияларды байкаңыз'),
          L3(en: 'Mealtime is messy learning — embrace it', ru: 'Еда — это грязное обучение, примите это', ky: 'Тамактануу — булганыч окуу, кабыл алыңыз'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not sit with support', ru: 'Не сидит даже с поддержкой', ky: 'Колдоо менен да отура албайт'),
        L3(en: 'Does not babble', ru: 'Не лепечет', ky: 'Тилдешпейт'),
        L3(en: 'Does not respond to own name', ru: 'Не реагирует на своё имя', ky: 'Өз атына жооп бербейт'),
        L3(en: 'Does not show interest in surroundings', ru: 'Не проявляет интереса к окружающему', ky: 'Айланасына кызыкчылык көрсөтпөйт'),
      ],
      parentTips: const [
        L3(en: 'Baby-proof everything at crawling level', ru: 'Обезопасьте всё на уровне ползания', ky: 'Эмгектөө деңгээлинде бардыгын коопсуз кылыңыз'),
        L3(en: 'This is a big social month — stranger anxiety is NORMAL', ru: 'Это важный социальный месяц — боязнь чужих НОРМАЛЬНА', ky: 'Бул чоң социалдык ай — бөтөн адамдардан коркуу КАДИМКИ'),
        L3(en: 'Don\'t force baby to go to unfamiliar people', ru: 'Не заставляйте ребёнка идти к незнакомым людям', ky: 'Баланы тааныбаган адамдарга мажбурлабаңыз'),
        L3(en: 'Take lots of photos — they change so fast', ru: 'Делайте много фотографий — они меняются так быстро', ky: 'Көп сүрөткө тартыңыз — алар абдан тез өзгөрүшөт'),
      ],
    ),

    8: BabyMonthData(
      month: 8,
      title: const L3(en: 'Crawling & Curious', ru: 'Ползаем и любопытничаем', ky: 'Эмгектөө жана кызыкчылык'),
      emoji: '🕷️',
      avgWeightKgBoy: 8.6,
      avgWeightKgGirl: 7.9,
      avgHeightCmBoy: 70.6,
      avgHeightCmGirl: 68.7,
      physicalDevelopment: const L3(
        en: 'Many babies crawl this month (though 9-10 is common too). Pulls to stand. Sits confidently. Pincer grasp refining. May cruise along furniture.',
        ru: 'Многие дети начинают ползать в этом месяце (хотя 9-10 месяцев тоже норма). Подтягивается и встаёт. Уверенно сидит. Пинцетный захват совершенствуется. Может передвигаться вдоль мебели.',
        ky: 'Көп балдар бул айда эмгектей баштайт (бирок 9-10 ай да кадимки). Кармалып турат. Ишенимдүү отурат. Чымчуу кармоо жакшырууда. Эмеректер боюнча жылышы мүмкүн.',
      ),
      cognitiveDevelopment: const L3(
        en: 'Understands simple words. Looks for hidden objects. Shows preferences for toys and people. Explores cause-effect constantly.',
        ru: 'Понимает простые слова. Ищет спрятанные предметы. Проявляет предпочтения к игрушкам и людям. Постоянно исследует причинно-следственные связи.',
        ky: 'Жөнөкөй сөздөрдү түшүнөт. Жашырылган буюмдарды издейт. Оюнчуктарга жана адамдарга артыкчылык көрсөтөт. Себеп-натыйжа байланышын тынымсыз изилдейт.',
      ),
      socialEmotional: const L3(
        en: 'Strong attachment to caregivers. Separation anxiety peaks. Mimics facial expressions. Plays social games actively.',
        ru: 'Сильная привязанность к воспитателям. Тревога разлуки достигает пика. Подражает выражениям лица. Активно играет в социальные игры.',
        ky: 'Тарбиячыларга күчтүү байланыш. Ажыроо тынчсыздыгы чокусуна жетет. Жүз мимикасын туурайт. Социалдык оюндарды жигердүү ойнойт.',
      ),
      languageDevelopment: const L3(
        en: '"Mama" and "dada" may emerge (not yet specific). Combines syllables. Responds to gestures like waving.',
        ru: '«Мама» и «папа» могут появиться (ещё не конкретно). Комбинирует слоги. Реагирует на жесты, например махание рукой.',
        ky: '«Мама» жана «папа» пайда болушу мүмкүн (азырынча конкреттүү эмес). Муундарды айкалыштырат. Кол булгалоо сыяктуу жаңсоолорго жооп берет.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Crawls or scoots', ru: 'Ползает или передвигается', ky: 'Эмгектейт же жылат'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Pulls up to standing', ru: 'Подтягивается и встаёт', ky: 'Кармалып турат'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses pincer grasp', ru: 'Использует пинцетный захват', ky: 'Чымчуу кармоону колдонот'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Says "mama"/"dada" non-specifically', ru: 'Говорит «мама»/«папа» неконкретно', ky: '«Мама»/«папа» деп конкреттүү эмес айтат'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Responds to own name consistently', ru: 'Стабильно реагирует на своё имя', ky: 'Өз атына туруктуу жооп берет'), MilestoneCategory.language),
      ],
      activities: const [
        L3(en: 'Create safe crawling spaces', ru: 'Создайте безопасные пространства для ползания', ky: 'Эмгектөө үчүн коопсуз мейкиндик түзүңүз'),
        L3(en: 'Stacking cups, soft blocks', ru: 'Стаканчики-пирамидки, мягкие кубики', ky: 'Чөйчөк пирамидалар, жумшак кубиктер'),
        L3(en: 'Cause-effect toys (buttons, lids, containers)', ru: 'Игрушки «причина-следствие» (кнопки, крышки, контейнеры)', ky: 'Себеп-натыйжа оюнчуктары (баскычтар, капкактар, идиштер)'),
        L3(en: 'Read picture books together', ru: 'Читайте книжки с картинками вместе', ky: 'Сүрөттүү китептерди бирге окуңуз'),
        L3(en: 'Sing songs with gestures', ru: 'Пойте песни с жестами', ky: 'Жаңсоолор менен ыр ырдаңыз'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-15 hours',
        pattern: L3(en: '10-12h at night, 2 naps (morning + afternoon).', ru: '10-12ч ночью, 2 дневных сна (утром + после обеда).', ky: 'Түнкүсүн 10-12с, 2 күндүзгү уйку (эртең + түштөн кийин).'),
        tips: [
          L3(en: '8-month sleep regression is real — hang in there', ru: 'Регресс сна в 8 месяцев реален — держитесь', ky: '8 айлык уйку регресси чыныгы — чыдаңыз'),
          L3(en: 'Milestones (crawling, standing) disrupt sleep', ru: 'Вехи развития (ползание, стояние) нарушают сон', ky: 'Өнүгүү жетишкендиктери (эмгектөө, туруу) уйкуну бузат'),
          L3(en: 'Consistency is more important than ever', ru: 'Последовательность важна как никогда', ky: 'Ырааттуулук мурдагыдан да маанилүүрөөк'),
          L3(en: 'Practice new skills during day, not in crib', ru: 'Тренируйте новые навыки днём, а не в кроватке', ky: 'Жаңы көндүмдөрдү күндүз машыктырыңыз, бешикте эмес'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Milk + solids 2-3x daily', ru: 'Молоко + прикорм 2-3 раза в день', ky: 'Сүт + кошумча тамак күнүнө 2-3 жолу'),
        frequency: L3(en: '4 milk feeds + 3 meals', ru: '4 молочных кормления + 3 приёма пищи', ky: '4 сүт тамактандыруу + 3 тамак'),
        amount: L3(en: '180-240ml milk, several tablespoons solids per meal', ru: '180-240 мл молока, несколько столовых ложек прикорма за приём', ky: '180-240 мл сүт, ар тамакка бир нече чоң кашык кошумча тамак'),
        tips: [
          L3(en: 'Offer a variety of textures now — not just purees', ru: 'Предлагайте разнообразные текстуры — не только пюре', ky: 'Ар түрдүү текстура сунуштаңыз — пюре гана эмес'),
          L3(en: 'Self-feeding with fingers builds skills', ru: 'Самостоятельная еда руками развивает навыки', ky: 'Манжалар менен өз алдынча тамактануу көндүмдөрдү өнүктүрөт'),
          L3(en: 'Water in an open/straw cup with meals', ru: 'Вода в открытой/трубочной чашке во время еды', ky: 'Тамак учурунда ачык/соргуч чөйчөктө суу'),
          L3(en: 'Don\'t add salt, sugar, or honey', ru: 'Не добавляйте соль, сахар или мёд', ky: 'Туз, кант же бал кошпоңуз'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not bear weight on legs', ru: 'Не опирается на ноги', ky: 'Буттарына салмак салбайт'),
        L3(en: 'Does not babble at all', ru: 'Совсем не лепечет', ky: 'Таптакыр тилдешпейт'),
        L3(en: 'Does not sit without support', ru: 'Не сидит без поддержки', ky: 'Колдоосуз отура албайт'),
        L3(en: 'Does not transfer toys hand to hand', ru: 'Не перекладывает игрушки из руки в руку', ky: 'Оюнчуктарды колдон колго өткөрбөйт'),
        L3(en: 'Does not show interest in others', ru: 'Не проявляет интерес к другим людям', ky: 'Башкаларга кызыкчылык көрсөтпөйт'),
      ],
      parentTips: const [
        L3(en: 'Put gates on stairs NOW', ru: 'Установите ворота на лестницы СЕЙЧАС', ky: 'Тепкичтерге дарбаза АЗЫР коюңуз'),
        L3(en: 'Secure heavy furniture to walls', ru: 'Прикрепите тяжёлую мебель к стенам', ky: 'Оор эмеректерди дубалдарга бекитиңиз'),
        L3(en: 'Cabinets need locks at this stage', ru: 'Шкафы нуждаются в замках на этом этапе', ky: 'Бул этапта шкафтарга кулпу керек'),
        L3(en: 'Peak separation anxiety — don\'t sneak out', ru: 'Пик тревоги разлуки — не уходите тайком', ky: 'Ажыроо тынчсыздыгынын чокусу — жашыруун кетпеңиз'),
      ],
    ),

    10: BabyMonthData(
      month: 10,
      title: const L3(en: 'Climbing & Cruising', ru: 'Карабкаемся и шагаем у опоры', ky: 'Тырмышуу жана таянып басуу'),
      emoji: '🧗',
      avgWeightKgBoy: 9.2,
      avgWeightKgGirl: 8.5,
      avgHeightCmBoy: 73.3,
      avgHeightCmGirl: 71.5,
      physicalDevelopment:
          L3(
        en: 'Cruises along furniture. May stand briefly without support. Sits down from standing. Picks up tiny objects with pincer grasp.',
        ru: 'Cruises along furniture. May stand briefly without support. Sits down from standing. Picks up tiny objects with pincer grasp.',
        ky: 'Cruises along furniture. May stand briefly without support. Sits down from standing. Picks up tiny objects with pincer grasp.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Shakes, bangs, throws things to explore. Uses toys correctly (cups to drink, brush to brush hair). Understands simple instructions.',
        ru: 'Shakes, bangs, throws things to explore. Uses toys correctly (cups to drink, brush to brush hair). Understands simple instructions.',
        ky: 'Shakes, bangs, throws things to explore. Uses toys correctly (cups to drink, brush to brush hair). Understands simple instructions.',
      ),
      socialEmotional:
          L3(
        en: 'Waves bye-bye. Claps. Expresses more emotions clearly. May show preferences (favorite toy, blanket, parent).',
        ru: 'Waves bye-bye. Claps. Expresses more emotions clearly. May show preferences (favorite toy, blanket, parent).',
        ky: 'Waves bye-bye. Claps. Expresses more emotions clearly. May show preferences (favorite toy, blanket, parent).',
      ),
      languageDevelopment:
          L3(
        en: 'First real word possible ("mama" or "dada" with meaning). Follows simple commands. Understands "no."',
        ru: 'First real word possible ("mama" or "dada" with meaning). Follows simple commands. Understands "no."',
        ky: 'First real word possible ("mama" or "dada" with meaning). Follows simple commands. Understands "no."',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Cruises along furniture', ru: 'Cruises along furniture', ky: 'Cruises along furniture'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Stands briefly without support', ru: 'Stands briefly without support', ky: 'Stands briefly without support'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Says first word with meaning', ru: 'Says first word with meaning', ky: 'Says first word with meaning'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Waves and claps', ru: 'Waves and claps', ky: 'Waves and claps'), MilestoneCategory.social),
        MilestoneItem(L3(en: 'Follows simple commands', ru: 'Follows simple commands', ky: 'Follows simple commands'), MilestoneCategory.language),
      ],
      activities: const [
        L3(en: 'Push toys for early walking practice', ru: 'Push toys for early walking practice', ky: 'Push toys for early walking practice'),
        L3(en: 'Simple puzzles with knobs', ru: 'Simple puzzles with knobs', ky: 'Simple puzzles with knobs'),
        L3(en: 'Reading with pointing at pictures', ru: 'Reading with pointing at pictures', ky: 'Reading with pointing at pictures'),
        L3(en: 'Dance parties!', ru: 'Dance parties!', ky: 'Dance parties!'),
        L3(en: 'Stacking and knocking down', ru: 'Stacking and knocking down', ky: 'Stacking and knocking down'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: L3(en: '10-12h at night, 2 naps (may transition to 1 over next months).', ru: '10-12h at night, 2 naps (may transition to 1 over next months).', ky: '10-12h at night, 2 naps (may transition to 1 over next months).'),
        tips: [
          L3(en: 'Milestones may cause brief sleep regressions', ru: 'Milestones may cause brief sleep regressions', ky: 'Milestones may cause brief sleep regressions'),
          L3(en: 'Keep bedtime consistent', ru: 'Keep bedtime consistent', ky: 'Keep bedtime consistent'),
          L3(en: 'Morning nap usually drops between 12-18 months', ru: 'Morning nap usually drops between 12-18 months', ky: 'Morning nap usually drops between 12-18 months'),
          L3(en: 'Room should be dark and cool', ru: 'Room should be dark and cool', ky: 'Room should be dark and cool'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Milk + full meals 3x daily', ru: 'Milk + full meals 3x daily', ky: 'Milk + full meals 3x daily'),
        frequency: L3(en: '3-4 milk feeds + 3 meals + snacks', ru: '3-4 milk feeds + 3 meals + snacks', ky: '3-4 milk feeds + 3 meals + snacks'),
        amount: L3(en: '180-210ml milk, full servings at meals', ru: '180-210ml milk, full servings at meals', ky: '180-210ml milk, full servings at meals'),
        tips: [
          L3(en: 'Introduce cup for milk gradually', ru: 'Introduce cup for milk gradually', ky: 'Introduce cup for milk gradually'),
          L3(en: 'Family foods (appropriate textures)', ru: 'Family foods (appropriate textures)', ky: 'Family foods (appropriate textures)'),
          L3(en: 'Offer 3 meals and 2 snacks on schedule', ru: 'Offer 3 meals and 2 snacks on schedule', ky: 'Offer 3 meals and 2 snacks on schedule'),
          L3(en: 'Still avoid honey until 12 months', ru: 'Still avoid honey until 12 months', ky: 'Still avoid honey until 12 months'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not crawl in any fashion', ru: 'Does not crawl in any fashion', ky: 'Does not crawl in any fashion'),
        L3(en: 'Does not stand with support', ru: 'Does not stand with support', ky: 'Does not stand with support'),
        L3(en: 'Does not use any words or gestures', ru: 'Does not use any words or gestures', ky: 'Does not use any words or gestures'),
        L3(en: 'Does not search for hidden objects', ru: 'Does not search for hidden objects', ky: 'Does not search for hidden objects'),
      ],
      parentTips: const [
        L3(en: 'Walking is coming — prepare safe floors', ru: 'Walking is coming — prepare safe floors', ky: 'Walking is coming — prepare safe floors'),
        L3(en: 'Say "yes" more than "no" when possible', ru: 'Say "yes" more than "no" when possible', ky: 'Say "yes" more than "no" when possible'),
        L3(en: 'Name everything throughout the day', ru: 'Name everything throughout the day', ky: 'Name everything throughout the day'),
        L3(en: 'Praise effort, not just success', ru: 'Praise effort, not just success', ky: 'Praise effort, not just success'),
      ],
    ),

    11: BabyMonthData(
      month: 11,
      title: const L3(en: 'Almost Walking', ru: 'Почти ходим', ky: 'Дээрлик басуу'),
      emoji: '🎈',
      avgWeightKgBoy: 9.4,
      avgWeightKgGirl: 8.7,
      avgHeightCmBoy: 74.5,
      avgHeightCmGirl: 72.8,
      physicalDevelopment:
          L3(
        en: 'Stands alone for several seconds. May take first independent steps. Walks holding furniture with confidence. Uses pincer grasp precisely.',
        ru: 'Stands alone for several seconds. May take first independent steps. Walks holding furniture with confidence. Uses pincer grasp precisely.',
        ky: 'Stands alone for several seconds. May take first independent steps. Walks holding furniture with confidence. Uses pincer grasp precisely.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Imitates actions. Uses objects for their purpose (phone to ear). Understands many more words than they can say. Shows interest in books.',
        ru: 'Imitates actions. Uses objects for their purpose (phone to ear). Understands many more words than they can say. Shows interest in books.',
        ky: 'Imitates actions. Uses objects for their purpose (phone to ear). Understands many more words than they can say. Shows interest in books.',
      ),
      socialEmotional:
          L3(
        en: 'Shows humor. Performs for attention. May have specific fears (loud noises, strangers). Shows affection actively.',
        ru: 'Shows humor. Performs for attention. May have specific fears (loud noises, strangers). Shows affection actively.',
        ky: 'Shows humor. Performs for attention. May have specific fears (loud noises, strangers). Shows affection actively.',
      ),
      languageDevelopment:
          L3(
        en: 'Says 1-3 words meaningfully. Understands 30-50 words. Uses gestures to communicate. Shakes head for "no."',
        ru: 'Says 1-3 words meaningfully. Understands 30-50 words. Uses gestures to communicate. Shakes head for "no."',
        ky: 'Says 1-3 words meaningfully. Understands 30-50 words. Uses gestures to communicate. Shakes head for "no."',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Stands independently', ru: 'Stands independently', ky: 'Stands independently'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'May take first steps', ru: 'May take first steps', ky: 'May take first steps'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 1-3 meaningful words', ru: 'Uses 1-3 meaningful words', ky: 'Uses 1-3 meaningful words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Imitates actions', ru: 'Imitates actions', ky: 'Imitates actions'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Shows affection', ru: 'Shows affection', ky: 'Shows affection'), MilestoneCategory.social),
      ],
      activities: const [
        L3(en: 'Walk around holding hands', ru: 'Walk around holding hands', ky: 'Walk around holding hands'),
        L3(en: 'Push walker toys', ru: 'Push walker toys', ky: 'Push walker toys'),
        L3(en: 'Ball rolling/tossing games', ru: 'Ball rolling/tossing games', ky: 'Ball rolling/tossing games'),
        L3(en: 'Simple pretend play (feeding a doll)', ru: 'Simple pretend play (feeding a doll)', ky: 'Simple pretend play (feeding a doll)'),
        L3(en: 'Interactive books with flaps', ru: 'Interactive books with flaps', ky: 'Interactive books with flaps'),
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: L3(en: '10-12h at night, 2 naps.', ru: '10-12h at night, 2 naps.', ky: '10-12h at night, 2 naps.'),
        tips: [
          L3(en: 'Milestones can disrupt sleep temporarily', ru: 'Milestones can disrupt sleep temporarily', ky: 'Milestones can disrupt sleep temporarily'),
          L3(en: 'Keep consistent bedtime — it\'s the anchor', ru: 'Keep consistent bedtime — it\'s the anchor', ky: 'Keep consistent bedtime — it\'s the anchor'),
          L3(en: 'Security objects (lovey) may help', ru: 'Security objects (lovey) may help', ky: 'Security objects (lovey) may help'),
          L3(en: 'Expect some nightmares/night wakings', ru: 'Expect some nightmares/night wakings', ky: 'Expect some nightmares/night wakings'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Full family meals + milk', ru: 'Full family meals + milk', ky: 'Full family meals + milk'),
        frequency: L3(en: '3 meals + 2 snacks + 3 milk feeds', ru: '3 meals + 2 snacks + 3 milk feeds', ky: '3 meals + 2 snacks + 3 milk feeds'),
        amount: L3(en: 'Standard toddler portions starting', ru: 'Standard toddler portions starting', ky: 'Standard toddler portions starting'),
        tips: [
          L3(en: 'Transitioning to whole cow milk soon (at 12 months)', ru: 'Transitioning to whole cow milk soon (at 12 months)', ky: 'Transitioning to whole cow milk soon (at 12 months)'),
          L3(en: 'Self-feeding with spoon — messy but essential', ru: 'Self-feeding with spoon — messy but essential', ky: 'Self-feeding with spoon — messy but essential'),
          L3(en: 'Water with meals', ru: 'Water with meals', ky: 'Water with meals'),
          L3(en: 'Family meals together when possible', ru: 'Family meals together when possible', ky: 'Family meals together when possible'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not pull up to standing', ru: 'Does not pull up to standing', ky: 'Does not pull up to standing'),
        L3(en: 'Does not say any words', ru: 'Does not say any words', ky: 'Does not say any words'),
        L3(en: 'Does not respond to familiar voices', ru: 'Does not respond to familiar voices', ky: 'Does not respond to familiar voices'),
        L3(en: 'Does not show interest in social interaction', ru: 'Does not show interest in social interaction', ky: 'Does not show interest in social interaction'),
      ],
      parentTips: const [
        L3(en: 'First steps are coming — capture on video!', ru: 'First steps are coming — capture on video!', ky: 'First steps are coming — capture on video!'),
        L3(en: 'Celebrate effort, not just achievements', ru: 'Celebrate effort, not just achievements', ky: 'Celebrate effort, not just achievements'),
        L3(en: 'Slow down and follow baby\'s lead', ru: 'Slow down and follow baby\'s lead', ky: 'Slow down and follow baby\'s lead'),
        L3(en: 'First birthday planning — keep it simple', ru: 'First birthday planning — keep it simple', ky: 'First birthday planning — keep it simple'),
      ],
    ),

    // =====================================================
    // TODDLER fill-ins (14, 16, 17, 19, 20, 21, 22, 23 months)
    // =====================================================
    14: BabyMonthData(
      month: 14,
      title: const L3(en: 'Walking & Exploring', ru: 'Ходим и исследуем', ky: 'Басуу жана изилдөө'),
      emoji: '🚶',
      avgWeightKgBoy: 10.1,
      avgWeightKgGirl: 9.5,
      avgHeightCmBoy: 78.0,
      avgHeightCmGirl: 76.4,
      physicalDevelopment:
          L3(
        en: 'Walking independently (most babies). Climbs stairs with help. Stacks 2-3 blocks. Scribbles with crayons.',
        ru: 'Walking independently (most babies). Climbs stairs with help. Stacks 2-3 blocks. Scribbles with crayons.',
        ky: 'Walking independently (most babies). Climbs stairs with help. Stacks 2-3 blocks. Scribbles with crayons.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Follows simple instructions. Points to body parts. Identifies familiar objects and people. Shows clear preferences.',
        ru: 'Follows simple instructions. Points to body parts. Identifies familiar objects and people. Shows clear preferences.',
        ky: 'Follows simple instructions. Points to body parts. Identifies familiar objects and people. Shows clear preferences.',
      ),
      socialEmotional:
          L3(
        en: 'Shows independence. "No!" becomes a favorite word. Tests limits. Shows empathy (hugs a crying friend).',
        ru: 'Shows independence. "No!" becomes a favorite word. Tests limits. Shows empathy (hugs a crying friend).',
        ky: 'Shows independence. "No!" becomes a favorite word. Tests limits. Shows empathy (hugs a crying friend).',
      ),
      languageDevelopment:
          L3(
        en: 'Uses 3-10 words. Points to show you things. Imitates words. Understands much more than speaks.',
        ru: 'Uses 3-10 words. Points to show you things. Imitates words. Understands much more than speaks.',
        ky: 'Uses 3-10 words. Points to show you things. Imitates words. Understands much more than speaks.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Walks well independently', ru: 'Walks well independently', ky: 'Walks well independently'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 3-10 words', ru: 'Uses 3-10 words', ky: 'Uses 3-10 words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Points to communicate', ru: 'Points to communicate', ky: 'Points to communicate'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Follows simple instructions', ru: 'Follows simple instructions', ky: 'Follows simple instructions'), MilestoneCategory.cognitive),
      ],
      activities: const [
        L3(en: 'Walking practice outside', ru: 'Walking practice outside', ky: 'Walking practice outside'),
        L3(en: 'Scribbling with chunky crayons', ru: 'Scribbling with chunky crayons', ky: 'Scribbling with chunky crayons'),
        L3(en: 'Simple shape sorters', ru: 'Simple shape sorters', ky: 'Simple shape sorters'),
        L3(en: 'Water play in small amounts', ru: 'Water play in small amounts', ky: 'Water play in small amounts'),
        L3(en: 'Naming body parts in mirror', ru: 'Naming body parts in mirror', ky: 'Naming body parts in mirror'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-11h at night, transitioning to 1 midday nap.', ru: '10-11h at night, transitioning to 1 midday nap.', ky: '10-11h at night, transitioning to 1 midday nap.'),
        tips: [
          L3(en: '1-nap transition usually 14-18 months', ru: '1-nap transition usually 14-18 months', ky: '1-nap transition usually 14-18 months'),
          L3(en: 'Nap timing matters: 12-1pm works best', ru: 'Nap timing matters: 12-1pm works best', ky: 'Nap timing matters: 12-1pm works best'),
          L3(en: 'Total nap ~2 hours', ru: 'Total nap ~2 hours', ky: 'Total nap ~2 hours'),
          L3(en: 'Earlier bedtime during nap transition', ru: 'Earlier bedtime during nap transition', ky: 'Earlier bedtime during nap transition'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Toddler meals + whole milk', ru: 'Toddler meals + whole milk', ky: 'Toddler meals + whole milk'),
        frequency: L3(en: '3 meals + 2 snacks + milk at meals', ru: '3 meals + 2 snacks + milk at meals', ky: '3 meals + 2 snacks + milk at meals'),
        amount: L3(en: '~500ml milk total daily max', ru: '~500ml milk total daily max', ky: '~500ml milk total daily max'),
        tips: [
          L3(en: 'Avoid battles over food — offer, don\'t force', ru: 'Avoid battles over food — offer, don\'t force', ky: 'Avoid battles over food — offer, don\'t force'),
          L3(en: 'Picky eating is normal — keep offering variety', ru: 'Picky eating is normal — keep offering variety', ky: 'Picky eating is normal — keep offering variety'),
          L3(en: 'Let toddler self-feed', ru: 'Let toddler self-feed', ky: 'Let toddler self-feed'),
          L3(en: 'Toddlers eat variable amounts day to day', ru: 'Toddlers eat variable amounts day to day', ky: 'Toddlers eat variable amounts day to day'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not walk', ru: 'Does not walk', ky: 'Does not walk'),
        L3(en: 'Does not use at least 3 words', ru: 'Does not use at least 3 words', ky: 'Does not use at least 3 words'),
        L3(en: 'Loses previously acquired skills', ru: 'Loses previously acquired skills', ky: 'Loses previously acquired skills'),
        L3(en: 'Does not respond to instructions', ru: 'Does not respond to instructions', ky: 'Does not respond to instructions'),
      ],
      parentTips: const [
        L3(en: 'Tantrums are normal — your toddler is learning emotions', ru: 'Tantrums are normal — your toddler is learning emotions', ky: 'Tantrums are normal — your toddler is learning emotions'),
        L3(en: 'Give choices: "red cup or blue cup?"', ru: 'Give choices: "red cup or blue cup?"', ky: 'Give choices: "red cup or blue cup?"'),
        L3(en: 'Name emotions: "you are frustrated"', ru: 'Name emotions: "you are frustrated"', ky: 'Name emotions: "you are frustrated"'),
        L3(en: 'Routines are their anchor', ru: 'Routines are their anchor', ky: 'Routines are their anchor'),
      ],
    ),

    16: BabyMonthData(
      month: 16,
      title: const L3(en: 'Running & Talking', ru: 'Бегаем и говорим', ky: 'Чуркоо жана сүйлөө'),
      emoji: '💨',
      avgWeightKgBoy: 10.5,
      avgWeightKgGirl: 9.9,
      avgHeightCmBoy: 80.2,
      avgHeightCmGirl: 78.6,
      physicalDevelopment:
          L3(
        en: 'Walks confidently, attempts running. Climbs on furniture. Kicks a ball. Scribbles more purposefully. Uses spoon clumsily.',
        ru: 'Walks confidently, attempts running. Climbs on furniture. Kicks a ball. Scribbles more purposefully. Uses spoon clumsily.',
        ky: 'Walks confidently, attempts running. Climbs on furniture. Kicks a ball. Scribbles more purposefully. Uses spoon clumsily.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Sorts shapes and colors. Identifies objects in pictures. Understands "in" and "out." Pretends (feeding a doll).',
        ru: 'Sorts shapes and colors. Identifies objects in pictures. Understands "in" and "out." Pretends (feeding a doll).',
        ky: 'Sorts shapes and colors. Identifies objects in pictures. Understands "in" and "out." Pretends (feeding a doll).',
      ),
      socialEmotional:
          L3(
        en: 'Shows pride in accomplishments. May have favorite peers. Parallel play (next to, not with). Tantrums frequent.',
        ru: 'Shows pride in accomplishments. May have favorite peers. Parallel play (next to, not with). Tantrums frequent.',
        ky: 'Shows pride in accomplishments. May have favorite peers. Parallel play (next to, not with). Tantrums frequent.',
      ),
      languageDevelopment:
          L3(
        en: 'Vocabulary 7-20 words. Uses gestures + words together. Follows 2-step directions.',
        ru: 'Vocabulary 7-20 words. Uses gestures + words together. Follows 2-step directions.',
        ky: 'Vocabulary 7-20 words. Uses gestures + words together. Follows 2-step directions.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Walks and runs unsteadily', ru: 'Walks and runs unsteadily', ky: 'Walks and runs unsteadily'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 7-20 words', ru: 'Uses 7-20 words', ky: 'Uses 7-20 words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Scribbles purposefully', ru: 'Scribbles purposefully', ky: 'Scribbles purposefully'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Identifies objects in pictures', ru: 'Identifies objects in pictures', ky: 'Identifies objects in pictures'), MilestoneCategory.cognitive),
      ],
      activities: const [
        L3(en: 'Playground time daily', ru: 'Playground time daily', ky: 'Playground time daily'),
        L3(en: 'Ball games — kick, throw, roll', ru: 'Ball games — kick, throw, roll', ky: 'Ball games — kick, throw, roll'),
        L3(en: 'Singing songs with motions', ru: 'Singing songs with motions', ky: 'Singing songs with motions'),
        L3(en: 'Simple puzzles (2-4 pieces)', ru: 'Simple puzzles (2-4 pieces)', ky: 'Simple puzzles (2-4 pieces)'),
        L3(en: 'Read together, ask "what\'s that?"', ru: 'Read together, ask "what\'s that?"', ky: 'Read together, ask "what\'s that?"'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-12h at night, 1 midday nap (1.5-2.5 hours).', ru: '10-12h at night, 1 midday nap (1.5-2.5 hours).', ky: '10-12h at night, 1 midday nap (1.5-2.5 hours).'),
        tips: [
          L3(en: 'Nap refusal can signal overtiredness, not readiness to skip', ru: 'Nap refusal can signal overtiredness, not readiness to skip', ky: 'Nap refusal can signal overtiredness, not readiness to skip'),
          L3(en: 'Keep naps until at least 3 years old', ru: 'Keep naps until at least 3 years old', ky: 'Keep naps until at least 3 years old'),
          L3(en: 'Consistent bedtime routine is essential', ru: 'Consistent bedtime routine is essential', ky: 'Consistent bedtime routine is essential'),
          L3(en: 'Toddler bed transition? Wait until 2+', ru: 'Toddler bed transition? Wait until 2+', ky: 'Toddler bed transition? Wait until 2+'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Toddler foods', ru: 'Toddler foods', ky: 'Toddler foods'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: '~1/4 adult portions', ru: '~1/4 adult portions', ky: '~1/4 adult portions'),
        tips: [
          L3(en: 'Don\'t become a short-order cook', ru: 'Don\'t become a short-order cook', ky: 'Don\'t become a short-order cook'),
          L3(en: 'Offer same foods as family', ru: 'Offer same foods as family', ky: 'Offer same foods as family'),
          L3(en: 'Expect 1-2 "good" eating days per week', ru: 'Expect 1-2 "good" eating days per week', ky: 'Expect 1-2 "good" eating days per week'),
          L3(en: 'Avoid using food as reward or punishment', ru: 'Avoid using food as reward or punishment', ky: 'Avoid using food as reward or punishment'),
        ],
      ),
      redFlags: const [
        L3(en: 'Not walking well', ru: 'Not walking well', ky: 'Not walking well'),
        L3(en: 'Does not use at least 6 words', ru: 'Does not use at least 6 words', ky: 'Does not use at least 6 words'),
        L3(en: 'Does not point to show things', ru: 'Does not point to show things', ky: 'Does not point to show things'),
        L3(en: 'Does not imitate others', ru: 'Does not imitate others', ky: 'Does not imitate others'),
      ],
      parentTips: const [
        L3(en: 'Consistency beats perfection', ru: 'Consistency beats perfection', ky: 'Consistency beats perfection'),
        L3(en: 'Toddlers need predictability', ru: 'Toddlers need predictability', ky: 'Toddlers need predictability'),
        L3(en: 'Read together every day', ru: 'Read together every day', ky: 'Read together every day'),
        L3(en: 'Take a breath — this phase is intense but temporary', ru: 'Take a breath — this phase is intense but temporary', ky: 'Take a breath — this phase is intense but temporary'),
      ],
    ),

    17: BabyMonthData(
      month: 17,
      title: const L3(en: 'Independent Spirit', ru: 'Самостоятельный дух', ky: 'Өз алдынча рух'),
      emoji: '🦁',
      avgWeightKgBoy: 10.7,
      avgWeightKgGirl: 10.0,
      avgHeightCmBoy: 81.2,
      avgHeightCmGirl: 79.7,
      physicalDevelopment:
          L3(
        en: 'Runs (sometimes falls). Walks backward. Climbs onto and off furniture. Drinks from open cup with spills. Throws a ball.',
        ru: 'Runs (sometimes falls). Walks backward. Climbs onto and off furniture. Drinks from open cup with spills. Throws a ball.',
        ky: 'Runs (sometimes falls). Walks backward. Climbs onto and off furniture. Drinks from open cup with spills. Throws a ball.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Imitates household chores. Pretend play expands. Identifies body parts. Follows 2-step instructions.',
        ru: 'Imitates household chores. Pretend play expands. Identifies body parts. Follows 2-step instructions.',
        ky: 'Imitates household chores. Pretend play expands. Identifies body parts. Follows 2-step instructions.',
      ),
      socialEmotional:
          L3(
        en: 'Shows independence fiercely. Tests boundaries constantly. Affectionate with caregivers. May have favorite songs or stories.',
        ru: 'Shows independence fiercely. Tests boundaries constantly. Affectionate with caregivers. May have favorite songs or stories.',
        ky: 'Shows independence fiercely. Tests boundaries constantly. Affectionate with caregivers. May have favorite songs or stories.',
      ),
      languageDevelopment:
          L3(
        en: 'Vocabulary 10-20+ words. May combine 2 words. Repeats words from conversations.',
        ru: 'Vocabulary 10-20+ words. May combine 2 words. Repeats words from conversations.',
        ky: 'Vocabulary 10-20+ words. May combine 2 words. Repeats words from conversations.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Runs (unsteadily)', ru: 'Runs (unsteadily)', ky: 'Runs (unsteadily)'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Throws overhand', ru: 'Throws overhand', ky: 'Throws overhand'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 10-20+ words', ru: 'Uses 10-20+ words', ky: 'Uses 10-20+ words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Imitates household tasks', ru: 'Imitates household tasks', ky: 'Imitates household tasks'), MilestoneCategory.cognitive),
      ],
      activities: const [
        L3(en: 'Let them "help" with small tasks', ru: 'Let them "help" with small tasks', ky: 'Let them "help" with small tasks'),
        L3(en: 'Bubbles, crayons, play-doh', ru: 'Bubbles, crayons, play-doh', ky: 'Bubbles, crayons, play-doh'),
        L3(en: 'Balls, toy cars, push toys', ru: 'Balls, toy cars, push toys', ky: 'Balls, toy cars, push toys'),
        L3(en: 'Simple dance and movement', ru: 'Simple dance and movement', ky: 'Simple dance and movement'),
        L3(en: 'Read the same books again and again', ru: 'Read the same books again and again', ky: 'Read the same books again and again'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-12h at night, 1 nap (1-2.5 hours).', ru: '10-12h at night, 1 nap (1-2.5 hours).', ky: '10-12h at night, 1 nap (1-2.5 hours).'),
        tips: [
          L3(en: 'Night wakings can increase with new skills', ru: 'Night wakings can increase with new skills', ky: 'Night wakings can increase with new skills'),
          L3(en: 'Consistency is everything', ru: 'Consistency is everything', ky: 'Consistency is everything'),
          L3(en: 'No screens before bed', ru: 'No screens before bed', ky: 'No screens before bed'),
          L3(en: 'Watch for overtiredness signs', ru: 'Watch for overtiredness signs', ky: 'Watch for overtiredness signs'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods', ru: 'Family foods', ky: 'Family foods'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Toddler portions (1-2 tablespoons per year of age per food)', ru: 'Toddler portions (1-2 tablespoons per year of age per food)', ky: 'Toddler portions (1-2 tablespoons per year of age per food)'),
        tips: [
          L3(en: 'Picky eating peaks this age', ru: 'Picky eating peaks this age', ky: 'Picky eating peaks this age'),
          L3(en: 'Keep offering rejected foods (may take 15+ tries)', ru: 'Keep offering rejected foods (may take 15+ tries)', ky: 'Keep offering rejected foods (may take 15+ tries)'),
          L3(en: 'Limit juice to 120ml/day', ru: 'Limit juice to 120ml/day', ky: 'Limit juice to 120ml/day'),
          L3(en: 'Dairy: 2 servings daily', ru: 'Dairy: 2 servings daily', ky: 'Dairy: 2 servings daily'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not walk independently', ru: 'Does not walk independently', ky: 'Does not walk independently'),
        L3(en: 'Uses fewer than 6 words', ru: 'Uses fewer than 6 words', ky: 'Uses fewer than 6 words'),
        L3(en: 'Doesn\'t follow simple directions', ru: 'Doesn\'t follow simple directions', ky: 'Doesn\'t follow simple directions'),
        L3(en: 'Loses skills previously had', ru: 'Loses skills previously had', ky: 'Loses skills previously had'),
      ],
      parentTips: const [
        L3(en: 'Autonomy is healthy — let them try', ru: 'Autonomy is healthy — let them try', ky: 'Autonomy is healthy — let them try'),
        L3(en: 'Two choices keeps tantrums lower', ru: 'Two choices keeps tantrums lower', ky: 'Two choices keeps tantrums lower'),
        L3(en: 'Praise effort, name emotions', ru: 'Praise effort, name emotions', ky: 'Praise effort, name emotions'),
        L3(en: 'You are allowed to be tired', ru: 'You are allowed to be tired', ky: 'You are allowed to be tired'),
      ],
    ),

    19: BabyMonthData(
      month: 19,
      title: const L3(en: 'Language Explosion', ru: 'Языковой взрыв', ky: 'Тил жарылуусу'),
      emoji: '🗣️',
      avgWeightKgBoy: 11.1,
      avgWeightKgGirl: 10.4,
      avgHeightCmBoy: 82.9,
      avgHeightCmGirl: 81.4,
      physicalDevelopment:
          L3(
        en: 'Climbs stairs with rail. Kicks a ball forward. Stacks 4-6 blocks. Scribbles and makes marks with intent.',
        ru: 'Climbs stairs with rail. Kicks a ball forward. Stacks 4-6 blocks. Scribbles and makes marks with intent.',
        ky: 'Climbs stairs with rail. Kicks a ball forward. Stacks 4-6 blocks. Scribbles and makes marks with intent.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Sorts by color and shape. Pretend play is complex. Follows instructions. Solves simple problems.',
        ru: 'Sorts by color and shape. Pretend play is complex. Follows instructions. Solves simple problems.',
        ky: 'Sorts by color and shape. Pretend play is complex. Follows instructions. Solves simple problems.',
      ),
      socialEmotional:
          L3(
        en: 'Shows empathy. Tantrums from frustration. May be shy with strangers. Strong attachment to caregivers.',
        ru: 'Shows empathy. Tantrums from frustration. May be shy with strangers. Strong attachment to caregivers.',
        ky: 'Shows empathy. Tantrums from frustration. May be shy with strangers. Strong attachment to caregivers.',
      ),
      languageDevelopment:
          L3(
        en: 'Uses 20-50+ words. Combines 2 words frequently. Asks questions through tone. Says "mine" a lot.',
        ru: 'Uses 20-50+ words. Combines 2 words frequently. Asks questions through tone. Says "mine" a lot.',
        ky: 'Uses 20-50+ words. Combines 2 words frequently. Asks questions through tone. Says "mine" a lot.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Walks up stairs holding rail', ru: 'Walks up stairs holding rail', ky: 'Walks up stairs holding rail'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses 20-50+ words', ru: 'Uses 20-50+ words', ky: 'Uses 20-50+ words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Combines 2 words', ru: 'Combines 2 words', ky: 'Combines 2 words'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Pretend play is elaborate', ru: 'Pretend play is elaborate', ky: 'Pretend play is elaborate'), MilestoneCategory.cognitive),
      ],
      activities: const [
        L3(en: 'Sorting activities (by color, size)', ru: 'Sorting activities (by color, size)', ky: 'Sorting activities (by color, size)'),
        L3(en: 'Singing alphabet, counting', ru: 'Singing alphabet, counting', ky: 'Singing alphabet, counting'),
        L3(en: 'Outdoor play — running, climbing', ru: 'Outdoor play — running, climbing', ky: 'Outdoor play — running, climbing'),
        L3(en: 'Finger painting, stickers', ru: 'Finger painting, stickers', ky: 'Finger painting, stickers'),
        L3(en: 'Name everything together', ru: 'Name everything together', ky: 'Name everything together'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-12h at night, 1 nap.', ru: '10-12h at night, 1 nap.', ky: '10-12h at night, 1 nap.'),
        tips: [
          L3(en: 'Stalling at bedtime is age-appropriate', ru: 'Stalling at bedtime is age-appropriate', ky: 'Stalling at bedtime is age-appropriate'),
          L3(en: 'Set clear, kind limits', ru: 'Set clear, kind limits', ky: 'Set clear, kind limits'),
          L3(en: 'A bedtime routine card with pictures helps', ru: 'A bedtime routine card with pictures helps', ky: 'A bedtime routine card with pictures helps'),
          L3(en: 'Validate feelings, hold limits', ru: 'Validate feelings, hold limits', ky: 'Validate feelings, hold limits'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods', ru: 'Family foods', ky: 'Family foods'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Toddler portions', ru: 'Toddler portions', ky: 'Toddler portions'),
        tips: [
          L3(en: 'Let them serve themselves when possible', ru: 'Let them serve themselves when possible', ky: 'Let them serve themselves when possible'),
          L3(en: 'Involve them in food prep (stirring, pouring)', ru: 'Involve them in food prep (stirring, pouring)', ky: 'Involve them in food prep (stirring, pouring)'),
          L3(en: 'Don\'t force clean plates', ru: 'Don\'t force clean plates', ky: 'Don\'t force clean plates'),
          L3(en: 'Water is the main beverage', ru: 'Water is the main beverage', ky: 'Water is the main beverage'),
        ],
      ),
      redFlags: const [
        L3(en: 'Uses fewer than 10 words', ru: 'Uses fewer than 10 words', ky: 'Uses fewer than 10 words'),
        L3(en: 'Does not combine words', ru: 'Does not combine words', ky: 'Does not combine words'),
        L3(en: 'Does not walk well', ru: 'Does not walk well', ky: 'Does not walk well'),
        L3(en: 'Does not imitate', ru: 'Does not imitate', ky: 'Does not imitate'),
      ],
      parentTips: const [
        L3(en: 'Vocabulary explosion coming soon', ru: 'Vocabulary explosion coming soon', ky: 'Vocabulary explosion coming soon'),
        L3(en: 'Name emotions they show', ru: 'Name emotions they show', ky: 'Name emotions they show'),
        L3(en: 'Model the behavior you want', ru: 'Model the behavior you want', ky: 'Model the behavior you want'),
        L3(en: 'Read books 3-4x a day', ru: 'Read books 3-4x a day', ky: 'Read books 3-4x a day'),
      ],
    ),

    20: BabyMonthData(
      month: 20,
      title: const L3(en: 'Discovery', ru: 'Открытие', ky: 'Ачылыш'),
      emoji: '🔍',
      avgWeightKgBoy: 11.3,
      avgWeightKgGirl: 10.6,
      avgHeightCmBoy: 83.7,
      avgHeightCmGirl: 82.3,
      physicalDevelopment:
          L3(
        en: 'Jumps (both feet off ground). Climbs low structures. Turns pages of a book one at a time. Feeds self with spoon fairly well.',
        ru: 'Jumps (both feet off ground). Climbs low structures. Turns pages of a book one at a time. Feeds self with spoon fairly well.',
        ky: 'Jumps (both feet off ground). Climbs low structures. Turns pages of a book one at a time. Feeds self with spoon fairly well.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Understands "big" and "little." Matches objects. Finds hidden objects. Pretend play expands.',
        ru: 'Understands "big" and "little." Matches objects. Finds hidden objects. Pretend play expands.',
        ky: 'Understands "big" and "little." Matches objects. Finds hidden objects. Pretend play expands.',
      ),
      socialEmotional:
          L3(
        en: 'Shows independence intensely. Parallel play with other kids. Strong likes/dislikes. Copies adult behaviors.',
        ru: 'Shows independence intensely. Parallel play with other kids. Strong likes/dislikes. Copies adult behaviors.',
        ky: 'Shows independence intensely. Parallel play with other kids. Strong likes/dislikes. Copies adult behaviors.',
      ),
      languageDevelopment:
          L3(
        en: 'Vocabulary grows daily (~50+ words). 2-word phrases common. Names objects in books.',
        ru: 'Vocabulary grows daily (~50+ words). 2-word phrases common. Names objects in books.',
        ky: 'Vocabulary grows daily (~50+ words). 2-word phrases common. Names objects in books.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Jumps', ru: 'Jumps', ky: 'Jumps'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Names objects', ru: 'Names objects', ky: 'Names objects'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Self-feeds with spoon', ru: 'Self-feeds with spoon', ky: 'Self-feeds with spoon'), MilestoneCategory.feeding),
        MilestoneItem(L3(en: 'Matches objects', ru: 'Matches objects', ky: 'Matches objects'), MilestoneCategory.cognitive),
      ],
      activities: const [
        L3(en: 'Obstacle courses (cushions on floor)', ru: 'Obstacle courses (cushions on floor)', ky: 'Obstacle courses (cushions on floor)'),
        L3(en: 'Matching games', ru: 'Matching games', ky: 'Matching games'),
        L3(en: 'Water tables / sensory bins', ru: 'Water tables / sensory bins', ky: 'Water tables / sensory bins'),
        L3(en: 'Singing and dancing', ru: 'Singing and dancing', ky: 'Singing and dancing'),
        L3(en: 'Simple puzzles (4-6 pieces)', ru: 'Simple puzzles (4-6 pieces)', ky: 'Simple puzzles (4-6 pieces)'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-12h at night, 1 nap (1.5-2 hours).', ru: '10-12h at night, 1 nap (1.5-2 hours).', ky: '10-12h at night, 1 nap (1.5-2 hours).'),
        tips: [
          L3(en: 'Toddler bed transition can wait', ru: 'Toddler bed transition can wait', ky: 'Toddler bed transition can wait'),
          L3(en: 'Night weaning if still feeding at night', ru: 'Night weaning if still feeding at night', ky: 'Night weaning if still feeding at night'),
          L3(en: 'Watch for naptime shift signals', ru: 'Watch for naptime shift signals', ky: 'Watch for naptime shift signals'),
          L3(en: 'Cozy bedtime reading routine', ru: 'Cozy bedtime reading routine', ky: 'Cozy bedtime reading routine'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods', ru: 'Family foods', ky: 'Family foods'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Toddler portions', ru: 'Toddler portions', ky: 'Toddler portions'),
        tips: [
          L3(en: 'Make food fun (shapes, colors)', ru: 'Make food fun (shapes, colors)', ky: 'Make food fun (shapes, colors)'),
          L3(en: 'Model adventurous eating', ru: 'Model adventurous eating', ky: 'Model adventurous eating'),
          L3(en: 'Allow messes', ru: 'Allow messes', ky: 'Allow messes'),
          L3(en: 'Don\'t panic about picky days', ru: 'Don\'t panic about picky days', ky: 'Don\'t panic about picky days'),
        ],
      ),
      redFlags: const [
        L3(en: 'Not using 2-word phrases', ru: 'Not using 2-word phrases', ky: 'Not using 2-word phrases'),
        L3(en: 'Not following instructions', ru: 'Not following instructions', ky: 'Not following instructions'),
        L3(en: 'Loses skills', ru: 'Loses skills', ky: 'Loses skills'),
        L3(en: 'Does not make eye contact regularly', ru: 'Does not make eye contact regularly', ky: 'Does not make eye contact regularly'),
      ],
      parentTips: const [
        L3(en: 'Model the behavior you want', ru: 'Model the behavior you want', ky: 'Model the behavior you want'),
        L3(en: 'Enjoy the questions and curiosity', ru: 'Enjoy the questions and curiosity', ky: 'Enjoy the questions and curiosity'),
        L3(en: 'Outdoor time is essential', ru: 'Outdoor time is essential', ky: 'Outdoor time is essential'),
        L3(en: 'Consistent bedtime saves sanity', ru: 'Consistent bedtime saves sanity', ky: 'Consistent bedtime saves sanity'),
      ],
    ),

    21: BabyMonthData(
      month: 21,
      title: const L3(en: 'Personality Emerging', ru: 'Характер проявляется', ky: 'Мүнөз көрүнөт'),
      emoji: '🌟',
      avgWeightKgBoy: 11.5,
      avgWeightKgGirl: 10.9,
      avgHeightCmBoy: 84.5,
      avgHeightCmGirl: 83.2,
      physicalDevelopment:
          L3(
        en: 'Runs more smoothly. Kicks and throws balls with more control. Climbs up and down stairs with help. Builds 5-6 block towers.',
        ru: 'Runs more smoothly. Kicks and throws balls with more control. Climbs up and down stairs with help. Builds 5-6 block towers.',
        ky: 'Runs more smoothly. Kicks and throws balls with more control. Climbs up and down stairs with help. Builds 5-6 block towers.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Understands 2-step instructions. Sorts objects. Imitates adult activities in play. Stronger memory.',
        ru: 'Understands 2-step instructions. Sorts objects. Imitates adult activities in play. Stronger memory.',
        ky: 'Understands 2-step instructions. Sorts objects. Imitates adult activities in play. Stronger memory.',
      ),
      socialEmotional:
          L3(
        en: 'Emerging personality clear. Separation anxiety may return. Possessive of toys ("mine!"). Testing limits constantly.',
        ru: 'Emerging personality clear. Separation anxiety may return. Possessive of toys ("mine!"). Testing limits constantly.',
        ky: 'Emerging personality clear. Separation anxiety may return. Possessive of toys ("mine!"). Testing limits constantly.',
      ),
      languageDevelopment:
          L3(
        en: 'Vocabulary 50-100+ words. Uses 2-3 word sentences. Asks "what\'s that?" constantly.',
        ru: 'Vocabulary 50-100+ words. Uses 2-3 word sentences. Asks "what\'s that?" constantly.',
        ky: 'Vocabulary 50-100+ words. Uses 2-3 word sentences. Asks "what\'s that?" constantly.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Uses 2-3 word sentences', ru: 'Uses 2-3 word sentences', ky: 'Uses 2-3 word sentences'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Runs well', ru: 'Runs well', ky: 'Runs well'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Follows 2-step instructions', ru: 'Follows 2-step instructions', ky: 'Follows 2-step instructions'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Imitates adults', ru: 'Imitates adults', ky: 'Imitates adults'), MilestoneCategory.social),
      ],
      activities: const [
        L3(en: 'Story time with participation', ru: 'Story time with participation', ky: 'Story time with participation'),
        L3(en: 'Building with blocks', ru: 'Building with blocks', ky: 'Building with blocks'),
        L3(en: 'Outdoor exploration', ru: 'Outdoor exploration', ky: 'Outdoor exploration'),
        L3(en: 'Singing together', ru: 'Singing together', ky: 'Singing together'),
        L3(en: 'Pretend play: kitchen, doctor, grocery', ru: 'Pretend play: kitchen, doctor, grocery', ky: 'Pretend play: kitchen, doctor, grocery'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-11h at night, 1 nap.', ru: '10-11h at night, 1 nap.', ky: '10-11h at night, 1 nap.'),
        tips: [
          L3(en: 'Nightmares can begin — comfort and reassure', ru: 'Nightmares can begin — comfort and reassure', ky: 'Nightmares can begin — comfort and reassure'),
          L3(en: 'Nightlight OK if wanted', ru: 'Nightlight OK if wanted', ky: 'Nightlight OK if wanted'),
          L3(en: 'Keep wake-up time consistent', ru: 'Keep wake-up time consistent', ky: 'Keep wake-up time consistent'),
          L3(en: 'No added sugars near bedtime', ru: 'No added sugars near bedtime', ky: 'No added sugars near bedtime'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods', ru: 'Family foods', ky: 'Family foods'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Growing toddler portions', ru: 'Growing toddler portions', ky: 'Growing toddler portions'),
        tips: [
          L3(en: 'Involve them in meal prep', ru: 'Involve them in meal prep', ky: 'Involve them in meal prep'),
          L3(en: 'Allow food exploration', ru: 'Allow food exploration', ky: 'Allow food exploration'),
          L3(en: 'Water between meals', ru: 'Water between meals', ky: 'Water between meals'),
          L3(en: 'Family meals are powerful', ru: 'Family meals are powerful', ky: 'Family meals are powerful'),
        ],
      ),
      redFlags: const [
        L3(en: 'Not using 2-word phrases', ru: 'Not using 2-word phrases', ky: 'Not using 2-word phrases'),
        L3(en: 'Does not walk well', ru: 'Does not walk well', ky: 'Does not walk well'),
        L3(en: 'Loses language skills', ru: 'Loses language skills', ky: 'Loses language skills'),
        L3(en: 'Avoids eye contact consistently', ru: 'Avoids eye contact consistently', ky: 'Avoids eye contact consistently'),
      ],
      parentTips: const [
        L3(en: 'They understand MORE than they can say', ru: 'They understand MORE than they can say', ky: 'They understand MORE than they can say'),
        L3(en: 'Tantrums are communication', ru: 'Tantrums are communication', ky: 'Tantrums are communication'),
        L3(en: 'Name big emotions', ru: 'Name big emotions', ky: 'Name big emotions'),
        L3(en: 'Your calm is their anchor', ru: 'Your calm is their anchor', ky: 'Your calm is their anchor'),
      ],
    ),

    22: BabyMonthData(
      month: 22,
      title: const L3(en: 'Pretend & Play', ru: 'Воображение и игра', ky: 'Элестетүү жана оюн'),
      emoji: '🎭',
      avgWeightKgBoy: 11.7,
      avgWeightKgGirl: 11.1,
      avgHeightCmBoy: 85.4,
      avgHeightCmGirl: 84.1,
      physicalDevelopment:
          L3(
        en: 'Walks on tiptoes. Jumps in place. Throws overhand. Builds 6-8 block towers. Uses fork and spoon well.',
        ru: 'Walks on tiptoes. Jumps in place. Throws overhand. Builds 6-8 block towers. Uses fork and spoon well.',
        ky: 'Walks on tiptoes. Jumps in place. Throws overhand. Builds 6-8 block towers. Uses fork and spoon well.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Symbolic play (box is a car). Memory strong. Simple problem solving. Organizes toys by category.',
        ru: 'Symbolic play (box is a car). Memory strong. Simple problem solving. Organizes toys by category.',
        ky: 'Symbolic play (box is a car). Memory strong. Simple problem solving. Organizes toys by category.',
      ),
      socialEmotional:
          L3(
        en: 'Starts parallel play naturally. Shows sympathy. Less separation anxiety for some. Big feelings, small vocabulary still.',
        ru: 'Starts parallel play naturally. Shows sympathy. Less separation anxiety for some. Big feelings, small vocabulary still.',
        ky: 'Starts parallel play naturally. Shows sympathy. Less separation anxiety for some. Big feelings, small vocabulary still.',
      ),
      languageDevelopment:
          L3(
        en: '50-200+ words. 2-3 word phrases common. Strangers can understand some words.',
        ru: '50-200+ words. 2-3 word phrases common. Strangers can understand some words.',
        ky: '50-200+ words. 2-3 word phrases common. Strangers can understand some words.',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Symbolic play', ru: 'Symbolic play', ky: 'Symbolic play'), MilestoneCategory.cognitive),
        MilestoneItem(L3(en: 'Jumps in place', ru: 'Jumps in place', ky: 'Jumps in place'), MilestoneCategory.motor),
        MilestoneItem(L3(en: 'Uses fork and spoon', ru: 'Uses fork and spoon', ky: 'Uses fork and spoon'), MilestoneCategory.feeding),
        MilestoneItem(L3(en: '50-200+ words', ru: '50-200+ words', ky: '50-200+ words'), MilestoneCategory.language),
      ],
      activities: const [
        L3(en: 'Pretend play props (toy food, doctor kit)', ru: 'Pretend play props (toy food, doctor kit)', ky: 'Pretend play props (toy food, doctor kit)'),
        L3(en: 'Singing songs with words', ru: 'Singing songs with words', ky: 'Singing songs with words'),
        L3(en: 'Gentle ball games', ru: 'Gentle ball games', ky: 'Gentle ball games'),
        L3(en: 'Coloring, stickers', ru: 'Coloring, stickers', ky: 'Coloring, stickers'),
        L3(en: 'Sandbox, water table', ru: 'Sandbox, water table', ky: 'Sandbox, water table'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-11h at night, 1 nap (1-2 hours).', ru: '10-11h at night, 1 nap (1-2 hours).', ky: '10-11h at night, 1 nap (1-2 hours).'),
        tips: [
          L3(en: 'Potty learning readiness may start', ru: 'Potty learning readiness may start', ky: 'Potty learning readiness may start'),
          L3(en: 'Dream feeds are done', ru: 'Dream feeds are done', ky: 'Dream feeds are done'),
          L3(en: 'Consistent naptime = better bedtime', ru: 'Consistent naptime = better bedtime', ky: 'Consistent naptime = better bedtime'),
          L3(en: 'Wind-down 30 min before bed', ru: 'Wind-down 30 min before bed', ky: 'Wind-down 30 min before bed'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods', ru: 'Family foods', ky: 'Family foods'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Growing portions', ru: 'Growing portions', ky: 'Growing portions'),
        tips: [
          L3(en: 'Introduce more food cultures', ru: 'Introduce more food cultures', ky: 'Introduce more food cultures'),
          L3(en: 'Let them pick fruits at store', ru: 'Let them pick fruits at store', ky: 'Let them pick fruits at store'),
          L3(en: 'Normalize "trying" without forcing', ru: 'Normalize "trying" without forcing', ky: 'Normalize "trying" without forcing'),
          L3(en: 'Limit milk to 500ml/day for appetite', ru: 'Limit milk to 500ml/day for appetite', ky: 'Limit milk to 500ml/day for appetite'),
        ],
      ),
      redFlags: const [
        L3(en: 'Speech regression', ru: 'Speech regression', ky: 'Speech regression'),
        L3(en: 'Does not engage in pretend play', ru: 'Does not engage in pretend play', ky: 'Does not engage in pretend play'),
        L3(en: 'Cannot follow simple directions', ru: 'Cannot follow simple directions', ky: 'Cannot follow simple directions'),
        L3(en: 'Does not respond to name', ru: 'Does not respond to name', ky: 'Does not respond to name'),
      ],
      parentTips: const [
        L3(en: 'Play is how they learn', ru: 'Play is how they learn', ky: 'Play is how they learn'),
        L3(en: 'Read 20+ minutes daily', ru: 'Read 20+ minutes daily', ky: 'Read 20+ minutes daily'),
        L3(en: 'Outdoor time boosts everything', ru: 'Outdoor time boosts everything', ky: 'Outdoor time boosts everything'),
        L3(en: 'Your calm voice = their calm nervous system', ru: 'Your calm voice = their calm nervous system', ky: 'Your calm voice = their calm nervous system'),
      ],
    ),

    23: BabyMonthData(
      month: 23,
      title: const L3(en: 'Almost Two', ru: 'Почти два', ky: 'Дээрлик эки'),
      emoji: '🎉',
      avgWeightKgBoy: 11.9,
      avgWeightKgGirl: 11.3,
      avgHeightCmBoy: 86.3,
      avgHeightCmGirl: 85.0,
      physicalDevelopment:
          L3(
        en: 'Walks on tiptoe and heels. Runs and kicks confidently. Catches a large ball. Builds tall block towers. Turns doorknobs.',
        ru: 'Walks on tiptoe and heels. Runs and kicks confidently. Catches a large ball. Builds tall block towers. Turns doorknobs.',
        ky: 'Walks on tiptoe and heels. Runs and kicks confidently. Catches a large ball. Builds tall block towers. Turns doorknobs.',
      ),
      cognitiveDevelopment:
          L3(
        en: 'Counts to 2 or 3 (not always in order). Understands opposites. Sorts by size. Recognizes self in photos.',
        ru: 'Counts to 2 or 3 (not always in order). Understands opposites. Sorts by size. Recognizes self in photos.',
        ky: 'Counts to 2 or 3 (not always in order). Understands opposites. Sorts by size. Recognizes self in photos.',
      ),
      socialEmotional:
          L3(
        en: 'Shows a range of emotions. Starts saying "thank you." Shows pride. Parallel play transitioning to some interactive play.',
        ru: 'Shows a range of emotions. Starts saying "thank you." Shows pride. Parallel play transitioning to some interactive play.',
        ky: 'Shows a range of emotions. Starts saying "thank you." Shows pride. Parallel play transitioning to some interactive play.',
      ),
      languageDevelopment:
          L3(
        en: '100-300+ words. 2-4 word sentences. Understands most of what you say. Uses "I," "me," "you."',
        ru: '100-300+ words. 2-4 word sentences. Understands most of what you say. Uses "I," "me," "you."',
        ky: '100-300+ words. 2-4 word sentences. Understands most of what you say. Uses "I," "me," "you."',
      ),
      milestones: const [
        MilestoneItem(L3(en: 'Runs smoothly', ru: 'Runs smoothly', ky: 'Runs smoothly'), MilestoneCategory.motor),
        MilestoneItem(L3(en: '100-300+ words', ru: '100-300+ words', ky: '100-300+ words'), MilestoneCategory.language),
        MilestoneItem(L3(en: '2-4 word sentences', ru: '2-4 word sentences', ky: '2-4 word sentences'), MilestoneCategory.language),
        MilestoneItem(L3(en: 'Sorts by size', ru: 'Sorts by size', ky: 'Sorts by size'), MilestoneCategory.cognitive),
      ],
      activities: const [
        L3(en: 'Potty introduction if ready', ru: 'Potty introduction if ready', ky: 'Potty introduction if ready'),
        L3(en: 'Dance parties, music', ru: 'Dance parties, music', ky: 'Dance parties, music'),
        L3(en: 'Puzzles (4-8 pieces)', ru: 'Puzzles (4-8 pieces)', ky: 'Puzzles (4-8 pieces)'),
        L3(en: 'Chalk outdoors', ru: 'Chalk outdoors', ky: 'Chalk outdoors'),
        L3(en: 'Simple pretend play with storyline', ru: 'Simple pretend play with storyline', ky: 'Simple pretend play with storyline'),
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: L3(en: '10-11h night, 1 nap (1-2 hours).', ru: '10-11h night, 1 nap (1-2 hours).', ky: '10-11h night, 1 nap (1-2 hours).'),
        tips: [
          L3(en: 'Naptime is valuable — keep it', ru: 'Naptime is valuable — keep it', ky: 'Naptime is valuable — keep it'),
          L3(en: 'Nightmares can happen — comfort quickly', ru: 'Nightmares can happen — comfort quickly', ky: 'Nightmares can happen — comfort quickly'),
          L3(en: 'Toddler bed can wait until 2.5-3', ru: 'Toddler bed can wait until 2.5-3', ky: 'Toddler bed can wait until 2.5-3'),
          L3(en: 'Dark room, cool temp, quiet', ru: 'Dark room, cool temp, quiet', ky: 'Dark room, cool temp, quiet'),
        ],
      ),
      feeding: const FeedingGuide(
        type: L3(en: 'Family foods', ru: 'Family foods', ky: 'Family foods'),
        frequency: L3(en: '3 meals + 2 snacks', ru: '3 meals + 2 snacks', ky: '3 meals + 2 snacks'),
        amount: L3(en: 'Growing toddler portions', ru: 'Growing toddler portions', ky: 'Growing toddler portions'),
        tips: [
          L3(en: 'Almost switching to low-fat milk (at 2)', ru: 'Almost switching to low-fat milk (at 2)', ky: 'Almost switching to low-fat milk (at 2)'),
          L3(en: 'Expand vegetables gradually', ru: 'Expand vegetables gradually', ky: 'Expand vegetables gradually'),
          L3(en: 'Water always available', ru: 'Water always available', ky: 'Water always available'),
          L3(en: 'Keep offering new foods', ru: 'Keep offering new foods', ky: 'Keep offering new foods'),
        ],
      ),
      redFlags: const [
        L3(en: 'Does not combine 2 words', ru: 'Does not combine 2 words', ky: 'Does not combine 2 words'),
        L3(en: 'Uses fewer than 25 words', ru: 'Uses fewer than 25 words', ky: 'Uses fewer than 25 words'),
        L3(en: 'Cannot walk well', ru: 'Cannot walk well', ky: 'Cannot walk well'),
        L3(en: 'Does not follow simple directions', ru: 'Does not follow simple directions', ky: 'Does not follow simple directions'),
      ],
      parentTips: const [
        L3(en: 'Second birthday planning time', ru: 'Second birthday planning time', ky: 'Second birthday planning time'),
        L3(en: 'Pictures, pictures, pictures', ru: 'Pictures, pictures, pictures', ky: 'Pictures, pictures, pictures'),
        L3(en: 'Emotion coaching never stops', ru: 'Emotion coaching never stops', ky: 'Emotion coaching never stops'),
        L3(en: 'You\'re almost a parent of a 2-year-old!', ru: 'You\'re almost a parent of a 2-year-old!', ky: 'You\'re almost a parent of a 2-year-old!'),
      ],
    ),
  };
}

// =========================================================
// SUPPORTING MODELS
// =========================================================

enum MilestoneCategory {
  motor('Motor', '🏃'),
  cognitive('Cognitive', '🧠'),
  language('Language', '🗣️'),
  social('Social & Emotional', '💕'),
  sensory('Sensory', '👁️'),
  feeding('Feeding', '🍽️');

  const MilestoneCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

class MilestoneItem {
  final L3 description;
  final MilestoneCategory category;

  const MilestoneItem(this.description, this.category);
}

class SleepGuide {
  final String totalHours;
  final L3 pattern;
  final List<L3> tips;

  const SleepGuide({
    required this.totalHours,
    required this.pattern,
    required this.tips,
  });
}

class FeedingGuide {
  final L3 type;
  final L3 frequency;
  final L3 amount;
  final List<L3> tips;

  const FeedingGuide({
    required this.type,
    required this.frequency,
    required this.amount,
    required this.tips,
  });
}

class HealthCheckup {
  final L3 timing;
  final List<L3> vaccines;
  final List<L3> screenings;

  const HealthCheckup({
    required this.timing,
    required this.vaccines,
    required this.screenings,
  });
}

/// Week-by-week pregnancy data — the core of the journey experience
import '../../core/l10n/content_localizations.dart';

class PregnancyWeekData {
  final int week;
  final L3 babySize;
  final String babySizeEmoji;
  final double babyLengthCm;
  final double babyWeightG;
  final L3 babyDevelopment;
  final List<L3> commonSymptoms;
  final List<L3> tips;
  final L3 trimester;

  const PregnancyWeekData({
    required this.week,
    required this.babySize,
    required this.babySizeEmoji,
    required this.babyLengthCm,
    required this.babyWeightG,
    required this.babyDevelopment,
    required this.commonSymptoms,
    required this.tips,
    required this.trimester,
  });

  static PregnancyWeekData getWeek(int week) {
    final clamped = week.clamp(4, 42);
    // Exact match
    if (_weekData.containsKey(clamped)) return _weekData[clamped]!;
    // Find closest week (prefer earlier)
    final keys = _weekData.keys.toList()..sort();
    int closest = keys.first;
    for (final k in keys) {
      if (k <= clamped) closest = k;
    }
    return _weekData[closest]!;
  }

  static const _first = L3(en: 'First', ru: 'Первый', ky: 'Биринчи');
  static const _second = L3(en: 'Second', ru: 'Второй', ky: 'Экинчи');
  static const _third = L3(en: 'Third', ru: 'Третий', ky: 'Үчүнчү');

  static final Map<int, PregnancyWeekData> _weekData = {
    // =====================================================
    // WEEK 4
    // =====================================================
    4: const PregnancyWeekData(
      week: 4,
      babySize: L3(
        en: 'Poppy seed',
        ru: 'Маковое зёрнышко',
        ky: 'Кызгалдак уругу',
      ),
      babySizeEmoji: '🫘',
      babyLengthCm: 0.1,
      babyWeightG: 0.04,
      babyDevelopment: L3(
        en: 'The embryo has implanted in the uterus. The neural tube, which becomes the brain and spinal cord, is forming.',
        ru: 'Эмбрион имплантировался в матку. Формируется нервная трубка, из которой разовьются головной и спинной мозг.',
        ky: 'Эмбрион жатынга орношту. Мээ жана жүлүн болуп калчу нерв түтүкчөсү түзүлүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Missed period', ru: 'Задержка менструации', ky: 'Айбашынын кечигүүсү'),
        L3(en: 'Light spotting', ru: 'Лёгкие мажущие выделения', ky: 'Жеңил тамчылоо'),
        L3(en: 'Fatigue', ru: 'Усталость', ky: 'Чарчоо'),
        L3(en: 'Tender breasts', ru: 'Чувствительность груди', ky: 'Эмчектин сезгичтиги'),
      ],
      tips: [
        L3(
          en: 'Start taking prenatal vitamins if you haven\'t already',
          ru: 'Начните принимать витамины для беременных, если ещё не начали',
          ky: 'Кош бойлуулар үчүн витаминдерди ичүүнү баштаңыз',
        ),
        L3(
          en: 'Schedule your first prenatal appointment',
          ru: 'Запишитесь на первый приём к акушеру-гинекологу',
          ky: 'Акушер-гинекологго биринчи кабыл алууга жазылыңыз',
        ),
        L3(
          en: 'Avoid alcohol and smoking',
          ru: 'Откажитесь от алкоголя и курения',
          ky: 'Алкоголь жана тамекиден баш тартыңыз',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 5
    // =====================================================
    5: const PregnancyWeekData(
      week: 5,
      babySize: L3(
        en: 'Sesame seed',
        ru: 'Кунжутное семечко',
        ky: 'Кунжут уругу',
      ),
      babySizeEmoji: '🫘',
      babyLengthCm: 0.2,
      babyWeightG: 0.08,
      babyDevelopment: L3(
        en: 'The heart begins to form and may start beating this week. The neural tube is closing. Tiny arm and leg buds appear. The embryo is growing about 1mm per day.',
        ru: 'Сердце начинает формироваться и может начать биться на этой неделе. Нервная трубка закрывается. Появляются зачатки ручек и ножек. Эмбрион растёт примерно на 1 мм в день.',
        ky: 'Жүрөк түзүлө баштайт жана бул жумада согуп баштайт. Нерв түтүкчөсү жабылууда. Кол жана бут бүчүрлөрү пайда болот. Эмбрион күнүнө 1 мм чоңоюуда.',
      ),
      commonSymptoms: [
        L3(en: 'Positive pregnancy test', ru: 'Положительный тест на беременность', ky: 'Кош бойлуулукка тест оң'),
        L3(en: 'Breast tenderness', ru: 'Болезненность груди', ky: 'Эмчектин ооруусу'),
        L3(en: 'Fatigue deepens', ru: 'Усталость усиливается', ky: 'Чарчоо күчөйт'),
        L3(en: 'Frequent urination starts', ru: 'Частое мочеиспускание', ky: 'Тез-тез заара кылуу башталат'),
        L3(en: 'Mild cramping', ru: 'Лёгкие спазмы', ky: 'Жеңил түйүлүүлөр'),
      ],
      tips: [
        L3(
          en: 'Confirm pregnancy with your doctor',
          ru: 'Подтвердите беременность у врача',
          ky: 'Кош бойлуулугуңузду дарыгерден тастыктаңыз',
        ),
        L3(
          en: 'Prenatal vitamins with folic acid are essential',
          ru: 'Витамины для беременных с фолиевой кислотой обязательны',
          ky: 'Фолий кислотасы бар витаминдер абдан маанилүү',
        ),
        L3(
          en: 'Cut out alcohol, smoking, and hot tubs',
          ru: 'Исключите алкоголь, курение и горячие ванны',
          ky: 'Алкоголь, тамеки жана ысык ваннадан баш тартыңыз',
        ),
        L3(
          en: 'Rest when you need to — growing a human is hard work',
          ru: 'Отдыхайте, когда нужно — вы выращиваете человека, это серьёзная работа',
          ky: 'Керек болгондо эс алыңыз — бала өстүрүү оор жумуш',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 6
    // =====================================================
    6: const PregnancyWeekData(
      week: 6,
      babySize: L3(
        en: 'Sweet pea',
        ru: 'Горошинка',
        ky: 'Буурчак данеги',
      ),
      babySizeEmoji: '🟢',
      babyLengthCm: 0.5,
      babyWeightG: 0.2,
      babyDevelopment: L3(
        en: 'The heart beats at 100-150 beats per minute — often visible on ultrasound now. Eyes and ears are forming as tiny dark spots. Arm and leg buds are growing.',
        ru: 'Сердце бьётся с частотой 100–150 ударов в минуту — часто уже видно на УЗИ. Глаза и уши формируются в виде крошечных тёмных точек. Зачатки рук и ног растут.',
        ky: 'Жүрөк мүнөтүнө 100–150 жолу согуп жатат — УЗИде көрүнөт. Көз жана кулактар кичинекей кара тактар катары түзүлүүдө. Кол жана бут бүчүрлөрү өсүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Morning sickness may begin', ru: 'Может начаться утренняя тошнота', ky: 'Эртеңки жүрөк айлануу башталышы мүмкүн'),
        L3(en: 'Heightened sense of smell', ru: 'Обострённое обоняние', ky: 'Жыт сезүүнүн күчөшү'),
        L3(en: 'Food aversions', ru: 'Отвращение к еде', ky: 'Тамактан жийиркенүү'),
        L3(en: 'Mood swings', ru: 'Перепады настроения', ky: 'Маанайдын өзгөрүшү'),
        L3(en: 'Frequent urination', ru: 'Частое мочеиспускание', ky: 'Тез-тез заара кылуу'),
      ],
      tips: [
        L3(
          en: 'Your first prenatal visit may happen this week',
          ru: 'На этой неделе может быть ваш первый визит к врачу',
          ky: 'Бул жумада биринчи дарыгерге барууңуз болушу мүмкүн',
        ),
        L3(
          en: 'Eat crackers before getting out of bed for nausea',
          ru: 'Ешьте крекеры до подъёма с кровати при тошноте',
          ky: 'Жүрөк айланууда төшөктөн турардан мурун крекер жеңиз',
        ),
        L3(
          en: 'Small frequent meals beat 3 big ones',
          ru: 'Частые маленькие порции лучше 3 больших',
          ky: 'Тез-тез аз тамактануу 3 чоң тамактан жакшы',
        ),
        L3(
          en: 'Ginger and vitamin B6 help with nausea',
          ru: 'Имбирь и витамин B6 помогают при тошноте',
          ky: 'Имбирь жана B6 витамини жүрөк айланууга жардам берет',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 7
    // =====================================================
    7: const PregnancyWeekData(
      week: 7,
      babySize: L3(
        en: 'Blueberry',
        ru: 'Черника',
        ky: 'Черника',
      ),
      babySizeEmoji: '🫐',
      babyLengthCm: 1.0,
      babyWeightG: 0.5,
      babyDevelopment: L3(
        en: 'Baby\'s brain is growing rapidly — about 100 cells per minute. The mouth and tongue are forming. Hand and foot paddles appear. Nostrils form.',
        ru: 'Мозг малыша растёт стремительно — около 100 клеток в минуту. Формируются рот и язык. Появляются кисти и стопы в виде лопаточек. Формируются ноздри.',
        ky: 'Баланын мээси тез өсүүдө — мүнөтүнө 100 клетка. Ооз жана тил түзүлүүдө. Алакан жана табан калыптанууда. Мурун тешиктери пайда болууда.',
      ),
      commonSymptoms: [
        L3(en: 'Full-blown morning sickness', ru: 'Сильная утренняя тошнота', ky: 'Күчтүү эртеңки жүрөк айлануу'),
        L3(en: 'Exhaustion', ru: 'Истощение', ky: 'Чаалыгуу'),
        L3(en: 'Larger, sore breasts', ru: 'Увеличенная, болезненная грудь', ky: 'Чоңойгон, ооруган эмчек'),
        L3(en: 'Heartburn may start', ru: 'Может начаться изжога', ky: 'Ашказандын ачышы башталышы мүмкүн'),
        L3(en: 'Emotional roller coaster', ru: 'Эмоциональные «горки»', ky: 'Эмоциялык толкундоолор'),
      ],
      tips: [
        L3(
          en: 'Stay hydrated — aim for 10 glasses of water daily',
          ru: 'Пейте больше воды — не менее 10 стаканов в день',
          ky: 'Суу ичиңиз — күнүнө 10 стакандан кем эмес',
        ),
        L3(
          en: 'Eat what stays down; nutrition matters less than calories right now',
          ru: 'Ешьте то, что удерживается; сейчас калории важнее идеального питания',
          ky: 'Сиңимдүүнү жеңиз; азыр калория толук тамактанмадан маанилүүрөөк',
        ),
        L3(
          en: 'Nap without guilt',
          ru: 'Спите днём без чувства вины',
          ky: 'Күндүз уйкулаңыз — ыйбаа кылбаңыз',
        ),
        L3(
          en: 'Tell your workplace if your job involves hazardous exposure',
          ru: 'Сообщите на работе, если ваша работа связана с вредными факторами',
          ky: 'Жумушуңуз зыяндуу болсо, жетекчиликке айтыңыз',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 8
    // =====================================================
    8: const PregnancyWeekData(
      week: 8,
      babySize: L3(
        en: 'Raspberry',
        ru: 'Малина',
        ky: 'Малина',
      ),
      babySizeEmoji: '🫐',
      babyLengthCm: 1.6,
      babyWeightG: 1.0,
      babyDevelopment: L3(
        en: 'Baby\'s fingers and toes are forming. The heart is beating at about 150 beats per minute — twice as fast as yours!',
        ru: 'Формируются пальчики на руках и ногах. Сердце бьётся с частотой около 150 ударов в минуту — вдвое быстрее вашего!',
        ky: 'Баланын кол жана бут манжалары түзүлүүдө. Жүрөк мүнөтүнө 150 жолу согуп жатат — сиздикинен эки эсе тез!',
      ),
      commonSymptoms: [
        L3(en: 'Morning sickness', ru: 'Утренняя тошнота', ky: 'Эртеңки жүрөк айлануу'),
        L3(en: 'Fatigue', ru: 'Усталость', ky: 'Чарчоо'),
        L3(en: 'Frequent urination', ru: 'Частое мочеиспускание', ky: 'Тез-тез заара кылуу'),
        L3(en: 'Food aversions', ru: 'Отвращение к еде', ky: 'Тамактан жийиркенүү'),
      ],
      tips: [
        L3(
          en: 'Eat small, frequent meals to manage nausea',
          ru: 'Ешьте часто и понемногу, чтобы уменьшить тошноту',
          ky: 'Жүрөк айланууну азайтуу үчүн аз-аздан тез-тез тамактаныңыз',
        ),
        L3(
          en: 'Stay hydrated',
          ru: 'Пейте достаточно жидкости',
          ky: 'Суусундукту жетиштүү ичиңиз',
        ),
        L3(
          en: 'Rest when you can — your body is working hard',
          ru: 'Отдыхайте при возможности — ваш организм работает за двоих',
          ky: 'Мүмкүнчүлүк болгондо эс алыңыз — денеңиз эки адамга иштеп жатат',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 9
    // =====================================================
    9: const PregnancyWeekData(
      week: 9,
      babySize: L3(
        en: 'Grape',
        ru: 'Виноградинка',
        ky: 'Жүзүм данеги',
      ),
      babySizeEmoji: '🍇',
      babyLengthCm: 2.3,
      babyWeightG: 2.0,
      babyDevelopment: L3(
        en: 'Baby is now officially a fetus — no longer an embryo. All essential organs have begun to form. Tiny toes are visible. The tail is gone. Muscles begin to develop.',
        ru: 'Малыш теперь официально плод — больше не эмбрион. Все основные органы начали формироваться. Видны крошечные пальчики ног. Хвостик исчез. Мышцы начинают развиваться.',
        ky: 'Бала эми расмий түрдө урук (плод) — эмбрион эмес. Бардык негизги органдар түзүлө баштады. Бут манжалары көрүнөт. Куйрук жоголду. Булчуңдар өнүгө баштады.',
      ),
      commonSymptoms: [
        L3(en: 'Nausea often peaks', ru: 'Тошнота часто достигает пика', ky: 'Жүрөк айлануу эң күчтүү болот'),
        L3(en: 'Bloating', ru: 'Вздутие живота', ky: 'Ичтин көбүүсү'),
        L3(en: 'Constipation', ru: 'Запор', ky: 'Ич каттоо'),
        L3(en: 'Visible veins', ru: 'Заметные вены', ky: 'Тамырлардын көрүнүшү'),
        L3(en: 'Increased vaginal discharge (normal)', ru: 'Усиленные выделения (норма)', ky: 'Бөлүнүүлөрдүн көбөйүшү (нормалдуу)'),
      ],
      tips: [
        L3(
          en: 'Genetic screening options can be discussed now',
          ru: 'Сейчас можно обсудить варианты генетического скрининга',
          ky: 'Генетикалык скрининг жөнүндө сүйлөшүүгө мезгил келди',
        ),
        L3(
          en: 'Eat fiber-rich foods for constipation',
          ru: 'Ешьте продукты, богатые клетчаткой, от запора',
          ky: 'Ич каттоого каршы клетчаткага бай тамак жеңиз',
        ),
        L3(
          en: 'Comfortable shoes — feet may start swelling',
          ru: 'Удобная обувь — ноги могут начать отекать',
          ky: 'Ыңгайлуу бут кийим — буттар шишиши мүмкүн',
        ),
        L3(
          en: 'Acupressure wristbands help nausea for some',
          ru: 'Акупрессурные браслеты помогают некоторым от тошноты',
          ky: 'Акупрессура билериктери кээ бирөөлөргө жардам берет',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 10
    // =====================================================
    10: const PregnancyWeekData(
      week: 10,
      babySize: L3(
        en: 'Strawberry',
        ru: 'Клубника',
        ky: 'Кулпунай',
      ),
      babySizeEmoji: '🍓',
      babyLengthCm: 3.1,
      babyWeightG: 4.0,
      babyDevelopment: L3(
        en: 'Vital organs are formed and will grow and mature from here. Fingernails begin forming. Baby can bend limbs. Tooth buds appear in the gums.',
        ru: 'Жизненно важные органы сформированы и будут расти и созревать дальше. Начинают формироваться ногти. Малыш может сгибать конечности. В дёснах появляются зачатки зубов.',
        ky: 'Негизги органдар түзүлдү жана мындан ары өсүп жетилет. Тырмактар пайда болуп баштайт. Бала муундарын бүгө алат. Тиш бүчүрлөрү пайда болот.',
      ),
      commonSymptoms: [
        L3(en: 'Visible weight gain may begin', ru: 'Может начаться заметная прибавка в весе', ky: 'Салмак кошулуусу байкалышы мүмкүн'),
        L3(en: 'Round ligament twinges', ru: 'Покалывание круглых связок', ky: 'Тегерек байламдын сыздоосу'),
        L3(en: 'Acne flare-ups', ru: 'Обострение акне', ky: 'Безгектердин чыгышы'),
        L3(en: 'Vivid dreams', ru: 'Яркие сны', ky: 'Жаркын түштөр'),
        L3(en: 'Slight belly bloat', ru: 'Лёгкое вздутие живота', ky: 'Ичтин бир аз көбүүсү'),
      ],
      tips: [
        L3(
          en: 'NIPT (non-invasive prenatal testing) available from week 10',
          ru: 'НИПТ (неинвазивный пренатальный тест) доступен с 10-й недели',
          ky: 'НИПТ (инвазивсиз пренаталдык тест) 10-жумадан баштап жеткиликтүү',
        ),
        L3(
          en: 'Start thinking about who to announce to first',
          ru: 'Подумайте, кому рассказать первому',
          ky: 'Кимге биринчи айтарыңызды ойлоп баштаңыз',
        ),
        L3(
          en: 'Gentle exercise like walking is great now',
          ru: 'Лёгкие упражнения, например прогулки, сейчас очень полезны',
          ky: 'Басуу сыяктуу жеңил көнүгүүлөр азыр абдан пайдалуу',
        ),
        L3(
          en: 'Moisturize your belly — stretching skin needs love',
          ru: 'Увлажняйте кожу живота — растягивающейся коже нужен уход',
          ky: 'Курсагыңыздын терисин нымдаңыз — созулган тери кам көрүүнү талап кылат',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 11
    // =====================================================
    11: const PregnancyWeekData(
      week: 11,
      babySize: L3(
        en: 'Fig',
        ru: 'Инжир',
        ky: 'Инжир',
      ),
      babySizeEmoji: '🫑',
      babyLengthCm: 4.1,
      babyWeightG: 7.0,
      babyDevelopment: L3(
        en: 'Baby\'s head is still large relative to body. External genitals start to differentiate. Fingers are separating. Baby practices kicking and stretching (too small to feel).',
        ru: 'Голова малыша всё ещё велика относительно тела. Наружные половые органы начинают дифференцироваться. Пальцы разделяются. Малыш тренируется пинаться и потягиваться (слишком мал, чтобы чувствовать).',
        ky: 'Баланын башы денесине караганда чоң. Сырткы жыныстык органдар айырмалана баштайт. Манжалар бөлүнүүдө. Бала тепкилеп жана керилип машыгат (сезүүгө али эрте).',
      ),
      commonSymptoms: [
        L3(en: 'Nausea may be easing', ru: 'Тошнота может ослабевать', ky: 'Жүрөк айлануу басылышы мүмкүн'),
        L3(en: 'Energy returning slowly', ru: 'Энергия медленно возвращается', ky: 'Күч акырындап кайтууда'),
        L3(en: 'Metallic taste may fade', ru: 'Металлический привкус может пройти', ky: 'Оозундагы металл даамы өтүшү мүмкүн'),
        L3(en: 'Heightened libido for some', ru: 'Повышение либидо у некоторых', ky: 'Кээ бирөөлөрдө либидонун жогорулашы'),
      ],
      tips: [
        L3(
          en: 'First trimester screening window (11-14 weeks)',
          ru: 'Окно скрининга первого триместра (11–14 недель)',
          ky: 'Биринчи триместр скринингинин мөөнөтү (11–14 жума)',
        ),
        L3(
          en: 'Dental cleaning is safe and important',
          ru: 'Чистка зубов у стоматолога безопасна и важна',
          ky: 'Тиш тазалатуу коопсуз жана маанилүү',
        ),
        L3(
          en: 'Sleep on your left side for best circulation',
          ru: 'Спите на левом боку для лучшего кровообращения',
          ky: 'Жакшы кан айлануу үчүн сол капталга жатыңыз',
        ),
        L3(
          en: 'Still no need for maternity clothes — soft waistbands help',
          ru: 'Одежда для беременных пока не нужна — мягкие пояса помогут',
          ky: 'Кош бойлуулар кийими али керек эмес — жумшак белдиктер жардам берет',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 12
    // =====================================================
    12: const PregnancyWeekData(
      week: 12,
      babySize: L3(
        en: 'Lime',
        ru: 'Лайм',
        ky: 'Лайм',
      ),
      babySizeEmoji: '🍋',
      babyLengthCm: 5.4,
      babyWeightG: 14.0,
      babyDevelopment: L3(
        en: 'Baby can open and close their fists. Fingernails are forming. Vocal cords are developing.',
        ru: 'Малыш может сжимать и разжимать кулачки. Формируются ногти. Развиваются голосовые связки.',
        ky: 'Бала муштумдарын жумуп жана ачат. Тырмактар түзүлүүдө. Үн тарамыштары өнүгүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Morning sickness easing', ru: 'Утренняя тошнота ослабевает', ky: 'Эртеңки жүрөк айлануу басылууда'),
        L3(en: 'Growing belly', ru: 'Растущий животик', ky: 'Чоңоюп жаткан курсак'),
        L3(en: 'Dizziness', ru: 'Головокружение', ky: 'Баш айлануу'),
        L3(en: 'Increased energy', ru: 'Прилив энергии', ky: 'Күчтүн кайтуусу'),
      ],
      tips: [
        L3(
          en: 'This is a common time to share the news!',
          ru: 'Самое время поделиться новостью!',
          ky: 'Жакшы кабарды бөлүшүүгө мезгил келди!',
        ),
        L3(
          en: 'First trimester screening can happen now',
          ru: 'Скрининг первого триместра можно пройти сейчас',
          ky: 'Биринчи триместр скринингин азыр өткөрсө болот',
        ),
        L3(
          en: 'Start a pregnancy journal',
          ru: 'Начните вести дневник беременности',
          ky: 'Кош бойлуулук күндөлүгүн жүргүзө баштаңыз',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 13
    // =====================================================
    13: const PregnancyWeekData(
      week: 13,
      babySize: L3(
        en: 'Lemon',
        ru: 'Лимон',
        ky: 'Лимон',
      ),
      babySizeEmoji: '🍋',
      babyLengthCm: 7.4,
      babyWeightG: 23.0,
      babyDevelopment: L3(
        en: 'Welcome to the LAST week of first trimester! Vocal cords are forming. Baby can put thumb in mouth. Intestines move from umbilical cord into the abdomen.',
        ru: 'Добро пожаловать в ПОСЛЕДНЮЮ неделю первого триместра! Голосовые связки формируются. Малыш может сосать большой палец. Кишечник перемещается из пуповины в брюшную полость.',
        ky: 'Биринчи триместрдин АКЫРКЫ жумасына кош келиңиз! Үн тарамыштары түзүлүүдө. Бала бармагын соро алат. Ичеги киндик боодон курсак көңдөйүнө жылат.',
      ),
      commonSymptoms: [
        L3(en: 'Lower miscarriage risk from here', ru: 'Риск выкидыша снижается', ky: 'Бойдон түшүү коркунучу азаят'),
        L3(en: 'Energy returning', ru: 'Энергия возвращается', ky: 'Күч кайтууда'),
        L3(en: 'Less nausea for most', ru: 'Меньше тошноты у большинства', ky: 'Көпчүлүктө жүрөк айлануу азаят'),
        L3(en: 'Visible baby bump for some', ru: 'У некоторых заметен животик', ky: 'Кээ бирөөлөрдө курсак байкалат'),
      ],
      tips: [
        L3(
          en: 'Celebrate — the hardest trimester is almost done!',
          ru: 'Празднуйте — самый тяжёлый триместр почти позади!',
          ky: 'Куттуктаңыз — эң оор триместр бүтүп баратат!',
        ),
        L3(
          en: 'Time to share the news with close family if you want',
          ru: 'Самое время рассказать близким, если хотите',
          ky: 'Каалсаңыз, жакындарга кабар айтууга убакыт келди',
        ),
        L3(
          en: 'Schedule the anatomy scan (around week 20)',
          ru: 'Запланируйте УЗИ-скрининг (примерно на 20-й неделе)',
          ky: 'Анатомиялык УЗИ жазылыңыз (20-жума чамасында)',
        ),
        L3(
          en: 'Start thinking about maternity clothes shopping',
          ru: 'Пора подумать о покупке одежды для беременных',
          ky: 'Кош бойлуулар кийимин сатып алууну ойлоно баштаңыз',
        ),
      ],
      trimester: _first,
    ),

    // =====================================================
    // WEEK 14
    // =====================================================
    14: const PregnancyWeekData(
      week: 14,
      babySize: L3(
        en: 'Peach',
        ru: 'Персик',
        ky: 'Шабдаалы',
      ),
      babySizeEmoji: '🍑',
      babyLengthCm: 8.7,
      babyWeightG: 43.0,
      babyDevelopment: L3(
        en: 'Welcome to the second trimester — often called the "golden" one! Baby can make facial expressions. Hair begins to grow. Liver and kidneys start functioning.',
        ru: 'Добро пожаловать во второй триместр — его часто называют «золотым»! Малыш может строить гримасы. Начинают расти волосы. Печень и почки начинают работать.',
        ky: 'Экинчи триместрге кош келиңиз — аны «алтын мезгил» деп аташат! Бала жүз кыймылдарын жасай алат. Чач өсө баштайт. Боор жана бөйрөк иштей баштайт.',
      ),
      commonSymptoms: [
        L3(en: 'Energy returning', ru: 'Энергия возвращается', ky: 'Күч кайтууда'),
        L3(en: 'Bump starting to show', ru: 'Животик начинает быть заметным', ky: 'Курсак көрүнө баштоодо'),
        L3(en: 'Round ligament pain', ru: 'Боль в круглой связке', ky: 'Тегерек байламдын ооруусу'),
        L3(en: 'Nasal congestion (pregnancy rhinitis)', ru: 'Заложенность носа (ринит беременных)', ky: 'Мурундун тумоолуусу (кош бойлуулардын риниди)'),
      ],
      tips: [
        L3(
          en: 'Start a pregnancy journal if you want',
          ru: 'Если хотите, начните вести дневник беременности',
          ky: 'Каалсаңыз, кош бойлуулук күндөлүгүн баштаңыз',
        ),
        L3(
          en: 'Schedule a babymoon while travel is easier',
          ru: 'Запланируйте романтический отпуск, пока путешествовать комфортнее',
          ky: 'Саякаттоо жеңил кезде бэбимун пландаңыз',
        ),
        L3(
          en: 'Keep up with hydration — you need 10+ glasses daily',
          ru: 'Пейте достаточно воды — вам нужно 10+ стаканов в день',
          ky: 'Суу ичүүнү унутпаңыз — күнүнө 10+ стакан керек',
        ),
        L3(
          en: 'Saline nasal spray helps congestion',
          ru: 'Солевой спрей для носа помогает при заложенности',
          ky: 'Туздуу мурун спрейи тумоолукка жардам берет',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 15
    // =====================================================
    15: const PregnancyWeekData(
      week: 15,
      babySize: L3(
        en: 'Apple',
        ru: 'Яблоко',
        ky: 'Алма',
      ),
      babySizeEmoji: '🍎',
      babyLengthCm: 10.1,
      babyWeightG: 70.0,
      babyDevelopment: L3(
        en: 'Baby can sense light through eyelids. Taste buds are developing. Skeletal system is hardening. Baby wiggles, though you may not feel it yet.',
        ru: 'Малыш чувствует свет через веки. Развиваются вкусовые рецепторы. Скелет твердеет. Малыш шевелится, хотя вы можете этого ещё не ощущать.',
        ky: 'Бала жарыкты кабактары аркылуу сезет. Даам сезүү рецепторлору өнүгүүдө. Скелет катуулоодо. Бала кыймылдайт, бирок сиз аны али сезбешиңиз мүмкүн.',
      ),
      commonSymptoms: [
        L3(en: 'Rosy glow of pregnancy', ru: 'Сияние беременности', ky: 'Кош бойлуулуктун нуру'),
        L3(en: 'Increased sex drive for some', ru: 'Повышение либидо у некоторых', ky: 'Кээ бирөөлөрдө либидонун жогорулашы'),
        L3(en: 'Slight bleeding gums', ru: 'Лёгкая кровоточивость дёсен', ky: 'Тиш этинин бир аз канашы'),
        L3(en: 'Bigger appetite', ru: 'Повышенный аппетит', ky: 'Ашказандын ачылышы'),
      ],
      tips: [
        L3(
          en: 'Use a soft toothbrush — gums are sensitive',
          ru: 'Используйте мягкую зубную щётку — дёсны чувствительны',
          ky: 'Жумшак тиш щёткасын колдонуңуз — тиш эти сезгич',
        ),
        L3(
          en: 'Prenatal yoga can start now',
          ru: 'Йога для беременных уже можно начинать',
          ky: 'Кош бойлуулар үчүн йога баштаса болот',
        ),
        L3(
          en: 'Eat 300 extra calories per day',
          ru: 'Съедайте на 300 калорий больше в день',
          ky: 'Күнүнө 300 кошумча калория жеңиз',
        ),
        L3(
          en: 'Consider getting the flu shot (safe in pregnancy)',
          ru: 'Рассмотрите прививку от гриппа (безопасна при беременности)',
          ky: 'Грипке каршы эмдөө жөнүндө ойлонуңуз (кош бойлуулукта коопсуз)',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 16
    // =====================================================
    16: const PregnancyWeekData(
      week: 16,
      babySize: L3(
        en: 'Avocado',
        ru: 'Авокадо',
        ky: 'Авокадо',
      ),
      babySizeEmoji: '🥑',
      babyLengthCm: 11.6,
      babyWeightG: 100.0,
      babyDevelopment: L3(
        en: 'Baby can make facial expressions now. Their eyes can slowly move. The nervous system is functioning.',
        ru: 'Малыш уже может строить гримасы. Глазки медленно двигаются. Нервная система функционирует.',
        ky: 'Бала жүз кыймылдарын жасай алат. Көздөрү жай кыймылдайт. Нерв системасы иштеп жатат.',
      ),
      commonSymptoms: [
        L3(en: 'Round ligament pain', ru: 'Боль в круглой связке', ky: 'Тегерек байламдын ооруусу'),
        L3(en: 'Nasal congestion', ru: 'Заложенность носа', ky: 'Мурундун тумоолуусу'),
        L3(en: 'Backache', ru: 'Боль в спине', ky: 'Арканын ооруусу'),
        L3(en: 'Possible first flutters', ru: 'Возможны первые шевеления', ky: 'Биринчи кыймылдар болушу мүмкүн'),
      ],
      tips: [
        L3(
          en: 'You might feel the first movements (quickening) soon',
          ru: 'Скоро вы можете почувствовать первые шевеления',
          ky: 'Жакында биринчи кыймылдарды сезишиңиз мүмкүн',
        ),
        L3(
          en: 'Consider a gender reveal if finding out',
          ru: 'Можно устроить раскрытие пола, если хотите узнать',
          ky: 'Жынысын билгиңиз келсе, гендер-пати уюштурсаңыз болот',
        ),
        L3(
          en: 'Start sleeping on your side',
          ru: 'Начните спать на боку',
          ky: 'Капталга жатып уктай баштаңыз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 17
    // =====================================================
    17: const PregnancyWeekData(
      week: 17,
      babySize: L3(
        en: 'Pear',
        ru: 'Груша',
        ky: 'Алмурут',
      ),
      babySizeEmoji: '🍐',
      babyLengthCm: 13.0,
      babyWeightG: 140.0,
      babyDevelopment: L3(
        en: 'Baby is starting to grow a protective layer of fat. Umbilical cord is thicker and stronger. Sweat glands develop. Baby can hear loud noises from outside.',
        ru: 'У малыша начинает формироваться защитный слой жира. Пуповина стала толще и прочнее. Развиваются потовые железы. Малыш слышит громкие звуки извне.',
        ky: 'Баланын коргоочу май катмары пайда болуп баштады. Киндик боосу жоон жана бекем болду. Тер бездери өнүгүүдө. Бала сырттан катуу үндөрдү угат.',
      ),
      commonSymptoms: [
        L3(en: 'Heartburn', ru: 'Изжога', ky: 'Ашказандын ачышы'),
        L3(en: 'Increased appetite', ru: 'Повышенный аппетит', ky: 'Ашказандын ачылышы'),
        L3(en: 'Stuffy nose', ru: 'Заложенность носа', ky: 'Мурундун тумоолуусу'),
        L3(en: 'Strange aches in hips and abdomen', ru: 'Странные боли в бёдрах и животе', ky: 'Жамбаш жана курсактагы сыздоо'),
      ],
      tips: [
        L3(
          en: 'Elevate head with pillows for heartburn',
          ru: 'Приподнимите голову подушками при изжоге',
          ky: 'Ашказан ачышканда жаздыктар менен башыңызды көтөрүңүз',
        ),
        L3(
          en: 'Start sleeping on your side (left is best)',
          ru: 'Спите на боку (левый — лучше всего)',
          ky: 'Капталга жатып уктаңыз (сол капталы — эң жакшы)',
        ),
        L3(
          en: 'Stretching helps round ligament pain',
          ru: 'Растяжка помогает при боли в круглых связках',
          ky: 'Керилүү тегерек байламдын оорусуна жардам берет',
        ),
        L3(
          en: 'Start researching pediatricians',
          ru: 'Начните искать педиатра',
          ky: 'Педиатр издей баштаңыз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 18
    // =====================================================
    18: const PregnancyWeekData(
      week: 18,
      babySize: L3(
        en: 'Bell pepper',
        ru: 'Болгарский перец',
        ky: 'Болгар калемпири',
      ),
      babySizeEmoji: '🫑',
      babyLengthCm: 14.2,
      babyWeightG: 190.0,
      babyDevelopment: L3(
        en: 'Baby is yawning and hiccupping. Ears have moved to final position. Myelin (nerve coating) starts to form. Baby is very active — you may feel first movements.',
        ru: 'Малыш зевает и икает. Ушки заняли окончательное положение. Начинает формироваться миелин (оболочка нервов). Малыш очень активен — вы можете почувствовать первые шевеления.',
        ky: 'Бала эсиреп, ыкчырап жатат. Кулактар акыркы ордуна жайгашты. Миелин (нерв кабыгы) түзүлө баштады. Бала абдан активдүү — биринчи кыймылдарды сезишиңиз мүмкүн.',
      ),
      commonSymptoms: [
        L3(en: 'First flutters (quickening)', ru: 'Первые шевеления', ky: 'Биринчи кыймылдар'),
        L3(en: 'Dizziness when standing up', ru: 'Головокружение при вставании', ky: 'Турганда баш айлануу'),
        L3(en: 'Swelling in feet', ru: 'Отёки ног', ky: 'Буттардын шишиши'),
        L3(en: 'Backache', ru: 'Боль в спине', ky: 'Арканын ооруусу'),
      ],
      tips: [
        L3(
          en: 'Get up slowly to avoid dizziness',
          ru: 'Вставайте медленно, чтобы избежать головокружения',
          ky: 'Баш айланбас үчүн жай туруңуз',
        ),
        L3(
          en: 'Drink water — dehydration worsens dizziness',
          ru: 'Пейте воду — обезвоживание усиливает головокружение',
          ky: 'Суу ичиңиз — суусуздук баш айланууну күчөтөт',
        ),
        L3(
          en: 'Take the big anatomy scan appointment around now-20 weeks',
          ru: 'Запишитесь на большой анатомический скрининг (18–20 недель)',
          ky: 'Чоң анатомиялык скринингге жазылыңыз (18–20 жума)',
        ),
        L3(
          en: 'Talk to baby — they can hear you',
          ru: 'Разговаривайте с малышом — он вас слышит',
          ky: 'Бала менен сүйлөшүңүз — ал сизди угат',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 19
    // =====================================================
    19: const PregnancyWeekData(
      week: 19,
      babySize: L3(
        en: 'Mango',
        ru: 'Манго',
        ky: 'Манго',
      ),
      babySizeEmoji: '🥭',
      babyLengthCm: 15.3,
      babyWeightG: 240.0,
      babyDevelopment: L3(
        en: 'Vernix caseosa (white waxy coating) covers baby\'s skin for protection. Lanugo (fine hair) covers the body. Limbs are in proportion now.',
        ru: 'Первородная смазка (белое восковое покрытие) защищает кожу малыша. Лануго (тонкие волоски) покрывает тело. Конечности теперь пропорциональны.',
        ky: 'Баланын терисин первородный смазка (ак мом катмар) коргойт. Лануго (ичке түктөр) денени каптайт. Кол-буттар эми пропорционалдуу.',
      ),
      commonSymptoms: [
        L3(en: 'Round ligament pain more common', ru: 'Боль в круглой связке чаще', ky: 'Тегерек байламдын ооруусу тезирээк'),
        L3(en: 'Shortness of breath', ru: 'Одышка', ky: 'Дем кысылуу'),
        L3(en: 'Leg cramps at night', ru: 'Судороги ног по ночам', ky: 'Түнкүсүн бут түйүлүүсү'),
        L3(en: 'Skin changes (darker areolas)', ru: 'Изменения кожи (потемнение ареол)', ky: 'Теринин өзгөрүшү (ареоланын караюусу)'),
      ],
      tips: [
        L3(
          en: 'Stretch calves before bed to prevent cramps',
          ru: 'Разминайте икры перед сном, чтобы избежать судорог',
          ky: 'Түйүлүүдөн сактануу үчүн уктаардан мурун балтырларды керип коюңуз',
        ),
        L3(
          en: 'Bananas and magnesium help leg cramps',
          ru: 'Бананы и магний помогают при судорогах ног',
          ky: 'Банан жана магний бут түйүлүүсүнө жардам берет',
        ),
        L3(
          en: 'Don\'t skip meals — baby needs steady fuel',
          ru: 'Не пропускайте приёмы пищи — малышу нужно постоянное питание',
          ky: 'Тамакты калтырбаңыз — балага туруктуу тамактануу керек',
        ),
        L3(
          en: 'Moisturize belly — stretch marks may appear',
          ru: 'Увлажняйте живот — могут появиться растяжки',
          ky: 'Курсакты нымдаңыз — созулуу издери пайда болушу мүмкүн',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 20
    // =====================================================
    20: const PregnancyWeekData(
      week: 20,
      babySize: L3(
        en: 'Banana',
        ru: 'Банан',
        ky: 'Банан',
      ),
      babySizeEmoji: '🍌',
      babyLengthCm: 25.6,
      babyWeightG: 300.0,
      babyDevelopment: L3(
        en: 'Halfway there! Baby can hear sounds. They are developing a sleep-wake cycle. Vernix (waxy coating) covers the skin.',
        ru: 'Полпути пройдено! Малыш слышит звуки. У него формируется цикл сна и бодрствования. Первородная смазка покрывает кожу.',
        ky: 'Жарым жол артта! Бала үндөрдү угат. Уйку-ойгонуу цикли калыптанууда. Первородный смазка терини каптайт.',
      ),
      commonSymptoms: [
        L3(en: 'Visible baby movements', ru: 'Заметные шевеления малыша', ky: 'Баланын байкалган кыймылдары'),
        L3(en: 'Leg cramps', ru: 'Судороги ног', ky: 'Бут түйүлүүсү'),
        L3(en: 'Swelling in feet', ru: 'Отёки ног', ky: 'Буттардын шишиши'),
        L3(en: 'Shortness of breath', ru: 'Одышка', ky: 'Дем кысылуу'),
      ],
      tips: [
        L3(
          en: 'Anatomy scan ultrasound is usually around now',
          ru: 'Анатомическое УЗИ обычно проводится в это время',
          ky: 'Анатомиялык УЗИ адатта ушул мезгилде жүргүзүлөт',
        ),
        L3(
          en: 'Start thinking about a birth plan',
          ru: 'Начните думать о плане родов',
          ky: 'Төрөт планы жөнүндө ойлоно баштаңыз',
        ),
        L3(
          en: 'Keep up with pelvic floor exercises',
          ru: 'Продолжайте упражнения для мышц тазового дна',
          ky: 'Жамбаш түбү булчуңдарынын көнүгүүлөрүн улантыңыз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 21
    // =====================================================
    21: const PregnancyWeekData(
      week: 21,
      babySize: L3(
        en: 'Carrot',
        ru: 'Морковь',
        ky: 'Сабиз',
      ),
      babySizeEmoji: '🥕',
      babyLengthCm: 26.7,
      babyWeightG: 360.0,
      babyDevelopment: L3(
        en: 'Baby is producing meconium (first poop) already. Taste buds working — they taste flavors through amniotic fluid. Eyebrows and lids are forming.',
        ru: 'У малыша уже вырабатывается меконий (первый стул). Вкусовые рецепторы работают — малыш ощущает вкус околоплодных вод. Формируются брови и веки.',
        ky: 'Баланын мекониуму (биринчи нечи) иштелип чыгууда. Даам сезүү рецепторлору иштейт — бала жатын суюктугунун даамын сезет. Каштар жана кабактар түзүлүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Stronger kicks', ru: 'Более сильные толчки', ky: 'Күчтүүрөөк тепкилер'),
        L3(en: 'Braxton Hicks may start', ru: 'Могут начаться схватки Брэкстона-Хикса', ky: 'Брэкстон-Хикс жыйрылуулары башталышы мүмкүн'),
        L3(en: 'Swelling in hands and feet', ru: 'Отёки рук и ног', ky: 'Кол жана буттардын шишиши'),
        L3(en: 'Heartburn worsens', ru: 'Изжога усиливается', ky: 'Ашказан ачышы күчөйт'),
      ],
      tips: [
        L3(
          en: 'Track baby\'s movements daily (though not formal kick counts yet)',
          ru: 'Наблюдайте за шевелениями ежедневно (формальный подсчёт ещё не нужен)',
          ky: 'Баланын кыймылдарын күн сайын байкаңыз (расмий эсеп али эрте)',
        ),
        L3(
          en: 'Remove rings if fingers swell',
          ru: 'Снимите кольца, если пальцы отекают',
          ky: 'Манжалар шишсе, шакектерди чыгарыңыз',
        ),
        L3(
          en: 'Eat small portions for heartburn',
          ru: 'Ешьте маленькими порциями при изжоге',
          ky: 'Ашказан ачышканда аз-аздан тамактаныңыз',
        ),
        L3(
          en: 'Rest with feet elevated',
          ru: 'Отдыхайте с приподнятыми ногами',
          ky: 'Буттарды көтөрүп эс алыңыз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 22
    // =====================================================
    22: const PregnancyWeekData(
      week: 22,
      babySize: L3(
        en: 'Papaya',
        ru: 'Папайя',
        ky: 'Папайя',
      ),
      babySizeEmoji: '🍈',
      babyLengthCm: 27.8,
      babyWeightG: 430.0,
      babyDevelopment: L3(
        en: 'Baby looks like a miniature newborn now. Tooth buds are developing. Pancreas is developing. Baby is roughly 50% bigger than 2 weeks ago.',
        ru: 'Малыш выглядит как миниатюрный новорождённый. Развиваются зачатки зубов. Формируется поджелудочная железа. За 2 недели малыш вырос примерно на 50%.',
        ky: 'Бала кичинекей жаңы төрөлгөн балага окшош. Тиш бүчүрлөрү өнүгүүдө. Ашказан алды безинин калыптануусу жүрүүдө. Бала 2 жумада 50% чоңоюду.',
      ),
      commonSymptoms: [
        L3(en: 'Visible belly movements', ru: 'Заметные движения живота', ky: 'Курсактын байкалган кыймылы'),
        L3(en: 'Larger breasts leaking colostrum for some', ru: 'У некоторых из груди выделяется молозиво', ky: 'Кээ бирөөлөрдүн эмчегинен уузмай агат'),
        L3(en: 'Stretch marks', ru: 'Растяжки', ky: 'Созулуу издери'),
        L3(en: 'Back pain', ru: 'Боль в спине', ky: 'Арканын ооруусу'),
      ],
      tips: [
        L3(
          en: 'Start thinking about birth classes',
          ru: 'Подумайте о курсах подготовки к родам',
          ky: 'Төрөткө даярдык курстары жөнүндө ойлонуңуз',
        ),
        L3(
          en: 'Research birthing options',
          ru: 'Изучите варианты родов',
          ky: 'Төрөт варианттарын изилдеңиз',
        ),
        L3(
          en: 'Maternity bras with nursing flaps save money later',
          ru: 'Бюстгальтеры для кормления экономят деньги в будущем',
          ky: 'Эмизүү бюстгальтерлери кийин акчаны үнөмдөйт',
        ),
        L3(
          en: 'Support pillow between knees when sleeping',
          ru: 'Кладите подушку между колен во время сна',
          ky: 'Уктаганда тизелердин арасына жаздык коюңуз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 23
    // =====================================================
    23: const PregnancyWeekData(
      week: 23,
      babySize: L3(
        en: 'Grapefruit',
        ru: 'Грейпфрут',
        ky: 'Грейпфрут',
      ),
      babySizeEmoji: '🍊',
      babyLengthCm: 28.9,
      babyWeightG: 500.0,
      babyDevelopment: L3(
        en: 'Baby\'s lungs are developing surfactant. Inner ear is fully formed — baby has sense of balance. Baby can recognize your voice patterns.',
        ru: 'В лёгких малыша вырабатывается сурфактант. Внутреннее ухо полностью сформировано — малыш чувствует равновесие. Малыш узнаёт интонацию вашего голоса.',
        ky: 'Баланын өпкөсүндө сурфактант иштелип чыгууда. Ички кулак толук калыптанды — бала тең салмактыкты сезет. Бала сиздин үнүңүздүн интонациясын тааныйт.',
      ),
      commonSymptoms: [
        L3(en: 'Thicker hair', ru: 'Более густые волосы', ky: 'Калыңыраак чач'),
        L3(en: 'Faster-growing nails', ru: 'Быстрее растущие ногти', ky: 'Тезирээк өсүүчү тырмактар'),
        L3(en: 'Vivid dreams', ru: 'Яркие сны', ky: 'Жаркын түштөр'),
        L3(en: 'Clumsiness', ru: 'Неуклюжесть', ky: 'Шалактоо'),
      ],
      tips: [
        L3(
          en: 'Avoid hot yoga, saunas, hot tubs',
          ru: 'Избегайте горячей йоги, саун и горячих ванн',
          ky: 'Ысык йога, сауна жана ысык ваннадан сактаныңыз',
        ),
        L3(
          en: 'Take your time — balance is off',
          ru: 'Не торопитесь — равновесие нарушено',
          ky: 'Шашылбаңыз — тең салмактык бузулган',
        ),
        L3(
          en: 'Keep walking — 30 min most days',
          ru: 'Продолжайте гулять — 30 минут почти каждый день',
          ky: 'Басууну улантыңыз — көпчүлүк күндөрү 30 мүнөт',
        ),
        L3(
          en: 'Sign up for a prenatal class',
          ru: 'Запишитесь на курсы для беременных',
          ky: 'Кош бойлуулар курсуна жазылыңыз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 24
    // =====================================================
    24: const PregnancyWeekData(
      week: 24,
      babySize: L3(
        en: 'Cantaloupe',
        ru: 'Дыня-канталупа',
        ky: 'Канталупа коону',
      ),
      babySizeEmoji: '🍈',
      babyLengthCm: 30.0,
      babyWeightG: 600.0,
      babyDevelopment: L3(
        en: 'Baby can hear your voice and respond to sounds. Their lungs are developing branches and surfactant. Taste buds are forming.',
        ru: 'Малыш слышит ваш голос и реагирует на звуки. В лёгких развиваются бронхи и вырабатывается сурфактант. Формируются вкусовые рецепторы.',
        ky: 'Бала сиздин үнүңүздү угат жана үндөргө жооп берет. Өпкөдө бронхтар жана сурфактант өнүгүүдө. Даам сезүү рецепторлору түзүлүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Braxton Hicks contractions', ru: 'Схватки Брэкстона-Хикса', ky: 'Брэкстон-Хикс жыйрылуулары'),
        L3(en: 'Backache', ru: 'Боль в спине', ky: 'Арканын ооруусу'),
        L3(en: 'Swollen ankles', ru: 'Отёкшие лодыжки', ky: 'Шишкен тобуктар'),
        L3(en: 'Linea nigra darkening', ru: 'Потемнение полоски на животе (linea nigra)', ky: 'Курсактагы тилкенин караюусу (linea nigra)'),
      ],
      tips: [
        L3(
          en: 'Talk and sing to your baby — they can hear you now!',
          ru: 'Разговаривайте и пойте малышу — он теперь вас слышит!',
          ky: 'Балага сүйлөңүз жана ырдаңыз — ал сизди угат!',
        ),
        L3(
          en: 'Glucose screening test is coming up (24-28 weeks)',
          ru: 'Скоро глюкозотолерантный тест (24–28 недель)',
          ky: 'Глюкозага толеранттуулук тести жакындады (24–28 жума)',
        ),
        L3(
          en: 'Start planning the nursery',
          ru: 'Начните планировать детскую комнату',
          ky: 'Балдар бөлмөсүн пландай баштаңыз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 25
    // =====================================================
    25: const PregnancyWeekData(
      week: 25,
      babySize: L3(
        en: 'Cauliflower',
        ru: 'Цветная капуста',
        ky: 'Гүл капуста',
      ),
      babySizeEmoji: '🥦',
      babyLengthCm: 34.6,
      babyWeightG: 660.0,
      babyDevelopment: L3(
        en: 'Baby is practicing breathing (moving amniotic fluid in and out). Hair color and texture forming. Response to touch is now very strong.',
        ru: 'Малыш тренирует дыхание (вдыхает и выдыхает околоплодные воды). Формируются цвет и структура волос. Реакция на прикосновения очень сильная.',
        ky: 'Бала дем алууну машыктырууда (жатын суюктугун кирип-чыгып жатат). Чачтын түсү жана түзүлүшү калыптанууда. Тийүүгө реакция абдан күчтүү.',
      ),
      commonSymptoms: [
        L3(en: 'Trouble sleeping', ru: 'Проблемы со сном', ky: 'Уйку көйгөйлөрү'),
        L3(en: 'Pelvic pressure', ru: 'Давление в тазу', ky: 'Жамбаштагы басым'),
        L3(en: 'Leg cramps', ru: 'Судороги ног', ky: 'Бут түйүлүүсү'),
        L3(en: 'Hemorrhoids for some', ru: 'Геморрой у некоторых', ky: 'Кээ бирөөлөрдө геморрой'),
      ],
      tips: [
        L3(
          en: 'Side sleep with pillow support',
          ru: 'Спите на боку с поддержкой подушки',
          ky: 'Жаздыкка сүйөнүп капталга жатып уктаңыз',
        ),
        L3(
          en: 'Cold witch hazel helps hemorrhoids',
          ru: 'Холодный гамамелис помогает при геморрое',
          ky: 'Муздак гамамелис геморройго жардам берет',
        ),
        L3(
          en: 'Kick counts are OK to start',
          ru: 'Можно начинать считать шевеления',
          ky: 'Кыймылдарды санай баштасаңыз болот',
        ),
        L3(
          en: 'Hydrate, hydrate, hydrate',
          ru: 'Пейте воду, пейте воду, пейте воду',
          ky: 'Суу ичиңиз, суу ичиңиз, суу ичиңиз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 26
    // =====================================================
    26: const PregnancyWeekData(
      week: 26,
      babySize: L3(
        en: 'Lettuce head',
        ru: 'Кочан салата',
        ky: 'Салат башы',
      ),
      babySizeEmoji: '🥬',
      babyLengthCm: 35.6,
      babyWeightG: 760.0,
      babyDevelopment: L3(
        en: 'Baby opens eyes for the first time. Alveoli (air sacs) develop in lungs. Brain waves become more mature. Baby has a grip reflex.',
        ru: 'Малыш впервые открывает глаза. В лёгких развиваются альвеолы (воздушные мешочки). Мозговые волны становятся более зрелыми. Появляется хватательный рефлекс.',
        ky: 'Бала биринчи жолу көзүн ачат. Өпкөдө альвеолалар (аба капчыктары) өнүгүүдө. Мээ толкундары жетилүүдө. Кармоо рефлекси пайда болот.',
      ),
      commonSymptoms: [
        L3(en: 'Braxton Hicks more noticeable', ru: 'Схватки Брэкстона-Хикса заметнее', ky: 'Брэкстон-Хикс жыйрылуулары байкалаарлык'),
        L3(en: 'Carpal tunnel symptoms', ru: 'Симптомы синдрома запястного канала', ky: 'Карпал түнөл синдромунун белгилери'),
        L3(en: 'Dizziness', ru: 'Головокружение', ky: 'Баш айлануу'),
        L3(en: 'Pregnancy brain (forgetfulness)', ru: '«Беременный мозг» (забывчивость)', ky: 'Кош бойлуулук унутчаактыгы'),
      ],
      tips: [
        L3(
          en: 'Glucose tolerance test coming up (24-28 weeks)',
          ru: 'Скоро глюкозотолерантный тест (24–28 недель)',
          ky: 'Глюкозага толеранттуулук тести жакындады (24–28 жума)',
        ),
        L3(
          en: 'Write things down — you\'ll forget',
          ru: 'Записывайте всё — иначе забудете',
          ky: 'Баарын жазып коюңуз — унутуп каласыз',
        ),
        L3(
          en: 'Wrist splints help carpal tunnel at night',
          ru: 'Ортез на запястье помогает при синдроме запястного канала ночью',
          ky: 'Билек шинасы түнкүсүн карпал түнөл синдромуна жардам берет',
        ),
        L3(
          en: 'Sit down when feeling dizzy',
          ru: 'Присядьте, если кружится голова',
          ky: 'Баш айланса, отуруңуз',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 27
    // =====================================================
    27: const PregnancyWeekData(
      week: 27,
      babySize: L3(
        en: 'Head of cabbage',
        ru: 'Кочан капусты',
        ky: 'Капуста башы',
      ),
      babySizeEmoji: '🥬',
      babyLengthCm: 36.6,
      babyWeightG: 875.0,
      babyDevelopment: L3(
        en: 'Last week of second trimester! Baby has regular sleep and wake cycles. Nervous system is developing rapidly. Baby can now taste sweet vs bitter.',
        ru: 'Последняя неделя второго триместра! У малыша регулярные циклы сна и бодрствования. Нервная система развивается стремительно. Малыш различает сладкое и горькое.',
        ky: 'Экинчи триместрдин акыркы жумасы! Баланын уйку-ойгонуу цикли туруктуу. Нерв системасы тез өнүгүүдө. Бала таттууну жана ачууну айырмалайт.',
      ),
      commonSymptoms: [
        L3(en: 'Rib pain (baby kicking up)', ru: 'Боль в рёбрах (малыш пинается вверх)', ky: 'Кабырга ооруусу (бала өйдө тебет)'),
        L3(en: 'Tailbone discomfort', ru: 'Дискомфорт в копчике', ky: 'Куймулчактагы ыңгайсыздык'),
        L3(en: 'Leaking breasts possible', ru: 'Возможно подтекание из груди', ky: 'Эмчектен суюктук агышы мүмкүн'),
        L3(en: 'Increased back pain', ru: 'Усиление боли в спине', ky: 'Арка ооруусунун күчөшү'),
      ],
      tips: [
        L3(
          en: 'Tour the hospital or birth center',
          ru: 'Посетите с экскурсией роддом или перинатальный центр',
          ky: 'Тууруканага экскурсия жасаңыз',
        ),
        L3(
          en: 'Start packing hospital bag list',
          ru: 'Начните составлять список вещей в роддом',
          ky: 'Тууруканага сумка тизмесин түзө баштаңыз',
        ),
        L3(
          en: 'Pelvic tilts ease back pain',
          ru: 'Наклоны таза облегчают боль в спине',
          ky: 'Жамбаш ийилүүсү арка оорусун жеңилдетет',
        ),
        L3(
          en: 'Final trimester — you\'re 2/3 of the way!',
          ru: 'Финальный триместр — уже 2/3 пути пройдено!',
          ky: 'Акыркы триместр — жолдун 2/3 бөлүгү артта!',
        ),
      ],
      trimester: _second,
    ),

    // =====================================================
    // WEEK 28
    // =====================================================
    28: const PregnancyWeekData(
      week: 28,
      babySize: L3(
        en: 'Eggplant',
        ru: 'Баклажан',
        ky: 'Баклажан',
      ),
      babySizeEmoji: '🍆',
      babyLengthCm: 37.6,
      babyWeightG: 1000.0,
      babyDevelopment: L3(
        en: 'Welcome to the third trimester! Baby can blink, dream, and has regular sleep cycles. Their brain is developing rapidly.',
        ru: 'Добро пожаловать в третий триместр! Малыш может моргать, видеть сны и имеет регулярные циклы сна. Мозг развивается стремительно.',
        ky: 'Үчүнчү триместрге кош келиңиз! Бала ирмей алат, түш көрөт жана туруктуу уйку цикли бар. Мээсү тез өнүгүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Shortness of breath', ru: 'Одышка', ky: 'Дем кысылуу'),
        L3(en: 'Trouble sleeping', ru: 'Проблемы со сном', ky: 'Уйку көйгөйлөрү'),
        L3(en: 'Heartburn', ru: 'Изжога', ky: 'Ашказандын ачышы'),
        L3(en: 'Frequent urination returns', ru: 'Частое мочеиспускание возвращается', ky: 'Тез-тез заара кылуу кайра башталат'),
      ],
      tips: [
        L3(
          en: 'Start doing kick counts daily',
          ru: 'Начните ежедневно считать шевеления',
          ky: 'Кыймылдарды күн сайын санай баштаңыз',
        ),
        L3(
          en: 'Take a childbirth class',
          ru: 'Запишитесь на курсы подготовки к родам',
          ky: 'Төрөткө даярдык курсуна жазылыңыз',
        ),
        L3(
          en: 'Tour the hospital or birth center',
          ru: 'Посетите роддом с экскурсией',
          ky: 'Тууруканага экскурсия жасаңыз',
        ),
        L3(
          en: 'Begin packing your hospital bag',
          ru: 'Начните собирать сумку в роддом',
          ky: 'Тууруканага сумка жыйнай баштаңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 29
    // =====================================================
    29: const PregnancyWeekData(
      week: 29,
      babySize: L3(
        en: 'Butternut squash',
        ru: 'Мускатная тыква',
        ky: 'Мускат ашкабагы',
      ),
      babySizeEmoji: '🎃',
      babyLengthCm: 38.6,
      babyWeightG: 1150.0,
      babyDevelopment: L3(
        en: 'Baby\'s muscles and lungs are maturing rapidly. Bones are absorbing lots of calcium. Baby\'s head is growing to make room for developing brain.',
        ru: 'Мышцы и лёгкие малыша быстро созревают. Кости активно усваивают кальций. Головка растёт, освобождая место для развивающегося мозга.',
        ky: 'Баланын булчуңдары жана өпкөсү тез жетилүүдө. Сөөктөр кальцийди активдүү сиңирүүдө. Башы мээнин өнүгүшү үчүн чоңоюуда.',
      ),
      commonSymptoms: [
        L3(en: 'Shortness of breath', ru: 'Одышка', ky: 'Дем кысылуу'),
        L3(en: 'Heartburn worsens', ru: 'Изжога усиливается', ky: 'Ашказан ачышы күчөйт'),
        L3(en: 'Varicose veins', ru: 'Варикозное расширение вен', ky: 'Варикоздук кеңейүү'),
        L3(en: 'Swelling continues', ru: 'Отёки продолжаются', ky: 'Шишүү улантылууда'),
      ],
      tips: [
        L3(
          en: 'Eat iron and protein daily',
          ru: 'Ежедневно получайте железо и белок',
          ky: 'Күн сайын темир жана белок алыңыз',
        ),
        L3(
          en: 'Count baby\'s kicks daily (10 in 2 hours)',
          ru: 'Считайте шевеления ежедневно (10 за 2 часа)',
          ky: 'Кыймылдарды күн сайын саналыңыз (2 саатта 10)',
        ),
        L3(
          en: 'Elevate legs to reduce swelling',
          ru: 'Приподнимайте ноги для уменьшения отёков',
          ky: 'Шишүүнү азайтуу үчүн буттарды көтөрүңүз',
        ),
        L3(
          en: 'Write out your birth plan',
          ru: 'Напишите план родов',
          ky: 'Төрөт планын жазыңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 30
    // =====================================================
    30: const PregnancyWeekData(
      week: 30,
      babySize: L3(
        en: 'Cabbage',
        ru: 'Капуста',
        ky: 'Капуста',
      ),
      babySizeEmoji: '🥬',
      babyLengthCm: 39.9,
      babyWeightG: 1320.0,
      babyDevelopment: L3(
        en: 'Baby\'s brain is developing folds and grooves. Lanugo (fine hair) is starting to disappear. Bone marrow makes red blood cells. Baby can hear you clearly.',
        ru: 'В мозге малыша формируются извилины и борозды. Лануго (тонкие волоски) начинает исчезать. Костный мозг вырабатывает красные кровяные клетки. Малыш отчётливо слышит вас.',
        ky: 'Баланын мээсинде бүктөлүштөр жана бороздор түзүлүүдө. Лануго (ичке түктөр) жоголо баштады. Сөөк чучугу кызыл кан клеткаларын чыгарат. Бала сизди ачык угат.',
      ),
      commonSymptoms: [
        L3(en: 'Mood swings return', ru: 'Перепады настроения возвращаются', ky: 'Маанай өзгөрүүлөрү кайтат'),
        L3(en: 'Waddling walk', ru: 'Переваливающаяся походка', ky: 'Чайпалып басуу'),
        L3(en: 'Trouble getting comfortable', ru: 'Трудно найти удобное положение', ky: 'Ыңгайлуу абал табуу кыйын'),
        L3(en: 'Fatigue returns', ru: 'Усталость возвращается', ky: 'Чарчоо кайтат'),
      ],
      tips: [
        L3(
          en: 'Sing and talk to baby daily',
          ru: 'Пойте и разговаривайте с малышом каждый день',
          ky: 'Балага күн сайын ырдаңыз жана сүйлөшүңүз',
        ),
        L3(
          en: 'Hospital pre-registration if not done',
          ru: 'Пройдите предварительную регистрацию в роддоме, если ещё не сделали',
          ky: 'Тууруканага алдын ала жазылыңыз, эгер али жазылбасаңыз',
        ),
        L3(
          en: 'Install car seat and check it',
          ru: 'Установите детское автокресло и проверьте его',
          ky: 'Балдар унаа отургучун орнотуп, текшериңиз',
        ),
        L3(
          en: 'Rest when you can',
          ru: 'Отдыхайте при любой возможности',
          ky: 'Мүмкүнчүлүк болгондо эс алыңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 31
    // =====================================================
    31: const PregnancyWeekData(
      week: 31,
      babySize: L3(
        en: 'Coconut',
        ru: 'Кокос',
        ky: 'Кокос',
      ),
      babySizeEmoji: '🥥',
      babyLengthCm: 41.1,
      babyWeightG: 1500.0,
      babyDevelopment: L3(
        en: 'Baby is gaining weight fast — about 230g per week. Five senses are all working. Baby processes multiple stimuli at once now.',
        ru: 'Малыш быстро набирает вес — около 230 г в неделю. Все пять чувств работают. Малыш обрабатывает несколько раздражителей одновременно.',
        ky: 'Бала тез салмак алууда — жумасына 230 г чамасында. Бардык беш сезим иштейт. Бала бир эле учурда бир нече таасирди кабыл алат.',
      ),
      commonSymptoms: [
        L3(en: 'Leaky breasts', ru: 'Подтекание из груди', ky: 'Эмчектен суюктук агуу'),
        L3(en: 'Pressure in pelvis', ru: 'Давление в тазу', ky: 'Жамбаштагы басым'),
        L3(en: 'Braxton Hicks', ru: 'Схватки Брэкстона-Хикса', ky: 'Брэкстон-Хикс жыйрылуулары'),
        L3(en: 'Frequent urination', ru: 'Частое мочеиспускание', ky: 'Тез-тез заара кылуу'),
      ],
      tips: [
        L3(
          en: 'Nursing pads for breast leaks',
          ru: 'Используйте прокладки для груди при подтекании',
          ky: 'Эмчектен агуу үчүн эмчек тегеректерин колдонуңуз',
        ),
        L3(
          en: 'Pelvic floor exercises (Kegels) daily',
          ru: 'Ежедневно делайте упражнения Кегеля',
          ky: 'Кегель көнүгүүлөрүн күн сайын жасаңыз',
        ),
        L3(
          en: 'Know difference: Braxton Hicks vs real contractions',
          ru: 'Знайте разницу: тренировочные схватки и настоящие',
          ky: 'Машыгуу жыйрылуулары менен чыныгы толгоонун айырмасын билиңиз',
        ),
        L3(
          en: 'Pack partner\'s bag too',
          ru: 'Соберите сумку и для партнёра',
          ky: 'Жубайыңыздын сумкасын да жыйнаңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 32
    // =====================================================
    32: const PregnancyWeekData(
      week: 32,
      babySize: L3(
        en: 'Squash',
        ru: 'Тыква',
        ky: 'Ашкабак',
      ),
      babySizeEmoji: '🎃',
      babyLengthCm: 42.4,
      babyWeightG: 1700.0,
      babyDevelopment: L3(
        en: 'Baby is practicing breathing movements. Their bones are hardening (except the skull, which stays soft for delivery). They\'re gaining weight fast now.',
        ru: 'Малыш тренирует дыхательные движения. Кости твердеют (кроме черепа — он остаётся мягким для родов). Вес набирается быстро.',
        ky: 'Бала дем алуу кыймылдарын машыктырууда. Сөөктөрү катуулоодо (баш сөөгүнөн башка — ал төрөт үчүн жумшак калат). Салмакты тез алууда.',
      ),
      commonSymptoms: [
        L3(en: 'Braxton Hicks more frequent', ru: 'Тренировочные схватки учащаются', ky: 'Машыгуу жыйрылуулары тездейт'),
        L3(en: 'Heartburn', ru: 'Изжога', ky: 'Ашказандын ачышы'),
        L3(en: 'Leaking colostrum', ru: 'Выделение молозива', ky: 'Уузмай бөлүнүүсү'),
        L3(en: 'Pelvic pressure', ru: 'Давление в тазу', ky: 'Жамбаштагы басым'),
      ],
      tips: [
        L3(
          en: 'Finalize your birth plan',
          ru: 'Завершите план родов',
          ky: 'Төрөт планын бүтүрүңүз',
        ),
        L3(
          en: 'Pre-register at the hospital',
          ru: 'Пройдите предварительную регистрацию в роддоме',
          ky: 'Тууруканага алдын ала жазылыңыз',
        ),
        L3(
          en: 'Install the car seat',
          ru: 'Установите детское автокресло',
          ky: 'Балдар унаа отургучун орнотуңуз',
        ),
        L3(
          en: 'Consider a prenatal massage',
          ru: 'Рассмотрите массаж для беременных',
          ky: 'Кош бойлуулар массажын ойлонуңуз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 33
    // =====================================================
    33: const PregnancyWeekData(
      week: 33,
      babySize: L3(
        en: 'Pineapple',
        ru: 'Ананас',
        ky: 'Ананас',
      ),
      babySizeEmoji: '🍍',
      babyLengthCm: 43.7,
      babyWeightG: 1920.0,
      babyDevelopment: L3(
        en: 'Baby\'s skull stays soft and flexible for birth. Amniotic fluid peaks this week. Baby\'s immune system is getting antibodies from you.',
        ru: 'Череп малыша остаётся мягким и гибким для родов. На этой неделе объём околоплодных вод максимален. Иммунная система малыша получает антитела от вас.',
        ky: 'Баланын баш сөөгү төрөт үчүн жумшак жана ийкемдүү калат. Бул жумада жатын суюктугу эң көп. Баланын иммундук системасы сизден антитело алат.',
      ),
      commonSymptoms: [
        L3(en: 'Clumsiness', ru: 'Неуклюжесть', ky: 'Шалактоо'),
        L3(en: 'Aches everywhere', ru: 'Боли по всему телу', ky: 'Бүткүл денеде оорулар'),
        L3(en: 'Shortness of breath improving if baby drops', ru: 'Одышка может улучшиться, если малыш опустился', ky: 'Бала түшсө, дем алуу жакшырышы мүмкүн'),
        L3(en: 'Braxton Hicks increasing', ru: 'Тренировочные схватки учащаются', ky: 'Машыгуу жыйрылуулары көбөйүүдө'),
      ],
      tips: [
        L3(
          en: 'Finalize childcare arrangements',
          ru: 'Завершите подготовку к уходу за ребёнком',
          ky: 'Бала багуу даярдыгын аяктаңыз',
        ),
        L3(
          en: 'Freeze meals for after birth',
          ru: 'Заморозьте еду на послеродовой период',
          ky: 'Төрөттөн кийинки мезгилге тамак тоңдуруңуз',
        ),
        L3(
          en: 'Learn newborn CPR basics',
          ru: 'Изучите основы реанимации новорождённых',
          ky: 'Жаңы төрөлгөн баланын реанимациясынын негиздерин үйрөнүңүз',
        ),
        L3(
          en: 'Stock up on postpartum supplies',
          ru: 'Запаситесь послеродовыми принадлежностями',
          ky: 'Төрөттөн кийинки буюмдарды даярдап коюңуз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 34
    // =====================================================
    34: const PregnancyWeekData(
      week: 34,
      babySize: L3(
        en: 'Cantaloupe',
        ru: 'Дыня-канталупа',
        ky: 'Канталупа коону',
      ),
      babySizeEmoji: '🍈',
      babyLengthCm: 45.0,
      babyWeightG: 2150.0,
      babyDevelopment: L3(
        en: 'Baby\'s lungs are almost fully mature. Baby practices sucking and swallowing. Fingernails reach fingertips. Vernix thickens for the journey.',
        ru: 'Лёгкие малыша почти полностью созрели. Малыш тренирует сосание и глотание. Ногти достигли кончиков пальцев. Первородная смазка утолщается перед родами.',
        ky: 'Баланын өпкөсү дээрлик толук жетилди. Бала эмүүнү жана жутунууну машыктырууда. Тырмактар манжалардын учуна жетти. Первородный смазка төрөт алдында жоондойт.',
      ),
      commonSymptoms: [
        L3(en: 'Leaking urine when coughing/sneezing', ru: 'Подтекание мочи при кашле/чихании', ky: 'Жөтөлгөндө/чүчкүргөндө заара агуу'),
        L3(en: 'Baby kicks under ribs', ru: 'Малыш пинает под рёбрами', ky: 'Бала кабырганын астын тебет'),
        L3(en: 'Foot swelling', ru: 'Отёки ног', ky: 'Буттун шишиши'),
        L3(en: 'Extreme fatigue', ru: 'Сильная усталость', ky: 'Катуу чарчоо'),
      ],
      tips: [
        L3(
          en: 'Pads for bladder leaks — normal',
          ru: 'Используйте прокладки при подтекании мочи — это нормально',
          ky: 'Заара агуу үчүн прокладкалар — бул нормалдуу',
        ),
        L3(
          en: 'Weekly doctor visits start around now',
          ru: 'Примерно сейчас начинаются еженедельные визиты к врачу',
          ky: 'Болжол менен азыр жума сайын дарыгерге барууга мезгил келди',
        ),
        L3(
          en: 'Practice breathing techniques for labor',
          ru: 'Практикуйте дыхательные техники для родов',
          ky: 'Төрөт үчүн дем алуу техникаларын машыктырыңыз',
        ),
        L3(
          en: 'Pre-register at hospital if possible',
          ru: 'Пройдите предварительную регистрацию в роддоме, если возможно',
          ky: 'Мүмкүн болсо, тууруканага алдын ала жазылыңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 35
    // =====================================================
    35: const PregnancyWeekData(
      week: 35,
      babySize: L3(
        en: 'Honeydew',
        ru: 'Медовая дыня',
        ky: 'Бал коону',
      ),
      babySizeEmoji: '🍈',
      babyLengthCm: 46.2,
      babyWeightG: 2380.0,
      babyDevelopment: L3(
        en: 'Baby is running out of room. Brain is still developing rapidly. Kidneys are fully developed. Liver can process some waste.',
        ru: 'Малышу становится тесно. Мозг по-прежнему быстро развивается. Почки полностью сформированы. Печень может перерабатывать некоторые отходы.',
        ky: 'Балага тар болуп баратат. Мээ дагы деле тез өнүгүүдө. Бөйрөктөр толук жетилди. Боор кээ бир калдыктарды иштеп чыга алат.',
      ),
      commonSymptoms: [
        L3(en: 'Pelvic pain', ru: 'Боль в тазу', ky: 'Жамбаш ооруусу'),
        L3(en: 'Difficulty sleeping', ru: 'Проблемы со сном', ky: 'Уйку көйгөйлөрү'),
        L3(en: 'Nesting instinct', ru: 'Инстинкт гнездования', ky: 'Уя салуу инстинкти'),
        L3(en: 'Group B strep test around now', ru: 'Тест на стрептококк группы B примерно сейчас', ky: 'B тобундагы стрептококк тести ушул убакта'),
      ],
      tips: [
        L3(
          en: 'Sleep whenever you can — naps count',
          ru: 'Спите при любой возможности — дневной сон тоже считается',
          ky: 'Мүмкүн болгондо уктаңыз — күндүзгү уйку да саналат',
        ),
        L3(
          en: 'GBS swab test — completely normal',
          ru: 'Мазок на стрептококк группы B — совершенно нормальный анализ',
          ky: 'Стрептококк B мазоги — толук нормалдуу анализ',
        ),
        L3(
          en: 'Finalize hospital bag',
          ru: 'Завершите сбор сумки в роддом',
          ky: 'Тууруканага сумканы даярдап бүтүңүз',
        ),
        L3(
          en: 'Practice relaxation techniques',
          ru: 'Практикуйте техники расслабления',
          ky: 'Эс алуу техникаларын машыктырыңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 36
    // =====================================================
    36: const PregnancyWeekData(
      week: 36,
      babySize: L3(
        en: 'Honeydew melon',
        ru: 'Медовая дыня',
        ky: 'Бал коону',
      ),
      babySizeEmoji: '🍈',
      babyLengthCm: 47.4,
      babyWeightG: 2600.0,
      babyDevelopment: L3(
        en: 'Baby is running out of room! They\'re gaining about 28g per day. Most babies move to a head-down position by now.',
        ru: 'Малышу уже совсем тесно! Он набирает около 28 г в день. Большинство детей к этому времени поворачиваются головкой вниз.',
        ky: 'Балага абдан тар болуп баратат! Күнүнө 28 г чамасында салмак алууда. Көпчүлүк балдар бул убакка карай башы ылдый жайгашат.',
      ),
      commonSymptoms: [
        L3(en: 'Lightning crotch', ru: 'Острая стреляющая боль в промежности', ky: 'Чаптын курч ооруусу'),
        L3(en: 'Nesting instinct', ru: 'Инстинкт гнездования', ky: 'Уя салуу инстинкти'),
        L3(en: 'Difficulty sleeping', ru: 'Проблемы со сном', ky: 'Уйку көйгөйлөрү'),
        L3(en: 'Baby "dropping" lower', ru: 'Малыш «опускается» ниже', ky: 'Бала ылдыйлап «түшүүдө»'),
      ],
      tips: [
        L3(
          en: 'Hospital bag should be packed',
          ru: 'Сумка в роддом должна быть собрана',
          ky: 'Тууруканага сумка даяр болушу керек',
        ),
        L3(
          en: 'Know the signs of labor',
          ru: 'Знайте признаки начала родов',
          ky: 'Толгоонун белгилерин билиңиз',
        ),
        L3(
          en: 'Freeze some meals for postpartum',
          ru: 'Заморозьте еду на послеродовой период',
          ky: 'Төрөттөн кийинки мезгилге тамак тоңдуруңуз',
        ),
        L3(
          en: 'Rest and enjoy these last weeks',
          ru: 'Отдыхайте и наслаждайтесь последними неделями',
          ky: 'Эс алыңыз жана акыркы жумалардан ырахат алыңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 37
    // =====================================================
    37: const PregnancyWeekData(
      week: 37,
      babySize: L3(
        en: 'Bunch of Swiss chard',
        ru: 'Пучок мангольда',
        ky: 'Бир байлам мангольд',
      ),
      babySizeEmoji: '🥬',
      babyLengthCm: 48.6,
      babyWeightG: 2860.0,
      babyDevelopment: L3(
        en: 'Baby is early term (official "full term" is 39 weeks). Lanugo is mostly gone. Baby can grasp firmly. Digestive system is ready.',
        ru: 'Малыш на раннем сроке доношенности (официально «доношенный» — с 39 недель). Лануго почти исчез. Малыш крепко хватает. Пищеварительная система готова.',
        ky: 'Бала эрте мөөнөткө жетти (расмий «толук мөөнөт» — 39 жума). Лануго дээрлик жоголду. Бала бекем кармайт. Тамак сиңирүү системасы даяр.',
      ),
      commonSymptoms: [
        L3(en: 'Increased discharge (possible mucus plug)', ru: 'Усиленные выделения (возможно отхождение слизистой пробки)', ky: 'Бөлүнүүлөрдүн көбөйүшү (шилекей тыгыны кетиши мүмкүн)'),
        L3(en: 'Lightening (baby drops)', ru: 'Облегчение (малыш опускается)', ky: 'Жеңилдөө (бала түшөт)'),
        L3(en: 'Pelvic pressure', ru: 'Давление в тазу', ky: 'Жамбаштагы басым'),
        L3(en: 'Braxton Hicks frequent', ru: 'Частые тренировочные схватки', ky: 'Тез-тез машыгуу жыйрылуулары'),
      ],
      tips: [
        L3(
          en: 'Know signs of labor',
          ru: 'Знайте признаки родов',
          ky: 'Толгоонун белгилерин билиңиз',
        ),
        L3(
          en: 'Keep hospital bag by the door',
          ru: 'Держите сумку в роддом у двери',
          ky: 'Тууруканага сумканы эшик жанында кармаңыз',
        ),
        L3(
          en: 'Rest as much as possible',
          ru: 'Отдыхайте как можно больше',
          ky: 'Мүмкүн болушунча көп эс алыңыз',
        ),
        L3(
          en: 'Stay hydrated',
          ru: 'Пейте достаточно жидкости',
          ky: 'Суусундукту жетиштүү ичиңиз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 38
    // =====================================================
    38: const PregnancyWeekData(
      week: 38,
      babySize: L3(
        en: 'Leek',
        ru: 'Лук-порей',
        ky: 'Порей пиязы',
      ),
      babySizeEmoji: '🥬',
      babyLengthCm: 49.8,
      babyWeightG: 3080.0,
      babyDevelopment: L3(
        en: 'Baby has a firm grasp. Eye color at birth may change over first year. Vocal cords ready to cry. Body fat continues to build.',
        ru: 'У малыша крепкий хватательный рефлекс. Цвет глаз при рождении может измениться в течение первого года. Голосовые связки готовы к крику. Подкожный жир продолжает накапливаться.',
        ky: 'Баланын кармоо рефлекси күчтүү. Төрөлгөндөгү көз түсү биринчи жылда өзгөрүшү мүмкүн. Үн тарамыштары ыйлоого даяр. Дене майы топтоло берүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Loose bowel movements', ru: 'Послабление стула', ky: 'Ичтин жумшарышы'),
        L3(en: 'Intense tiredness', ru: 'Сильная усталость', ky: 'Катуу чарчоо'),
        L3(en: 'Back pain', ru: 'Боль в спине', ky: 'Арканын ооруусу'),
        L3(en: 'Emotional swings', ru: 'Эмоциональные перепады', ky: 'Эмоция толкундоолору'),
      ],
      tips: [
        L3(
          en: 'Any day now is possible',
          ru: 'Роды возможны в любой день',
          ky: 'Каалаган күнү төрөт болушу мүмкүн',
        ),
        L3(
          en: 'Have a labor plan ready',
          ru: 'Держите план родов наготове',
          ky: 'Төрөт планын даяр кармаңыз',
        ),
        L3(
          en: 'Don\'t over-schedule last weeks',
          ru: 'Не перегружайте расписание последних недель',
          ky: 'Акыркы жумаларга көп иш пландабаңыз',
        ),
        L3(
          en: 'Try to enjoy quiet moments',
          ru: 'Старайтесь наслаждаться тихими моментами',
          ky: 'Тынч учурлардан ырахат алууга аракет кылыңыз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 39
    // =====================================================
    39: const PregnancyWeekData(
      week: 39,
      babySize: L3(
        en: 'Mini watermelon',
        ru: 'Мини-арбуз',
        ky: 'Кичине дарбыз',
      ),
      babySizeEmoji: '🍉',
      babyLengthCm: 50.7,
      babyWeightG: 3290.0,
      babyDevelopment: L3(
        en: 'Baby is officially FULL TERM. Every day in the womb now is a bonus for brain development. Baby is ready for life outside.',
        ru: 'Малыш официально ДОНОШЕННЫЙ. Каждый день в утробе — бонус для развития мозга. Малыш готов к жизни снаружи.',
        ky: 'Бала расмий түрдө ТОЛУК МӨӨНӨТКӨ жетти. Жатындагы ар бир күн — мээнин өнүгүшүнө бонус. Бала сырткы жашоого даяр.',
      ),
      commonSymptoms: [
        L3(en: 'Feeling very uncomfortable', ru: 'Очень некомфортно', ky: 'Абдан ыңгайсыз'),
        L3(en: 'Frequent bathroom trips', ru: 'Частые походы в туалет', ky: 'Тез-тез даараткана барыңыз'),
        L3(en: 'Irregular contractions', ru: 'Нерегулярные схватки', ky: 'Туруксуз жыйрылуулар'),
        L3(en: 'Restlessness', ru: 'Беспокойство', ky: 'Тынчсыздануу'),
      ],
      tips: [
        L3(
          en: 'Rest and conserve energy',
          ru: 'Отдыхайте и берегите силы',
          ky: 'Эс алыңыз жана күчүңүздү сактаңыз',
        ),
        L3(
          en: 'Gentle walking may help labor start',
          ru: 'Лёгкие прогулки могут помочь началу родов',
          ky: 'Жеңил басуу толгоонун башталышына жардам берет',
        ),
        L3(
          en: 'Spicy food, acupressure — unproven but harmless',
          ru: 'Острая еда, акупрессура — не доказано, но безвредно',
          ky: 'Аччуу тамак, акупрессура — далилденген эмес, бирок зыянсыз',
        ),
        L3(
          en: 'Trust your body',
          ru: 'Доверяйте своему телу',
          ky: 'Денеңизге ишениңиз',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 40
    // =====================================================
    40: const PregnancyWeekData(
      week: 40,
      babySize: L3(
        en: 'Watermelon',
        ru: 'Арбуз',
        ky: 'Дарбыз',
      ),
      babySizeEmoji: '🍉',
      babyLengthCm: 51.2,
      babyWeightG: 3400.0,
      babyDevelopment: L3(
        en: 'Baby is fully developed and ready to meet you! Their skull bones are not yet fused — this helps them fit through the birth canal.',
        ru: 'Малыш полностью развит и готов встретиться с вами! Кости черепа ещё не срослись — это помогает ему пройти через родовой канал.',
        ky: 'Бала толук өнүккөн жана сиз менен жолугууга даяр! Баш сөөктөрү али биригип бүтө элек — бул төрөт каналынан өтүүгө жардам берет.',
      ),
      commonSymptoms: [
        L3(en: 'Mucus plug loss', ru: 'Отхождение слизистой пробки', ky: 'Шилекей тыгынынын кетиши'),
        L3(en: 'Nesting energy', ru: 'Прилив энергии для подготовки', ky: 'Уя салуу энергиясы'),
        L3(en: 'Irregular contractions', ru: 'Нерегулярные схватки', ky: 'Туруксуз жыйрылуулар'),
        L3(en: 'Anxiety and excitement', ru: 'Тревога и волнение', ky: 'Тынчсыздык жана толкундоо'),
      ],
      tips: [
        L3(
          en: 'You\'re at your due date — baby will come when they\'re ready!',
          ru: 'Наступил ваш срок — малыш родится, когда будет готов!',
          ky: 'Мөөнөтүңүз келди — бала даяр болгондо төрөлөт!',
        ),
        L3(
          en: 'Call your doctor if contractions are 5 min apart for 1 hour',
          ru: 'Звоните врачу, если схватки каждые 5 минут в течение часа',
          ky: 'Жыйрылуулар 1 саат бою 5 мүнөт сайын болсо, дарыгерге чалыңыз',
        ),
        L3(
          en: 'Try to stay calm and rested',
          ru: 'Старайтесь сохранять спокойствие и отдыхать',
          ky: 'Тынч жана эс алган бойдон калууга аракет кылыңыз',
        ),
        L3(
          en: 'You\'ve got this, mama!',
          ru: 'Вы справитесь, мамочка!',
          ky: 'Сиз баарын жасай аласыз, апа!',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 41
    // =====================================================
    41: const PregnancyWeekData(
      week: 41,
      babySize: L3(
        en: 'Watermelon',
        ru: 'Арбуз',
        ky: 'Дарбыз',
      ),
      babySizeEmoji: '🍉',
      babyLengthCm: 51.5,
      babyWeightG: 3600.0,
      babyDevelopment: L3(
        en: 'Baby is fully mature and ready. Skin may start to peel slightly (no more vernix). Hair continues to grow.',
        ru: 'Малыш полностью зрелый и готов. Кожа может слегка шелушиться (первородная смазка исчезла). Волосы продолжают расти.',
        ky: 'Бала толук жетилген жана даяр. Тери бир аз аршылышы мүмкүн (первородный смазка жоголду). Чач өсө берүүдө.',
      ),
      commonSymptoms: [
        L3(en: 'Extreme discomfort', ru: 'Сильный дискомфорт', ky: 'Катуу ыңгайсыздык'),
        L3(en: 'Impatience', ru: 'Нетерпение', ky: 'Чыдамсыздык'),
        L3(en: 'Everyone asking if baby is here yet', ru: 'Все спрашивают, родился ли малыш', ky: 'Баары баланын төрөлгөнүн сурашат'),
        L3(en: 'Emotional ups and downs', ru: 'Эмоциональные подъёмы и спады', ky: 'Эмоциялык көтөрүлүүлөр жана түшүүлөр'),
      ],
      tips: [
        L3(
          en: 'Doctor may discuss induction options',
          ru: 'Врач может обсудить варианты стимуляции родов',
          ky: 'Дарыгер төрөттү стимуляциялоо жөнүндө сүйлөшүшү мүмкүн',
        ),
        L3(
          en: 'Non-stress test likely',
          ru: 'Вероятно, назначат нестрессовый тест',
          ky: 'Стресссиз тест болушу мүмкүн',
        ),
        L3(
          en: 'Keep moving gently',
          ru: 'Продолжайте двигаться — плавно и спокойно',
          ky: 'Жай кыймылдай бериңиз',
        ),
        L3(
          en: 'Baby is coming soon — you\'re OK',
          ru: 'Малыш скоро появится — всё будет хорошо',
          ky: 'Бала жакында төрөлөт — баары жакшы болот',
        ),
      ],
      trimester: _third,
    ),

    // =====================================================
    // WEEK 42
    // =====================================================
    42: const PregnancyWeekData(
      week: 42,
      babySize: L3(
        en: 'Watermelon',
        ru: 'Арбуз',
        ky: 'Дарбыз',
      ),
      babySizeEmoji: '🍉',
      babyLengthCm: 52.0,
      babyWeightG: 3700.0,
      babyDevelopment: L3(
        en: 'Baby is post-term. Doctor will monitor closely. Fingernails and hair are long. Most babies are born by 42 weeks.',
        ru: 'Малыш переношенный. Врач будет тщательно наблюдать. Ногти и волосы длинные. Большинство детей рождаются к 42 неделям.',
        ky: 'Бала мөөнөтүнөн ашты. Дарыгер жакындан байкоо жүргүзөт. Тырмактар жана чач узун. Көпчүлүк балдар 42 жумага чейин төрөлөт.',
      ),
      commonSymptoms: [
        L3(en: 'Done being pregnant', ru: 'Беременность порядком надоела', ky: 'Кош бойлуулуктан чарчадым'),
        L3(en: 'Anxiety about baby\'s size/wellbeing', ru: 'Тревога о размере и состоянии малыша', ky: 'Баланын абалы жөнүндө тынчсыздануу'),
        L3(en: 'Possibly being induced', ru: 'Возможна стимуляция родов', ky: 'Төрөттү стимуляциялоо мүмкүн'),
        L3(en: 'Exhaustion', ru: 'Истощение', ky: 'Чаалыгуу'),
      ],
      tips: [
        L3(
          en: 'Induction is common and safe at 42 weeks',
          ru: 'Стимуляция родов на 42-й неделе — обычная и безопасная практика',
          ky: '42-жумада төрөттү стимуляциялоо — кадимки жана коопсуз',
        ),
        L3(
          en: 'Non-stress tests check baby\'s wellbeing',
          ru: 'Нестрессовые тесты проверяют состояние малыша',
          ky: 'Стресссиз тесттер баланын абалын текшерет',
        ),
        L3(
          en: 'Ask all your questions',
          ru: 'Задавайте все ваши вопросы',
          ky: 'Бардык суроолоруңузду бериңиз',
        ),
        L3(
          en: 'You\'re about to meet your baby',
          ru: 'Вы вот-вот встретите своего малыша',
          ky: 'Балаңыз менен жакында жолугасыз',
        ),
      ],
      trimester: _third,
    ),
  };
}

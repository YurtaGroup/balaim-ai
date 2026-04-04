/// Week-by-week pregnancy data — the core of the journey experience
class PregnancyWeekData {
  final int week;
  final String babySize;
  final String babySizeEmoji;
  final double babyLengthCm;
  final double babyWeightG;
  final String babyDevelopment;
  final List<String> commonSymptoms;
  final List<String> tips;
  final String trimester;

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
    return _weekData[week.clamp(4, 42)] ?? _weekData[24]!;
  }

  static final Map<int, PregnancyWeekData> _weekData = {
    4: const PregnancyWeekData(
      week: 4,
      babySize: 'Poppy seed',
      babySizeEmoji: '🫘',
      babyLengthCm: 0.1,
      babyWeightG: 0.04,
      babyDevelopment: 'The embryo has implanted in the uterus. The neural tube, which becomes the brain and spinal cord, is forming.',
      commonSymptoms: ['Missed period', 'Light spotting', 'Fatigue', 'Tender breasts'],
      tips: ['Start taking prenatal vitamins if you haven\'t already', 'Schedule your first prenatal appointment', 'Avoid alcohol and smoking'],
      trimester: 'First',
    ),
    8: const PregnancyWeekData(
      week: 8,
      babySize: 'Raspberry',
      babySizeEmoji: '🫐',
      babyLengthCm: 1.6,
      babyWeightG: 1.0,
      babyDevelopment: 'Baby\'s fingers and toes are forming. The heart is beating at about 150 beats per minute — twice as fast as yours!',
      commonSymptoms: ['Morning sickness', 'Fatigue', 'Frequent urination', 'Food aversions'],
      tips: ['Eat small, frequent meals to manage nausea', 'Stay hydrated', 'Rest when you can — your body is working hard'],
      trimester: 'First',
    ),
    12: const PregnancyWeekData(
      week: 12,
      babySize: 'Lime',
      babySizeEmoji: '🍋',
      babyLengthCm: 5.4,
      babyWeightG: 14.0,
      babyDevelopment: 'Baby can open and close their fists. Fingernails are forming. Vocal cords are developing.',
      commonSymptoms: ['Morning sickness easing', 'Growing belly', 'Dizziness', 'Increased energy'],
      tips: ['This is a common time to share the news!', 'First trimester screening can happen now', 'Start a pregnancy journal'],
      trimester: 'First',
    ),
    16: const PregnancyWeekData(
      week: 16,
      babySize: 'Avocado',
      babySizeEmoji: '🥑',
      babyLengthCm: 11.6,
      babyWeightG: 100.0,
      babyDevelopment: 'Baby can make facial expressions now. Their eyes can slowly move. The nervous system is functioning.',
      commonSymptoms: ['Round ligament pain', 'Nasal congestion', 'Backache', 'Possible first flutters'],
      tips: ['You might feel the first movements (quickening) soon', 'Consider a gender reveal if finding out', 'Start sleeping on your side'],
      trimester: 'Second',
    ),
    20: const PregnancyWeekData(
      week: 20,
      babySize: 'Banana',
      babySizeEmoji: '🍌',
      babyLengthCm: 25.6,
      babyWeightG: 300.0,
      babyDevelopment: 'Halfway there! Baby can hear sounds. They are developing a sleep-wake cycle. Vernix (waxy coating) covers the skin.',
      commonSymptoms: ['Visible baby movements', 'Leg cramps', 'Swelling in feet', 'Shortness of breath'],
      tips: ['Anatomy scan ultrasound is usually around now', 'Start thinking about a birth plan', 'Keep up with pelvic floor exercises'],
      trimester: 'Second',
    ),
    24: const PregnancyWeekData(
      week: 24,
      babySize: 'Cantaloupe',
      babySizeEmoji: '🍈',
      babyLengthCm: 30.0,
      babyWeightG: 600.0,
      babyDevelopment: 'Baby can hear your voice and respond to sounds. Their lungs are developing branches and surfactant. Taste buds are forming.',
      commonSymptoms: ['Braxton Hicks contractions', 'Backache', 'Swollen ankles', 'Linea nigra darkening'],
      tips: ['Talk and sing to your baby — they can hear you now!', 'Glucose screening test is coming up (24-28 weeks)', 'Start planning the nursery'],
      trimester: 'Second',
    ),
    28: const PregnancyWeekData(
      week: 28,
      babySize: 'Eggplant',
      babySizeEmoji: '🍆',
      babyLengthCm: 37.6,
      babyWeightG: 1000.0,
      babyDevelopment: 'Welcome to the third trimester! Baby can blink, dream, and has regular sleep cycles. Their brain is developing rapidly.',
      commonSymptoms: ['Shortness of breath', 'Trouble sleeping', 'Heartburn', 'Frequent urination returns'],
      tips: ['Start doing kick counts daily', 'Take a childbirth class', 'Tour the hospital or birth center', 'Begin packing your hospital bag'],
      trimester: 'Third',
    ),
    32: const PregnancyWeekData(
      week: 32,
      babySize: 'Squash',
      babySizeEmoji: '🎃',
      babyLengthCm: 42.4,
      babyWeightG: 1700.0,
      babyDevelopment: 'Baby is practicing breathing movements. Their bones are hardening (except the skull, which stays soft for delivery). They\'re gaining weight fast now.',
      commonSymptoms: ['Braxton Hicks more frequent', 'Heartburn', 'Leaking colostrum', 'Pelvic pressure'],
      tips: ['Finalize your birth plan', 'Pre-register at the hospital', 'Install the car seat', 'Consider a prenatal massage'],
      trimester: 'Third',
    ),
    36: const PregnancyWeekData(
      week: 36,
      babySize: 'Honeydew melon',
      babySizeEmoji: '🍈',
      babyLengthCm: 47.4,
      babyWeightG: 2600.0,
      babyDevelopment: 'Baby is running out of room! They\'re gaining about 28g per day. Most babies move to a head-down position by now.',
      commonSymptoms: ['Lightning crotch', 'Nesting instinct', 'Difficulty sleeping', 'Baby "dropping" lower'],
      tips: ['Hospital bag should be packed', 'Know the signs of labor', 'Freeze some meals for postpartum', 'Rest and enjoy these last weeks'],
      trimester: 'Third',
    ),
    40: const PregnancyWeekData(
      week: 40,
      babySize: 'Watermelon',
      babySizeEmoji: '🍉',
      babyLengthCm: 51.2,
      babyWeightG: 3400.0,
      babyDevelopment: 'Baby is fully developed and ready to meet you! Their skull bones are not yet fused — this helps them fit through the birth canal.',
      commonSymptoms: ['Mucus plug loss', 'Nesting energy', 'Irregular contractions', 'Anxiety and excitement'],
      tips: ['You\'re at your due date — baby will come when they\'re ready!', 'Call your doctor if contractions are 5 min apart for 1 hour', 'Try to stay calm and rested', 'You\'ve got this, mama!'],
      trimester: 'Third',
    ),
  };
}

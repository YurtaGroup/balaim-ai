/// Birth plan seed data — questions grouped by section with preset options.
/// No medical recommendations, just structured preference capture.
class BirthPlanQuestion {
  final String id;
  final String section;
  final String question;
  final List<String> options;
  final bool allowCustom;

  const BirthPlanQuestion({
    required this.id,
    required this.section,
    required this.question,
    required this.options,
    this.allowCustom = true,
  });
}

class BirthPlanData {
  BirthPlanData._();

  static const sections = <String>[
    'Environment',
    'Pain Management',
    'Labor Support',
    'Delivery',
    'After Birth',
    'Newborn Care',
  ];

  static const questions = <BirthPlanQuestion>[
    // ENVIRONMENT
    BirthPlanQuestion(
      id: 'env-lights',
      section: 'Environment',
      question: 'Lighting preference',
      options: ['Dim lights', 'Natural light', 'Bright lights OK'],
    ),
    BirthPlanQuestion(
      id: 'env-music',
      section: 'Environment',
      question: 'Music',
      options: ['Yes, my playlist', 'Yes, any music', 'Quiet, no music'],
    ),
    BirthPlanQuestion(
      id: 'env-visitors',
      section: 'Environment',
      question: 'Visitors during labor',
      options: ['Partner only', 'Partner + support person', 'Extended family welcome'],
    ),
    BirthPlanQuestion(
      id: 'env-photos',
      section: 'Environment',
      question: 'Photos & video',
      options: [
        'Yes, photos and video welcome',
        'Photos only',
        'After birth only',
        'No photos/video',
      ],
    ),

    // PAIN MANAGEMENT
    BirthPlanQuestion(
      id: 'pain-preference',
      section: 'Pain Management',
      question: 'Pain management preference',
      options: [
        'Unmedicated',
        'Open to medication if I ask',
        'Epidural as soon as possible',
        'Let me decide during labor',
      ],
    ),
    BirthPlanQuestion(
      id: 'pain-techniques',
      section: 'Pain Management',
      question: 'Non-medical techniques I want',
      options: [
        'Breathing techniques',
        'Movement / walking',
        'Shower / bath',
        'Birthing ball',
        'Massage',
        'Position changes',
      ],
    ),

    // LABOR SUPPORT
    BirthPlanQuestion(
      id: 'support-team',
      section: 'Labor Support',
      question: 'Who will be with me',
      options: ['Partner', 'Doula', 'Mother', 'Friend', 'Just medical staff'],
    ),
    BirthPlanQuestion(
      id: 'support-movement',
      section: 'Labor Support',
      question: 'Freedom of movement during labor',
      options: [
        'Walking and moving freely',
        'Birthing ball / chair',
        'Hydrotherapy (shower/bath)',
        'Limited to bed if necessary',
      ],
    ),
    BirthPlanQuestion(
      id: 'support-monitoring',
      section: 'Labor Support',
      question: 'Fetal monitoring preference',
      options: [
        'Intermittent only',
        'Continuous if required',
        'Whatever is safest',
      ],
    ),

    // DELIVERY
    BirthPlanQuestion(
      id: 'delivery-position',
      section: 'Delivery',
      question: 'Preferred birthing position',
      options: [
        'Whatever feels right in the moment',
        'Upright / squatting',
        'Side-lying',
        'On hands and knees',
        'Traditional / on back',
      ],
    ),
    BirthPlanQuestion(
      id: 'delivery-episiotomy',
      section: 'Delivery',
      question: 'Episiotomy preference',
      options: [
        'Avoid if possible, prefer natural tearing',
        'Only if medically necessary',
        'No strong preference',
      ],
    ),
    BirthPlanQuestion(
      id: 'delivery-partner-role',
      section: 'Delivery',
      question: 'Partner involvement at delivery',
      options: [
        'Hold my hand / coach me',
        'Catch baby',
        'Cut the cord',
        'Announce sex',
        'Stay by my head',
      ],
    ),

    // AFTER BIRTH
    BirthPlanQuestion(
      id: 'after-cord',
      section: 'After Birth',
      question: 'Cord clamping',
      options: [
        'Delayed cord clamping',
        'Whatever is standard',
        'Save cord blood',
      ],
    ),
    BirthPlanQuestion(
      id: 'after-skin-to-skin',
      section: 'After Birth',
      question: 'First moments',
      options: [
        'Immediate skin-to-skin for 1+ hours',
        'Weigh baby first, then skin-to-skin',
        'Follow hospital routine',
      ],
    ),
    BirthPlanQuestion(
      id: 'after-feeding',
      section: 'After Birth',
      question: 'First feeding',
      options: [
        'Breastfeed immediately',
        'Formula feed from the start',
        'Combination',
        'Still deciding',
      ],
    ),
    BirthPlanQuestion(
      id: 'after-placenta',
      section: 'After Birth',
      question: 'Placenta',
      options: [
        'Dispose normally',
        'I want to see it',
        'Save for encapsulation',
      ],
    ),

    // NEWBORN CARE
    BirthPlanQuestion(
      id: 'newborn-bath',
      section: 'Newborn Care',
      question: "Baby's first bath",
      options: [
        'Delay 24+ hours',
        'After first feeding',
        'Standard timing',
      ],
    ),
    BirthPlanQuestion(
      id: 'newborn-vitamin-k',
      section: 'Newborn Care',
      question: 'Vitamin K injection',
      options: ['Yes', 'Oral vitamin K instead', 'Discuss with doctor'],
    ),
    BirthPlanQuestion(
      id: 'newborn-eye-ointment',
      section: 'Newborn Care',
      question: 'Eye ointment',
      options: ['Yes', 'Delay', 'Decline'],
    ),
    BirthPlanQuestion(
      id: 'newborn-circumcision',
      section: 'Newborn Care',
      question: 'Circumcision (if applicable)',
      options: ['Yes', 'No', "Doesn't apply"],
    ),
    BirthPlanQuestion(
      id: 'newborn-nursery',
      section: 'Newborn Care',
      question: 'Rooming-in',
      options: [
        'Baby stays with me at all times',
        'Nursery at night only',
        'Follow hospital routine',
      ],
    ),
  ];

  static List<BirthPlanQuestion> bySection(String section) {
    return questions.where((q) => q.section == section).toList();
  }
}

/// Month-by-month baby development data (0-24 months)
/// Content reviewed against AAP, WHO, and CDC developmental guidelines
class BabyMonthData {
  final int month;
  final String title;
  final String emoji;
  final double avgWeightKgBoy;
  final double avgWeightKgGirl;
  final double avgHeightCmBoy;
  final double avgHeightCmGirl;
  final String physicalDevelopment;
  final String cognitiveDevelopment;
  final String socialEmotional;
  final String languageDevelopment;
  final List<MilestoneItem> milestones;
  final List<String> activities;
  final SleepGuide sleep;
  final FeedingGuide feeding;
  final List<String> redFlags;
  final List<String> parentTips;
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

  String get ageLabel {
    if (month == 0) return 'Newborn';
    if (month == 1) return '1 Month';
    if (month < 12) return '$month Months';
    if (month == 12) return '1 Year';
    if (month == 24) return '2 Years';
    return '$month Months';
  }

  static BabyMonthData getMonth(int month) {
    return _monthData[month.clamp(0, 24)] ?? _monthData[0]!;
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
      title: 'Hello, World',
      emoji: '👶',
      avgWeightKgBoy: 3.3,
      avgWeightKgGirl: 3.2,
      avgHeightCmBoy: 49.9,
      avgHeightCmGirl: 49.1,
      physicalDevelopment:
          'Your newborn has natural reflexes: rooting (turning toward touch on cheek), '
          'sucking, grasping (curling fingers around yours), and the startle (Moro) reflex. '
          'Their vision is blurry — they can only focus 20-30cm away, perfect for seeing your face during feeding. '
          'Head control is minimal; always support their neck.',
      cognitiveDevelopment:
          'Baby recognizes your voice from the womb and prefers it over all other sounds. '
          'They can distinguish between light and dark, and are drawn to high-contrast patterns. '
          'Their brain is forming 1 million neural connections per second.',
      socialEmotional:
          'Bonding begins immediately through skin-to-skin contact. Baby finds comfort in your heartbeat, '
          'warmth, and smell. Crying is their only communication tool — they are not manipulating you. '
          'Respond to every cry; you cannot spoil a newborn.',
      languageDevelopment:
          'Baby communicates through crying (hunger, discomfort, tiredness have different cries — '
          'you\'ll learn to distinguish them). They are actively listening and absorbing language patterns. '
          'Talk, sing, and narrate your day to them.',
      milestones: [
        MilestoneItem('Lifts head briefly during tummy time', MilestoneCategory.motor),
        MilestoneItem('Focuses on faces 20-30cm away', MilestoneCategory.cognitive),
        MilestoneItem('Responds to loud sounds (startle)', MilestoneCategory.sensory),
        MilestoneItem('Brings hands to face', MilestoneCategory.motor),
        MilestoneItem('Recognizes parent\'s voice', MilestoneCategory.social),
        MilestoneItem('Strong grasp reflex', MilestoneCategory.motor),
      ],
      activities: [
        'Skin-to-skin contact (kangaroo care) — 1+ hours daily',
        'Tummy time: Start with 1-2 minutes, 2-3 times per day on your chest',
        'Black and white contrast cards held 20-30cm from face',
        'Gentle talking and singing — narrate everything you do',
        'Gentle massage after bath — improves bonding and digestion',
        'Eye contact during feeding — this builds secure attachment',
      ],
      sleep: const SleepGuide(
        totalHours: '14-17 hours',
        pattern: 'No day/night rhythm yet. Sleeps in 2-4 hour stretches around the clock.',
        tips: [
          'Always place on back to sleep (reduces SIDS risk by 50%)',
          'Firm, flat surface with no blankets, pillows, or toys',
          'Room-sharing (not bed-sharing) for the first 6 months',
          'Swaddling helps mimic the womb — arms snug, hips loose',
          'White noise mimics womb sounds and helps them settle',
          'Day/night confusion is normal — expose to daylight during awake times',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Breast milk or formula exclusively',
        frequency: 'Every 2-3 hours (8-12 times per day)',
        amount: '30-90ml per feeding, increasing gradually',
        tips: [
          'Colostrum (first milk) is liquid gold — rich in antibodies',
          'Feed on demand, not on a schedule',
          'Watch for hunger cues: rooting, lip smacking, hand to mouth',
          'Breastfed babies typically feed more frequently than formula-fed',
          'Expect to lose 5-10% of birth weight — they regain it by day 10-14',
          'Wet diapers: at least 6 per day by day 5 = adequate feeding',
        ],
      ),
      redFlags: [
        'Not feeding well or refusing to eat',
        'Fewer than 6 wet diapers per day after day 5',
        'Yellow skin or eyes that worsen (jaundice)',
        'Rectal temperature above 38°C (100.4°F) — go to ER immediately',
        'Difficulty breathing or blue-tinged lips',
        'Excessive sleepiness — cannot wake for feedings',
        'No startle response to loud sounds',
      ],
      parentTips: [
        'Sleep when baby sleeps — seriously, do it',
        'Accept help from everyone who offers',
        'Postpartum mood changes are normal — but talk to your doctor if sadness persists beyond 2 weeks',
        'Your partner needs bonding time too — skin-to-skin, diaper changes, bath time',
        'Take photos every day — they change faster than you think',
        'You are not failing. This is hard. You are doing amazing.',
      ],
      checkup: const HealthCheckup(
        timing: '3-5 days after birth',
        vaccines: ['Hepatitis B (first dose, usually given at hospital)'],
        screenings: ['Newborn metabolic screening', 'Hearing test', 'Jaundice check', 'Weight check'],
      ),
    ),

    // =========================================================
    // 1 MONTH
    // =========================================================
    1: BabyMonthData(
      month: 1,
      title: 'Finding Focus',
      emoji: '👀',
      avgWeightKgBoy: 4.5,
      avgWeightKgGirl: 4.2,
      avgHeightCmBoy: 54.7,
      avgHeightCmGirl: 53.7,
      physicalDevelopment:
          'Neck muscles are getting stronger. During tummy time, baby can briefly lift their head '
          '45 degrees. Movements are still mostly reflexive but becoming more purposeful. '
          'They may start to uncurl from the fetal position.',
      cognitiveDevelopment:
          'Visual tracking is developing — baby can follow a slowly moving object with their eyes. '
          'They prefer faces over objects and can see bold patterns. Hearing is well-developed; '
          'they turn toward familiar sounds.',
      socialEmotional:
          'The first real social smile typically appears between 4-6 weeks — and it will melt your heart. '
          'Baby is learning to self-soothe by sucking on hands. They show clear preference for parents over strangers.',
      languageDevelopment:
          'Cooing begins — soft vowel sounds like "ooh" and "aah." '
          'Baby is starting to make sounds other than crying. '
          'They listen intently when you talk and may move their mouth as if trying to respond.',
      milestones: [
        MilestoneItem('Lifts head 45° during tummy time', MilestoneCategory.motor),
        MilestoneItem('Follows objects with eyes (tracking)', MilestoneCategory.cognitive),
        MilestoneItem('First social smile (4-6 weeks)', MilestoneCategory.social),
        MilestoneItem('Coos and makes "ooh/aah" sounds', MilestoneCategory.language),
        MilestoneItem('Brings hands to mouth', MilestoneCategory.motor),
        MilestoneItem('Recognizes parent from across the room', MilestoneCategory.cognitive),
      ],
      activities: [
        'Tummy time: Work up to 10 minutes total per day in short sessions',
        'Face-to-face time — make exaggerated expressions, baby will try to imitate',
        'Slowly move a rattle or toy side to side for visual tracking',
        'Read aloud — rhythm and tone matter more than words at this age',
        'Carry baby facing outward briefly to explore the world',
        'Play gentle peek-a-boo (early version — just covering and revealing your face)',
      ],
      sleep: const SleepGuide(
        totalHours: '14-17 hours',
        pattern: 'Starting to have slightly longer sleep stretches at night (3-4 hours). Still no fixed schedule.',
        tips: [
          'Begin differentiating day and night — bright and active during day, dim and quiet at night',
          'Start a simple bedtime routine: dim lights, warm bath, feeding, lullaby',
          'Put baby down drowsy but awake to start learning self-settling',
          'Swaddling still very helpful',
          'Cluster feeding in the evening is normal — it helps build milk supply',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Breast milk or formula exclusively',
        frequency: 'Every 2-3 hours (still 8-12 times per day)',
        amount: '60-120ml per feeding',
        tips: [
          'Growth spurt around 3 weeks — baby may feed more frequently for 2-3 days',
          'This is not a sign of low supply — more frequent feeding increases supply',
          'Spit-up is normal if baby is gaining weight and seems comfortable',
          'Burp during and after feedings to reduce gas',
        ],
      ),
      redFlags: [
        'No response to loud sounds',
        'Does not focus on or follow objects with eyes',
        'No social smile by 8 weeks',
        'Does not bring hands to mouth',
        'Seems very stiff or very floppy',
        'One eye turns in or out consistently',
      ],
      parentTips: [
        'That first smile is real — not gas. Celebrate it!',
        'Establish a simple routine (not a rigid schedule) — feed, play, sleep',
        'Get outside daily — fresh air is good for both of you',
        'Date night can be 30 minutes on the couch together after baby sleeps',
        'Document the small moments — first smile, first coo, first outfit',
      ],
      checkup: const HealthCheckup(
        timing: '1 month well-visit',
        vaccines: ['Hepatitis B (second dose if not given earlier)'],
        screenings: ['Growth and weight check', 'Head circumference', 'Reflexes assessment'],
      ),
    ),

    // =========================================================
    // 2 MONTHS
    // =========================================================
    2: BabyMonthData(
      month: 2,
      title: 'Smiles & Sounds',
      emoji: '😊',
      avgWeightKgBoy: 5.6,
      avgWeightKgGirl: 5.1,
      avgHeightCmBoy: 58.4,
      avgHeightCmGirl: 57.1,
      physicalDevelopment:
          'Head control is improving significantly. Baby can hold head up at 45° during tummy time '
          'for extended periods. They\'re discovering their hands — watching them, bringing them together. '
          'May begin to bat at objects dangling overhead.',
      cognitiveDevelopment:
          'Baby can now see color and is attracted to bright objects. They recognize familiar people '
          'from further away. Cause-and-effect learning begins — they notice that crying brings you, '
          'or that kicking makes a mobile move.',
      socialEmotional:
          'Social smiling is well-established now — baby smiles in response to your smile. '
          'They may coo when you talk to them, creating their first "conversations." '
          'Baby begins to show excitement when they see you.',
      languageDevelopment:
          'Cooing is more frequent and varied. Baby experiments with vowel sounds and occasionally '
          'squeals with delight. They listen carefully and may quiet down when you speak. '
          'First proto-conversations: you talk, baby coos back, you respond.',
      milestones: [
        MilestoneItem('Holds head at 45° steadily during tummy time', MilestoneCategory.motor),
        MilestoneItem('Smiles responsively at people', MilestoneCategory.social),
        MilestoneItem('Follows objects 180° with eyes', MilestoneCategory.cognitive),
        MilestoneItem('Coos and makes vowel sounds', MilestoneCategory.language),
        MilestoneItem('Discovers hands — watches and clasps them', MilestoneCategory.cognitive),
        MilestoneItem('Briefly holds a rattle placed in hand', MilestoneCategory.motor),
        MilestoneItem('Begins to self-soothe (sucking on fist)', MilestoneCategory.social),
      ],
      activities: [
        'Tummy time: 15-20 minutes total daily — use a rolled towel under chest for support',
        'Play gym / activity mat with dangling toys overhead',
        'Mirror play — babies love looking at faces, even their own',
        'Sing songs with hand motions (Itsy Bitsy Spider, Pat-a-cake)',
        'Gently bicycle baby\'s legs — helps with gas and builds awareness',
        'Narrate your daily activities in a warm, animated voice',
        'Hold colorful toys and slowly move them for tracking practice',
      ],
      sleep: const SleepGuide(
        totalHours: '14-17 hours',
        pattern: 'May start sleeping one 4-6 hour stretch at night. 3-4 naps during the day.',
        tips: [
          'Bedtime routine becomes very important now — consistency is key',
          'Drowsy but awake is the goal for bedtime',
          'Day naps can still be anywhere (carrier, stroller, crib)',
          'Don\'t let daytime naps exceed 2 hours — protect nighttime sleep',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Breast milk or formula exclusively',
        frequency: 'Every 3-4 hours (6-8 times per day)',
        amount: '120-150ml per feeding',
        tips: [
          'Growth spurt around 6 weeks — increased feeding is normal',
          'Baby becomes more efficient at feeding — sessions may get shorter',
          'If breastfeeding, this is often when it "clicks" and gets easier',
          'No water, juice, or solids yet',
        ],
      ),
      redFlags: [
        'Does not respond to loud sounds',
        'Does not follow moving objects with eyes',
        'Does not smile at people',
        'Does not bring hands to mouth',
        'Cannot hold head up when lying on stomach',
      ],
      parentTips: [
        'This is often called the "reward phase" — baby is more interactive and smiley',
        'Take a CPR class if you haven\'t already',
        'Start thinking about childcare options if returning to work',
        'Your body is still healing — be patient with yourself',
      ],
      checkup: const HealthCheckup(
        timing: '2 month well-visit',
        vaccines: [
          'DTaP (diphtheria, tetanus, pertussis) — dose 1',
          'IPV (polio) — dose 1',
          'Hib (Haemophilus influenzae) — dose 1',
          'PCV13 (pneumococcal) — dose 1',
          'Rotavirus — dose 1 (oral)',
          'Hepatitis B — dose 2 (if not already given)',
        ],
        screenings: ['Growth assessment', 'Developmental screening'],
      ),
    ),

    // =========================================================
    // 3 MONTHS
    // =========================================================
    3: BabyMonthData(
      month: 3,
      title: 'Reaching Out',
      emoji: '🤲',
      avgWeightKgBoy: 6.4,
      avgWeightKgGirl: 5.8,
      avgHeightCmBoy: 61.4,
      avgHeightCmGirl: 59.8,
      physicalDevelopment:
          'Head control is strong — baby holds head steady when held upright. During tummy time, '
          'they push up on forearms (mini push-up). Reaching for objects becomes intentional. '
          'They can open and close hands deliberately. The startle reflex is fading.',
      cognitiveDevelopment:
          'Baby recognizes familiar objects and reaches for them. They study their own hands intently. '
          'Memory is developing — they anticipate routines (getting excited when they see the bottle or breast). '
          'Object tracking is smooth and coordinated.',
      socialEmotional:
          'Baby laughs out loud for the first time! They are becoming a social butterfly — smiling at everyone, '
          'cooing in conversation, and showing displeasure when play stops. They can imitate some facial expressions.',
      languageDevelopment:
          'Babbling begins with consonant-vowel combinations: "goo," "gah," "bah." '
          'Baby "talks" when you talk and takes turns in vocal exchanges. '
          'They may squeal, growl, and blow raspberries experimenting with their voice.',
      milestones: [
        MilestoneItem('Holds head steady when upright', MilestoneCategory.motor),
        MilestoneItem('Pushes up on forearms during tummy time', MilestoneCategory.motor),
        MilestoneItem('Reaches for and bats at objects', MilestoneCategory.motor),
        MilestoneItem('Laughs out loud', MilestoneCategory.social),
        MilestoneItem('Babbles with consonant sounds', MilestoneCategory.language),
        MilestoneItem('Opens and closes hands deliberately', MilestoneCategory.motor),
        MilestoneItem('Bears some weight on legs when held standing', MilestoneCategory.motor),
      ],
      activities: [
        'Tummy time: 20-30 minutes daily — they may start to enjoy it now',
        'Offer toys to reach for and grasp — soft rattles, crinkle toys',
        'Play peek-a-boo — early understanding of object permanence',
        'Dance together while holding baby — they love rhythm and movement',
        'Water play during bath — let them splash with hands',
        'Read board books with bold, simple images',
        'Let them feel different textures: smooth, rough, soft, bumpy',
      ],
      sleep: const SleepGuide(
        totalHours: '14-16 hours',
        pattern: '6-8 hours at night (some babies!), 3 naps during the day. Circadian rhythm is developing.',
        tips: [
          'The 3-month sleep regression is common — hang in there',
          'Consistent wake-up time helps regulate the body clock',
          'Start transitioning out of the swaddle if baby is rolling',
          'Dark room + white noise + consistent routine = better sleep',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Breast milk or formula exclusively',
        frequency: 'Every 3-4 hours',
        amount: '150-180ml per feeding',
        tips: [
          'Baby is more distracted during feeding — find a quiet spot',
          '3-month growth spurt may increase hunger temporarily',
          'Still no solids — despite what grandma says!',
          'If pumping, this is when you may start building a freezer stash',
        ],
      ),
      redFlags: [
        'Does not follow moving objects with eyes',
        'Does not grasp or hold objects',
        'Does not smile at people',
        'Cannot support head well',
        'Does not babble or make sounds',
        'Does not respond to you or seems uninterested in people',
      ],
      parentTips: [
        'This is often when parents feel they\'re "getting the hang of it"',
        'Baby may start to resist naps — they don\'t want to miss anything!',
        'Start a "first year" photo book while memories are fresh',
        'Connect with other parents — isolation is the enemy of new parenthood',
      ],
    ),

    // =========================================================
    // 4 MONTHS
    // =========================================================
    4: BabyMonthData(
      month: 4,
      title: 'The Grabber',
      emoji: '✊',
      avgWeightKgBoy: 7.0,
      avgWeightKgGirl: 6.4,
      avgHeightCmBoy: 63.9,
      avgHeightCmGirl: 62.1,
      physicalDevelopment:
          'Baby grabs everything and brings it to their mouth — this is how they learn about objects. '
          'They can roll from tummy to back. During tummy time, they push up high on extended arms. '
          'They may start to reach across their body (crossing midline — an important milestone).',
      cognitiveDevelopment:
          'Cause and effect is clicking — baby shakes a rattle on purpose to hear the sound. '
          'They look for partially hidden objects. Memory is improving; they remember routines and people.',
      socialEmotional:
          'Baby initiates social interaction — smiling at you to get you to play. '
          'They show preferences for certain toys and people. Stranger awareness may begin (not full anxiety yet).',
      languageDevelopment:
          'Babbling is becoming more complex — strings of sounds "ba-ba-ba" or "ma-ma-ma" (not meaningful yet). '
          'Baby responds to their name by turning. They change volume and pitch experimentally.',
      milestones: [
        MilestoneItem('Rolls tummy to back', MilestoneCategory.motor),
        MilestoneItem('Reaches for objects with one hand', MilestoneCategory.motor),
        MilestoneItem('Brings objects to mouth to explore', MilestoneCategory.cognitive),
        MilestoneItem('Pushes up on extended arms during tummy time', MilestoneCategory.motor),
        MilestoneItem('Responds to name', MilestoneCategory.language),
        MilestoneItem('Babbles chains of consonants', MilestoneCategory.language),
        MilestoneItem('Bears full weight on legs when held standing', MilestoneCategory.motor),
      ],
      activities: [
        'Offer toys of different shapes and textures to grab and mouth',
        'Play "airplane" — lift baby in the air (strengthens core)',
        'Roll a ball toward baby during tummy time',
        'Sing action songs — "If You\'re Happy and You Know It"',
        'Let baby explore safe objects from the kitchen (wooden spoon, silicone cup)',
        'Blow raspberries on their belly — they\'ll love it',
        'Start reading books with simple repetitive text',
      ],
      sleep: const SleepGuide(
        totalHours: '12-16 hours',
        pattern: '10-12 hours at night (with 1-2 feedings), 2-3 naps.',
        tips: [
          'The 4-month sleep regression is REAL — sleep cycles are maturing',
          'This is a good time to consider gentle sleep training if needed',
          'Stop swaddling — baby needs arms free for rolling safety',
          'Consistent nap times help (roughly 9am, 12pm, 3pm)',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Breast milk or formula exclusively',
        frequency: 'Every 3-4 hours, 5-6 times per day',
        amount: '150-210ml per feeding',
        tips: [
          'Baby may show interest in your food — but 4 months is too early for solids',
          'Wait until 6 months for solids (WHO recommendation)',
          'Some pediatricians approve solids at 4-5 months — follow your doctor\'s guidance',
          'Signs of readiness: sits with support, good head control, tongue-thrust reflex gone',
        ],
      ),
      redFlags: [
        'Does not reach for or hold objects',
        'Does not roll in any direction',
        'Does not respond to sounds or name',
        'Does not babble',
        'Does not push up during tummy time',
        'Shows no interest in people',
      ],
      parentTips: [
        'Babyproof NOW — crawling comes sooner than you think',
        'Mouth everything? That\'s normal. Keep small objects away',
        'The 4-month sleep regression will pass. You will survive it.',
        'This is a great age for family photos — baby is expressive and alert',
      ],
      checkup: const HealthCheckup(
        timing: '4 month well-visit',
        vaccines: [
          'DTaP — dose 2',
          'IPV — dose 2',
          'Hib — dose 2',
          'PCV13 — dose 2',
          'Rotavirus — dose 2',
        ],
        screenings: ['Growth assessment', 'Developmental screening', 'Vision check'],
      ),
    ),

    // =========================================================
    // 6 MONTHS
    // =========================================================
    6: BabyMonthData(
      month: 6,
      title: 'Food Explorer',
      emoji: '🥄',
      avgWeightKgBoy: 7.9,
      avgWeightKgGirl: 7.3,
      avgHeightCmBoy: 67.6,
      avgHeightCmGirl: 65.7,
      physicalDevelopment:
          'Baby sits with minimal support (tripod sitting — using hands for balance). '
          'They roll both directions easily. Transfers objects between hands. '
          'May start rocking on hands and knees — pre-crawling! Pincer grasp is emerging (thumb and finger).',
      cognitiveDevelopment:
          'Object permanence is developing — baby looks for a dropped toy. '
          'They understand cause and effect well (drop a spoon, you pick it up — repeat 100 times). '
          'Baby explores everything by mouthing, shaking, banging, and dropping.',
      socialEmotional:
          'Stranger anxiety begins — baby may cry with unfamiliar people. This is healthy attachment, not regression. '
          'They show affection by reaching for you, patting your face, leaning in for "hugs." '
          'Separation anxiety may start.',
      languageDevelopment:
          'Babbling includes distinct syllables: "ba," "da," "ma," "ga." '
          'Baby understands tone — they know when you\'re happy, upset, or asking a question. '
          'They may respond to "no" (briefly). First gestures may emerge.',
      milestones: [
        MilestoneItem('Sits with minimal support', MilestoneCategory.motor),
        MilestoneItem('Rolls both ways easily', MilestoneCategory.motor),
        MilestoneItem('Transfers objects between hands', MilestoneCategory.motor),
        MilestoneItem('Babbles distinct syllables', MilestoneCategory.language),
        MilestoneItem('Looks for dropped objects', MilestoneCategory.cognitive),
        MilestoneItem('Shows stranger anxiety', MilestoneCategory.social),
        MilestoneItem('Begins to eat solid foods', MilestoneCategory.feeding),
        MilestoneItem('Rakes small objects with whole hand', MilestoneCategory.motor),
      ],
      activities: [
        'Introduce solid foods! Start with single-ingredient purees or baby-led weaning',
        'Let baby explore food textures — messy meals are learning meals',
        'Play "where did it go?" — hide a toy under a cloth',
        'Offer stacking cups, blocks, and nesting toys',
        'Encourage sitting practice on soft surfaces with pillows around',
        'Play music and clap hands together — baby may start clapping',
        'Water play with cups and pouring in the bath',
        'Read interactive books (lift-the-flap, touch-and-feel)',
      ],
      sleep: const SleepGuide(
        totalHours: '12-15 hours',
        pattern: '10-11 hours at night, 2-3 naps during the day. Many babies can sleep through the night.',
        tips: [
          'Most babies are ready for sleep training by 6 months if needed',
          'Night feedings may still be 0-1 times',
          'Transitioning to 2 naps often happens around 6-7 months',
          'Teething can disrupt sleep temporarily',
          'Consistent bedtime between 6-8 PM works for most babies',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Breast milk/formula + introduction of solid foods',
        frequency: 'Milk: 4-5 times per day. Solids: 1-2 times per day to start.',
        amount: 'Milk: 180-240ml per feeding. Solids: 1-2 tablespoons per sitting.',
        tips: [
          'Start with iron-rich foods: iron-fortified cereal, pureed meats, lentils',
          'Introduce one new food every 3 days to watch for allergies',
          'Early allergen introduction (peanut, egg, dairy) reduces allergy risk',
          'Offer water in a sippy cup with meals',
          'Food before 1 is for fun — milk is still the primary nutrition',
          'Let baby self-feed when possible (banana, avocado strips, soft cooked veggies)',
          'Never force feed — let baby decide how much to eat',
        ],
      ),
      redFlags: [
        'Cannot sit with support',
        'Does not reach for objects',
        'Does not respond to sounds or own name',
        'Does not show affection to familiar people',
        'Does not babble',
        'Does not roll in either direction',
        'Seems very stiff or very floppy',
      ],
      parentTips: [
        'Starting solids is exciting but messy — embrace the chaos',
        'A splat mat under the high chair saves your sanity',
        'Stranger anxiety means your baby has a secure attachment — that\'s a WIN',
        'Baby might have a favorite parent right now — the other parent shouldn\'t take it personally',
        'Crawl-proofing: get on your hands and knees and look for hazards at baby level',
      ],
      checkup: const HealthCheckup(
        timing: '6 month well-visit',
        vaccines: [
          'DTaP — dose 3',
          'PCV13 — dose 3',
          'Rotavirus — dose 3 (if applicable)',
          'Influenza (flu) — first dose (seasonal)',
          'Hepatitis B — dose 3 (if not completed)',
        ],
        screenings: ['Growth and development', 'Hemoglobin/iron screening', 'Dental assessment'],
      ),
    ),

    // =========================================================
    // 9 MONTHS
    // =========================================================
    9: BabyMonthData(
      month: 9,
      title: 'On the Move',
      emoji: '🏃',
      avgWeightKgBoy: 8.9,
      avgWeightKgGirl: 8.2,
      avgHeightCmBoy: 72.0,
      avgHeightCmGirl: 70.1,
      physicalDevelopment:
          'Crawling is in full swing (or army crawling, bottom scooting — all normal variants). '
          'Baby pulls to stand holding furniture. They sit independently with confidence. '
          'Pincer grasp (thumb and index finger) is developing — they can pick up small pieces of food.',
      cognitiveDevelopment:
          'Object permanence is established — baby knows hidden objects still exist and will look for them. '
          'They understand simple words: "no," "bye-bye," "milk." '
          'Problem-solving emerges: they figure out how to get a toy that\'s out of reach.',
      socialEmotional:
          'Separation anxiety peaks. Baby may cry when you leave the room. '
          'They play social games: peek-a-boo, pat-a-cake, waving bye-bye. '
          'They may cling to a comfort object (blanket, stuffed animal).',
      languageDevelopment:
          'Babbling sounds more like real language with rhythm and intonation. '
          '"Mama" and "dada" may emerge (often used nonspecifically at first). '
          'Baby understands 10-20 words even if they can\'t say them. Points at things they want.',
      milestones: [
        MilestoneItem('Crawls (any style)', MilestoneCategory.motor),
        MilestoneItem('Pulls to standing', MilestoneCategory.motor),
        MilestoneItem('Sits independently without support', MilestoneCategory.motor),
        MilestoneItem('Pincer grasp developing', MilestoneCategory.motor),
        MilestoneItem('Says "mama" or "dada" (nonspecific)', MilestoneCategory.language),
        MilestoneItem('Understands "no"', MilestoneCategory.language),
        MilestoneItem('Waves bye-bye', MilestoneCategory.social),
        MilestoneItem('Plays peek-a-boo', MilestoneCategory.social),
        MilestoneItem('Points at objects', MilestoneCategory.language),
      ],
      activities: [
        'Set up safe spaces for crawling exploration — obstacle courses with cushions',
        'Play "chase" while baby crawls — they\'ll squeal with excitement',
        'Offer finger foods to practice pincer grasp: small pieces of banana, peas, cheerios',
        'Stack blocks and let baby knock them down (they\'ll want to repeat it endlessly)',
        'Name everything: "That\'s a dog! The dog says woof!"',
        'Play with balls — roll back and forth, early turn-taking',
        'Let baby open and close containers with lids',
        'Sing "The Wheels on the Bus" with hand motions',
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: '10-12 hours at night, 2 naps (morning and afternoon).',
        tips: [
          'Separation anxiety can cause nighttime waking — be consistent',
          'Many babies drop to 2 naps around 8-9 months',
          'Standing in the crib is a new skill — practice during the day so it\'s less exciting at night',
          'Comfort objects are OK now (small lovey blanket)',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Breast milk/formula + expanding solid food variety',
        frequency: 'Milk: 3-4 times per day. Solids: 3 meals per day.',
        amount: 'Milk: 180-240ml. Solids: increasing to several tablespoons per meal.',
        tips: [
          'Offer a wide variety of textures — soft chunks, mashed, finger foods',
          'Baby should be eating most food groups now',
          'Encourage self-feeding with fingers and beginner spoons',
          'Offer a cup (open or 360) — start reducing bottles',
          'No honey until 12 months (botulism risk)',
          'No cow\'s milk as main drink until 12 months',
        ],
      ),
      redFlags: [
        'Does not sit independently',
        'Does not bear weight on legs when held standing',
        'Does not babble ("mama," "baba," "dada")',
        'Does not respond to own name',
        'Does not recognize familiar people',
        'Does not look where you point',
        'Does not transfer objects between hands',
      ],
      parentTips: [
        'Baby is mobile — your house will never be the same. Embrace it.',
        'Separation anxiety is NOT a behavior problem — it\'s healthy development',
        'Say bye-bye confidently and briefly. Don\'t sneak out — it makes anxiety worse',
        'This is the golden age of baby giggles. Soak it in.',
      ],
      checkup: const HealthCheckup(
        timing: '9 month well-visit',
        vaccines: ['Hepatitis B — dose 3 (if not completed)', 'Influenza — dose 2 (seasonal)'],
        screenings: ['Developmental screening (ASQ)', 'Growth assessment', 'Iron/lead screening'],
      ),
    ),

    // =========================================================
    // 12 MONTHS — HAPPY BIRTHDAY!
    // =========================================================
    12: BabyMonthData(
      month: 12,
      title: 'Happy First Birthday!',
      emoji: '🎂',
      avgWeightKgBoy: 9.6,
      avgWeightKgGirl: 8.9,
      avgHeightCmBoy: 75.7,
      avgHeightCmGirl: 74.0,
      physicalDevelopment:
          'Many babies take their first independent steps around 12 months (9-15 months is normal range). '
          'They cruise along furniture confidently. Fine motor skills are advancing — they can stack 2 blocks, '
          'turn pages of a board book, and use a pincer grasp precisely.',
      cognitiveDevelopment:
          'Baby understands simple instructions: "Give me the ball," "Where\'s your shoe?" '
          'They imitate actions they\'ve seen: talking on a phone, brushing hair. '
          'Symbolic play begins — using a banana as a phone. Trial and error learning is active.',
      socialEmotional:
          'Baby shows strong preferences for certain people and toys. They test boundaries — dropping food, '
          'banging things — not to be naughty, but to understand the world. '
          'They look to you for reactions (social referencing): "Is this safe? Should I be scared?"',
      languageDevelopment:
          'First real words emerge! Most babies have 1-5 words used consistently and meaningfully. '
          '"Mama," "dada," "ball," "more," "no" are common first words. '
          'Baby understands 50+ words. They follow simple directions.',
      milestones: [
        MilestoneItem('Stands independently', MilestoneCategory.motor),
        MilestoneItem('Takes first steps (9-15 months range is normal)', MilestoneCategory.motor),
        MilestoneItem('Says 1-5 words with meaning', MilestoneCategory.language),
        MilestoneItem('Understands simple instructions', MilestoneCategory.language),
        MilestoneItem('Uses pincer grasp precisely', MilestoneCategory.motor),
        MilestoneItem('Imitates actions (phone to ear, brushing hair)', MilestoneCategory.cognitive),
        MilestoneItem('Waves, claps, points with purpose', MilestoneCategory.social),
        MilestoneItem('Drinks from a cup with help', MilestoneCategory.feeding),
        MilestoneItem('Shows separation anxiety with specific caregivers', MilestoneCategory.social),
      ],
      activities: [
        'Encourage walking — hold both hands, then one hand, then let go briefly',
        'Push toys (toy shopping cart, push walker) build confidence for walking',
        'Shape sorters and simple puzzles (2-3 pieces)',
        'Pretend play: toy kitchen, phone, baby doll',
        'Play "go find the ___!" — builds vocabulary and comprehension',
        'Dance parties! Toddlers love music with a strong beat',
        'Outdoor exploration: park, sandbox, nature walks',
        'Crayons and large paper — first marks are a huge milestone',
        'Stack and knock down blocks endlessly',
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: '10-12 hours at night, 1-2 naps. Many start transitioning to 1 nap.',
        tips: [
          'The 12-month sleep regression often coincides with first steps and first words',
          'Resist dropping to 1 nap too early — most toddlers need 2 naps until 14-18 months',
          'Bedtime resistance may increase — toddlers FOMO is real',
          'A consistent, boring bedtime routine is your best friend',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Transition to whole cow\'s milk + table foods',
        frequency: '3 meals + 2-3 snacks per day. Milk: 3 cups per day.',
        amount: 'Milk: 360-480ml total per day (no more). Balanced meals.',
        tips: [
          'Switch from formula to whole cow\'s milk (or continue breastfeeding)',
          'Limit milk to 480ml/day — too much blocks iron absorption',
          'Wean from the bottle by 12-15 months — use cups',
          'Baby should eat what the family eats (with age-appropriate modifications)',
          'Picky eating often starts now — keep offering variety without pressure',
          'Division of responsibility: you decide WHAT and WHEN, baby decides IF and HOW MUCH',
          'Cut round foods (grapes, cherry tomatoes, hot dogs) lengthwise to prevent choking',
        ],
      ),
      redFlags: [
        'Does not stand with support',
        'Does not use any words',
        'Does not point to objects or pictures',
        'Does not wave or use gestures',
        'Loses skills they previously had',
        'Does not look where you point',
        'Does not search for hidden objects',
      ],
      parentTips: [
        'Happy birthday to your baby — and to you as a parent! You made it through year one.',
        'Don\'t compare walking timelines. 9-15 months is the normal range.',
        'The toddler phase is wild but so rewarding. Buckle up!',
        'Start saying "You did it!" more than "Good job!" — process over praise',
        'Celebrate this milestone — you transformed a helpless newborn into a walking, talking human',
      ],
      checkup: const HealthCheckup(
        timing: '12 month well-visit',
        vaccines: [
          'MMR (measles, mumps, rubella) — dose 1',
          'Varicella (chickenpox) — dose 1',
          'Hepatitis A — dose 1',
          'PCV13 — booster',
        ],
        screenings: ['Developmental screening', 'Autism screening (M-CHAT)', 'Growth assessment', 'Lead screening'],
      ),
    ),

    // =========================================================
    // 15 MONTHS
    // =========================================================
    15: BabyMonthData(
      month: 15,
      title: 'The Explorer',
      emoji: '🌍',
      avgWeightKgBoy: 10.3,
      avgWeightKgGirl: 9.6,
      avgHeightCmBoy: 79.1,
      avgHeightCmGirl: 77.5,
      physicalDevelopment:
          'Walking is becoming more stable and confident. Toddler may start running (a wobbly fast walk). '
          'They can squat to pick up objects and stand back up. Climbing stairs with help begins. '
          'They stack 2-4 blocks and turn book pages.',
      cognitiveDevelopment:
          'Toddler understands simple concepts: "in," "out," "up," "more." '
          'They can point to body parts when asked. Problem-solving is improving — '
          'they\'ll try different approaches to get what they want.',
      socialEmotional:
          'Tantrums begin! Big emotions, small vocabulary = frustration. This is 100% developmentally normal. '
          'Toddler wants to do things independently. They show empathy — may hug a crying friend. '
          'Parallel play (playing alongside, not with) other children.',
      languageDevelopment:
          'Vocabulary is growing: 5-10 words used consistently. '
          'Toddler uses gestures combined with words. They understand far more than they can say. '
          'Follow simple commands: "Give me the cup," "Where\'s daddy?"',
      milestones: [
        MilestoneItem('Walks well independently', MilestoneCategory.motor),
        MilestoneItem('Squats and stands back up', MilestoneCategory.motor),
        MilestoneItem('Stacks 2-4 blocks', MilestoneCategory.motor),
        MilestoneItem('Uses 5-10 words', MilestoneCategory.language),
        MilestoneItem('Points to body parts when named', MilestoneCategory.language),
        MilestoneItem('Follows simple instructions', MilestoneCategory.cognitive),
        MilestoneItem('Shows empathy toward others', MilestoneCategory.social),
        MilestoneItem('Attempts to use spoon/fork', MilestoneCategory.feeding),
      ],
      activities: [
        'Outdoor play every day — playground, nature walks, sandbox',
        'Ball play: kicking, throwing (overhand), rolling',
        'Simple art: finger painting, crayon scribbling, play dough',
        'Stacking and nesting toys, simple puzzles',
        'Name body parts while getting dressed: "Where\'s your nose?"',
        'Let toddler "help" with simple tasks: wiping, putting things in bins',
        'Pretend play with toy animals, cars, dolls',
        'Read, read, read — ask "where\'s the cat?" for interactive reading',
      ],
      sleep: const SleepGuide(
        totalHours: '12-14 hours',
        pattern: '10-12 hours at night, transitioning from 2 naps to 1 afternoon nap.',
        tips: [
          'The 2-to-1 nap transition takes 2-4 weeks — expect some cranky days',
          'If 1 nap, aim for 12:30-1:00 PM start, 2-2.5 hours long',
          'Bedtime may need to move earlier temporarily during nap transition',
          'Consistent routine matters more than ever with an opinionated toddler',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Table foods + whole milk (or continued breastfeeding)',
        frequency: '3 meals + 2 snacks',
        amount: 'Milk: max 480ml/day. Varied diet.',
        tips: [
          'Picky eating peaks between 15-24 months — this is normal',
          'It can take 15-20 exposures before a child accepts a new food',
          'Don\'t give up! Keep offering without pressure',
          'Eat together as a family when possible — modeling is powerful',
          'Toddler portion = roughly 1/4 of an adult portion',
        ],
      ),
      redFlags: [
        'Does not walk independently',
        'Does not use at least 3 words',
        'Does not point to show things',
        'Does not follow simple instructions',
        'Loses previously acquired skills',
        'Does not imitate others',
      ],
      parentTips: [
        'Tantrums are not personal. Stay calm. You are the rock.',
        'Offer choices: "Red shirt or blue shirt?" — it reduces power struggles',
        'Name their emotions: "You\'re frustrated because..." — builds emotional vocabulary',
        'Toddler-proofing is a continuous process — they find new dangers weekly',
      ],
      checkup: const HealthCheckup(
        timing: '15 month well-visit',
        vaccines: ['DTaP — booster (dose 4)', 'Hib — booster'],
        screenings: ['Developmental screening', 'Growth assessment'],
      ),
    ),

    // =========================================================
    // 18 MONTHS
    // =========================================================
    18: BabyMonthData(
      month: 18,
      title: 'The Talker',
      emoji: '🗣️',
      avgWeightKgBoy: 10.9,
      avgWeightKgGirl: 10.2,
      avgHeightCmBoy: 82.3,
      avgHeightCmGirl: 80.7,
      physicalDevelopment:
          'Walking is confident; running begins. Toddler can walk up stairs holding your hand. '
          'They kick a ball forward. Fine motor skills allow them to stack 4+ blocks, '
          'scribble with crayons, and turn single pages of a book.',
      cognitiveDevelopment:
          'Symbolic thinking explodes — a box becomes a car, a stick becomes a sword. '
          'Toddler can sort shapes and colors. They understand "mine" (the beginning of ownership). '
          'Memory is strong — they remember where things are kept and routines in detail.',
      socialEmotional:
          'The word "NO!" becomes a favorite. Autonomy is the driving force. '
          'Toddler shows pride when they accomplish something and frustration when they can\'t. '
          'They may hit, bite, or throw things — not out of malice, but out of overwhelming emotions.',
      languageDevelopment:
          'Vocabulary explosion begins! Toddler knows 20-50 words and is learning new ones daily. '
          'They start combining 2 words: "more milk," "daddy go," "big dog." '
          'They can point to pictures in books when you name them.',
      milestones: [
        MilestoneItem('Runs (wobbly but intentional)', MilestoneCategory.motor),
        MilestoneItem('Kicks a ball forward', MilestoneCategory.motor),
        MilestoneItem('Walks up stairs with hand held', MilestoneCategory.motor),
        MilestoneItem('Uses 20-50 words', MilestoneCategory.language),
        MilestoneItem('Combines 2 words together', MilestoneCategory.language),
        MilestoneItem('Points to pictures in books', MilestoneCategory.language),
        MilestoneItem('Pretend play (feeding a doll, driving a car)', MilestoneCategory.cognitive),
        MilestoneItem('Sorts shapes or colors', MilestoneCategory.cognitive),
        MilestoneItem('Shows defiance — says "no!"', MilestoneCategory.social),
        MilestoneItem('Uses spoon and fork with some spilling', MilestoneCategory.feeding),
      ],
      activities: [
        'Pretend play: toy kitchen, doctor kit, shopping, cleaning',
        'Simple shape sorters and chunky puzzles (4-6 pieces)',
        'Arts and crafts: stamp pads, dot markers, stickers, play dough',
        'Outdoor: climbing structures, tricycle (push with feet), sandbox',
        'Music: rhythm instruments (drums, maracas, tambourine)',
        'Sorting games: by color, shape, or size',
        'Build towers and let toddler knock them down',
        'Ask "what\'s this?" while reading — let them point and name',
        'Simple chores: putting toys in a bin, wiping surfaces',
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: '10-12 hours at night, 1 nap (1.5-3 hours).',
        tips: [
          'The 18-month sleep regression is often the toughest — caused by language explosion + autonomy',
          'Toddler may start climbing out of the crib — consider safety before switching to a bed',
          'Bedtime stalling tactics begin: "one more book," "water," "potty"',
          'Set clear, kind limits: "Two books, one song, then sleep"',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Family foods + whole milk (or continued breastfeeding)',
        frequency: '3 meals + 2 snacks',
        amount: 'Milk: 360-480ml. Varied diet including all food groups.',
        tips: [
          'Let toddler self-feed as much as possible — even if it\'s messy',
          'Serve deconstructed meals — toddlers like to see individual ingredients',
          'Don\'t short-order cook. Offer what the family eats + 1-2 safe foods',
          'Dips make everything more appealing: hummus, yogurt, guacamole',
          'Smoothies are great for hiding vegetables',
        ],
      ),
      redFlags: [
        'Does not use at least 10 words',
        'Does not walk well',
        'Does not point to show you things',
        'Does not copy others',
        'Does not gain new words',
        'Does not notice when a caregiver leaves or returns',
        'Loses skills they used to have',
      ],
      parentTips: [
        'The "terrible twos" often start at 18 months. It\'s really the "terrific toddler brain explosion"',
        'Give transition warnings: "5 more minutes, then we leave the park"',
        'Validate emotions first, redirect behavior second',
        '"I see you\'re angry. I won\'t let you hit. You can stomp your feet."',
        'This is one of the most exhausting AND most magical ages',
      ],
      checkup: const HealthCheckup(
        timing: '18 month well-visit',
        vaccines: ['Hepatitis A — dose 2'],
        screenings: ['Autism screening (M-CHAT-R) — very important at this age', 'Developmental screening', 'Growth assessment'],
      ),
    ),

    // =========================================================
    // 24 MONTHS — HAPPY SECOND BIRTHDAY!
    // =========================================================
    24: BabyMonthData(
      month: 24,
      title: 'Two Years of Wonder',
      emoji: '🎉',
      avgWeightKgBoy: 12.2,
      avgWeightKgGirl: 11.5,
      avgHeightCmBoy: 87.8,
      avgHeightCmGirl: 86.4,
      physicalDevelopment:
          'Running is confident. Toddler can jump with both feet off the ground. '
          'They walk up and down stairs holding a railing. They can kick a ball with aim. '
          'Fine motor: draws lines and circles, stacks 6+ blocks, turns doorknobs, unscrews lids.',
      cognitiveDevelopment:
          'Imagination is in full bloom — elaborate pretend play with storylines. '
          'Toddler can complete simple puzzles (4-6 pieces). They understand concepts like "big/small," '
          '"in/out," "hot/cold." They can sort by shape and color. Memory is excellent.',
      socialEmotional:
          'Toddler is developing a sense of self — they recognize themselves in the mirror and photos. '
          'They play alongside other children and may start sharing (briefly). '
          'Emotions are BIG but they\'re learning to regulate with your help. '
          'Defiance is a sign of healthy independence, not bad behavior.',
      languageDevelopment:
          'Vocabulary is 200-300+ words. Toddler uses 2-3 word sentences regularly: '
          '"I want milk," "Daddy go work," "More apple please." '
          'They ask "What\'s that?" constantly. Strangers can understand about 50% of speech. '
          'They start using pronouns: "I," "me," "you."',
      milestones: [
        MilestoneItem('Runs confidently', MilestoneCategory.motor),
        MilestoneItem('Jumps with both feet', MilestoneCategory.motor),
        MilestoneItem('Walks up and down stairs', MilestoneCategory.motor),
        MilestoneItem('Uses 200-300+ words', MilestoneCategory.language),
        MilestoneItem('Speaks in 2-3 word sentences', MilestoneCategory.language),
        MilestoneItem('Follows 2-step instructions', MilestoneCategory.cognitive),
        MilestoneItem('Engages in pretend play with storylines', MilestoneCategory.cognitive),
        MilestoneItem('Sorts shapes and colors', MilestoneCategory.cognitive),
        MilestoneItem('Shows interest in other children', MilestoneCategory.social),
        MilestoneItem('Expresses many emotions', MilestoneCategory.social),
        MilestoneItem('May show readiness for potty training', MilestoneCategory.motor),
        MilestoneItem('Draws lines and circles', MilestoneCategory.motor),
      ],
      activities: [
        'Elaborate pretend play: store, restaurant, school, doctor, construction',
        'Puzzles: 4-12 pieces, matching games, memory games',
        'Arts: painting, collage, stickers, play dough with tools',
        'Physical: playground climbing, tricycle, balance beam, ball games',
        'Building: larger block structures, train tracks, simple LEGO DUPLO',
        'Nature exploration: bugs, leaves, rocks, puddles, gardening',
        'Social play: playdates with 1-2 other toddlers',
        'Reading: ask "what happened?" and "how does the bear feel?"',
        'Simple counting in daily life: "1, 2, 3 bananas!"',
        'Singing: ABCs, counting songs, action songs',
        'Early potty introduction if showing readiness signs',
      ],
      sleep: const SleepGuide(
        totalHours: '11-14 hours',
        pattern: '10-12 hours at night, 1 nap (1-2.5 hours). Some start resisting the nap.',
        tips: [
          'Keep the nap! Most 2-year-olds still need it even if they resist',
          'If nap is a battle, try "quiet time" in the crib/room for 1 hour minimum',
          'The 2-year sleep regression is often tied to new skills (talking, climbing, potty)',
          'If transitioning to a toddler bed, keep the routine exactly the same',
          'Bedtime: consistent, boring, and non-negotiable. "Two books, one song, goodnight."',
        ],
      ),
      feeding: const FeedingGuide(
        type: 'Family foods + milk (whole or 2%)',
        frequency: '3 meals + 2 snacks per day',
        amount: 'Milk: 360-480ml/day max. Balanced varied diet.',
        tips: [
          'Toddlers are the pickiest eaters — this is developmentally normal',
          'Keep offering rejected foods without pressure — 15-20 exposures!',
          'Involve toddler in meal prep: stirring, washing vegetables, choosing fruit',
          'Family meals matter — eat together as often as possible',
          'Switch from whole milk to 2% after age 2',
          'Limit juice to 120ml/day (or skip it entirely)',
          'Model healthy eating — they watch everything you do',
          'May be ready for potty training — watch for signs of readiness',
        ],
      ),
      redFlags: [
        'Does not use 2-word phrases',
        'Does not use at least 50 words',
        'Does not follow simple instructions',
        'Does not walk steadily',
        'Does not copy actions or words',
        'Loses skills they had before',
        'Does not show interest in other children',
        'Does not point to things in a book',
        'Does not know what common objects are for (phone, brush, spoon)',
      ],
      parentTips: [
        'Happy birthday to your toddler! You survived the first two years. You\'re a champion.',
        'The "terrible twos" are really about a developing brain that wants independence but lacks impulse control',
        'Give yourself grace — parenting a toddler is relentless. Ask for help.',
        'Start thinking about preschool readiness: social skills, following routines, self-help skills',
        'They learn more from watching you than from anything you teach them directly',
        'Document their wild sentences — you\'ll want to remember "I want moon" and "More happy please"',
        'You are raising the next generation of leaders. Every hug, every boundary, every bedtime story matters.',
      ],
      checkup: const HealthCheckup(
        timing: '24 month (2 year) well-visit',
        vaccines: ['DTaP — dose 5 (4-6 years)', 'Hepatitis A — dose 2 (if not completed)'],
        screenings: [
          'Autism screening (M-CHAT-R) — second screening',
          'Developmental screening',
          'Growth assessment and BMI',
          'Dental referral if not already seeing a dentist',
          'Vision screening',
          'Lead screening',
        ],
      ),
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
  final String description;
  final MilestoneCategory category;

  const MilestoneItem(this.description, this.category);
}

class SleepGuide {
  final String totalHours;
  final String pattern;
  final List<String> tips;

  const SleepGuide({
    required this.totalHours,
    required this.pattern,
    required this.tips,
  });
}

class FeedingGuide {
  final String type;
  final String frequency;
  final String amount;
  final List<String> tips;

  const FeedingGuide({
    required this.type,
    required this.frequency,
    required this.amount,
    required this.tips,
  });
}

class HealthCheckup {
  final String timing;
  final List<String> vaccines;
  final List<String> screenings;

  const HealthCheckup({
    required this.timing,
    required this.vaccines,
    required this.screenings,
  });
}

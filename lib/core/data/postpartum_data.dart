import 'package:flutter/material.dart';

/// Postpartum self-care content for new moms.
/// Balam.AI is also for mom's recovery — not just baby care.
class PostpartumTopic {
  final String id;
  final String title;
  final String shortDescription;
  final IconData icon;
  final Color color;
  final String content;
  final List<String> quickTips;
  final List<String> redFlags;

  const PostpartumTopic({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.icon,
    required this.color,
    required this.content,
    required this.quickTips,
    this.redFlags = const [],
  });
}

class PostpartumData {
  PostpartumData._();

  static const topics = <PostpartumTopic>[
    PostpartumTopic(
      id: 'healing',
      title: 'Physical Healing',
      shortDescription: 'Your body just did the hardest thing. It needs time.',
      icon: Icons.favorite,
      color: Color(0xFFE8787A),
      content:
          'Postpartum recovery takes 6-12 weeks — sometimes longer. Be patient with yourself.\n\n'
          'After vaginal birth: bleeding (lochia) for 4-6 weeks, perineal soreness, swelling. '
          'After C-section: incision care for 6+ weeks, no heavy lifting, slower healing.\n\n'
          'You will see blood, swelling, and changes you didn\'t expect. This is all normal. '
          'Your uterus takes 6 weeks to return to its pre-pregnancy size. '
          'Hormonal shifts affect your hair, skin, mood, and sleep.\n\n'
          'This is NOT the time to "bounce back." This is the time to heal.',
      quickTips: [
        'Rest whenever baby rests — dishes can wait',
        'Ice pads (padsicles) soothe perineal swelling',
        'Peri bottle for gentle cleaning after using the bathroom',
        'Stool softeners help with first postpartum bowel movement',
        'Sitz baths 2-3x daily for 10 minutes',
        'Accept ALL help offered — cooking, cleaning, holding baby',
        'No penetrative sex for 6 weeks (until doctor clears)',
      ],
      redFlags: [
        'Soaking a pad in an hour or less',
        'Passing large clots (bigger than golf ball)',
        'Fever over 38°C (100.4°F)',
        'Foul-smelling discharge',
        'Severe headache, vision changes, or swelling',
        'Chest pain or shortness of breath',
        'Redness, warmth, or hardness in leg (blood clot signs)',
      ],
    ),

    PostpartumTopic(
      id: 'mental-health',
      title: 'Mental Health',
      shortDescription: 'Baby blues vs. postpartum depression. Know the difference.',
      icon: Icons.psychology,
      color: Color(0xFF9575CD),
      content:
          '80% of new moms get the baby blues — mood swings, tearfulness, irritability, '
          'anxiety — starting days 3-5 after birth. It should resolve within 2 weeks.\n\n'
          'If it lasts longer than 2 weeks, or if you feel hopeless, disconnected from baby, '
          'or have scary thoughts — that\'s postpartum depression or anxiety. '
          'It affects 1 in 7 mothers. It is TREATABLE. You are not broken. You are not a bad mom.\n\n'
          'Postpartum rage, postpartum OCD, and postpartum psychosis also exist. '
          'All are treatable. None are your fault.\n\n'
          'Asking for help is the bravest thing you can do.',
      quickTips: [
        'Track your mood daily in this app',
        'Tell your partner exactly how you\'re feeling',
        'Get outside every day — even just to the porch',
        'Sleep is medicine. Tag-team with partner for naps.',
        'Limit visitors if they drain you',
        'Join a moms\' group (online or local)',
        'Talk to your OB at every visit about your mental health',
      ],
      redFlags: [
        'Feeling sad/empty every day for 2+ weeks',
        'Thoughts of harming yourself or baby',
        'Unable to sleep even when baby sleeps',
        'Panic attacks',
        'Feeling disconnected from baby or reality',
        'Call doctor IMMEDIATELY for any of these',
      ],
    ),

    PostpartumTopic(
      id: 'sleep',
      title: 'Sleep & Exhaustion',
      shortDescription: 'Sleep deprivation is real. Here\'s how to survive.',
      icon: Icons.bedtime,
      color: Color(0xFF5BBCB4),
      content:
          'You will lose sleep. A lot of it. First 2 weeks: you might get 2-3 hour stretches at best.\n\n'
          'Strategy: abandon the idea of "a night of sleep." Think in chunks. Four 2-hour chunks = 8 hours.\n\n'
          'Sleep when baby sleeps — during the day, at 4pm, whenever. Don\'t clean. Don\'t scroll your phone. Sleep.\n\n'
          'Tag-team with your partner. One person handles nights for 4 hours, the other handles the next 4. '
          'If breastfeeding, partner can change the diaper and bring baby to you.',
      quickTips: [
        'Go to bed at 8pm. Yes, really.',
        'Black-out curtains — both your room AND baby\'s',
        'White noise for baby\'s naps and nights',
        'Keep phone out of bed',
        'Take a 20-minute nap, not 1-hour (avoids sleep inertia)',
        'One parent sleeps through the first shift',
        'No caffeine after 2pm',
      ],
    ),

    PostpartumTopic(
      id: 'nutrition',
      title: 'Nutrition & Hydration',
      shortDescription: 'Fuel your recovery. Especially if breastfeeding.',
      icon: Icons.restaurant,
      color: Color(0xFFF5C15A),
      content:
          'If breastfeeding, you need ~500 extra calories/day and LOTS of water. '
          'Aim for 12-13 glasses of water daily.\n\n'
          'Focus on: iron-rich foods (replace blood loss), protein (tissue repair), '
          'omega-3s (mood and brain), calcium (bones), and healthy fats.\n\n'
          'Don\'t diet. Don\'t restrict. This is the time to EAT.',
      quickTips: [
        'Freeze meals before birth — thank yourself later',
        'Keep snacks near the couch and bed (where you\'ll be nursing)',
        'Oatmeal + flax seeds boost milk supply',
        'Bone broth, lentils, spinach for iron',
        'Salmon, walnuts, chia for omega-3',
        'Drink a full glass of water every time you nurse',
        'Lactation cookies are hype but fine for a treat',
      ],
    ),

    PostpartumTopic(
      id: 'breastfeeding',
      title: 'Breastfeeding',
      shortDescription: 'It\'s natural but not always easy.',
      icon: Icons.child_care,
      color: Color(0xFFEC407A),
      content:
          'Breastfeeding is a learned skill — for both you and baby. Give it 4-6 weeks.\n\n'
          'Colostrum (first milk) is tiny in volume — 1-2 teaspoons. Baby\'s stomach is the size of a marble. '
          'Milk "comes in" days 3-5, often with engorgement. This passes.\n\n'
          'Cluster feeding is normal. So is cracked nipples (at first). So is crying because feeding hurts. '
          'A lactation consultant can change your life. Find one.\n\n'
          'If breastfeeding isn\'t working for you — formula is a valid, safe choice. Fed is best.',
      quickTips: [
        'Deep latch: aim baby\'s chin to your breast',
        'Nipple shields can help if latch hurts',
        'Lanolin cream for cracked nipples',
        'Nurse on demand (every 2-3 hours, or more)',
        'Both sides each feeding in the first weeks',
        'Hydrate before every nursing session',
        'See a lactation consultant in week 1 if pain/trouble',
      ],
      redFlags: [
        'Fever + hot, hard, red breast = mastitis, call doctor',
        'White coating in baby\'s mouth = thrush, both need treatment',
        'Baby not wetting 6+ diapers/day = low milk intake',
        'Cracked bleeding nipples lasting 2+ weeks',
      ],
    ),

    PostpartumTopic(
      id: 'relationship',
      title: 'Your Relationship',
      shortDescription: 'Parenting tests the strongest partnerships.',
      icon: Icons.diversity_2,
      color: Color(0xFF78909C),
      content:
          'A baby changes everything. Your relationship will shift — that\'s normal. Some days it will be hard.\n\n'
          'Resentment builds when one partner feels they\'re doing more. Make the invisible work visible. '
          'Talk about division of labor BEFORE it becomes a fight.\n\n'
          'Intimacy will change. It comes back — but slowly. Connection in other ways matters most.',
      quickTips: [
        'Schedule a daily 10-min check-in with partner',
        'Say "I need you to do X" (specific, not hints)',
        'Appreciate out loud — gratitude is fuel',
        '"You and me vs. the problem" — not each other',
        'Accept you\'ll have different parenting styles',
        'Date night = 30 min on the couch after baby sleeps',
        'Couples therapy is not failure — it\'s strength',
      ],
    ),

    PostpartumTopic(
      id: 'identity',
      title: 'Your New Identity',
      shortDescription: 'Becoming a mother changes who you are.',
      icon: Icons.face_retouching_natural,
      color: Color(0xFFB39DDB),
      content:
          'Matrescence — the process of becoming a mother — is as dramatic as adolescence. '
          'You are rewiring. You are grieving who you were. You are meeting who you\'re becoming.\n\n'
          'It\'s OK to miss your old life. It\'s OK to love your baby AND grieve your freedom. '
          'These feelings coexist. They don\'t make you a bad mom.\n\n'
          'Your body, brain, and priorities are all shifting. Give yourself radical compassion.',
      quickTips: [
        'Write down how you\'re feeling — even messy thoughts',
        'Keep one hobby alive (10 min a day is enough)',
        'Stay connected to one friend who "gets it"',
        'Take photos of yourself — you\'re always the photographer',
        'Ask "what do I need right now?" every morning',
        'Follow creators who normalize postpartum reality',
        'Therapy is for healthy people too',
      ],
    ),
  ];

  static PostpartumTopic? byId(String id) {
    try {
      return topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

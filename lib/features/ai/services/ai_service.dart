import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart' show ParentingStage;
import '../../../main.dart' show isFirebaseInitialized;
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/tracking_entry.dart';
import '../../journey/providers/journey_provider.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref);
});

class AiService {
  final Ref _ref;

  AiService(this._ref);

  /// Call the Cloud Function for AI chat.
  /// Uses real Cloud Function when Firebase is connected, demo responses otherwise.
  Future<String> chat(String message) async {
    final profile = _ref.read(userProfileProvider);
    final tracking = _ref.read(trackingEntriesProvider);
    final todayTracking = tracking.where((e) {
      final now = DateTime.now();
      return e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day;
    }).toList();

    // Try real Cloud Function first
    if (isFirebaseInitialized) {
      try {
        final userContext = {
          'week': profile.currentWeek,
          'stage': profile.stage.name,
          'babyName': profile.babyName,
          'ageMonths': profile.babyAgeMonths,
          'recentTracking': {
            'weight': _latestValue(todayTracking, TrackingType.weight),
            'water': _latestValue(todayTracking, TrackingType.water),
            'sleep': _latestValue(todayTracking, TrackingType.sleep),
            'lastKickCount': _latestValue(todayTracking, TrackingType.kicks),
          },
        };

        final result = await FirebaseFunctions.instance
            .httpsCallable('balamChat')
            .call({'message': message, 'userContext': userContext});
        return result.data['response'] as String;
      } catch (e) {
        debugPrint('[AI] Cloud Function error, falling back to demo: $e');
        // Fall through to demo
      }
    }

    // Demo mode: intelligent responses based on keywords
    return _demoResponse(message, profile);
  }

  double? _latestValue(List<TrackingEntry> entries, TrackingType type) {
    final matching = entries.where((e) => e.type == type);
    return matching.isNotEmpty ? matching.first.value : null;
  }

  /// Simulate AI responses until Cloud Functions are connected
  Future<String> _demoResponse(String message, UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Route to stage-appropriate responses
    if (profile.stage == ParentingStage.toddler) {
      return _demoToddlerResponse(message, profile);
    }
    if (profile.stage == ParentingStage.newborn) {
      return _demoNewbornResponse(message, profile);
    }
    return _demoPregnancyResponse(message, profile);
  }

  /// Demo responses for newborn stage (0-12 months)
  /// Survival mode: feeding, sleep, crying, basic milestones, bonding
  Future<String> _demoNewbornResponse(String message, UserProfile profile) async {
    final age = profile.babyAgeMonths ?? 3;
    final name = profile.babyName ?? 'your little one';
    final lower = message.toLowerCase();

    if (lower.contains('sleep') || lower.contains('nap') || lower.contains('night') || lower.contains('wake') || lower.contains('tired')) {
      if (age <= 3) {
        return "At $age months, $name's sleep is still very much newborn sleep — and that's okay! 🌙\n\n"
            "**What's normal right now:**\n"
            "• 14-17 hours total in 24 hours, in 2-4 hour stretches\n"
            "• No real day/night rhythm yet (this develops around 6-8 weeks)\n"
            "• Waking every 2-3 hours to feed is biological and healthy\n\n"
            "**What helps:**\n"
            "• Dark room + white noise for naps and nighttime\n"
            "• Expose to daylight during awake windows — this builds their circadian rhythm\n"
            "• Watch for sleepy cues: yawning, rubbing eyes, looking away. Awake windows are only 45-90 minutes!\n"
            "• Swaddling helps the startle reflex (until they start rolling)\n\n"
            "You're not creating bad habits. You're meeting a tiny human's needs. 💕";
      }
      return "At $age months, $name's sleep should be consolidating! 🌙\n\n"
          "**Typical schedule at this age:**\n"
          "• 12-15 hours total (including naps)\n"
          "• ${age <= 6 ? '3 naps' : '2 naps'} during the day\n"
          "• Longer stretches at night (4-6+ hours)\n"
          "• Awake windows of ${age <= 6 ? '1.5-2.5' : '2.5-3.5'} hours\n\n"
          "**If sleep suddenly gets worse:**\n"
          "It's likely a developmental leap — $name's brain is busy learning new skills! "
          "Regressions typically happen at 4, 6, 8, and 12 months. They pass in 1-3 weeks. "
          "Stay consistent with your routine and it will get better.";
    }

    if (lower.contains('feed') || lower.contains('eat') || lower.contains('milk') || lower.contains('breast') || lower.contains('bottle') || lower.contains('food') || lower.contains('solid')) {
      if (age < 6) {
        return "At $age months, $name needs only breast milk or formula — nothing else! 🍼\n\n"
            "**How to know feeding is going well:**\n"
            "• 6+ wet diapers per day = well hydrated\n"
            "• Steady weight gain at checkups\n"
            "• ${age <= 2 ? '8-12 feeds per day (every 2-3 hours)' : '6-8 feeds per day (every 3-4 hours)'}\n"
            "• Breast: ${age <= 2 ? '10-20 minutes per side' : '5-15 minutes per side (they get more efficient!)'}\n"
            "• Bottle: ${age <= 2 ? '60-90ml per feed' : '120-180ml per feed'}\n\n"
            "**Remember:** Cluster feeding (wanting to eat constantly) is normal, especially in the evenings. "
            "It doesn't mean your milk isn't enough — it's how babies boost supply.";
      }
      return "At $age months, $name is ready to explore solid foods alongside milk! 🥑\n\n"
          "**Starting solids:**\n"
          "• Signs of readiness: sitting with support, good head control, reaching for food, lost tongue-thrust reflex\n"
          "• Start with single-ingredient purees: avocado, sweet potato, banana, peas\n"
          "• One new food every 3 days (to spot allergies)\n"
          "• Milk is still the primary nutrition until 12 months — solids are for practice!\n"
          "• ${age >= 8 ? 'At $age months, you can start soft finger foods — banana chunks, steamed broccoli, toast strips' : 'Texture progression: smooth puree → mashed → soft chunks'}\n\n"
          "Gagging is normal (it's a safety reflex). Choking is silent. Learn the difference — and always supervise meals.";
    }

    if (lower.contains('normal') || lower.contains('worried') || lower.contains('concern') || lower.contains('on track') || lower.contains('milestone')) {
      if (age <= 3) {
        return "At $age months, here's what's normal for $name: 👶\n\n"
            "**What you should see:**\n"
            "• Lifting head briefly during tummy time\n"
            "• Focusing on faces (especially yours!) at 20-30cm distance\n"
            "• Startling at loud sounds\n"
            "• Making cooing sounds\n"
            "• Grasping your finger reflexively\n\n"
            "**What's normal but worrying:**\n"
            "• Hiccups (a LOT of them — totally normal)\n"
            "• Spitting up after feeds\n"
            "• Grunting, sneezing, making weird noises\n"
            "• Irregular breathing patterns (fast then slow)\n"
            "• Wanting to be held ALL the time (this is biological, not a bad habit)\n\n"
            "You cannot spoil a newborn. Hold them, respond to them, love them. 💕";
      }
      return "At $age months, $name should be showing some exciting development! 🌟\n\n"
          "**Key milestones to watch for:**\n"
          "${age <= 6 ? '• Rolling over (tummy to back first, then back to tummy)\n• Reaching for and grasping objects\n• Babbling vowel sounds (\"aaah\", \"ooooh\")\n• Social smiling and laughing\n• Recognizing familiar faces' : '• Sitting without support\n• Passing objects between hands\n• Babbling consonants (\"baba\", \"dada\")\n• Responding to their name\n• ${age >= 9 ? 'Pulling to stand, cruising along furniture' : 'Starting to creep or crawl'}'}\n\n"
          "**When to talk to your pediatrician:**\n"
          "If $name isn't ${age <= 6 ? 'making eye contact, responding to sounds, or showing interest in faces' : 'babbling, responding to their name, or showing interest in moving around'}.\n\n"
          "Remember: there's a wide range of normal. Late crawlers become great walkers!";
    }

    if (lower.contains('cry') || lower.contains('colic') || lower.contains('fussy') || lower.contains('won\'t stop')) {
      return "Crying is $name's only way to communicate right now — they're not manipulating you! 💕\n\n"
          "**The checklist (in order):**\n"
          "1. Hungry? (last feed was how long ago?)\n"
          "2. Tired? (check awake window — at $age months it's ${age <= 3 ? '45-90 minutes' : '1.5-3 hours'})\n"
          "3. Diaper? (wet or dirty?)\n"
          "4. Overstimulated? (too much noise, light, activity)\n"
          "5. Gas? (bicycle legs, tummy massage, burping)\n"
          "6. Temperature? (feel their chest, not hands/feet)\n\n"
          "**If nothing works:** The \"5 S's\" — Swaddle, Side/Stomach (held, not sleeping), Shush (loud), Swing (gentle jiggle), Suck (pacifier).\n\n"
          "**Important:** If crying is inconsolable for 3+ hours, fever over 38°C, or your gut says something is wrong — call your doctor. "
          "And if YOU need a break, put $name down safely in the crib and step away for 5 minutes. A calm parent is a better parent.";
    }

    if (lower.contains('tummy') || lower.contains('activ') || lower.contains('play') || lower.contains('stimulat')) {
      return "At $age months, play IS development! Here's what helps $name grow: 🎯\n\n"
          "${age <= 3 ? '**Tummy time** (most important activity right now!):\n• Start with 1-2 minutes, work up to 15-20 min/day\n• On your chest counts! So does across your lap\n• Use a rolled towel under their chest for support\n• Get face-to-face with them — you are the best toy\n\n**Other activities:**\n• High-contrast cards (black & white patterns)\n• Talking and singing to them constantly\n• Gentle baby massage\n• Mirror play (they love faces!)' : age <= 6 ? '**Best activities at $age months:**\n• Tummy time with toys just out of reach (motivates reaching/rolling)\n• Sensory play: crinkly fabric, different textures, water play in the bath\n• Peek-a-boo (builds object permanence)\n• Reading board books — let them grab and mouth them\n• Baby-safe mirror play\n• Sitting practice with pillow support' : '**Best activities at $age months:**\n• Stacking and nesting cups\n• Push/pull toys (if cruising or walking)\n• Container play — putting things in and out\n• Board books with flaps\n• Music and dancing\n• Safe exploration — let them crawl/cruise freely\n• Pointing at things and naming them'}\n\n"
          "The best stimulation is YOU — talking, singing, responding. Fancy toys are unnecessary.";
    }

    if (lower.contains('bond') || lower.contains('love') || lower.contains('connect') || lower.contains('attach')) {
      return "The bond you're building with $name right now is literally shaping their brain architecture. 💛\n\n"
          "**At $age months, bonding looks like:**\n"
          "• Responding when they cry (you CANNOT spoil a baby by responding)\n"
          "• Skin-to-skin contact (still powerful even past the newborn stage)\n"
          "• Eye contact during feeds — put the phone down and look at them\n"
          "• Narrating your day: \"Now we're changing your diaper. There we go! All clean.\"\n"
          "• Mirroring their sounds and expressions back to them\n"
          "• Holding, rocking, carrying — they need your closeness\n\n"
          "**The science:** Secure attachment is built through thousands of tiny moments of \"serve and return\" — "
          "baby signals, you respond. That's it. You're already doing it. 🐆";
    }

    // Default
    return "At $age months, $name is changing every single day! 👶\n\n"
        "These early months are a marathon, not a sprint. Right now the most important things are:\n\n"
        "• **Feeding**: Making sure $name is getting enough (6+ wet diapers = good sign)\n"
        "• **Sleep**: Following their cues, not the clock\n"
        "• **Connection**: Responding, talking, holding — you can't do too much\n"
        "• **Tummy time**: A little every day builds strength for everything that comes next\n\n"
        "Ask me anything — feeding questions, sleep schedules, \"is this normal?\", "
        "or just \"I'm exhausted, help.\" I'm here. 💕";
  }

  /// Demo responses for toddler stage (12+ months)
  /// Independence, language, Montessori, tantrums, boundaries
  Future<String> _demoToddlerResponse(String message, UserProfile profile) async {
    final age = profile.babyAgeMonths ?? 12;
    final name = profile.babyName ?? 'your little one';
    final lower = message.toLowerCase();

    if (lower.contains('normal') || lower.contains('worried') || lower.contains('concern') || lower.contains('on track')) {
      return "At $age months, $name is in an incredible period of development! "
          "Every child has their own timeline, and the range of 'normal' is much wider than most parents realize.\n\n"
          "What specifically are you noticing? I can help you understand whether it's a typical variation "
          "or something worth discussing with your pediatrician. Most of the time, what worries us is actually "
          "a sign of healthy development happening in its own time. 🐆";
    }

    if (lower.contains('speech') || lower.contains('talk') || lower.contains('word') || lower.contains('language') || lower.contains('say')) {
      if (age <= 18) {
        return "At $age months, $name is building the foundations for a language explosion! "
            "Right now, typical vocabulary is about 5-20 words, but understanding is way ahead — "
            "$name likely understands 50+ words already.\n\n"
            "**What you can do today:**\n"
            "• **Narrate everything**: \"Now we're putting on your shoes. One foot, two feet!\"\n"
            "• **Expand their words**: If $name says \"ball,\" you say \"Yes! Big red ball!\"\n"
            "• **Read together** — point at pictures and wait for them to respond\n"
            "• **Sing songs** with repetitive words and gestures\n\n"
            "If $name has fewer than 5 words by 18 months, a speech evaluation is a wonderful proactive step — "
            "early support makes a huge difference! 💬";
      }
      return "At $age months, $name should be in the middle of a language explosion! "
          "Typical vocabulary at this age is 50-200+ words, with 2-word combinations starting to emerge "
          "(\"more milk\", \"daddy go\", \"big truck\").\n\n"
          "**Montessori language tips:**\n"
          "• **Use real words** — say \"rhinoceros\" not \"big animal.\" Children love big, precise words!\n"
          "• **3-period lesson**: \"This is a spoon\" → \"Show me the spoon\" → \"What is this?\"\n"
          "• **Read, read, read** — and let $name turn the pages and point\n"
          "• **Ask open questions**: \"What do you see?\" instead of \"Is that a dog?\"\n\n"
          "If $name has fewer than 50 words or isn't combining 2 words by 24 months, "
          "a speech-language evaluation can help — and early intervention works remarkably well! 💬";
    }

    if (lower.contains('tantrum') || lower.contains('behavior') || lower.contains('hit') || lower.contains('scream') || lower.contains('angry') || lower.contains('no')) {
      return "Tantrums at $age months are NOT misbehavior — they're a developing brain overwhelmed by big emotions "
          "without the impulse control to manage them yet. This is completely normal and actually healthy! 🧠\n\n"
          "**The Montessori approach:**\n"
          "1. **Connect first**: Get on $name's level, stay calm. \"You're really frustrated right now. I see that.\"\n"
          "2. **Name the feeling**: \"You wanted to keep playing and it's hard to stop. That makes sense.\"\n"
          "3. **Hold the boundary with empathy**: \"I won't let you hit. You CAN stomp your feet or squeeze this pillow.\"\n"
          "4. **Wait it out**: Stay close, stay calm. They need to feel the feeling — you can't fix it, just be there.\n"
          "5. **Repair after**: \"That was really hard. I love you. Would you like a hug?\"\n\n"
          "The fact that $name has big feelings means their emotional brain is developing exactly as it should. "
          "You're doing great by being there through it. 💕";
    }

    if (lower.contains('sleep') || lower.contains('nap') || lower.contains('night') || lower.contains('regression') || lower.contains('wake')) {
      return "Sleep changes at $age months often catch parents off guard! "
          "There are real developmental reasons behind sleep regressions — "
          "the brain is literally reorganizing itself during major skill leaps.\n\n"
          "**What helps at this age:**\n"
          "• **Consistent routine** — same sequence every night (bath, book, song, bed)\n"
          "• **Wind-down time** — dim lights 30 min before bed, no screens\n"
          "• **Montessori floor bed** allows independence — they can get in/out themselves\n"
          "• **Acknowledge their feelings**: \"You don't want to sleep. It's hard to stop playing.\"\n"
          "• **Daytime exercise** — a tired body sleeps better. Active play outside is golden.\n\n"
          "If $name is going through a regression, it usually passes in 2-4 weeks. "
          "Stay consistent and know that it means their brain is growing! 🌙";
    }

    if (lower.contains('eat') || lower.contains('food') || lower.contains('picky') || lower.contains('nutrition') || lower.contains('meal')) {
      return "Picky eating at $age months is one of the most common — and most stressful — parent concerns. "
          "Here's the Montessori truth: children are wired to be cautious about new foods. It's a survival instinct! 🥦\n\n"
          "**The Montessori approach to meals:**\n"
          "• **Division of responsibility**: YOU decide what and when. $name decides IF and how much.\n"
          "• **Involve them**: Let $name help wash vegetables, stir, pour, set the table\n"
          "• **No pressure**: \"You don't have to eat it. It's there if you want to try.\"\n"
          "• **Serve what the family eats** — don't make separate kid meals\n"
          "• **Model enjoyment**: Eat together and let $name see YOU enjoying the food\n"
          "• **Repeated exposure**: It can take 15-20 times seeing a food before trying it. That's normal!\n\n"
          "Food throwing? At this age, it's about cause and effect, not defiance. "
          "Try smaller portions and calmly say: \"Food stays on the plate. When you throw it, meal time is over.\"";
    }

    if (lower.contains('activ') || lower.contains('play') || lower.contains('montessori') || lower.contains('learn') || lower.contains('teach')) {
      return "Great question! At $age months, the best Montessori activities use everyday household items — "
          "you don't need fancy toys! 🏠\n\n"
          "**Try these today:**\n"
          "• **Pouring practice**: Two small cups and dried beans or water (with a towel underneath!)\n"
          "• **Transfer work**: Use a spoon to move pom-poms between bowls\n"
          "• **Practical life**: Let $name help wipe the table, water a plant, or put clothes in the hamper\n"
          "• **Nature walk**: Collect leaves, rocks, sticks. Name what you find. Let $name lead.\n"
          "• **Art**: Big paper on the floor, chunky crayons or finger paint. Process, not product.\n"
          "• **Book basket**: Rotate 5-6 books on a low shelf. Let $name choose.\n\n"
          "The Montessori secret: the activity matters less than HOW you approach it. "
          "Follow $name's interest, don't interrupt concentration, and let them struggle a little before helping. "
          "\"Help me do it myself\" is the toddler motto! 🌟";
    }

    if (lower.contains('love') || lower.contains('bond') || lower.contains('connect') || lower.contains('quality time') || lower.contains('relationship')) {
      return "This question tells me you're already an amazing parent. The fact that you're thinking about this means $name is lucky. 💛\n\n"
          "**How to deepen connection at $age months:**\n"
          "• **10 minutes of special time** daily: $name chooses the activity, you follow their lead. No teaching, no correcting, just being present.\n"
          "• **Narrate their world**: \"You're stacking those blocks so carefully! You put the big one on the bottom.\"\n"
          "• **Physical affection on THEIR terms** — some kids want hugs, some want roughhousing, some want quiet sitting together.\n"
          "• **Repair after conflict**: \"I'm sorry I raised my voice. That wasn't okay. I was frustrated and I'm working on it.\"\n"
          "• **Slow down transitions**: Instead of rushing, say \"In 2 minutes we'll put shoes on. You can bring one toy.\"\n\n"
          "In Montessori, we say: *\"The child who is most unlovable is the child who needs love the most.\"* "
          "On hard days, connection is even more important than correction. You've got this. 🐆";
    }

    // Default — teach about their current developmental stage
    return "At $age months, $name is in a fascinating developmental window! 🐆\n\n"
        "Right now, their brain is building connections at an incredible rate. "
        "The Montessori approach for this age focuses on:\n\n"
        "• **Independence**: Let $name try things themselves, even when it's messy and slow\n"
        "• **Language**: Narrate your day, read together, use rich vocabulary\n"
        "• **Practical life**: Real tasks like helping cook, cleaning up, getting dressed\n"
        "• **Connection**: 10 minutes of fully present, child-led play every day\n\n"
        "I'm your parenting teacher — ask me about speech milestones, tantrums, sleep, "
        "Montessori activities, nutrition, or anything else on your mind. "
        "No question is too small! 💕";
  }

  /// Demo responses for pregnancy stage
  Future<String> _demoPregnancyResponse(String message, UserProfile profile) async {
    final week = profile.currentWeek ?? 24;
    final lower = message.toLowerCase();

    if (lower.contains('normal') || lower.contains('worried') || lower.contains('concern')) {
      return "At week $week, it's completely normal to have new sensations and questions. "
          "Your body is doing incredible work right now!\n\n"
          "What specifically are you experiencing? I can give you more targeted guidance. "
          "And of course, if anything feels off or you're in pain, don't hesitate to call your doctor.";
    }

    if (lower.contains('eat') || lower.contains('food') || lower.contains('nutrition') || lower.contains('diet')) {
      return "Great question! At week $week, focus on:\n\n"
          "**Iron-rich foods** — your blood volume is increasing significantly\n"
          "**Omega-3s** — salmon, walnuts, chia seeds for baby's brain development\n"
          "**Calcium** — baby is building bones right now\n"
          "**Folate** — leafy greens, legumes\n\n"
          "Aim for small, frequent meals if heartburn is an issue. And stay hydrated!";
    }

    if (lower.contains('sleep') || lower.contains('tired') || lower.contains('insomnia')) {
      return "Sleep gets trickier around week $week — your growing belly makes it hard to get comfortable. "
          "Here's what helps:\n\n"
          "**Side sleeping** (left side is ideal for blood flow)\n"
          "**Pillow fortress** — one between your knees, one supporting your back\n"
          "**Wind-down routine** — no screens 30 min before bed\n"
          "**Warm milk or chamomile tea** before bed\n\n"
          "If you're waking up frequently, try reducing fluids 2 hours before bedtime "
          "but make sure you're getting enough during the day!";
    }

    if (lower.contains('kick') || lower.contains('movement') || lower.contains('baby doing')) {
      return "At week $week, your baby is really active!\n\n"
          "They're about 30cm long and can hear your voice. "
          "You should feel regular movements throughout the day. "
          "A good rule: **10 kicks in 2 hours** is the benchmark.\n\n"
          "Try the kick counter in the Journey tab to track patterns. "
          "If you notice a significant decrease in movement, contact your doctor — "
          "it's always better to check!";
    }

    if (lower.contains('partner') || lower.contains('husband') || lower.contains('dad')) {
      return "Partners play such an important role! Here are some ideas for week $week:\n\n"
          "**Talk to the baby together** — they can hear both of you now!\n"
          "**Read a bedtime story** to the bump\n"
          "**Offer a foot or back massage** — swelling and aches are real\n"
          "**Take over a daily task** — cooking, cleaning, or errands\n"
          "**Take a bump photo** — you'll treasure these memories\n\n"
          "The fact that you're asking means you're already an amazing partner.";
    }

    // Default response
    return "At week $week, your baby is developing rapidly!\n\n"
        "They're developing taste buds and can hear your voice. This is a beautiful stage of your journey.\n\n"
        "I'm here to help with anything — nutrition, symptoms, sleep tips, baby development, "
        "emotional support, or just someone to talk to. What's on your mind?";
  }
}

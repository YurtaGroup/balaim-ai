import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_profile.dart';
// import '../../../shared/models/tracking_entry.dart';  // Uncomment when Cloud Functions connected
import '../../journey/providers/journey_provider.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref);
});

class AiService {
  final Ref _ref;

  AiService(this._ref);

  /// Call the Cloud Function for AI chat
  /// For now: returns demo responses. When Firebase is connected,
  /// swap to: FirebaseFunctions.instance.httpsCallable('chat').call(...)
  Future<String> chat(String message) async {
    final profile = _ref.read(userProfileProvider);
    // final tracking = _ref.read(trackingEntriesProvider);
    // final todayTracking = tracking.where((e) {
    //   final now = DateTime.now();
    //   return e.timestamp.year == now.year &&
    //       e.timestamp.month == now.month &&
    //       e.timestamp.day == now.day;
    // }).toList();

    // Build context for the AI — used when Cloud Functions are connected
    // final userContext = {
    //   'week': profile.currentWeek,
    //   'stage': profile.stage.name,
    //   'babyName': profile.babyName,
    //   'recentTracking': {
    //     'weight': _latestValue(todayTracking, TrackingType.weight),
    //     'water': _latestValue(todayTracking, TrackingType.water),
    //     'sleep': _latestValue(todayTracking, TrackingType.sleep),
    //     'lastKickCount': _latestValue(todayTracking, TrackingType.kicks),
    //   },
    // };
    //
    // final result = await FirebaseFunctions.instance
    //     .httpsCallable('chat')
    //     .call({'message': message, 'userContext': userContext});
    // return result.data['response'] as String;

    // Demo mode: intelligent responses based on keywords
    return _demoResponse(message, profile);
  }

  // double? _latestValue(List<TrackingEntry> entries, TrackingType type) {
  //   final matching = entries.where((e) => e.type == type);
  //   return matching.isNotEmpty ? matching.first.value : null;
  // }

  /// Simulate AI responses until Cloud Functions are connected
  Future<String> _demoResponse(String message, UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final week = profile.currentWeek ?? 24;
    final lower = message.toLowerCase();

    if (lower.contains('normal') || lower.contains('worried') || lower.contains('concern')) {
      return "At week $week, it's completely normal to have new sensations and questions. "
          "Your body is doing incredible work right now! 💪\n\n"
          "What specifically are you experiencing? I can give you more targeted guidance. "
          "And of course, if anything feels off or you're in pain, don't hesitate to call your doctor.";
    }

    if (lower.contains('eat') || lower.contains('food') || lower.contains('nutrition') || lower.contains('diet')) {
      return "Great question! At week $week, focus on:\n\n"
          "🥩 **Iron-rich foods** — your blood volume is increasing significantly\n"
          "🐟 **Omega-3s** — salmon, walnuts, chia seeds for baby's brain development\n"
          "🥛 **Calcium** — baby is building bones right now\n"
          "🥬 **Folate** — leafy greens, legumes\n\n"
          "Aim for small, frequent meals if heartburn is an issue. And stay hydrated — "
          "I see you've been tracking your water, keep it up! 💧";
    }

    if (lower.contains('sleep') || lower.contains('tired') || lower.contains('insomnia')) {
      return "Sleep gets trickier around week $week — your growing belly makes it hard to get comfortable. "
          "Here's what helps:\n\n"
          "🛏️ **Side sleeping** (left side is ideal for blood flow)\n"
          "🪨 **Pillow fortress** — one between your knees, one supporting your back\n"
          "🌙 **Wind-down routine** — no screens 30 min before bed\n"
          "🫖 **Warm milk or chamomile tea** before bed\n\n"
          "If you're waking up frequently to pee, try reducing fluids 2 hours before bedtime "
          "but make sure you're getting enough during the day!";
    }

    if (lower.contains('kick') || lower.contains('movement') || lower.contains('baby doing')) {
      return "At week $week, your baby is really active! 🤸\n\n"
          "They're about 30cm long and can hear your voice. "
          "You should feel regular movements throughout the day. "
          "A good rule: **10 kicks in 2 hours** is the benchmark.\n\n"
          "Try the kick counter in the Journey tab to track patterns. "
          "If you notice a significant decrease in movement, contact your doctor — "
          "it's always better to check!";
    }

    if (lower.contains('partner') || lower.contains('husband') || lower.contains('dad')) {
      return "Partners play such an important role! Here are some ideas for week $week:\n\n"
          "💬 **Talk to the baby together** — they can hear both of you now!\n"
          "📚 **Read a bedtime story** to the bump\n"
          "🧴 **Offer a foot or back massage** — swelling and aches are real\n"
          "🍳 **Take over a daily task** — cooking, cleaning, or errands\n"
          "📸 **Take a bump photo** — you'll treasure these memories\n\n"
          "The fact that you're asking means you're already an amazing partner. 💕";
    }

    // Default response
    return "At week $week, your baby is about the size of a cantaloupe and weighs around 600g! 🍈\n\n"
        "They're developing taste buds and can hear your voice. This is a beautiful stage of your journey.\n\n"
        "I'm here to help with anything — nutrition, symptoms, sleep tips, baby development, "
        "emotional support, or just someone to talk to. What's on your mind?";
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart' show ParentingStage;
import '../../journey/providers/journey_provider.dart';
import '../services/ai_service.dart';

class ChatMessage {
  final String id;
  final bool isAi;
  final String text;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.isAi,
    required this.text,
    required this.timestamp,
    this.isLoading = false,
  });
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatMessagesNotifier(this._ref)
      : super([]) {
    _initWelcome();
  }

  void _initWelcome() {
    final profile = _ref.read(userProfileProvider);
    final stage = profile.stage;

    final name = profile.babyName ?? 'your little one';
    final age = profile.babyAgeMonths ?? 0;

    String welcomeText;
    if (stage == ParentingStage.toddler) {
      welcomeText =
          "Hi! I'm Balam, your Montessori parenting teacher 🐆\n\n"
          "$name is $age months — what an amazing age! They're becoming their own little person "
          "with big feelings, big ideas, and a need for independence.\n\n"
          "Ask me about speech, tantrums, Montessori activities, boundaries, "
          "or just \"am I doing this right?\" — I'm here to teach and reassure.";
    } else if (stage == ParentingStage.newborn) {
      welcomeText =
          "Hi! I'm Balam, your parenting guide 🐆\n\n"
          "$name is $age months old. These early months are intense — feeding, sleep, "
          "bonding, and wondering if everything is normal. You're not alone.\n\n"
          "Ask me about feeding schedules, sleep patterns, milestones, tummy time, "
          "or anything that's worrying you. No question is too small.";
    } else {
      welcomeText =
          "Hi! I'm Balam, your AI parenting companion 🐆\n\n"
          "I know you're on an amazing journey right now. "
          "Ask me anything about your pregnancy, symptoms, nutrition, "
          "baby development, or just vent — I'm here for you!\n\n"
          "Try tapping one of the suggestions below to get started.";
    }

    state = [
      ChatMessage(
        id: 'welcome',
        isAi: true,
        text: welcomeText,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    // Add user message
    final userMsg = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      isAi: false,
      text: text,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    // Add loading indicator
    final loadingMsg = ChatMessage(
      id: 'loading-${DateTime.now().millisecondsSinceEpoch}',
      isAi: true,
      text: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
    state = [...state, loadingMsg];

    // Get AI response
    try {
      final aiService = _ref.read(aiServiceProvider);
      final response = await aiService.chat(text);

      // Replace loading with actual response
      state = [
        ...state.where((m) => !m.isLoading),
        ChatMessage(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          isAi: true,
          text: response,
          timestamp: DateTime.now(),
        ),
      ];
    } catch (e) {
      state = [
        ...state.where((m) => !m.isLoading),
        ChatMessage(
          id: 'error-${DateTime.now().millisecondsSinceEpoch}',
          isAi: true,
          text: "I'm having a moment — could you try asking again? 💕",
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}

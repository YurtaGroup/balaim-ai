import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      : super([
          ChatMessage(
            id: 'welcome',
            isAi: true,
            text:
                "Hi! I'm Balam, your AI parenting companion 🐆\n\n"
                "I know you're on an amazing journey right now. "
                "Ask me anything about your pregnancy, symptoms, nutrition, "
                "baby development, or just vent — I'm here for you!\n\n"
                "Try tapping one of the suggestions below to get started.",
            timestamp: DateTime.now(),
          ),
        ]);

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

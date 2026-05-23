import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart' show ParentingStage;
import '../../../main.dart' show localeProvider;
import '../../journey/providers/journey_provider.dart';
import '../services/ai_service.dart';

export '../services/ai_service.dart' show Triage, TriageUrgency;

class ChatMessage {
  final String id;
  final bool isAi;
  final String text;
  final DateTime timestamp;
  final bool isLoading;
  final Triage? triage;

  /// True when this message is the free-tier paywall prompt — the chat
  /// screen reacts by opening the paywall.
  final bool limitReached;

  ChatMessage({
    required this.id,
    required this.isAi,
    required this.text,
    required this.timestamp,
    this.isLoading = false,
    this.triage,
    this.limitReached = false,
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
    final locale = _ref.read(localeProvider)?.languageCode ?? 'en';

    final name = profile.babyName ?? _fallbackBabyName(locale);
    final age = profile.babyAgeMonths ?? 0;

    state = [
      ChatMessage(
        id: 'welcome',
        isAi: true,
        text: _welcomeText(stage: stage, name: name, age: age, locale: locale),
        timestamp: DateTime.now(),
      ),
    ];
  }

  String _fallbackBabyName(String locale) => switch (locale) {
        'ru' => 'твой малыш',
        'ky' => 'балаңыз',
        _ => 'your little one',
      };

  String _welcomeText({
    required ParentingStage stage,
    required String name,
    required int age,
    required String locale,
  }) {
    if (stage == ParentingStage.toddler) {
      return switch (locale) {
        'ru' =>
          'Привет! Я Balam, твой Монтессори-педагог 🐆\n\n'
              '$name — $age мес. Прекрасный возраст! Ребёнок становится личностью: сильные эмоции, идеи, потребность в самостоятельности.\n\n'
              'Спрашивай про речь, истерики, Монтессори-занятия, границы — я здесь, чтобы учить и поддерживать.',
        'ky' =>
          'Салам! Мен Balam, сиздин Монтессори мугалимиңиз 🐆\n\n'
              '$name — $age ай. Кереметтүү куррак! Бала өзүнчө инсан болуп жатат: күчтүү сезимдер, идеялар, көз карандысыздык керек.\n\n'
              'Сүйлөө, каршылык, Монтессори иштери, чекара жөнүндө сураңыз — мен үйрөтөм жана колдойм.',
        _ =>
          "Hi! I'm Balam, your Montessori parenting teacher 🐆\n\n"
              "$name is $age months — what an amazing age! They're becoming their own little person "
              "with big feelings, big ideas, and a need for independence.\n\n"
              "Ask me about speech, tantrums, Montessori activities, boundaries, "
              "or just \"am I doing this right?\" — I'm here to teach and reassure.",
      };
    }
    if (stage == ParentingStage.newborn) {
      return switch (locale) {
        'ru' =>
          'Привет! Я Balam, твой помощник 🐆\n\n'
              '$name — $age мес. Первые месяцы сложные: кормление, сон, связь, вопрос «это нормально?». Ты не одна.\n\n'
              'Спрашивай про графики кормления, сон, вехи, тамми-тайм — любой вопрос важен.',
        'ky' =>
          'Салам! Мен Balam, сиздин колдоочуңуз 🐆\n\n'
              '$name — $age ай. Биринчи айлар оор: тамактануу, уйку, байланыш, «бул кадыресеби?» деген суроолор. Сиз жалгыз эмессиз.\n\n'
              'Тамак убактысы, уйку, этаптар тууралуу сураңыз — кичинекей суроо да маанилүү.',
        _ =>
          "Hi! I'm Balam, your parenting guide 🐆\n\n"
              "$name is $age months old. These early months are intense — feeding, sleep, "
              "bonding, and wondering if everything is normal. You're not alone.\n\n"
              "Ask me about feeding schedules, sleep patterns, milestones, tummy time, "
              "or anything that's worrying you. No question is too small.",
      };
    }
    return switch (locale) {
      'ru' =>
        'Привет! Я Balam, твой AI-спутник 🐆\n\n'
            'Ты переживаешь удивительный путь. Спрашивай про беременность, симптомы, питание, развитие малыша — или просто поделись мыслями, я рядом.\n\n'
            'Попробуй одну из подсказок ниже, чтобы начать.',
      'ky' =>
        'Салам! Мен Balam, сиздин AI шеригиңиз 🐆\n\n'
            'Сиз укмуштуудай жолдо жүрүп жатасыз. Кош бойлуулук, симптомдор, тамактануу, бала өнүгүүсү жөнүндө сураңыз — же жөн эле сезимиңизди бөлүшүңүз.\n\n'
            'Баштоо үчүн төмөнкү сунуштардын бирин басыңыз.',
      _ =>
        "Hi! I'm Balam, your AI parenting companion 🐆\n\n"
            "I know you're on an amazing journey right now. "
            "Ask me anything about your pregnancy, symptoms, nutrition, "
            "baby development, or just vent — I'm here for you!\n\n"
            "Try tapping one of the suggestions below to get started.",
    };
  }

  /// Is the user in "3am mode" — exhausted, wants brief answers.
  /// Active between 23:00 and 05:00 local time.
  static bool isNightMode([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    return h >= 23 || h < 5;
  }

  Future<void> sendMessage(String text, {bool emergencyMode = false}) async {
    // Snapshot history BEFORE we add the new user message — last 10 non-loading,
    // non-welcome messages (the welcome is stage-specific and lives in system prompt anyway).
    final historySource = state.where((m) => !m.isLoading && m.id != 'welcome').toList();
    final history = historySource
        .sublist(historySource.length > 10 ? historySource.length - 10 : 0)
        .map((m) => ChatHistoryMessage(isAi: m.isAi, text: m.text))
        .toList();

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
      final locale = _ref.read(localeProvider)?.languageCode ??
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final normalized = {'en', 'ru', 'ky'}.contains(locale) ? locale : 'en';
      final result = await aiService.chat(
        text,
        locale: normalized,
        briefMode: isNightMode() || emergencyMode,
        emergencyMode: emergencyMode,
        history: history,
      );

      // Replace loading with actual response
      state = [
        ...state.where((m) => !m.isLoading),
        ChatMessage(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          isAi: true,
          text: result.response,
          timestamp: DateTime.now(),
          triage: result.triage,
          limitReached: result.limitReached,
        ),
      ];
    } catch (e) {
      final locale = _ref.read(localeProvider)?.languageCode ?? 'en';
      final errorText = switch (locale) {
        'ru' => 'Небольшая заминка — попробуй спросить ещё раз 💕',
        'ky' => 'Кичине тайгаланып калдым — кайра сурасаң, жардам берем 💕',
        _ => "I'm having a moment — could you try asking again? 💕",
      };
      state = [
        ...state.where((m) => !m.isLoading),
        ChatMessage(
          id: 'error-${DateTime.now().millisecondsSinceEpoch}',
          isAi: true,
          text: errorText,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}

import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart' show ParentingStage;
import '../../../shared/models/child_model.dart';
import '../../../shared/models/user_profile.dart';
import '../../emergency/emergency_dial.dart';
import '../providers/ai_provider.dart';
import '../widgets/persona_pill.dart';
import '../widgets/prompt_library_carousel.dart';
import '../../journey/providers/journey_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  final String? prefill;
  final bool emergency;

  const AiChatScreen({super.key, this.prefill, this.emergency = false});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _prefillSent = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-send prefill message from toolkit deep links
    if (widget.prefill != null && !_prefillSent) {
      _prefillSent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _send(widget.prefill);
      });
    }
  }

  void _send([String? prefill]) {
    final text = (prefill ?? _controller.text).trim();
    if (text.isEmpty) return;

    _controller.clear();
    ref
        .read(chatMessagesProvider.notifier)
        .sendMessage(text, emergencyMode: widget.emergency);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  HouseholdMember? _resolveActiveChild(UserProfile profile) {
    final selected = profile.selectedMember;
    if (selected != null && selected.role == MemberRole.child) return selected;
    for (final m in profile.members) {
      if (m.role == MemberRole.child) return m;
    }
    return null;
  }

  String _getSubtitle(UserProfile profile) {
    final stage = profile.stage;
    if (stage == ParentingStage.toddler || stage == ParentingStage.newborn) {
      final name = profile.babyName ?? L.of(context).myBaby;
      final age = profile.babyAgeMonths ?? 0;
      return L.of(context).parentingTeacherSubtitle(name, age);
    }
    final week = profile.currentWeek ?? 24;
    return L.of(context).weekCompanion(week);
  }

  @override
  Widget build(BuildContext context) {
    // When the server gates a free user (3 questions/week used), the
    // last AI message comes back flagged — open the paywall. Suppressed
    // in emergency mode (the server already bypasses the gate there).
    ref.listen(chatMessagesProvider, (prev, next) {
      if (!widget.emergency &&
          next.isNotEmpty &&
          next.last.limitReached) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.push('/paywall');
        });
      }
    });

    final messages = ref.watch(chatMessagesProvider);
    final profile = ref.watch(userProfileProvider);
    final activeChild = _resolveActiveChild(profile);
    final isEmergency = widget.emergency;
    final isNight = !isEmergency && ChatMessagesNotifier.isNightMode();
    final lang = currentLang(context);

    final scaffoldBg = isNight ? const Color(0xFF0E1116) : AppColors.background;
    final surfaceBg = isNight ? const Color(0xFF181C22) : AppColors.surface;
    final textPrimary = isNight ? Colors.white : AppColors.textPrimary;
    final textHint = isNight ? Colors.white60 : AppColors.textHint;
    final messageFontSize = isNight ? 18.0 : 15.0;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: isEmergency
            ? AppColors.error
            : (isNight ? surfaceBg : null),
        foregroundColor: isEmergency
            ? Colors.white
            : (isNight ? Colors.white : null),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isEmergency
                    ? Colors.white.withValues(alpha: 0.22)
                    : AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEmergency ? Icons.medical_services : Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEmergency
                        ? tr(lang,
                            en: 'AI Pediatrician',
                            ru: 'AI Педиатр',
                            ky: 'AI Педиатр')
                        : L.of(context).balamAI,
                    style: TextStyle(
                      fontSize: 16,
                      color: isEmergency ? Colors.white : textPrimary,
                      fontWeight: isEmergency ? FontWeight.w800 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isEmergency
                        ? tr(lang,
                            en: 'Emergency mode — brief, free',
                            ru: 'Экстренный режим — кратко, бесплатно',
                            ky: 'Шашылыш режим — кыска, акысыз')
                        : (isNight
                            ? L.of(context).nightModeBadge
                            : _getSubtitle(profile)),
                    style: TextStyle(
                      fontSize: 11,
                      color: isEmergency
                          ? Colors.white.withValues(alpha: 0.92)
                          : textHint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: isEmergency
            ? [
                IconButton(
                  tooltip: tr(lang,
                      en: 'Call emergency services',
                      ru: 'Вызвать экстренную службу',
                      ky: 'Шашылыш кызматка чал'),
                  icon: const Icon(Icons.call),
                  onPressed: () => dialEmergency(lang),
                ),
              ]
            : [
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Center(child: PersonaPill(compact: true)),
                ),
                IconButton(
                  icon: const Icon(Icons.menu_book_outlined),
                  tooltip: L.of(context).exampleConversations,
                  onPressed: () => context.push('/ai/examples'),
                ),
              ],
      ),
      body: Column(
        children: [
          // Emergency banner — always visible while in emergency mode so the
          // "helping, not replacing" promise stays on screen.
          if (isEmergency) _EmergencyDisclaimer(lang: lang),

          // Library carousel — age-bucketed prompts in the active persona's
          // voice. Hidden in 3am mode and emergency mode (parent needs
          // focus, not options).
          if (!isNight && !isEmergency) ...[
            PromptLibraryCarousel(
              activeChild: activeChild,
              onPick: _send,
            ),
            const Divider(height: 1),
          ],

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _MessageBubble(
                  message: msg,
                  night: isNight,
                  emergency: isEmergency,
                  fontSize: messageFontSize,
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 32),
            decoration: BoxDecoration(
              color: surfaceBg,
              border: Border(
                top: BorderSide(color: isNight ? Colors.white12 : AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: textPrimary, fontSize: messageFontSize),
                    decoration: InputDecoration(
                      hintText: L.of(context).askBalamAnything,
                      hintStyle: TextStyle(color: textHint),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isNight ? const Color(0xFF242830) : AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _send(),
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool night;
  final bool emergency;
  final double fontSize;

  const _MessageBubble({
    required this.message,
    this.night = false,
    this.emergency = false,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final aiSurface = night ? const Color(0xFF1E232B) : AppColors.surface;
    final aiText = night ? Colors.white : AppColors.textPrimary;
    final aiBorder = night ? Colors.white12 : AppColors.divider;

    if (message.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: aiSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: aiBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TypingDot(delay: 0),
                  const SizedBox(width: 4),
                  _TypingDot(delay: 150),
                  const SizedBox(width: 4),
                  _TypingDot(delay: 300),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            message.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment:
                message.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isAi)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isAi ? aiSurface : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isAi ? 4 : 16),
                      bottomRight: Radius.circular(message.isAi ? 16 : 4),
                    ),
                    border: message.isAi ? Border.all(color: aiBorder) : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isAi ? aiText : Colors.white,
                      fontSize: fontSize,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // In normal mode we only surface high/emergency triage. In
          // emergency mode every urgency level is rendered — the parent
          // came here for a verdict, low/medium counts.
          if (message.isAi &&
              message.triage != null &&
              (emergency || message.triage!.isRedFlag)) ...[
            const SizedBox(height: 10),
            _TriageBanner(triage: message.triage!, night: night, emergency: emergency),
          ],
        ],
      ),
    );
  }
}

class _TriageBanner extends StatelessWidget {
  final Triage triage;
  final bool night;
  final bool emergency;

  const _TriageBanner({
    required this.triage,
    required this.night,
    this.emergency = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final lang = currentLang(context);
    final urgency = triage.urgency;
    final colorScheme = _colorFor(urgency);
    final title = _titleFor(lang, urgency, l);
    final body = _bodyFor(lang, urgency, l);
    final showCallCta = urgency == TriageUrgency.emergency;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.withValues(alpha: night ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconFor(urgency),
                color: colorScheme,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: night ? Colors.white : colorScheme,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: night ? Colors.white70 : AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (showCallCta) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => dialEmergency(lang),
                  icon: const Icon(Icons.call, size: 16),
                  label: Text(
                    '${l.triageCallEmergencyCta} (${emergencyDialNumber(lang)})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme,
                    side: BorderSide(color: colorScheme),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _colorFor(TriageUrgency u) {
    switch (u) {
      case TriageUrgency.low:
        return AppColors.success;
      case TriageUrgency.medium:
        return AppColors.warning;
      case TriageUrgency.high:
        return AppColors.accentDark;
      case TriageUrgency.emergency:
        return AppColors.error;
    }
  }

  IconData _iconFor(TriageUrgency u) {
    switch (u) {
      case TriageUrgency.low:
        return Icons.check_circle_outline;
      case TriageUrgency.medium:
        return Icons.schedule;
      case TriageUrgency.high:
        return Icons.medical_services;
      case TriageUrgency.emergency:
        return Icons.emergency;
    }
  }

  String _titleFor(String lang, TriageUrgency u, L l) {
    switch (u) {
      case TriageUrgency.low:
        return tr(lang,
            en: 'Watch at home',
            ru: 'Наблюдай дома',
            ky: 'Үйдө карап тур');
      case TriageUrgency.medium:
        return tr(lang,
            en: 'Schedule a visit this week',
            ru: 'Запишись к врачу на этой неделе',
            ky: 'Бул жуманын ичинде дарыгерге жазыл');
      case TriageUrgency.high:
        return l.triageHighTitle;
      case TriageUrgency.emergency:
        return l.triageEmergencyTitle;
    }
  }

  String _bodyFor(String lang, TriageUrgency u, L l) {
    switch (u) {
      case TriageUrgency.low:
        return tr(lang,
            en: 'No red flags right now. Keep an eye on it and recheck in a few hours.',
            ru: 'Серьёзных признаков нет. Понаблюдай и проверь через несколько часов.',
            ky: 'Олуттуу белгилер жок. Бир нече сааттан кийин кайра текшер.');
      case TriageUrgency.medium:
        return tr(lang,
            en: 'Worth a non-urgent visit or a call to your clinic this week.',
            ru: 'Стоит сходить или позвонить в клинику на этой неделе.',
            ky: 'Бул жума ичинде клиникага барсаң же чалсаң жакшы.');
      case TriageUrgency.high:
        return l.triageHighBody;
      case TriageUrgency.emergency:
        return l.triageEmergencyBody;
    }
  }
}

class _EmergencyDisclaimer extends StatelessWidget {
  final String lang;
  const _EmergencyDisclaimer({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: AppColors.error.withValues(alpha: 0.10),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tr(lang,
                  en: 'I\'m helping you decide — I\'m not a doctor. If you sense danger, call ${emergencyDialNumber(lang)} now.',
                  ru: 'Я помогаю тебе сориентироваться — я не врач. Если чувствуешь опасность — звони ${emergencyDialNumber(lang)} сейчас.',
                  ky: 'Мен сага чечүүгө жардам берем — мен дарыгер эмесмин. Коркунуч сезсең, азыр ${emergencyDialNumber(lang)} чал.'),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textHint.withValues(alpha: 0.3 + _controller.value * 0.7),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}


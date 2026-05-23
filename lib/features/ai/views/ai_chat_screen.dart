import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart' show ParentingStage;
import '../../../shared/models/child_model.dart';
import '../../../shared/models/user_profile.dart';
import '../providers/ai_provider.dart';
import '../widgets/persona_pill.dart';
import '../widgets/prompt_library_carousel.dart';
import '../../journey/providers/journey_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  final String? prefill;

  const AiChatScreen({super.key, this.prefill});

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
    ref.read(chatMessagesProvider.notifier).sendMessage(text);

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
    // last AI message comes back flagged — open the paywall.
    ref.listen(chatMessagesProvider, (prev, next) {
      if (next.isNotEmpty && next.last.limitReached) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.push('/paywall');
        });
      }
    });

    final messages = ref.watch(chatMessagesProvider);
    final profile = ref.watch(userProfileProvider);
    final activeChild = _resolveActiveChild(profile);
    final isNight = ChatMessagesNotifier.isNightMode();

    final scaffoldBg = isNight ? const Color(0xFF0E1116) : AppColors.background;
    final surfaceBg = isNight ? const Color(0xFF181C22) : AppColors.surface;
    final textPrimary = isNight ? Colors.white : AppColors.textPrimary;
    final textHint = isNight ? Colors.white60 : AppColors.textHint;
    final messageFontSize = isNight ? 18.0 : 15.0;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: isNight ? surfaceBg : null,
        foregroundColor: isNight ? Colors.white : null,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L.of(context).balamAI,
                    style: TextStyle(fontSize: 16, color: textPrimary)),
                Text(
                  isNight ? L.of(context).nightModeBadge : _getSubtitle(profile),
                  style: TextStyle(fontSize: 11, color: textHint),
                ),
              ],
            ),
          ],
        ),
        actions: [
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
          // Library carousel — age-bucketed prompts in the active persona's
          // voice. Hidden in 3am mode (parent needs focus, not options).
          if (!isNight) ...[
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
  final double fontSize;

  const _MessageBubble({
    required this.message,
    this.night = false,
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
          if (message.isAi && message.triage != null && message.triage!.isRedFlag) ...[
            const SizedBox(height: 10),
            _TriageBanner(triage: message.triage!, night: night),
          ],
        ],
      ),
    );
  }
}

class _TriageBanner extends StatelessWidget {
  final Triage triage;
  final bool night;

  const _TriageBanner({required this.triage, required this.night});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final isEmergency = triage.urgency == TriageUrgency.emergency;
    final bg = isEmergency ? AppColors.error : AppColors.accentDark;
    final title = isEmergency ? l.triageEmergencyTitle : l.triageHighTitle;
    final body = isEmergency ? l.triageEmergencyBody : l.triageHighBody;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: night ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bg.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEmergency ? Icons.emergency : Icons.medical_services,
                color: bg,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: night ? Colors.white : bg,
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
          if (isEmergency) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final uri = Uri.parse('tel:112');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: bg,
                    side: BorderSide(color: bg),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    l.triageCallEmergencyCta,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
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


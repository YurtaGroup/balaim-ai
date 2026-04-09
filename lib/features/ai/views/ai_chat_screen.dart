import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart' show ParentingStage;
import '../../../shared/models/user_profile.dart';
import '../providers/ai_provider.dart';
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

  List<_ChipData> _getSuggestionChips(UserProfile profile) {
    final stage = profile.stage;
    final name = profile.babyName ?? 'baby';
    final age = profile.babyAgeMonths ?? 12;
    final week = profile.currentWeek ?? 24;

    // ── TODDLER (12+ months) ──
    // Independence, language explosion, tantrums, Montessori practical life
    if (stage == ParentingStage.toddler) {
      return [
        _ChipData(
          label: L.of(context).speechMilestones,
          message: "What speech and language milestones should $name be hitting at $age months? What words or phrases are typical, and when should I consider getting help?",
        ),
        _ChipData(
          label: L.of(context).handleTantrums,
          message: "How do I handle tantrums with my $age-month-old the Montessori way? $name has been having big meltdowns lately.",
        ),
        _ChipData(
          label: L.of(context).activitiesForToday,
          message: "What Montessori activities can I do with $name today at $age months? Things I can do at home with everyday items.",
        ),
        _ChipData(
          label: L.of(context).isThisNormal,
          message: "What's normal development for a $age-month-old? What should I be seeing and what should I not worry about?",
        ),
        _ChipData(
          label: L.of(context).bondingTips,
          message: "How do I connect with $name at $age months? Quality time ideas and how to show love at this age.",
        ),
      ];
    }

    // ── NEWBORN (0-12 months) ──
    // Survival mode: feeding, sleep, crying, milestones, bonding
    if (stage == ParentingStage.newborn) {
      if (age <= 3) {
        // 0-3 months: fourth trimester, feeding marathon, sleep deprivation
        return [
          _ChipData(
            label: L.of(context).sleepHelp,
            message: "$name is $age months old. What's a normal sleep pattern? How many hours should they sleep and how long between feeds at night?",
          ),
          _ChipData(
            label: L.of(context).nutritionTips,
            message: "Is $name eating enough at $age months? How do I know if breastfeeding or bottle feeding is going well? How often should they eat?",
          ),
          _ChipData(
            label: L.of(context).isThisNormal,
            message: "$name is $age months old. What's normal behavior? Crying, spitting up, grunting, hiccups — what should I worry about vs what's just being a newborn?",
          ),
          _ChipData(
            label: L.of(context).developmentOnTrack,
            message: "What should $name be able to do at $age months? Head control, eye tracking, responses to sound — what milestones should I see?",
          ),
          _ChipData(
            label: L.of(context).bondingTips,
            message: "How do I bond with $name at $age months? Skin-to-skin, eye contact, talking — what matters most right now?",
          ),
        ];
      } else if (age <= 6) {
        // 4-6 months: tummy time, rolling, laughing, starting solids
        return [
          _ChipData(
            label: L.of(context).developmentOnTrack,
            message: "What milestones should $name be hitting at $age months? Rolling, reaching, babbling — what should I see?",
          ),
          _ChipData(
            label: L.of(context).sleepHelp,
            message: "How should $name's sleep look at $age months? Nap schedule, night wakings, sleep training — what's the right approach?",
          ),
          _ChipData(
            label: age >= 5 ? L.of(context).nutritionTips : L.of(context).activitiesForToday,
            message: age >= 5
                ? "Is $name ready for solid foods at $age months? What signs should I look for? What do I introduce first?"
                : "What activities can I do with $name at $age months? Tummy time variations, sensory play, things that help development.",
          ),
          _ChipData(
            label: L.of(context).isThisNormal,
            message: "Is $name developing normally at $age months? What's the range of normal and when should I be concerned?",
          ),
          _ChipData(
            label: L.of(context).bondingTips,
            message: "Best ways to play with and stimulate $name at $age months? What do they need from me right now?",
          ),
        ];
      } else {
        // 7-12 months: crawling, first foods, separation anxiety, first words
        return [
          _ChipData(
            label: L.of(context).nutritionTips,
            message: "What foods should $name be eating at $age months? How much solid food vs milk? Textures, portions, meal schedule?",
          ),
          _ChipData(
            label: L.of(context).developmentOnTrack,
            message: "What should $name be doing at $age months? Crawling, pulling up, babbling, pointing — what milestones matter?",
          ),
          _ChipData(
            label: L.of(context).sleepHelp,
            message: "$name is $age months. How many naps? What time should bedtime be? They keep waking up at night — is this a regression?",
          ),
          _ChipData(
            label: L.of(context).isThisNormal,
            message: "$name has separation anxiety at $age months. Is this normal? They cry when I leave the room. How do I handle it?",
          ),
          _ChipData(
            label: L.of(context).activitiesForToday,
            message: "What activities help $name's development at $age months? They're starting to move around — how do I keep them stimulated and safe?",
          ),
        ];
      }
    }

    // Pregnancy chips (keep existing)
    return [
      _ChipData(
        label: L.of(context).isThisNormal,
        message: 'Is it normal to feel Braxton Hicks at week $week?',
      ),
      _ChipData(
        label: L.of(context).whatsBabyDoing,
        message: "What is my baby doing at week $week?",
      ),
      _ChipData(
        label: L.of(context).nutritionTips,
        message: 'What should I eat this week for my baby\'s development?',
      ),
      _ChipData(
        label: L.of(context).sleepHelp,
        message: "I can't sleep well at week $week, any tips?",
      ),
      _ChipData(
        label: L.of(context).partnerTips,
        message: "How can my partner be more involved at week $week?",
      ),
    ];
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
    final messages = ref.watch(chatMessagesProvider);
    final profile = ref.watch(userProfileProvider);
    final chips = _getSuggestionChips(profile);

    return Scaffold(
      appBar: AppBar(
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
                Text(L.of(context).balamAI, style: TextStyle(fontSize: 16)),
                Text(
                  _getSubtitle(profile),
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suggestion chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: chips.map((chip) => _SuggestionChip(
                label: chip.label,
                onTap: () => _send(chip.message),
              )).toList(),
            ),
          ),
          const Divider(height: 1),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: L.of(context).askBalamAnything,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
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

class _ChipData {
  final String label;
  final String message;
  const _ChipData({required this.label, required this.message});
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
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
      child: Row(
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
                color: message.isAi ? AppColors.surface : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isAi ? 4 : 16),
                  bottomRight: Radius.circular(message.isAi ? 16 : 4),
                ),
                border: message.isAi ? Border.all(color: AppColors.divider) : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isAi ? AppColors.textPrimary : Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
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

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        onPressed: onTap,
        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

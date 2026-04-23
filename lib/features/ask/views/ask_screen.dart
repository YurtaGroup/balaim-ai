import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/child_model.dart';
import '../../journey/providers/journey_provider.dart';

/// v2 Ask — the tab that tries to feel like "a doctor in your pocket."
///
/// Big mic button in the center, type fallback below, common-starter
/// chips below that. Tapping any of them routes to the existing
/// AiChatScreen (which is already vault-grounded — see build 17
/// vault_retrieval.ts). Speech-to-text wiring lands in a follow-up
/// once the Ruby/CocoaPods issue is fixed and we can safely add the
/// speech_to_text pod.
class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _launch(String prompt) {
    final text = prompt.trim();
    if (text.isEmpty) {
      context.go('/ai');
      return;
    }
    context.go('/ai?prefill=${Uri.encodeComponent(text)}');
  }

  List<_Starter> _starters(BuildContext context, HouseholdMember? child) {
    final lang = currentLang(context);
    final firstName = child?.name.split(' ').first;
    final childSuffix = firstName != null ? ' ${tr(lang, en: 'for', ru: 'про', ky: 'тууралуу')} $firstName' : '';
    return [
      _Starter(
        icon: Icons.auto_awesome,
        label: tr(lang,
            en: 'Summarize the latest records$childSuffix',
            ru: 'Сделай сводку последних записей$childSuffix',
            ky: 'Акыркы жазуулардын корутундусун бер$childSuffix'),
        prompt: tr(lang,
            en: 'Summarize the latest records$childSuffix in plain language. What should I pay attention to?',
            ru: 'Сделай сводку последних записей$childSuffix простыми словами. На что обратить внимание?',
            ky: 'Акыркы жазуулардын корутундусун$childSuffix жөнөкөй тил менен бер. Эмнеге көңүл буруу керек?'),
      ),
      _Starter(
        icon: Icons.vaccines_outlined,
        label: tr(lang,
            en: "What's due next for vaccinations?",
            ru: 'Когда следующие прививки?',
            ky: 'Кийинки эмдөөлөр качан?'),
        prompt: tr(lang,
            en: 'Based on the vaccination records in our vault$childSuffix, what shots are due next and when?',
            ru: 'На основе прививочной карты в медкарте$childSuffix — какие прививки следующие и когда?',
            ky: 'Медкартадагы эмдөө жазуулары$childSuffix боюнча кийинки эмдөөлөр кайсылар жана качан?'),
      ),
      _Starter(
        icon: Icons.medication_outlined,
        label: tr(lang,
            en: 'Which medications are we on?',
            ru: 'Какие препараты принимаем?',
            ky: 'Кайсы дары-дармектерди ичип жатабыз?'),
        prompt: tr(lang,
            en: 'List every medication in our recent prescriptions$childSuffix — dose, frequency, and why it was prescribed.',
            ru: 'Перечисли все препараты из недавних рецептов$childSuffix — доза, частота и зачем назначили.',
            ky: 'Жакынкы рецепттердеги бардык дары-дармектерди тизме кыл$childSuffix — доза, жыштыгы жана эмне үчүн дайындалганы.'),
      ),
      _Starter(
        icon: Icons.warning_amber_rounded,
        label: tr(lang,
            en: 'Is this a red flag?',
            ru: 'Это тревожный знак?',
            ky: 'Бул коркунуч белгиси?'),
        prompt: tr(lang,
            en: "I'm worried about something$childSuffix. Can you triage it — is this routine, should I watch it, or should I see a doctor today?",
            ru: 'Меня что-то беспокоит$childSuffix. Поможешь оценить — это рутина, стоит понаблюдать, или к врачу сегодня?',
            ky: 'Мени бир нерсе тынчсыздандырып жатат$childSuffix. Баалап бересиңби — бул кадимкидей, карап турабызбы, же бүгүн дарыгерге барабызбы?'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final selected = profile.selectedMember;
    HouseholdMember? activeChild;
    if (selected != null && selected.role == MemberRole.child) {
      activeChild = selected;
    } else {
      for (final m in profile.members) {
        if (m.role == MemberRole.child) {
          activeChild = m;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(tr(currentLang(context),
            en: 'Ask Balam', ru: 'Спросить Balam', ky: 'Balam-дан сур')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MicButton(onTap: () => _launch(_controller.text)),
                      const SizedBox(height: 16),
                      Text(
                        tr(currentLang(context),
                            en: 'Tap to talk, or type below',
                            ru: 'Нажми, чтобы говорить, или набери ниже',
                            ky: 'Сүйлөө үчүн бас, же төмөндө терип баштагыла'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tr(currentLang(context),
                            en: 'Balam reads your child\'s records before answering.',
                            ru: 'Balam читает записи ребёнка перед ответом.',
                            ky: 'Balam жооп берүү алдында баланын жазууларын окуйт.'),
                        style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              _PromptField(
                controller: _controller,
                onSubmit: _launch,
              ),
              const SizedBox(height: 14),
              _Starters(
                starters: _starters(context, activeChild),
                onTap: _launch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Starter {
  final IconData icon;
  final String label;
  final String prompt;
  const _Starter({required this.icon, required this.label, required this.prompt});
}

class _MicButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MicButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 56),
      ),
    );
  }
}

class _PromptField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const _PromptField({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: onSubmit,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: tr(currentLang(context),
                    en: 'Type a question…',
                    ru: 'Напиши вопрос…',
                    ky: 'Суроо жазыңыз…'),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.primary),
            onPressed: () => onSubmit(controller.text),
          ),
        ],
      ),
    );
  }
}

class _Starters extends StatelessWidget {
  final List<_Starter> starters;
  final ValueChanged<String> onTap;
  const _Starters({required this.starters, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: starters.map((s) {
        return InkWell(
          onTap: () => onTap(s.prompt),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

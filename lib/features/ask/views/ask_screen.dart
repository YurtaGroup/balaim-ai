import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/child_model.dart';
import '../../ai/widgets/persona_pill.dart';
import '../../ai/widgets/prompt_library_carousel.dart';
import '../../journey/providers/journey_provider.dart';

/// v3 Ask — AI-native entry point. Persona pill at top tells the parent
/// which AI specialist is on call; the curated prompt carousel below
/// shows age-appropriate questions for that specialist. Big mic button
/// stays as the primary affordance for free-form questions. Tapping any
/// chip or hitting send routes to AiChatScreen which inherits the same
/// active persona.
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: const PersonaPillWithLabel(),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
            ),
            _AgeHeader(child: activeChild),
            PromptLibraryCarousel(
              activeChild: activeChild,
              onPick: _launch,
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _PromptField(
                controller: _controller,
                onSubmit: _launch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeHeader extends StatelessWidget {
  final HouseholdMember? child;
  const _AgeHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    final age = child?.ageMonths;
    String headline;
    if (age == null) {
      headline = tr(lang,
          en: 'Good questions to ask',
          ru: 'Хорошие вопросы',
          ky: 'Жакшы суроолор');
    } else if (age < 24) {
      headline = tr(lang,
          en: 'Questions to ask at $age months',
          ru: 'Вопросы в $age мес.',
          ky: '$age айда берүүчү суроолор');
    } else {
      final years = (age / 12).floor();
      headline = tr(lang,
          en: 'Questions to ask at $years years',
          ru: 'Вопросы в $years года',
          ky: '$years жашта берүүчү суроолор');
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          headline,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
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

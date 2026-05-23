import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/persona.dart';
import '../providers/active_persona_provider.dart';
import '../views/persona_picker_sheet.dart';

/// Small pill rendered at the top of Ask + in the chat app bar. Shows the
/// active persona's emoji + name. Tapping opens the persona picker.
class PersonaPill extends ConsumerWidget {
  final bool compact;

  const PersonaPill({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activePersonaProvider);
    final persona = personaById(activeId);
    final lang = currentLang(context);

    return InkWell(
      onTap: () => showPersonaPickerSheet(context),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: persona.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: persona.color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(persona.emoji, style: TextStyle(fontSize: compact ? 14 : 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                persona.label(lang),
                style: TextStyle(
                  color: persona.color,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 12 : 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, color: persona.color, size: compact ? 16 : 18),
          ],
        ),
      ),
    );
  }
}

/// A subdued variant used inline on the Ask screen as a header — gets a
/// "Talking to:" prefix to make the affordance obvious for first-time use.
class PersonaPillWithLabel extends ConsumerWidget {
  const PersonaPillWithLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    return Row(
      children: [
        Text(
          tr(lang,
              en: 'Talking to',
              ru: 'Разговор с',
              ky: 'Сүйлөшүп жатат'),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: PersonaPill()),
      ],
    );
  }
}

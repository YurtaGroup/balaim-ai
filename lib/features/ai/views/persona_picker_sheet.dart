import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../paywall/providers/premium_provider.dart';
import '../models/persona.dart';
import '../providers/active_persona_provider.dart';

/// Show the persona picker as a modal bottom sheet. Free users can pick
/// Balam; tapping a premium persona routes to the paywall instead of
/// changing selection.
Future<void> showPersonaPickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _PersonaPickerSheet(),
  );
}

class _PersonaPickerSheet extends ConsumerWidget {
  const _PersonaPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final activeId = ref.watch(activePersonaProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(lang,
                  en: 'Pick your AI specialist',
                  ru: 'Выбери AI-специалиста',
                  ky: 'AI адисти танда'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(lang,
                  en: 'One at a time. Switch any time.',
                  ru: 'По одному. Можно сменить в любой момент.',
                  ky: 'Бирден гана. Каалаган учурда алмаштыр.'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ...kPersonas.map((p) => _PersonaTile(
                  persona: p,
                  selected: p.id == activeId,
                  locked: p.premium && !isPremium,
                  onTap: () async {
                    if (p.premium && !isPremium) {
                      Navigator.of(context).pop();
                      context.push('/paywall');
                      return;
                    }
                    await ref.read(activePersonaProvider.notifier).set(p.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                )),
            const SizedBox(height: 8),
            Text(
              tr(lang,
                  en: 'AI specialists are not real licensed clinicians. Always confirm with a real one.',
                  ru: 'AI-специалисты — не настоящие лицензированные специалисты. Всегда подтверждай у живого.',
                  ky: 'AI адистер чыныгы лицензияланган адистер эмес. Дайыма чыныгысынан тастыкта.'),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonaTile extends StatelessWidget {
  final Persona persona;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const _PersonaTile({
    required this.persona,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? persona.color.withValues(alpha: 0.10)
                : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? persona.color.withValues(alpha: 0.6)
                  : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: persona.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(persona.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            persona.label(lang),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: selected ? persona.color : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (locked) ...[
                          const SizedBox(width: 8),
                          _PremiumBadge(color: persona.color),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      persona.tagline(lang),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: persona.color, size: 22)
              else if (locked)
                const Icon(Icons.lock_outline, color: AppColors.textHint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final Color color;
  const _PremiumBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tr(lang, en: 'Premium', ru: 'Премиум', ky: 'Премиум'),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

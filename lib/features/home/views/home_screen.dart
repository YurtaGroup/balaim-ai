import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/child_model.dart';
import '../../family/views/add_member_sheet.dart';
import '../../journey/providers/journey_provider.dart';
import '../../paywall/add_child_gate.dart';
import '../../notices/notice_card.dart';
import '../../vault/vault_provider.dart';

/// v2 Home — single unified feed for the selected child.
///
/// Compared to v1 Today: no stage-specific Focus/Activity/Worry/Insight/
/// Product cards, no Balam Box CTA, no Quick Access tile row, no
/// pregnancy week hero. Just the things that compound for every family:
/// today's notices, the child's recent vault entries, and a big
/// invitation to ask Balam.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    // v2 is child-only at launch — filter the member roster.
    final children = profile.members.where((m) => m.role == MemberRole.child).toList();
    final selectedMember = profile.selectedMember;
    final activeChild = (selectedMember != null && selectedMember.role == MemberRole.child)
        ? selectedMember
        : (children.isNotEmpty ? children.first : null);
    final vaultItems = activeChild != null
        ? ref.watch(vaultItemsForMemberProvider(activeChild.id))
        : const <VaultItem>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(currentLang(context), en: 'Balam', ru: 'Balam', ky: 'Balam')),
        actions: [
          IconButton(
            tooltip: tr(currentLang(context), en: 'More', ru: 'Ещё', ky: 'Көбүрөөк'),
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showOverflow(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(vaultItemsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _ChildHeader(
              children: children,
              activeChild: activeChild,
              onSelect: (id) => ref.read(userProfileProvider.notifier).selectChild(id),
              onAdd: () {
                if (ensureCanAddChild(context, ref)) {
                  AddMemberSheet.show(context);
                }
              },
            ),
            const SizedBox(height: 16),
            // Today's proactive nudge for the selected child. Self-hides
            // when there's nothing to show.
            const NoticeCard(),
            const SizedBox(height: 12),
            _AskBalamHero(childName: activeChild?.name),
            const SizedBox(height: 16),
            _VaultStrip(items: vaultItems, activeChild: activeChild),
          ],
        ),
      ),
    );
  }

  void _showOverflow(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            _OverflowTile(
              icon: Icons.tune_outlined,
              label: tr(currentLang(ctx), en: 'Settings', ru: 'Настройки', ky: 'Жөндөөлөр'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/settings');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ChildHeader extends StatelessWidget {
  final List<HouseholdMember> children;
  final HouseholdMember? activeChild;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;
  const _ChildHeader({
    required this.children,
    required this.activeChild,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return _EmptyHeader(onAdd: onAdd);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(activeChild, context),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: children.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              if (i == children.length) {
                return _AddChildChip(onTap: onAdd);
              }
              final c = children[i];
              final selected = c.id == activeChild?.id;
              return GestureDetector(
                onTap: () => onSelect(c.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColors.primary : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        _iconFor(c),
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 60,
                      child: Text(
                        c.name.split(' ').first,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _greeting(HouseholdMember? c, BuildContext context) {
    if (c == null) {
      return tr(currentLang(context),
          en: 'Your family',
          ru: 'Твоя семья',
          ky: 'Үй-бүлөңүз');
    }
    final months = c.ageMonths;
    if (months != null && months < 12) {
      return '${c.name}, $months ${tr(currentLang(context), en: 'mo', ru: 'мес.', ky: 'ай')}';
    }
    final years = c.ageYears;
    if (years != null) {
      return '${c.name}, ${years}y';
    }
    return c.name;
  }

  IconData _iconFor(HouseholdMember c) {
    final months = c.ageMonths ?? 0;
    if (months < 12) return Icons.child_care;
    return Icons.child_friendly;
  }
}

class _EmptyHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.child_care, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(currentLang(context),
                      en: 'Add your child to start',
                      ru: 'Добавь ребёнка, чтобы начать',
                      ky: 'Баштоо үчүн балаңызды кошуңуз'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr(currentLang(context),
                      en: "Balam needs a name + date of birth to tailor age-appropriate notices and to index your child's records.",
                      ru: 'Balam нужно имя и дата рождения, чтобы присылать уместные напоминания и разобрать медкарту.',
                      ky: 'Balam-га тиешелүү эскертүү жана медкартаны иретке салуу үчүн аты жана туулган күнү керек.'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(tr(currentLang(context),
                      en: 'Add child',
                      ru: 'Добавить ребёнка',
                      ky: 'Бала кошуу')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

class _AddChildChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChildChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: const Icon(Icons.add, color: AppColors.textHint, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            tr(currentLang(context), en: 'Add', ru: 'Добавить', ky: 'Кошуу'),
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _AskBalamHero extends StatelessWidget {
  final String? childName;
  const _AskBalamHero({required this.childName});

  @override
  Widget build(BuildContext context) {
    final name = childName?.split(' ').first;
    final prompt = name == null
        ? tr(currentLang(context),
            en: 'Ask Balam anything',
            ru: 'Спроси Balam о чём угодно',
            ky: 'Каалаган нерсени Balam-дан сура')
        : tr(currentLang(context),
            en: 'Ask Balam about $name',
            ru: 'Спроси Balam про $name',
            ky: '$name тууралуу Balam-дан сура');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/ask'),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(currentLang(context),
                          en: 'Balam reads your records before answering.',
                          ru: 'Balam читает ваши записи перед ответом.',
                          ky: 'Balam жооп берүү алдында жазууларыңды окуйт.'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultStrip extends StatelessWidget {
  final List<VaultItem> items;
  final HouseholdMember? activeChild;
  const _VaultStrip({required this.items, required this.activeChild});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tr(currentLang(context),
                    en: 'Recent records',
                    ru: 'Последние записи',
                    ky: 'Акыркы жазуулар'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/child'),
              child: Text(tr(currentLang(context),
                  en: 'See all',
                  ru: 'Все',
                  ky: 'Баары')),
            ),
          ],
        ),
        if (items.isEmpty)
          _EmptyVault(childName: activeChild?.name)
        else
          ...items.take(3).map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _VaultRow(item: it),
              )),
      ],
    );
  }
}

class _EmptyVault extends StatelessWidget {
  final String? childName;
  const _EmptyVault({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_shared_outlined, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(currentLang(context),
                  en: 'No records yet. Upload a photo of a prescription, lab, or doctor\'s note in the Child tab — Balam will read it.',
                  ru: 'Пока ничего нет. Загрузи фото рецепта, анализа или заключения врача на вкладке «Ребёнок» — Balam разберёт.',
                  ky: 'Азырынча эч нерсе жок. «Бала» өтмөгүнөн рецепт, анализ же дарыгер жазуусунун сүрөтүн жүктө — Balam окуп берет.'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultRow extends StatelessWidget {
  final VaultItem item;
  const _VaultRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(item.docType);
    final title = item.providerName ?? _labelFor(item.docType, context);
    final subtitle = item.summary.isNotEmpty
        ? item.summary
        : (item.diagnoses.isNotEmpty ? item.diagnoses.join('; ') : _statusText(item, context));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String? t) {
    switch (t) {
      case 'lab_result':
        return Icons.science_outlined;
      case 'prescription':
        return Icons.medication_outlined;
      case 'doctor_note':
        return Icons.note_alt_outlined;
      case 'discharge_summary':
        return Icons.local_hospital_outlined;
      case 'imaging_report':
        return Icons.camera_outdoor_outlined;
      case 'vaccination_card':
        return Icons.vaccines_outlined;
      case 'growth_chart':
        return Icons.show_chart;
      default:
        return Icons.description_outlined;
    }
  }

  String _labelFor(String? t, BuildContext ctx) {
    final lang = currentLang(ctx);
    switch (t) {
      case 'lab_result':
        return tr(lang, en: 'Lab result', ru: 'Анализы', ky: 'Анализ');
      case 'prescription':
        return tr(lang, en: 'Prescription', ru: 'Рецепт', ky: 'Рецепт');
      case 'doctor_note':
        return tr(lang, en: 'Doctor note', ru: 'Заключение врача', ky: 'Дарыгер жазуусу');
      default:
        return tr(lang, en: 'Record', ru: 'Запись', ky: 'Жазуу');
    }
  }

  String _statusText(VaultItem item, BuildContext ctx) {
    if (item.isPending) {
      return tr(currentLang(ctx), en: 'Balam is reading this…', ru: 'Balam читает…', ky: 'Balam окуп жатат…');
    }
    if (item.isFailed) {
      return tr(currentLang(ctx), en: 'Couldn\'t read this one', ru: 'Не удалось разобрать', ky: 'Окуу ишке ашкан жок');
    }
    return '';
  }
}

class _OverflowTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OverflowTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

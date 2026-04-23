import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/child_model.dart';
import '../../journey/providers/journey_provider.dart';
import '../family_invite.dart';

/// Bottom sheet that captures a new household member in a few taps.
/// The single most important acquisition surface — every new member
/// makes the AI doctor smarter and is one more person the owner wants
/// to invite onto Balam. After save, offers an instant WhatsApp share.
class AddMemberSheet extends ConsumerStatefulWidget {
  const AddMemberSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMemberSheet(),
    );
  }

  @override
  ConsumerState<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<AddMemberSheet> {
  final _name = TextEditingController();
  MemberRole _role = MemberRole.mother;
  DateTime? _birthDate;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final id = '${_role.name}-${DateTime.now().millisecondsSinceEpoch}';
    final member = HouseholdMember(
      id: id,
      name: name,
      role: _role,
      birthDate: _birthDate,
      // Stage only matters for children pre-2 years; leave null for adults.
      stage: _role == MemberRole.child
          ? (_birthDate != null &&
                  DateTime.now().difference(_birthDate!).inDays < 365)
              ? ParentingStage.newborn
              : ParentingStage.toddler
          : null,
    );
    ref.read(userProfileProvider.notifier).addChild(member);
    if (!mounted) return;
    Navigator.of(context).pop();

    // Immediately offer to invite — the whole point.
    await _offerInvite(context, name);
  }

  Future<void> _offerInvite(BuildContext context, String memberName) async {
    final profile = ref.read(userProfileProvider);
    final senderName = profile.displayName.isNotEmpty
        ? profile.displayName
        : profile.members.firstWhere(
            (m) => m.role == MemberRole.self,
            orElse: () => HouseholdMember(
              id: 'self-fallback',
              name: 'Your family',
              role: MemberRole.self,
            ),
          ).name;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr(currentLang(ctx),
            en: 'Invite $memberName to Balam?',
            ru: 'Пригласить $memberName в Balam?',
            ky: '$memberName-ды Balam-га чакырабызбы?')),
        content: Text(tr(currentLang(ctx),
            en: 'Balam gets smarter with every family member. Send a WhatsApp invite so $memberName can upload their own records too.',
            ru: 'Balam умнеет с каждым новым членом семьи. Отправь приглашение в WhatsApp — $memberName сможет тоже загружать свои документы.',
            ky: 'Ар бир жаңы үй-бүлө мүчөсү менен Balam акылдуураак болот. WhatsApp аркылуу чакыруу жөнөт — $memberName да документтерин жүктөй алат.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr(currentLang(ctx),
                en: 'Later',
                ru: 'Позже',
                ky: 'Кийин')),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FamilyInvite.share(
                locale: currentLang(ctx),
                senderName: senderName,
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(tr(currentLang(ctx),
                en: 'Send on WhatsApp',
                ru: 'Отправить в WhatsApp',
                ky: 'WhatsApp-ка жөнөт')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr(currentLang(context),
                    en: 'Add a family member',
                    ru: 'Добавить члена семьи',
                    ky: 'Үй-бүлө мүчөсүн кошуу'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(currentLang(context),
                    en: 'Who else should Balam look after? Add anyone whose health matters to you — your mother, wife, dad, child, grandparent.',
                    ru: 'Кого ещё Balam должен беречь? Добавь любого, чьё здоровье тебе важно — маму, жену, папу, ребёнка, бабушку.',
                    ky: 'Balam дагы кимди карашы керек? Ден соолугу сага маанилүү ар кимди кош — апаңды, жубайыңды, атаңды, балаңды, чоң энеңди.'),
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              Text(
                tr(currentLang(context),
                    en: 'Their name',
                    ru: 'Имя',
                    ky: 'Аты'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                decoration: InputDecoration(
                  hintText: tr(currentLang(context),
                      en: 'e.g. Gulnara',
                      ru: 'напр. Гульнара',
                      ky: 'мисалы, Гүлнара'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tr(currentLang(context),
                    en: 'Relationship',
                    ru: 'Кто это для тебя',
                    ky: 'Кимиңиз болот'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presentableRoles().map((r) {
                  final selected = _role == r;
                  return ChoiceChip(
                    label: Text(_roleLabel(r, context)),
                    selected: selected,
                    onSelected: (_) => setState(() => _role = r),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                tr(currentLang(context),
                    en: 'Birth date (helps with age-based reminders)',
                    ru: 'Дата рождения (для напоминаний по возрасту)',
                    ky: 'Туулган күнү (курак боюнча эскертүүлөр үчүн)'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _birthDate == null
                              ? tr(currentLang(context),
                                  en: 'Tap to pick',
                                  ru: 'Нажми, чтобы выбрать',
                                  ky: 'Тандоо үчүн бас')
                              : _formatDate(_birthDate!),
                          style: TextStyle(
                            color: _birthDate == null
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving || _name.text.trim().isEmpty ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          tr(currentLang(context),
                              en: 'Add to my family',
                              ru: 'Добавить в семью',
                              ky: 'Үй-бүлөгө кошуу'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Order + filter so the picker is fast to scan. 'self' is hidden —
  // the self member is auto-created on first load.
  List<MemberRole> _presentableRoles() => const [
        MemberRole.mother,
        MemberRole.father,
        MemberRole.partner,
        MemberRole.child,
        MemberRole.grandmother,
        MemberRole.grandfather,
        MemberRole.sibling,
        MemberRole.other,
      ];

  String _roleLabel(MemberRole r, BuildContext ctx) {
    final lang = currentLang(ctx);
    switch (r) {
      case MemberRole.mother:
        return tr(lang, en: 'Mother', ru: 'Мама', ky: 'Апа');
      case MemberRole.father:
        return tr(lang, en: 'Father', ru: 'Папа', ky: 'Ата');
      case MemberRole.partner:
        return tr(lang, en: 'Partner', ru: 'Супруг(а)', ky: 'Жубай');
      case MemberRole.child:
        return tr(lang, en: 'Child', ru: 'Ребёнок', ky: 'Бала');
      case MemberRole.grandmother:
        return tr(lang, en: 'Grandmother', ru: 'Бабушка', ky: 'Чоң эне');
      case MemberRole.grandfather:
        return tr(lang, en: 'Grandfather', ru: 'Дедушка', ky: 'Чоң ата');
      case MemberRole.sibling:
        return tr(lang, en: 'Sibling', ru: 'Брат/Сестра', ky: 'Бир тууган');
      case MemberRole.uncleAunt:
        return tr(lang, en: 'Uncle/Aunt', ru: 'Дядя/Тётя', ky: 'Таяке/Эже');
      case MemberRole.other:
        return tr(lang, en: 'Other', ru: 'Другое', ky: 'Башка');
      case MemberRole.self:
        return tr(lang, en: 'Me', ru: 'Я', ky: 'Мен');
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

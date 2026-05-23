import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/user_profile.dart';
import '../../journey/providers/journey_provider.dart';
import '../emergency_dial.dart';

/// The 3am screen. Eight big buttons covering the most common panic
/// scenarios, plus a tap-to-call emergency-services button up top.
///
/// Each button forwards to /ai with the emergency query flag set, which
/// puts AiChatScreen into emergency mode: AI Pediatrician persona,
/// brief replies, weekly free-tier cap bypassed.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final profile = ref.watch(userProfileProvider);
    final activeChild = _resolveActiveChild(profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          tr(lang,
              en: 'Emergency',
              ru: 'Экстренная помощь',
              ky: 'Шашылыш жардам'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              _CallEmergencyButton(lang: lang),
              const SizedBox(height: 10),
              _Disclaimer(lang: lang),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tr(lang,
                      en: 'What\'s happening?',
                      ru: 'Что происходит?',
                      ky: 'Эмне болуп жатат?'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _EmergencyGrid(
                  lang: lang,
                  activeChild: activeChild,
                  onPick: (seed) {
                    context.go(
                      '/ai?prefill=${Uri.encodeComponent(seed)}&emergency=1',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  HouseholdMember? _resolveActiveChild(UserProfile profile) {
    final selected = profile.selectedMember;
    if (selected != null && selected.role == MemberRole.child) return selected;
    for (final m in profile.members) {
      if (m.role == MemberRole.child) return m;
    }
    return null;
  }
}

class _CallEmergencyButton extends StatelessWidget {
  final String lang;
  const _CallEmergencyButton({required this.lang});

  @override
  Widget build(BuildContext context) {
    final number = emergencyDialNumber(lang);
    return InkWell(
      onTap: () => dialEmergency(lang),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.call, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(lang,
                        en: 'Call emergency services',
                        ru: 'Вызвать экстренную службу',
                        ky: 'Шашылыш кызматка чалуу'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr(lang,
                        en: 'If you are not sure, call. Then come back to Balam.',
                        ru: 'Сомневаешься — звони. Потом вернись к Balam.',
                        ky: 'Күмөнү болсоң — чал. Андан кийин Balam-га кайт.'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  final String lang;
  const _Disclaimer({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tr(lang,
                  en: 'I\'m helping you decide — I\'m not a doctor. If you sense danger, call now.',
                  ru: 'Я помогаю тебе сориентироваться — я не врач. Если чувствуешь опасность — звони сейчас.',
                  ky: 'Мен сага чечүүгө жардам берем — мен дарыгер эмесмин. Коркунуч сезсең, азыр чал.'),
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

class _EmergencyGrid extends StatelessWidget {
  final String lang;
  final HouseholdMember? activeChild;
  final ValueChanged<String> onPick;

  const _EmergencyGrid({
    required this.lang,
    required this.activeChild,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards(lang, activeChild);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) {
        final c = cards[i];
        return _EmergencyCard(
          icon: c.icon,
          label: c.label,
          color: c.color,
          onTap: () => onPick(c.seed),
        );
      },
    );
  }
}

class _CardData {
  final IconData icon;
  final String label;
  final String seed;
  final Color color;
  const _CardData({
    required this.icon,
    required this.label,
    required this.seed,
    required this.color,
  });
}

List<_CardData> _buildCards(String lang, HouseholdMember? child) {
  final name = child?.name.split(' ').first;
  final age = child?.ageMonths;
  // Build a short "context tail" we append to each seed so Pediatrician
  // has the child's age + name without having to ask.
  String tail() {
    if (name == null || age == null) return '';
    if (age < 24) {
      return ' (${tr(lang, en: name, ru: name, ky: name)}, $age ${tr(lang, en: 'mo', ru: 'мес', ky: 'ай')})';
    }
    final years = (age / 12).floor();
    return ' (${tr(lang, en: name, ru: name, ky: name)}, $years ${tr(lang, en: 'yr', ru: 'г', ky: 'жаш')})';
  }

  final t = tail();
  return [
    _CardData(
      icon: Icons.thermostat,
      color: const Color(0xFFD9534F),
      label: tr(lang, en: 'Fever', ru: 'Температура', ky: 'Ысытма'),
      seed: tr(lang,
              en: 'Sudden fever — what should I do right now?',
              ru: 'Внезапная температура — что делать прямо сейчас?',
              ky: 'Күтүүсүздөн ысытма чыкты — азыр эмне кылам?') +
          t,
    ),
    _CardData(
      icon: Icons.air,
      color: const Color(0xFFC0392B),
      label: tr(lang,
          en: 'Breathing trouble',
          ru: 'Трудно дышать',
          ky: 'Дем алуу кыйын'),
      seed: tr(lang,
              en: 'My child is having trouble breathing — what do I check first?',
              ru: 'Малышу трудно дышать — что проверить в первую очередь?',
              ky: 'Балам дем алууда кыйналып жатат — биринчи эмнени текшерем?') +
          t,
    ),
    _CardData(
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFE67E22),
      label: tr(lang,
          en: 'Allergic reaction',
          ru: 'Аллергическая реакция',
          ky: 'Аллергиялык реакция'),
      seed: tr(lang,
              en: 'Possible allergic reaction — hives or swelling. What should I do?',
              ru: 'Похоже на аллергию — крапивница или отёк. Что делать?',
              ky: 'Аллергия окшойт — каүыктар же шиш. Эмне кылам?') +
          t,
    ),
    _CardData(
      icon: Icons.healing,
      color: const Color(0xFFAF7AC5),
      label: tr(lang, en: 'Rash', ru: 'Сыпь', ky: 'Бөртмө'),
      seed: tr(lang,
              en: 'New rash appeared — should I worry, and what should I look for?',
              ru: 'Появилась новая сыпь — стоит ли волноваться и на что обращать внимание?',
              ky: 'Жаңы бөртмө пайда болду — кооптонсом болобу, эмнеге көңүл бурам?') +
          t,
    ),
    _CardData(
      icon: Icons.no_food,
      color: const Color(0xFFD35400),
      label: tr(lang, en: 'Choking', ru: 'Задыхается', ky: 'Тыгылып калды'),
      seed: tr(lang,
              en: 'Choking on something — what do I do right now?',
              ru: 'Подавился — что делать прямо сейчас?',
              ky: 'Бирөөгө тыгылды — азыр эмне кылам?') +
          t,
    ),
    _CardData(
      icon: Icons.healing_outlined,
      color: const Color(0xFF8E44AD),
      label: tr(lang,
          en: 'Fall / head bump',
          ru: 'Упал / удар головой',
          ky: 'Жыгылды / башын тийгизди'),
      seed: tr(lang,
              en: 'Bumped their head from a fall — what signs mean I need urgent care?',
              ru: 'Ударился(лась) головой при падении — какие признаки требуют срочной помощи?',
              ky: 'Жыгылып башын тийгизди — кайсы белгилер шашылыш жардамды талап кылат?') +
          t,
    ),
    _CardData(
      icon: Icons.sentiment_very_dissatisfied,
      color: const Color(0xFFE57373),
      label: tr(lang,
          en: 'Crying won\'t stop',
          ru: 'Не перестаёт плакать',
          ky: 'Ыйы токтобойт'),
      seed: tr(lang,
              en: 'Inconsolable crying that won\'t stop — what should I check and when do I call?',
              ru: 'Безутешный плач, не утихает — что проверить и когда звонить?',
              ky: 'Ыйы такыр басылбай жатат — эмнени текшерем, качан чалам?') +
          t,
    ),
    _CardData(
      icon: Icons.more_horiz,
      color: AppColors.textSecondary,
      label: tr(lang, en: 'Something else', ru: 'Что-то другое', ky: 'Башка нерсе'),
      seed: tr(lang,
              en: 'I\'m worried about something — help me triage it quickly.',
              ru: 'Я переживаю — помоги быстро оценить ситуацию.',
              ky: 'Мен кооптонуп жатам — кырдаалды тез баалоого жардам бер.') +
          t,
    ),
  ];
}

class _EmergencyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

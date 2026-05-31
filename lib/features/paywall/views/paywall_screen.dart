import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/premium_provider.dart';

/// Balam Premium paywall. Reached from the free-tier AI gate, the
/// add-second-child gate, and the Settings screen.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<Package> _packages = const [];
  bool _loading = true;
  bool _busy = false;
  PackageType _selected = PackageType.annual;

  @override
  void initState() {
    super.initState();
    _load();
    Analytics.instance.paywallViewed(surface: 'paywall_screen');
  }

  Future<void> _load() async {
    final pkgs = await PaymentService().premiumPackages();
    if (!mounted) return;
    setState(() {
      _packages = pkgs;
      _loading = false;
      if (!pkgs.any((p) => p.packageType == PackageType.annual) &&
          pkgs.any((p) => p.packageType == PackageType.monthly)) {
        _selected = PackageType.monthly;
      }
    });
  }

  Package? _pkg(PackageType t) {
    for (final p in _packages) {
      if (p.packageType == t) return p;
    }
    return null;
  }

  Future<void> _buy() async {
    final pkg = _pkg(_selected);
    if (pkg == null) return;
    setState(() => _busy = true);
    final res = await PaymentService().purchase(pkg, surface: 'paywall_screen');
    if (!mounted) return;
    setState(() => _busy = false);
    if (res.success) {
      Navigator.of(context).maybePop();
    } else if (!res.cancelled && res.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.error!)));
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    final premium = await PaymentService().restorePurchases();
    if (!mounted) return;
    setState(() => _busy = false);
    if (premium) {
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr(currentLang(context),
            en: 'No previous purchase found.',
            ru: 'Прошлых покупок не найдено.',
            ky: 'Мурунку сатып алуу табылган жок.')),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    final premium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: premium
          ? _AlreadyPremium(onDone: () => Navigator.of(context).maybePop())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                children: [
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(lang,
                        en: 'Balam Premium',
                        ru: 'Balam Premium',
                        ky: 'Balam Premium'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr(lang,
                        en: 'Everything Balam knows about your child — without limits.',
                        ru: 'Всё, что Balam знает о твоём ребёнке — без ограничений.',
                        ky: 'Balam балаңыз тууралуу билгендин баары — чексиз.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  _Feature(
                    icon: Icons.chat_bubble_outline,
                    title: tr(lang,
                        en: 'Unlimited questions',
                        ru: 'Безлимитные вопросы',
                        ky: 'Чексиз суроолор'),
                    body: tr(lang,
                        en: 'Ask Balam any time, day or night — grounded in your child\'s records.',
                        ru: 'Спрашивай Balam в любое время — с опорой на медкарту ребёнка.',
                        ky: 'Каалаган убакта Balam\'дан сура — баланын медкартасына негизделген.'),
                  ),
                  _Feature(
                    icon: Icons.family_restroom,
                    title: tr(lang,
                        en: 'All your children',
                        ru: 'Все твои дети',
                        ky: 'Бардык балдарыңыз'),
                    body: tr(lang,
                        en: 'One vault and one AI for every child in the family.',
                        ru: 'Одна медкарта и один AI для каждого ребёнка в семье.',
                        ky: 'Үй-бүлөдөгү ар бир балага бир медкарта жана бир AI.'),
                  ),
                  _Feature(
                    icon: Icons.picture_as_pdf_outlined,
                    title: tr(lang,
                        en: 'Export health records',
                        ru: 'Экспорт медкарты',
                        ky: 'Медкартаны экспорттоо'),
                    body: tr(lang,
                        en: 'A clean PDF of your child\'s history for any doctor visit.',
                        ru: 'Аккуратный PDF истории ребёнка для визита к врачу.',
                        ky: 'Дарыгерге баруу үчүн баланын тарыхынын таза PDF\'и.'),
                  ),
                  _Feature(
                    icon: Icons.favorite_outline,
                    title: tr(lang,
                        en: 'Share with your partner',
                        ru: 'Доступ для партнёра',
                        ky: 'Жубайыңыз менен бөлүшүү'),
                    body: tr(lang,
                        en: 'Both parents on the same page — literally.',
                        ru: 'Оба родителя видят одно и то же.',
                        ky: 'Эки ата-эне бир эле маалыматты көрөт.'),
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ))
                  else if (_packages.isEmpty)
                    _DemoNotice(lang: lang)
                  else ...[
                    _PlanCard(
                      selected: _selected == PackageType.annual,
                      enabled: _pkg(PackageType.annual) != null,
                      title: tr(lang,
                          en: 'Yearly', ru: 'На год', ky: 'Жылдык'),
                      price: _pkg(PackageType.annual)
                              ?.storeProduct
                              .priceString ??
                          '—',
                      badge: tr(lang,
                          en: 'Save 27%',
                          ru: 'Выгода 27%',
                          ky: '27% үнөмдөө'),
                      onTap: () =>
                          setState(() => _selected = PackageType.annual),
                    ),
                    const SizedBox(height: 10),
                    _PlanCard(
                      selected: _selected == PackageType.monthly,
                      enabled: _pkg(PackageType.monthly) != null,
                      title: tr(lang,
                          en: 'Monthly', ru: 'На месяц', ky: 'Айлык'),
                      price: _pkg(PackageType.monthly)
                              ?.storeProduct
                              .priceString ??
                          '—',
                      onTap: () =>
                          setState(() => _selected = PackageType.monthly),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _busy ? null : _buy,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                tr(lang,
                                    en: 'Start Balam Premium',
                                    ru: 'Подключить Premium',
                                    ky: 'Premium\'ду баштоо'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                      ),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _restore,
                      child: Text(tr(lang,
                          en: 'Restore purchases',
                          ru: 'Восстановить покупки',
                          ky: 'Сатып алууну калыбына келтирүү')),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _LegalRow(lang: lang),
                ],
              ),
            ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Feature(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(body,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final String title;
  final String price;
  final String? badge;
  final VoidCallback onTap;
  const _PlanCard({
    required this.selected,
    required this.enabled,
    required this.title,
    required this.price,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.textHint,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge!,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ],
              const Spacer(),
              Text(price,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  final String lang;
  const _DemoNotice({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        tr(lang,
            en: 'Subscriptions activate when the app is connected to the App Store. Everything above is what Premium unlocks.',
            ru: 'Подписки активируются после подключения к App Store. Выше — что даёт Premium.',
            ky: 'Жазылуулар App Store\'го туташканда иштейт. Жогоруда — Premium эмне ачат.'),
        style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.4),
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  final String lang;
  const _LegalRow({required this.lang});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          tr(lang,
              en: 'Auto-renews until cancelled. Cancel any time in the App Store.',
              ru: 'Продлевается автоматически. Отмена в любой момент в App Store.',
              ky: 'Автоматтык түрдө узарат. App Store\'до каалаган убакта токтотулат.'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => _open('https://balam.ai/terms'),
              child: Text(tr(lang,
                  en: 'Terms', ru: 'Условия', ky: 'Шарттар')),
            ),
            const Text('·', style: TextStyle(color: AppColors.textHint)),
            TextButton(
              onPressed: () => _open('https://balam.ai/privacy'),
              child: Text(tr(lang,
                  en: 'Privacy',
                  ru: 'Конфиденциальность',
                  ky: 'Купуялык')),
            ),
          ],
        ),
      ],
    );
  }
}

class _AlreadyPremium extends StatelessWidget {
  final VoidCallback onDone;
  const _AlreadyPremium({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            Text(
              tr(lang,
                  en: 'You\'re on Balam Premium',
                  ru: 'У тебя Balam Premium',
                  ky: 'Сизде Balam Premium бар'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              tr(lang,
                  en: 'Unlimited questions, every child, full export. Thank you for backing Balam. 🐆',
                  ru: 'Безлимит, все дети, полный экспорт. Спасибо, что поддерживаешь Balam. 🐆',
                  ky: 'Чексиз суроолор, бардык балдар, толук экспорт. Balam\'ды колдогонуңузга рахмат. 🐆'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(tr(lang, en: 'Done', ru: 'Готово', ky: 'Бүттү')),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final lang = currentLang(context);
    final pages = [
      _OnboardingPage(
        icon: Icons.folder_shared_outlined,
        color: AppColors.primary,
        title: tr(lang,
            en: 'Every detail of your child\'s health',
            ru: 'Всё о здоровье твоего ребёнка',
            ky: 'Балаңыздын ден соолугу тууралуу баары'),
        subtitle: tr(lang,
            en: 'Doctor visits, vaccines, prescriptions, growth — one place, never lost.',
            ru: 'Визиты к врачу, прививки, рецепты, рост — в одном месте, ничего не теряется.',
            ky: 'Дарыгерге баруу, эмдөө, рецепт, өсүү — бир жерде, эч качан жоголбойт.'),
      ),
      _OnboardingPage(
        icon: Icons.auto_awesome,
        color: AppColors.secondary,
        title: tr(lang,
            en: 'Ask anything, day or night',
            ru: 'Спрашивай в любое время',
            ky: 'Каалаган убакта сура'),
        subtitle: tr(lang,
            en: 'Balam reads your child\'s real records before answering — like a doctor who knows your kid.',
            ru: 'Balam читает медкарту ребёнка перед ответом — как врач, который знает твоего малыша.',
            ky: 'Balam жооп бергенге чейин баланын медкартасын окуйт — балаңызды билген дарыгердей.'),
      ),
      _OnboardingPage(
        icon: Icons.notifications_active_outlined,
        color: AppColors.accent,
        title: tr(lang,
            en: 'Know what\'s coming next',
            ru: 'Знай, что впереди',
            ky: 'Эмне болорун алдын ала бил'),
        subtitle: tr(lang,
            en: 'Vaccines, check-ups, milestones — Balam tells you before you have to ask.',
            ru: 'Прививки, осмотры, этапы развития — Balam напомнит заранее.',
            ky: 'Эмдөө, текшерүү, өнүгүү этаптары — Balam алдын ала эскертет.'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < pages.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        } else {
                          context.go('/signup');
                        }
                      },
                      child: Text(_currentPage < pages.length - 1 ? l.next : l.getStarted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage < pages.length - 1)
                    TextButton(onPressed: () => context.go('/signup'), child: Text(l.skip)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _OnboardingPage({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 56, color: color),
          ),
          const SizedBox(height: 48),
          Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L.of(context).featureComingSoon), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(currentUserInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).adminDashboard),
        actions: [
          TextButton.icon(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout, size: 18),
            label: Text(L.of(context).signOut),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${L.of(context).welcomeComma} ${userInfo.name ?? 'Admin'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    L.of(context).platformOverview,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // KPI cards
            Text(L.of(context).keyMetrics, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: L.of(context).totalUsers,
                    value: '12,847',
                    change: '+23%',
                    icon: Icons.people,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: L.of(context).activeToday,
                    value: '3,241',
                    change: '+8%',
                    icon: Icons.trending_up,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: L.of(context).aiChats,
                    value: '8,429',
                    change: '+45%',
                    icon: Icons.auto_awesome,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: L.of(context).revenue,
                    value: '\$24.8K',
                    change: '+31%',
                    icon: Icons.attach_money,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Platform sections
            Text(L.of(context).platformManagement, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.insights,
              title: L.of(context).liveMetrics,
              subtitle: L.of(context).realSignupCounts,
              color: AppColors.primary,
              onTap: () => context.push('/admin/metrics'),
            ),
            _AdminTile(
              icon: Icons.people_outline,
              title: L.of(context).userManagement,
              subtitle: L.of(context).userManagementSubtitle,
              color: AppColors.primary,
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.verified_user_outlined,
              title: L.of(context).professionalVerification,
              subtitle: L.of(context).pendingApplications,
              color: AppColors.secondary,
              badge: '23',
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.storefront_outlined,
              title: L.of(context).marketplaceVendors,
              subtitle: L.of(context).marketplaceVendorsSubtitle,
              color: AppColors.accent,
              badge: '8',
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.forum_outlined,
              title: L.of(context).communityModeration,
              subtitle: L.of(context).communityModerationSubtitle,
              color: AppColors.error,
              badge: '12',
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.auto_awesome_outlined,
              title: L.of(context).aiPerformance,
              subtitle: L.of(context).aiPerformanceSubtitle,
              color: Colors.purple,
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.analytics_outlined,
              title: L.of(context).analyticsReports,
              subtitle: L.of(context).analyticsReportsSubtitle,
              color: Colors.indigo,
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.payments_outlined,
              title: L.of(context).billingRevenue,
              subtitle: L.of(context).billingRevenueSubtitle,
              color: AppColors.success,
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.notifications_outlined,
              title: L.of(context).pushNotifications,
              subtitle: L.of(context).pushNotificationsSubtitle,
              color: Colors.orange,
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.settings_outlined,
              title: L.of(context).platformSettings,
              subtitle: L.of(context).platformSettingsSubtitle,
              color: AppColors.textSecondary,
              onTap: () => _comingSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/demo_auth_service.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Floating role-switcher chip — only visible for the app owner.
/// Lets the owner view the app as any role (Parent, Admin, Doctor).
class RoleSwitcher extends ConsumerWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(isOwnerProvider);
    if (!isOwner) return const SizedBox.shrink();

    final activeRole = ref.watch(activeViewRoleProvider);
    final label = switch (activeRole) {
      UserRole.admin => 'Admin',
      UserRole.doctor => 'Doctor',
      UserRole.vendor => 'Vendor',
      _ => 'Owner',
    };
    final icon = switch (activeRole) {
      UserRole.admin => Icons.admin_panel_settings,
      UserRole.doctor => Icons.medical_services,
      UserRole.vendor => Icons.storefront,
      _ => Icons.shield,
    };

    return Positioned(
      left: 16,
      bottom: 24,
      child: GestureDetector(
        onTap: () => _showRoleMenu(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentDark,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentDark.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch View',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Owner mode — you have access to everything',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _RoleOption(
              icon: Icons.pregnant_woman,
              label: 'Parent View',
              subtitle: 'Journey, AI, Community, Marketplace',
              color: AppColors.primary,
              onTap: () {
                ref.read(activeViewRoleProvider.notifier).state = null;
                Navigator.of(ctx).pop();
                context.go('/');
              },
            ),
            _RoleOption(
              icon: Icons.admin_panel_settings,
              label: 'Admin View',
              subtitle: 'Platform metrics, user management',
              color: AppColors.accentDark,
              onTap: () {
                ref.read(activeViewRoleProvider.notifier).state = UserRole.admin;
                Navigator.of(ctx).pop();
                context.go('/admin');
              },
            ),
            _RoleOption(
              icon: Icons.medical_services,
              label: 'Doctor View',
              subtitle: 'Case queue, patient reviews',
              color: AppColors.secondary,
              onTap: () {
                ref.read(activeViewRoleProvider.notifier).state = UserRole.doctor;
                Navigator.of(ctx).pop();
                context.go('/doctor');
              },
            ),
            _RoleOption(
              icon: Icons.science,
              label: 'Lab Results',
              subtitle: 'Analyze blood work, track health',
              color: AppColors.success,
              onTap: () {
                ref.read(activeViewRoleProvider.notifier).state = null;
                Navigator.of(ctx).pop();
                context.go('/lab');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

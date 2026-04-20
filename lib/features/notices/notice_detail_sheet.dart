import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../auth/providers/auth_provider.dart';
import 'notices_provider.dart';

/// Expanded modal for a notice. Full body + action + dismiss.
class NoticeDetailSheet extends ConsumerWidget {
  final Notice notice;
  const NoticeDetailSheet({super.key, required this.notice});

  static Future<void> show(BuildContext context, Notice notice) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NoticeDetailSheet(notice: notice),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final info = ref.watch(currentUserInfoProvider);
    final uid = info.uid;
    final urgencyColor = switch (notice.urgency) {
      'high' => AppColors.error,
      'medium' => AppColors.accentDark,
      _ => AppColors.secondary,
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l.balamNoticed,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: urgencyColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (notice.memberName.isNotEmpty)
                  Text(
                    notice.memberName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              notice.title.forContext(context),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),

            Text(
              notice.body.forContext(context),
              style: const TextStyle(fontSize: 15, height: 1.55),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  if (uid != null) {
                    await markNoticeActed(uid, notice.id);
                  }
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  context.push(notice.actionRoute);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: urgencyColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  notice.actionLabel.forContext(context),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: uid == null
                    ? null
                    : () async {
                        HapticFeedback.selectionClick();
                        await dismissNotice(uid, notice.id);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l.dismiss,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

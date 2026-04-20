import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../auth/providers/auth_provider.dart';
import 'notice_detail_sheet.dart';
import 'notices_provider.dart';

/// The "Balam noticed…" card that lives at the top of the Today screen
/// when there's an active notice for the selected member. Self-hides
/// (returns SizedBox.shrink) when there's nothing to show.
class NoticeCard extends ConsumerWidget {
  const NoticeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(topNoticeForSelectedMemberProvider);
    if (notice == null) return const SizedBox.shrink();

    final l = L.of(context);
    final info = ref.watch(currentUserInfoProvider);
    final uid = info.uid;

    final urgencyColor = switch (notice.urgency) {
      'high' => AppColors.error,
      'medium' => AppColors.accentDark,
      _ => AppColors.secondary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => NoticeDetailSheet.show(context, notice),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: urgencyColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active_outlined,
                              size: 12, color: urgencyColor),
                          const SizedBox(width: 4),
                          Text(
                            l.balamNoticed,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: urgencyColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (notice.memberName.isNotEmpty)
                      Text(
                        notice.memberName,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                      tooltip: l.dismiss,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: uid == null
                          ? null
                          : () async {
                              HapticFeedback.selectionClick();
                              await dismissNotice(uid, notice.id);
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notice.title.forContext(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notice.body.forContext(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        if (uid != null) {
                          await markNoticeActed(uid, notice.id);
                        }
                        if (context.mounted) {
                          context.push(notice.actionRoute);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: urgencyColor,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        notice.actionLabel.forContext(context),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => NoticeDetailSheet.show(context, notice),
                      child: Text(
                        l.readMore,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

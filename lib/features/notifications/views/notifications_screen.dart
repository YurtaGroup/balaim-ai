import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/consultation_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(currentUserInfoProvider);
    final uid = userInfo.uid;

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).notifications)),
      body: uid == null
          ? Center(child: Text(L.of(context).signInToContinue))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: ConsultationService().watchNotifications(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(
                          L.of(context).noNotificationsYet,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textHint),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          L.of(context).notificationsEmptyDesc,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, i) {
                    final n = notifications[i];
                    final isRead = n['read'] == true;
                    final type = n['type'] as String? ?? '';
                    final title = n['title'] as String? ?? _titleForType(type);
                    final body = n['body'] as String? ?? '';
                    final icon = _iconForType(type);
                    final color = _colorForType(type);

                    return Card(
                      color: isRead ? null : AppColors.primary.withValues(alpha: 0.04),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: body.isNotEmpty ? Text(body, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                        trailing: isRead
                            ? null
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onTap: () {
                          final nId = n['id'] as String?;
                          if (nId != null && !isRead) {
                            ConsultationService().markNotificationRead(nId);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Notification type titles are stored in Firestore 'title' field.
  // This fallback is only used when 'title' is missing from the doc.
  String _titleForType(String type) {
    switch (type) {
      case 'new_consultation':
      case 'consultation_answered':
      case 'follow_up_question':
      case 'follow_up_answered':
        return ''; // Title comes from Firestore notification doc
      case 'insight':
        return '';
      case 'tracking_reminder':
        return '';
      default:
        return '';
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_consultation':
      case 'consultation_answered':
      case 'follow_up_question':
      case 'follow_up_answered':
        return Icons.medical_services_outlined;
      case 'insight':
        return Icons.auto_awesome;
      case 'tracking_reminder':
        return Icons.edit_note;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'new_consultation':
      case 'follow_up_question':
        return AppColors.warning;
      case 'consultation_answered':
      case 'follow_up_answered':
        return AppColors.success;
      case 'insight':
        return AppColors.secondary;
      case 'tracking_reminder':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}

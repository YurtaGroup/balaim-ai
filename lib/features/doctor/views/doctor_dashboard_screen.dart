import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import 'case_review_screen.dart';

/// Doctor's home screen — shows pending cases, stats, and completed history.
///
/// Design philosophy: doctors are busy. Show them what needs attention FIRST.
/// No clutter, no marketing, just the work queue.
class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorName = AuthService().currentDisplayName ?? 'Doctor';

    // Demo data — in production, these come from ConsultationService streams
    final pendingCases = _demoPendingCases();
    final needsFollowUp = _demoFollowUpCases();
    final completedCount = 12;
    final totalEarnings = 2400.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          TextButton.icon(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign Out'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $doctorName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pendingCases.length} cases need your attention',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatBadge(
                      label: 'Pending',
                      value: '${pendingCases.length}',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(
                      label: 'Follow-ups',
                      value: '${needsFollowUp.length}',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(
                      label: 'Completed',
                      value: '$completedCount',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(
                      label: 'Earned',
                      value: '\$${totalEarnings.round()}',
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // URGENT: Follow-up questions waiting
          if (needsFollowUp.isNotEmpty) ...[
            _SectionTitle(
              title: 'Follow-up Questions',
              subtitle: 'Patient asked a follow-up — please respond',
              color: AppColors.warning,
              icon: Icons.reply,
            ),
            const SizedBox(height: 12),
            ...needsFollowUp.map((c) => _CaseCard(
                  caseData: c,
                  badge: 'FOLLOW-UP',
                  badgeColor: AppColors.warning,
                  onTap: () => _openCase(context, c),
                )),
            const SizedBox(height: 20),
          ],

          // PENDING: New cases to review
          _SectionTitle(
            title: 'Pending Cases',
            subtitle: 'Newest first — tap to review',
            color: AppColors.primary,
            icon: Icons.assignment,
          ),
          const SizedBox(height: 12),
          if (pendingCases.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 48, color: AppColors.success),
                  const SizedBox(height: 12),
                  const Text(
                    'All caught up!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No pending consultations right now.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ...pendingCases.map((c) => _CaseCard(
                  caseData: c,
                  badge: c['urgency'] == 'urgent'
                      ? 'URGENT'
                      : c['urgency'] == 'soon'
                          ? 'SOON'
                          : 'ROUTINE',
                  badgeColor: c['urgency'] == 'urgent'
                      ? AppColors.error
                      : c['urgency'] == 'soon'
                          ? AppColors.warning
                          : AppColors.secondary,
                  onTap: () => _openCase(context, c),
                )),

          const SizedBox(height: 24),

          // Quick links
          _SectionTitle(
            title: 'Quick Links',
            color: AppColors.textSecondary,
            icon: Icons.link,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickLink(
                icon: Icons.history,
                label: 'Completed Cases',
                onTap: () {},
              ),
              _QuickLink(
                icon: Icons.account_balance_wallet,
                label: 'Earnings',
                onTap: () {},
              ),
              _QuickLink(
                icon: Icons.person,
                label: 'My Profile',
                onTap: () {},
              ),
              _QuickLink(
                icon: Icons.help_outline,
                label: 'Guidelines',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Guidelines reminder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_information,
                        color: AppColors.accentDark, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Consultation Guidelines',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const _GuidelineItem(
                    'Review all patient-provided information thoroughly'),
                const _GuidelineItem(
                    'Include "when to seek emergency care" in every response'),
                const _GuidelineItem(
                    'Add disclaimer that this does not replace in-person exam'),
                const _GuidelineItem(
                    'Recommend follow-up tests if needed'),
                const _GuidelineItem(
                    'Respond within your stated response time'),
                const _GuidelineItem(
                    'If case is outside your scope, refer to appropriate specialist'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _openCase(BuildContext context, Map<String, dynamic> caseData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CaseReviewScreen(caseData: caseData),
      ),
    );
  }

  // Demo data — replaced by Firestore streams in production
  List<Map<String, dynamic>> _demoPendingCases() {
    return [
      {
        'id': 'demo-case-1',
        'patientName': 'Sarah J.',
        'patientAge': 28,
        'mainConcern': 'Thyroid levels seem off after pregnancy',
        'urgency': 'soon',
        'specialty': 'endocrinology',
        'status': 'submitted',
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'hasLabResults': true,
        'hasPhotos': false,
      },
      {
        'id': 'demo-case-2',
        'patientName': 'Mike T.',
        'patientAge': 0,
        'relationship': 'my child',
        'mainConcern': '3-month-old has a small lump near groin',
        'urgency': 'urgent',
        'specialty': 'pediatricSurgery',
        'status': 'submitted',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'hasLabResults': false,
        'hasPhotos': true,
      },
      {
        'id': 'demo-case-3',
        'patientName': 'Elena K.',
        'patientAge': 32,
        'mainConcern': 'Persistent fatigue and weight gain 6 months postpartum',
        'urgency': 'routine',
        'specialty': 'endocrinology',
        'status': 'submitted',
        'createdAt': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
        'hasLabResults': true,
        'hasPhotos': false,
      },
    ];
  }

  List<Map<String, dynamic>> _demoFollowUpCases() {
    return [
      {
        'id': 'demo-case-fu-1',
        'patientName': 'Anna M.',
        'mainConcern': 'TSH levels question',
        'urgency': 'routine',
        'followUpQuestion': 'Should I adjust my medication dose if symptoms improve?',
        'status': 'followUpAsked',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];
  }
}

// =========================================================
// WIDGETS
// =========================================================

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final IconData icon;
  const _SectionTitle({required this.title, this.subtitle, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        ),
        Icon(icon, color: color, size: 20),
      ],
    );
  }
}

class _CaseCard extends StatelessWidget {
  final Map<String, dynamic> caseData;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;
  const _CaseCard({required this.caseData, required this.badge, required this.badgeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(caseData['createdAt'] ?? '') ?? DateTime.now();
    final ago = DateTime.now().difference(createdAt);
    final agoStr = ago.inHours < 1
        ? '${ago.inMinutes}m ago'
        : ago.inHours < 24
            ? '${ago.inHours}h ago'
            : '${ago.inDays}d ago';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
                    ),
                  ),
                  const Spacer(),
                  Text(agoStr, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                caseData['patientName'] ?? 'Patient',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                caseData['mainConcern'] ?? '',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (caseData['hasLabResults'] == true)
                    _AttachmentChip(icon: Icons.science, label: 'Lab results'),
                  if (caseData['hasPhotos'] == true)
                    _AttachmentChip(icon: Icons.photo_camera, label: 'Photos'),
                  if (caseData['followUpQuestion'] != null)
                    _AttachmentChip(icon: Icons.reply, label: 'Follow-up'),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AttachmentChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.secondaryDark),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryDark)),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final String text;
  const _GuidelineItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.accentDark),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}

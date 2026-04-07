import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/consultation.dart';

/// What the patient sees after the doctor responds.
/// Shows: doctor's assessment, recommendations, follow-up tests,
/// emergency guidance, and option to ask 1 follow-up question.
class ConsultationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> consultationData;

  const ConsultationDetailScreen({
    super.key,
    required this.consultationData,
  });

  @override
  State<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  final _followUpController = TextEditingController();
  bool _showFollowUpInput = false;

  @override
  void dispose() {
    _followUpController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get c => widget.consultationData;
  Map<String, dynamic>? get response =>
      c['response'] as Map<String, dynamic>?;
  String? get status => c['status'] as String?;
  bool get canAskFollowUp =>
      status == ConsultationStatus.answered.name &&
      c['followUpQuestion'] == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Consultation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          _StatusBanner(status: status ?? 'submitted'),
          const SizedBox(height: 16),

          // Doctor info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                  child: const Icon(Icons.medical_services,
                      color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['doctorName'] ?? 'Your Doctor',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(c['specialty'] ?? '',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Your concern (what you submitted)
          _Section(
            title: 'Your Concern',
            icon: Icons.message_outlined,
            child: Text(
              c['mainConcern'] ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),

          // Doctor's response (if answered)
          if (response != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Doctor\'s Assessment',
              icon: Icons.medical_information,
              color: AppColors.secondary,
              child: Text(
                response!['assessment'] ?? '',
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Recommendations',
              icon: Icons.checklist,
              color: AppColors.success,
              child: Text(
                response!['recommendations'] ?? '',
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),

            if (response!['prescriptionNotes'] != null &&
                response!['prescriptionNotes'].isNotEmpty) ...[
              const SizedBox(height: 12),
              _Section(
                title: 'Medication Notes',
                icon: Icons.medication,
                child: Text(
                  response!['prescriptionNotes'],
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ],

            if (response!['followUpTests'] != null &&
                (response!['followUpTests'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              _Section(
                title: 'Recommended Follow-up Tests',
                icon: Icons.science,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (response!['followUpTests'] as List)
                      .map<Widget>((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.arrow_right,
                                    size: 18, color: AppColors.secondary),
                                Expanded(
                                    child: Text(t.toString(),
                                        style: const TextStyle(
                                            fontSize: 14, height: 1.4))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],

            if (response!['referralNote'] != null &&
                response!['referralNote'].isNotEmpty) ...[
              const SizedBox(height: 12),
              _Section(
                title: 'Referral',
                icon: Icons.swap_horiz,
                child: Text(
                  response!['referralNote'],
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ],

            // CRITICAL: When to seek emergency care
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emergency, color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'When to Seek Emergency Care',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    response!['whenToSeekEmergencyCare'] ?? '',
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                response!['disclaimer'] ??
                    'This assessment is based on the information provided and does not '
                        'replace an in-person examination. If symptoms worsen, please visit '
                        'your local healthcare provider.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textHint, height: 1.4),
              ),
            ),
          ],

          // Follow-up question section
          if (c['followUpQuestion'] != null) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Your Follow-up Question',
              icon: Icons.help_outline,
              color: AppColors.accent,
              child: Text(
                c['followUpQuestion'],
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            if (c['followUpAnswer'] != null) ...[
              const SizedBox(height: 12),
              _Section(
                title: 'Doctor\'s Answer',
                icon: Icons.reply,
                color: AppColors.secondary,
                child: Text(
                  c['followUpAnswer'],
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Waiting for doctor\'s response to your follow-up...',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],

          // Ask follow-up button
          if (canAskFollowUp && !_showFollowUpInput) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showFollowUpInput = true),
                icon: const Icon(Icons.reply),
                label: const Text('Ask a Follow-up Question (1 included)'),
              ),
            ),
          ],

          // Follow-up input
          if (_showFollowUpInput) ...[
            const SizedBox(height: 16),
            const Text(
              'Ask one follow-up question',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Be specific. The doctor will respond within 24-48 hours.',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _followUpController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Your follow-up question...',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _showFollowUpInput = false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_followUpController.text.trim().isEmpty) return;
                      // TODO: ConsultationService().askFollowUp(...)
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Follow-up Sent'),
                          content: const Text(
                            'Your doctor will respond within 24-48 hours.',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.pop();
                              },
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Send Question'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAnswered = status == 'answered' ||
        status == 'followUpAnswered' ||
        status == 'closed';
    final isFollowUpWaiting = status == 'followUpAsked';

    final color = isAnswered
        ? AppColors.success
        : isFollowUpWaiting
            ? AppColors.accent
            : AppColors.secondary;
    final icon = isAnswered
        ? Icons.check_circle
        : isFollowUpWaiting
            ? Icons.hourglass_top
            : Icons.schedule;
    final label = isAnswered
        ? 'Doctor has responded'
        : isFollowUpWaiting
            ? 'Waiting for follow-up answer'
            : 'Doctor is reviewing your case';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final Widget child;
  const _Section({
    required this.title,
    required this.icon,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style:
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

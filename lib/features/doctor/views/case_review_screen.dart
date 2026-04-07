import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The most critical screen in the app.
/// Doctor reads patient's full intake and writes their response.
///
/// Layout:
/// - Patient info summary at top
/// - Tabbed sections: Symptoms, History, Labs, Photos
/// - Response form at bottom (or follow-up answer)
class CaseReviewScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const CaseReviewScreen({super.key, required this.caseData});

  @override
  State<CaseReviewScreen> createState() => _CaseReviewScreenState();
}

class _CaseReviewScreenState extends State<CaseReviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Response form controllers
  final _assessmentController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _followUpTestsController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _referralController = TextEditingController();
  final _followUpAnswerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final isFollowUp = widget.caseData['status'] == 'followUpAsked';
    _tabController = TabController(
      length: isFollowUp ? 2 : 5,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _assessmentController.dispose();
    _recommendationsController.dispose();
    _prescriptionController.dispose();
    _followUpTestsController.dispose();
    _emergencyController.dispose();
    _referralController.dispose();
    _followUpAnswerController.dispose();
    super.dispose();
  }

  bool get _isFollowUp => widget.caseData['status'] == 'followUpAsked';

  @override
  Widget build(BuildContext context) {
    final c = widget.caseData;
    final urgency = c['urgency'] ?? 'routine';
    final urgencyColor = urgency == 'urgent'
        ? AppColors.error
        : urgency == 'soon'
            ? AppColors.warning
            : AppColors.secondary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(c['patientName'] ?? 'Patient Case'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: _isFollowUp
              ? const [
                  Tab(text: 'Follow-up'),
                  Tab(text: 'Original Case'),
                ]
              : const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Symptoms'),
                  Tab(text: 'History'),
                  Tab(text: 'Attachments'),
                  Tab(text: 'Respond'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _isFollowUp
            ? [
                _buildFollowUpTab(c),
                _buildOverviewTab(c, urgencyColor),
              ]
            : [
                _buildOverviewTab(c, urgencyColor),
                _buildSymptomsTab(c),
                _buildHistoryTab(c),
                _buildAttachmentsTab(c),
                _buildRespondTab(),
              ],
      ),
    );
  }

  // =========================================================
  // OVERVIEW TAB
  // =========================================================
  Widget _buildOverviewTab(Map<String, dynamic> c, Color urgencyColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Urgency badge
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                c['urgency'] == 'urgent'
                    ? Icons.warning
                    : Icons.access_time,
                color: urgencyColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(c['urgency'] ?? 'routine').toString().toUpperCase()} PRIORITY',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: urgencyColor,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c['urgency'] == 'urgent'
                          ? 'Please respond within 12 hours'
                          : c['urgency'] == 'soon'
                              ? 'Please respond within 24 hours'
                              : 'Please respond within 48 hours',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Patient info card
        _InfoCard(
          title: 'Patient Information',
          icon: Icons.person,
          rows: [
            _InfoRow('Name', c['patientName'] ?? '—'),
            _InfoRow('Age', '${c['patientAge'] ?? '—'}'),
            if (c['relationship'] != null)
              _InfoRow('Relationship', c['relationship']),
            _InfoRow('Specialty', c['specialty'] ?? '—'),
          ],
        ),
        const SizedBox(height: 12),

        // Main concern
        _InfoCard(
          title: 'Main Concern',
          icon: Icons.medical_services,
          children: [
            Text(
              c['mainConcern'] ?? 'No concern specified',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick indicators
        Row(
          children: [
            _Indicator(
              icon: Icons.science,
              label: 'Lab results',
              present: c['hasLabResults'] == true,
            ),
            const SizedBox(width: 10),
            _Indicator(
              icon: Icons.photo_camera,
              label: 'Photos',
              present: c['hasPhotos'] == true,
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // SYMPTOMS TAB
  // =========================================================
  Widget _buildSymptomsTab(Map<String, dynamic> c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Symptom Details',
          icon: Icons.healing,
          children: [
            _DetailBlock(
              label: 'Description',
              value: c['symptomDetails'] ??
                  'Patient describes: ${c['mainConcern'] ?? 'Not specified'}. '
                      'Symptoms have been ongoing. Please see lab results and photos for more context.',
            ),
            _DetailBlock(
              label: 'Duration',
              value: c['symptomDuration'] ?? 'Not specified',
            ),
            _DetailBlock(
              label: 'What patient has tried',
              value: c['whatTriedSoFar'] ??
                  'No mitigation efforts reported',
            ),
            _DetailBlock(
              label: 'Current medications',
              value: c['currentMedications'] ?? 'None reported',
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // HISTORY TAB
  // =========================================================
  Widget _buildHistoryTab(Map<String, dynamic> c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Medical History',
          icon: Icons.history,
          children: [
            _DetailBlock(
              label: 'Medical history',
              value: c['medicalHistory'] ?? 'No history provided',
            ),
            _DetailBlock(
              label: 'Allergies',
              value: c['allergies'] ?? 'None reported',
            ),
            _DetailBlock(
              label: 'Surgical history',
              value: c['surgicalHistory'] ?? 'None',
            ),
            _DetailBlock(
              label: 'Family history',
              value: c['familyHistory'] ?? 'Not provided',
            ),
            if (c['pregnancyWeek'] != null)
              _DetailBlock(
                label: 'Pregnancy week',
                value: 'Week ${c['pregnancyWeek']}',
              ),
            if (c['babyAgeMonths'] != null)
              _DetailBlock(
                label: 'Baby age',
                value: '${c['babyAgeMonths']} months',
              ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // ATTACHMENTS TAB
  // =========================================================
  Widget _buildAttachmentsTab(Map<String, dynamic> c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Lab results
        _InfoCard(
          title: 'Lab Results',
          icon: Icons.science,
          children: [
            if (c['hasLabResults'] == true)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science, size: 40, color: AppColors.textHint),
                      SizedBox(height: 8),
                      Text('Lab results attached',
                          style: TextStyle(color: AppColors.textSecondary)),
                      Text('Tap to view full size',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              )
            else
              const Text('No lab results uploaded',
                  style: TextStyle(color: AppColors.textHint)),
          ],
        ),
        const SizedBox(height: 12),

        // Photos
        _InfoCard(
          title: 'Patient Photos',
          icon: Icons.photo_camera,
          children: [
            if (c['hasPhotos'] == true)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera,
                          size: 40, color: AppColors.textHint),
                      SizedBox(height: 8),
                      Text('Photos attached',
                          style: TextStyle(color: AppColors.textSecondary)),
                      Text('Tap to view full size',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              )
            else
              const Text('No photos uploaded',
                  style: TextStyle(color: AppColors.textHint)),
          ],
        ),
        const SizedBox(height: 12),

        // Additional notes
        if (c['additionalNotes'] != null && c['additionalNotes'].isNotEmpty)
          _InfoCard(
            title: 'Additional Notes from Patient',
            icon: Icons.note,
            children: [
              Text(c['additionalNotes'],
                  style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
          ),
      ],
    );
  }

  // =========================================================
  // RESPOND TAB — Doctor writes their assessment
  // =========================================================
  Widget _buildRespondTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Warning
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.medical_information,
                  color: AppColors.error, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your response will be sent to the patient. Please be thorough, '
                  'compassionate, and include when to seek emergency care.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Assessment
        const _FormLabel(text: 'Clinical Assessment', required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _assessmentController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Based on the information provided, my assessment is...',
          ),
        ),
        const SizedBox(height: 16),

        // Recommendations
        const _FormLabel(text: 'Recommendations', required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _recommendationsController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'I recommend the following steps...',
          ),
        ),
        const SizedBox(height: 16),

        // Prescription notes
        const _FormLabel(text: 'Prescription / Medication Notes'),
        const SizedBox(height: 6),
        TextField(
          controller: _prescriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'If applicable: medication name, dosage, frequency, duration',
          ),
        ),
        const SizedBox(height: 16),

        // Follow-up tests
        const _FormLabel(text: 'Recommended Follow-up Tests'),
        const SizedBox(height: 6),
        TextField(
          controller: _followUpTestsController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., "Repeat TSH in 6 weeks", "Ultrasound of..."',
          ),
        ),
        const SizedBox(height: 16),

        // Referral
        const _FormLabel(text: 'Referral Note'),
        const SizedBox(height: 6),
        TextField(
          controller: _referralController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'If referring to another specialist...',
          ),
        ),
        const SizedBox(height: 16),

        // When to seek emergency care (REQUIRED)
        const _FormLabel(
            text: 'When to Seek Emergency Care', required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _emergencyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Go to the ER if you experience...',
          ),
        ),
        const SizedBox(height: 24),

        // Submit
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitResponse,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit Response to Patient',
                    style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A disclaimer will be automatically appended stating this does not '
          'replace an in-person examination.',
          style:
              TextStyle(fontSize: 11, color: AppColors.textHint, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // =========================================================
  // FOLLOW-UP TAB
  // =========================================================
  Widget _buildFollowUpTab(Map<String, dynamic> c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Patient's follow-up question
        _InfoCard(
          title: 'Patient\'s Follow-up Question',
          icon: Icons.help_outline,
          children: [
            Text(
              c['followUpQuestion'] ?? 'No question provided',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Doctor's answer
        const _FormLabel(text: 'Your Answer', required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _followUpAnswerController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Answer the patient\'s follow-up question thoroughly...',
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitFollowUp,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send Follow-up Answer',
                    style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _submitResponse() {
    if (_assessmentController.text.trim().isEmpty) {
      _showError('Assessment is required');
      return;
    }
    if (_recommendationsController.text.trim().isEmpty) {
      _showError('Recommendations are required');
      return;
    }
    if (_emergencyController.text.trim().isEmpty) {
      _showError('"When to seek emergency care" is required for patient safety');
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Call ConsultationService().submitResponse(...)
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Response Submitted'),
          content: const Text(
            'Your response has been sent to the patient. '
            'They will receive a notification.\n\n'
            'If the patient asks a follow-up question, '
            'you\'ll be notified.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      );
    });
  }

  void _submitFollowUp() {
    if (_followUpAnswerController.text.trim().isEmpty) {
      _showError('Please write your answer');
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Call ConsultationService().answerFollowUp(...)
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Follow-up Answer Sent'),
          content: const Text(
            'Your answer has been sent. This consultation is now complete.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// =========================================================
// SHARED WIDGETS
// =========================================================

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow>? rows;
  final List<Widget>? children;

  const _InfoCard({
    required this.title,
    required this.icon,
    this.rows,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
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
              Icon(icon, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          if (rows != null)
            ...rows!.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(r.label,
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textHint)),
                      ),
                      Expanded(
                        child: Text(r.value,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )),
          if (children != null) ...children!,
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _DetailBlock extends StatelessWidget {
  final String label;
  final String value;
  const _DetailBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool present;
  const _Indicator(
      {required this.icon, required this.label, required this.present});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: present
              ? AppColors.success.withValues(alpha: 0.08)
              : AppColors.divider.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: present
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: present ? AppColors.success : AppColors.textHint),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: present ? AppColors.success : AppColors.textHint,
              ),
            ),
            const Spacer(),
            Icon(
              present ? Icons.check_circle : Icons.remove_circle_outline,
              size: 18,
              color: present ? AppColors.success : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FormLabel({required this.text, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        if (required)
          const Text(' *',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/consultation_service.dart';
import '../../../shared/models/consultation.dart';
import '../../../l10n/app_localizations.dart';

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
        title: Text(c['patientName'] ?? L.of(context).patientCase),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: _isFollowUp
              ? [
                  Tab(text: L.of(context).followUp),
                  Tab(text: L.of(context).originalCase),
                ]
              : [
                  Tab(text: L.of(context).overview),
                  Tab(text: L.of(context).symptoms),
                  Tab(text: L.of(context).historyMedical),
                  Tab(text: L.of(context).attachments),
                  Tab(text: L.of(context).respond),
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
                      '${(c['urgency'] ?? 'routine').toString().toUpperCase()} ${L.of(context).priority}',
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
                          ? L.of(context).respondWithin12h
                          : c['urgency'] == 'soon'
                              ? L.of(context).respondWithin24h
                              : L.of(context).respondWithin48h,
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
          title: L.of(context).patientInformation,
          icon: Icons.person,
          rows: [
            _InfoRow(L.of(context).nameLabel, c['patientName'] ?? '—'),
            _InfoRow(L.of(context).ageLabel, '${c['patientAge'] ?? '—'}'),
            if (c['relationship'] != null)
              _InfoRow(L.of(context).relationship, c['relationship']),
            _InfoRow(L.of(context).specialty, c['specialty'] ?? '—'),
          ],
        ),
        const SizedBox(height: 12),

        // Main concern
        _InfoCard(
          title: L.of(context).mainConcern,
          icon: Icons.medical_services,
          children: [
            Text(
              c['mainConcern'] ?? L.of(context).noConcernSpecified,
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
              label: L.of(context).labResults,
              present: c['hasLabResults'] == true,
            ),
            const SizedBox(width: 10),
            _Indicator(
              icon: Icons.photo_camera,
              label: L.of(context).photos,
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
          title: L.of(context).symptomDetails,
          icon: Icons.healing,
          children: [
            _DetailBlock(
              label: L.of(context).description,
              value: c['symptomDetails'] ??
                  '${L.of(context).patientDescribes}: ${c['mainConcern'] ?? L.of(context).notSpecified}. '
                      '${L.of(context).symptomsOngoing}',
            ),
            _DetailBlock(
              label: L.of(context).duration,
              value: c['symptomDuration'] ?? L.of(context).notSpecified,
            ),
            _DetailBlock(
              label: L.of(context).whatPatientTried,
              value: c['whatTriedSoFar'] ??
                  L.of(context).noMitigationReported,
            ),
            _DetailBlock(
              label: L.of(context).currentMedications,
              value: c['currentMedications'] ?? L.of(context).noneReported,
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
          title: L.of(context).medicalHistory,
          icon: Icons.history,
          children: [
            _DetailBlock(
              label: L.of(context).medicalHistory,
              value: c['medicalHistory'] ?? L.of(context).noHistoryProvided,
            ),
            _DetailBlock(
              label: L.of(context).allergies,
              value: c['allergies'] ?? L.of(context).noneReported,
            ),
            _DetailBlock(
              label: L.of(context).surgicalHistory,
              value: c['surgicalHistory'] ?? L.of(context).none,
            ),
            _DetailBlock(
              label: L.of(context).familyHistory,
              value: c['familyHistory'] ?? L.of(context).notProvided,
            ),
            if (c['pregnancyWeek'] != null)
              _DetailBlock(
                label: L.of(context).pregnancyWeek,
                value: '${L.of(context).weekN(c['pregnancyWeek'])}',
              ),
            if (c['babyAgeMonths'] != null)
              _DetailBlock(
                label: L.of(context).babyAge,
                value: '${c['babyAgeMonths']} ${L.of(context).months}',
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
          title: L.of(context).labResults,
          icon: Icons.science,
          children: [
            if (c['hasLabResults'] == true)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.science, size: 40, color: AppColors.textHint),
                      const SizedBox(height: 8),
                      Text(L.of(context).labResultsAttached,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      Text(L.of(context).tapToViewFullSize,
                          style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              )
            else
              Text(L.of(context).noLabResultsUploaded,
                  style: const TextStyle(color: AppColors.textHint)),
          ],
        ),
        const SizedBox(height: 12),

        // Photos
        _InfoCard(
          title: L.of(context).patientPhotos,
          icon: Icons.photo_camera,
          children: [
            if (c['hasPhotos'] == true)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_camera,
                          size: 40, color: AppColors.textHint),
                      const SizedBox(height: 8),
                      Text(L.of(context).photosAttached,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      Text(L.of(context).tapToViewFullSize,
                          style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              )
            else
              Text(L.of(context).noPhotosUploaded,
                  style: const TextStyle(color: AppColors.textHint)),
          ],
        ),
        const SizedBox(height: 12),

        // Additional notes
        if (c['additionalNotes'] != null && c['additionalNotes'].isNotEmpty)
          _InfoCard(
            title: L.of(context).additionalNotesFromPatient,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.medical_information,
                  color: AppColors.error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  L.of(context).responseWarning,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Assessment
        _FormLabel(text: L.of(context).clinicalAssessment, required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _assessmentController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: L.of(context).assessmentHint,
          ),
        ),
        const SizedBox(height: 16),

        // Recommendations
        _FormLabel(text: L.of(context).recommendationsLabel, required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _recommendationsController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: L.of(context).recommendationsHint,
          ),
        ),
        const SizedBox(height: 16),

        // Prescription notes
        _FormLabel(text: L.of(context).prescriptionNotes),
        const SizedBox(height: 6),
        TextField(
          controller: _prescriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: L.of(context).prescriptionHint,
          ),
        ),
        const SizedBox(height: 16),

        // Follow-up tests
        _FormLabel(text: L.of(context).recommendedFollowUpTests),
        const SizedBox(height: 6),
        TextField(
          controller: _followUpTestsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: L.of(context).followUpTestsHint,
          ),
        ),
        const SizedBox(height: 16),

        // Referral
        _FormLabel(text: L.of(context).referralNote),
        const SizedBox(height: 6),
        TextField(
          controller: _referralController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: L.of(context).referralHint,
          ),
        ),
        const SizedBox(height: 16),

        // When to seek emergency care (REQUIRED)
        _FormLabel(
            text: L.of(context).whenToSeekEmergencyCare, required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _emergencyController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: L.of(context).emergencyCareHint,
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
                : Text(L.of(context).submitResponseToPatient,
                    style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          L.of(context).disclaimerAutoAppend,
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
          title: L.of(context).patientFollowUpQuestion,
          icon: Icons.help_outline,
          children: [
            Text(
              c['followUpQuestion'] ?? L.of(context).noQuestionProvided,
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
        _FormLabel(text: L.of(context).yourAnswer, required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _followUpAnswerController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: L.of(context).followUpAnswerHint,
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
                : Text(L.of(context).sendFollowUpAnswer,
                    style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _submitResponse() async {
    if (_assessmentController.text.trim().isEmpty) {
      _showError(L.of(context).assessmentRequired);
      return;
    }
    if (_recommendationsController.text.trim().isEmpty) {
      _showError(L.of(context).recommendationsRequired);
      return;
    }
    if (_emergencyController.text.trim().isEmpty) {
      _showError(L.of(context).emergencyCareRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    final response = DoctorResponse(
      assessment: _assessmentController.text.trim(),
      recommendations: _recommendationsController.text.trim(),
      prescriptionNotes: _prescriptionController.text.trim().isNotEmpty ? _prescriptionController.text.trim() : null,
      followUpTests: _followUpTestsController.text.trim().isNotEmpty
          ? _followUpTestsController.text.split(',').map((s) => s.trim()).toList()
          : [],
      referralNote: _referralController.text.trim().isNotEmpty ? _referralController.text.trim() : null,
      whenToSeekEmergencyCare: _emergencyController.text.trim(),
    );

    try {
      await ConsultationService().submitResponse(
        consultationId: widget.caseData['id'] ?? '',
        patientUid: widget.caseData['patientUid'] ?? '',
        response: response,
      );
    } catch (_) {
      // Demo mode — continue anyway
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(L.of(context).responseSubmitted),
        content: Text(
          L.of(context).responseSubmittedBody,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(L.of(context).backToDashboard),
          ),
        ],
      ),
    );
  }

  void _submitFollowUp() async {
    if (_followUpAnswerController.text.trim().isEmpty) {
      _showError(L.of(context).pleaseWriteAnswer);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ConsultationService().answerFollowUp(
        consultationId: widget.caseData['id'] ?? '',
        patientUid: widget.caseData['patientUid'] ?? '',
        answer: _followUpAnswerController.text.trim(),
      );
    } catch (_) {
      // Demo mode — continue anyway
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(L.of(context).followUpAnswerSent),
        content: Text(
          L.of(context).followUpAnswerSentBody,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(L.of(context).backToDashboard),
          ),
        ],
      ),
    );
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

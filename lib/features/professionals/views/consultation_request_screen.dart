import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/doctors_data.dart';
import '../../../core/services/consultation_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../shared/models/consultation.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/providers/journey_provider.dart';

/// Multi-step consultation request form.
///
/// Step 1: Who is this for? (self, child, partner)
/// Step 2: What's going on? (main concern, symptoms, duration)
/// Step 3: What have you tried? (medications, mitigation)
/// Step 4: Medical history (history, allergies, family)
/// Step 5: Upload evidence (lab results, photos)
/// Step 6: Review & pay
class ConsultationRequestScreen extends ConsumerStatefulWidget {
  final DoctorProfile doctor;

  const ConsultationRequestScreen({super.key, required this.doctor});

  @override
  ConsumerState<ConsultationRequestScreen> createState() =>
      _ConsultationRequestScreenState();
}

class _ConsultationRequestScreenState
    extends ConsumerState<ConsultationRequestScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  final _totalSteps = 6;

  // Step 1: Who
  String _relationship = 'my child';
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _sex = 'Female';

  // Step 2: What's wrong
  final _mainConcernController = TextEditingController();
  final _symptomDetailsController = TextEditingController();
  final _symptomDurationController = TextEditingController();

  // Step 3: What they've tried
  final _whatTriedController = TextEditingController();
  final _medicationsController = TextEditingController();

  // Step 4: History
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _familyHistoryController = TextEditingController();

  // Step 5: Uploads
  final List<String> _labResultUrls = [];
  final List<String> _photoUrls = [];
  final List<File> _labFiles = [];
  final List<File> _photoFiles = [];
  bool _isUploading = false;
  final _additionalNotesController = TextEditingController();

  // Step 6: Urgency
  ConsultationUrgency _urgency = ConsultationUrgency.routine;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _mainConcernController.dispose();
    _symptomDetailsController.dispose();
    _symptomDurationController.dispose();
    _whatTriedController.dispose();
    _medicationsController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _familyHistoryController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${L.of(context).consult} ${doctor.fullName}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      L.of(context).stepOf(_currentStep + 1, _totalSteps),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Steps
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1Who(),
                _buildStep2WhatsWrong(),
                _buildStep3WhatTried(),
                _buildStep4History(),
                _buildStep5Uploads(),
                _buildStep6Review(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      child: Text(L.of(context).back),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : _currentStep == _totalSteps - 1
                            ? _submit
                            : _nextStep,
                    child: _isUploading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? '${L.of(context).submitAndPay} ${doctor.priceFormatted}'
                                : L.of(context).continueButton,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STEP 1: WHO IS THIS FOR?
  // =========================================================
  Widget _buildStep1Who() {
    return _StepBody(
      title: L.of(context).whoIsConsultationFor,
      children: [
        _ChoiceRow(
          options: [L.of(context).selfOption, L.of(context).myChild, L.of(context).myPartner],
          selected: _relationship,
          onSelect: (v) => setState(() => _relationship = v.toLowerCase()),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: L.of(context).patientName,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _relationship == 'my child'
                      ? L.of(context).ageMonths
                      : L.of(context).ageYears,
                  prefixIcon: const Icon(Icons.cake_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L.of(context).sex,
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.textHint)),
                  const SizedBox(height: 8),
                  _ChoiceRow(
                    options: [L.of(context).female, L.of(context).male],
                    selected: _sex,
                    onSelect: (v) => setState(() => _sex = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // STEP 2: WHAT'S GOING ON?
  // =========================================================
  Widget _buildStep2WhatsWrong() {
    final reqs = IntakeRequirements.forSpecialty(widget.doctor.specialty);
    return _StepBody(
      title: L.of(context).whatsGoingOn,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.of(context).whatDoctorNeeds(widget.doctor.fullName),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              ...reqs.take(3).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                            child:
                                Text(r.of(context), style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _mainConcernController,
          decoration: InputDecoration(
            labelText: L.of(context).mainConcernLabel,
            hintText: L.of(context).mainConcernHint,
            prefixIcon: const Icon(Icons.medical_services_outlined),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _symptomDetailsController,
          decoration: InputDecoration(
            labelText: L.of(context).describeSymptomsLabel,
            hintText: L.of(context).describeSymptomsHint,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _symptomDurationController,
          decoration: InputDecoration(
            labelText: L.of(context).howLongLabel,
            hintText: L.of(context).howLongHint,
            prefixIcon: const Icon(Icons.timer_outlined),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STEP 3: WHAT HAVE YOU TRIED?
  // =========================================================
  Widget _buildStep3WhatTried() {
    return _StepBody(
      title: L.of(context).whatHaveYouTried,
      children: [
        TextField(
          controller: _whatTriedController,
          decoration: InputDecoration(
            labelText: L.of(context).whatDoneToAddress,
            hintText: L.of(context).whatDoneHint,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _medicationsController,
          decoration: InputDecoration(
            labelText: L.of(context).currentMedsSupplements,
            hintText: L.of(context).currentMedsHint,
            prefixIcon: const Icon(Icons.medication_outlined),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // =========================================================
  // STEP 4: MEDICAL HISTORY
  // =========================================================
  Widget _buildStep4History() {
    return _StepBody(
      title: L.of(context).medicalHistory,
      children: [
        TextField(
          controller: _medicalHistoryController,
          decoration: InputDecoration(
            labelText: L.of(context).medicalHistory,
            hintText: L.of(context).medicalHistoryHint,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _allergiesController,
          decoration: InputDecoration(
            labelText: L.of(context).allergies,
            hintText: L.of(context).allergiesHint,
            prefixIcon: const Icon(Icons.warning_amber),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _familyHistoryController,
          decoration: InputDecoration(
            labelText: L.of(context).relevantFamilyHistory,
            hintText: L.of(context).familyHistoryHint,
            prefixIcon: const Icon(Icons.family_restroom),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  // =========================================================
  // STEP 5: UPLOADS
  // =========================================================
  Widget _buildStep5Uploads() {
    return _StepBody(
      title: L.of(context).uploadEvidence,
      children: [
        // Lab results
        _UploadSection(
          title: L.of(context).labResults,
          icon: Icons.science_outlined,
          subtitle: L.of(context).labResultsSubtitle,
          urls: _labResultUrls,
          files: _labFiles,
          onAdd: () async {
            final file = await StorageService().showPickerSheet(context);
            if (file != null) {
              setState(() {
                _labFiles.add(file);
                _labResultUrls.add(file.path);
              });
            }
          },
          onRemove: (i) => setState(() {
            _labFiles.removeAt(i);
            _labResultUrls.removeAt(i);
          }),
        ),
        const SizedBox(height: 14),
        // Photos
        _UploadSection(
          title: L.of(context).photos,
          icon: Icons.camera_alt_outlined,
          subtitle: L.of(context).photosSubtitle,
          urls: _photoUrls,
          files: _photoFiles,
          onAdd: () async {
            final file = await StorageService().showPickerSheet(context);
            if (file != null) {
              setState(() {
                _photoFiles.add(file);
                _photoUrls.add(file.path);
              });
            }
          },
          onRemove: (i) => setState(() {
            _photoFiles.removeAt(i);
            _photoUrls.removeAt(i);
          }),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _additionalNotesController,
          decoration: InputDecoration(
            labelText: L.of(context).anythingElseDoctor,
            hintText: L.of(context).additionalContextHint,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // =========================================================
  // STEP 6: REVIEW & PAY
  // =========================================================
  Widget _buildStep6Review() {
    final doctor = widget.doctor;
    return _StepBody(
      title: L.of(context).reviewAndSubmit,
      children: [
        // Doctor card
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
                radius: 24,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                child: Text(
                  doctor.fullName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(doctor.specialty.label.of(context),
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textHint)),
                  ],
                ),
              ),
              Text(
                doctor.priceFormatted,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Urgency
        Text(L.of(context).urgency,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        ...ConsultationUrgency.values.map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: _urgency == u
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _urgency = u),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _urgency == u
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _urgency == u
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _urgency == u
                              ? AppColors.primary
                              : AppColors.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(u.description,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),

        const SizedBox(height: 16),
        // Summary
        _SummaryRow(label: L.of(context).patient, value: _nameController.text),
        _SummaryRow(label: L.of(context).concern, value: _mainConcernController.text),
        _SummaryRow(
            label: L.of(context).attachments,
            value: L.of(context).labsAndPhotosCount(_labResultUrls.length, _photoUrls.length)),
        _SummaryRow(label: L.of(context).responseTime, value: doctor.responseTime.of(context)),
        const SizedBox(height: 12),

        // What's included
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L.of(context).includedInConsultation,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              _IncludedItem(L.of(context).includedCaseReview),
              _IncludedItem(L.of(context).includedAssessment),
              _IncludedItem(L.of(context).includedFollowUp),
              _IncludedItem(L.of(context).includedEmergencyGuidance),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Text(
          L.of(context).submitDisclaimer,
          style:
              TextStyle(fontSize: 11, color: AppColors.textHint, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _submit() async {
    final doctor = widget.doctor;

    // Step 1: Process payment via RevenueCat IAP
    setState(() => _isUploading = true);
    final purchaseResult = await PaymentService().purchaseConsultation(
      priceUsd: doctor.consultationPrice,
    );

    if (!mounted) return;
    if (!purchaseResult.success) {
      setState(() => _isUploading = false);
      if (purchaseResult.error != null && purchaseResult.error != 'Purchase cancelled.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(purchaseResult.error!), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    // Step 2: Upload files & create consultation
    final profile = ref.read(userProfileProvider);
    final consultId = 'consult-${DateTime.now().millisecondsSinceEpoch}';

    // Upload files to Firebase Storage
    final uploadedLabUrls = <String>[];
    for (var i = 0; i < _labFiles.length; i++) {
      final url = await StorageService().uploadConsultationFile(
        file: _labFiles[i],
        consultationId: consultId,
        type: 'labs',
        index: i,
      );
      if (url != null) uploadedLabUrls.add(url);
    }

    final uploadedPhotoUrls = <String>[];
    for (var i = 0; i < _photoFiles.length; i++) {
      final url = await StorageService().uploadConsultationFile(
        file: _photoFiles[i],
        consultationId: consultId,
        type: 'photos',
        index: i,
      );
      if (url != null) uploadedPhotoUrls.add(url);
    }

    if (!mounted) return;
    setState(() => _isUploading = false);

    final consultation = Consultation(
      id: consultId,
      patientUid: profile.uid,
      doctorUid: doctor.uid,
      doctorName: doctor.fullName,
      specialty: doctor.specialty,
      status: ConsultationStatus.submitted,
      urgency: _urgency,
      createdAt: DateTime.now(),
      intake: PatientIntake(
        patientName: _nameController.text,
        patientAge: int.tryParse(_ageController.text) ?? 0,
        patientSex: _sex,
        relationship: _relationship,
        mainConcern: _mainConcernController.text,
        symptomDetails: _symptomDetailsController.text,
        symptomDuration: _symptomDurationController.text,
        whatTriedSoFar: _whatTriedController.text,
        currentMedications: _medicationsController.text.isNotEmpty
            ? _medicationsController.text.split(',').map((s) => s.trim()).toList()
            : [],
        medicalHistory: _medicalHistoryController.text,
        allergies: _allergiesController.text,
        familyHistory: _familyHistoryController.text,
        labResultUrls: uploadedLabUrls,
        photoUrls: uploadedPhotoUrls,
        additionalNotes: _additionalNotesController.text,
        pregnancyWeek: profile.currentWeek,
        babyAgeMonths: profile.babyAgeMonths,
      ),
      pricePaid: doctor.consultationPrice,
      currency: doctor.currency,
      paymentId: purchaseResult.transactionId,
    );

    try {
      await ConsultationService().submitConsultation(consultation);
    } catch (_) {
      // Demo mode — continue anyway
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(L.of(context).consultationSubmitted),
        content: Text(
          L.of(context).consultationSubmittedBody(doctor.fullName, doctor.responseTime.of(context).toLowerCase()),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: Text(L.of(context).gotIt),
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(L.of(context).discardConsultation),
        content: Text(
          L.of(context).progressWillBeLost,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(L.of(context).keepEditing),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(L.of(context).discard),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// SHARED WIDGETS
// =========================================================

class _StepBody extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _StepBody({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          ...children,
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ChoiceRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = selected.toLowerCase() == o.toLowerCase();
        return GestureDetector(
          onTap: () => onSelect(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Text(
              o,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UploadSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final List<String> urls;
  final List<File>? files;
  final VoidCallback onAdd;
  final ValueChanged<int>? onRemove;

  const _UploadSection({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.urls,
    this.files,
    required this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textHint)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: Text(L.of(context).add),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          if (urls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: urls.length,
                itemBuilder: (context, i) {
                  final hasFile = files != null && i < files!.length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasFile
                              ? Image.file(files![i], fit: BoxFit.cover)
                              : Center(
                                  child: Icon(Icons.insert_drive_file,
                                      color: AppColors.textHint, size: 28),
                                ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => onRemove?.call(i),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: AppColors.textHint)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncludedItem extends StatelessWidget {
  final String text;
  const _IncludedItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

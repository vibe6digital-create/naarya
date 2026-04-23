import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/medical_record_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/medical_record_model.dart';

enum _UploadMode { photos, document }

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // ── Section 1 ─────────────────────────────────────────────────────────────
  RecordType _type = RecordType.prescription;
  DateTime _recordDate = DateTime.now();

  // ── Section 2: Upload ─────────────────────────────────────────────────────
  _UploadMode _uploadMode = _UploadMode.photos;
  XFile? _selectedImage;
  fp.PlatformFile? _selectedDocument;
  final _picker = ImagePicker();

  // ── Section 3: Health Details ─────────────────────────────────────────────
  final _symptomsCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  Severity _severity = Severity.mild;
  DateTime? _followUpDate;

  // ── Upload state ─────────────────────────────────────────────────────────
  bool _isUploading = false;
  double _uploadProgress = 0;
  String _uploadStatusText = 'Uploading...';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _doctorCtrl.dispose();
    _hospitalCtrl.dispose();
    _notesCtrl.dispose();
    _symptomsCtrl.dispose();
    _diagnosisCtrl.dispose();
    _treatmentCtrl.dispose();
    _medicationsCtrl.dispose();
    super.dispose();
  }

  // ─── Image picking ────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 85);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _pickDocument() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedDocument = result.files.first);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Photo', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _sheetTile(
                icon: Icons.camera_alt_outlined,
                color: AppColors.primary,
                title: 'Take a photo',
                subtitle: 'Capture prescription with camera',
                onTap: () { Navigator.pop(ctx); _pickFromCamera(); },
              ),
              const SizedBox(height: 6),
              _sheetTile(
                icon: Icons.photo_library_outlined,
                color: AppColors.info,
                title: 'Choose from gallery',
                subtitle: 'Select an image from your library',
                onTap: () { Navigator.pop(ctx); _pickFromGallery(); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: AppTextStyles.subtitle1),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      onTap: onTap,
    );
  }

  // ─── Date pickers ─────────────────────────────────────────────────────────

  Future<void> _pickRecordDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: _dateTheme,
    );
    if (picked != null) setState(() => _recordDate = picked);
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: _dateTheme,
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  Widget _dateTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
      ),
      child: child!,
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isUploading = true; _uploadProgress = 0; });

    try {
      final recordId = const Uuid().v4();
      final userId = FirebaseAuthService.currentUser?.uid ?? 'anonymous';

      String? fileUrl;
      String? storagePath;
      FileType? fileType;

      if (_uploadMode == _UploadMode.photos && _selectedImage != null) {
        setState(() => _uploadStatusText = 'Uploading image...');
        final result = await MedicalRecordService.uploadImage(
          image: _selectedImage!,
          recordId: recordId,
          userId: userId,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
        if (result != null) {
          fileUrl = result.$1;
          storagePath = result.$2;
          fileType = FileType.image;
        }
      } else if (_uploadMode == _UploadMode.document &&
          _selectedDocument != null) {
        setState(() => _uploadStatusText = 'Uploading document...');
        final result = await MedicalRecordService.uploadDocument(
          file: _selectedDocument!,
          recordId: recordId,
          userId: userId,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
        if (result != null) {
          fileUrl = result.$1;
          storagePath = result.$2;
          fileType = FileType.pdf;
        }
      }

      setState(() => _uploadStatusText = 'Saving to your vault...');

      final healthDetails = HealthProblemDetails(
        symptoms: _symptomsCtrl.text.trim().isNotEmpty
            ? _symptomsCtrl.text.trim()
            : null,
        diagnosis: _diagnosisCtrl.text.trim().isNotEmpty
            ? _diagnosisCtrl.text.trim()
            : null,
        treatmentPlan: _treatmentCtrl.text.trim().isNotEmpty
            ? _treatmentCtrl.text.trim()
            : null,
        medications: _medicationsCtrl.text.trim().isNotEmpty
            ? _medicationsCtrl.text.trim()
            : null,
        severity: _severity,
        followUpDate: _followUpDate,
      );

      final now = DateTime.now();
      final record = MedicalRecord(
        id: recordId,
        title: _titleCtrl.text.trim(),
        type: _type,
        doctor: _doctorCtrl.text.trim().isNotEmpty
            ? _doctorCtrl.text.trim()
            : null,
        hospital: _hospitalCtrl.text.trim().isNotEmpty
            ? _hospitalCtrl.text.trim()
            : null,
        date: _formatDate(_recordDate),
        fileUrl: fileUrl,
        fileType: fileType,
        storagePath: storagePath,
        tags: const [],
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        createdAt: now,
        updatedAt: now,
        userId: userId,
        healthDetails: healthDetails.isEmpty ? null : healthDetails,
      );

      await MedicalRecordService.saveRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Record saved to your health vault!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
        Navigator.of(context).pop(record);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        _showError('Upload failed: ${e.toString()}');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Medical Record', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: _isUploading ? _buildUploadingState() : _buildForm(),
    );
  }

  Widget _buildUploadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                value: _uploadProgress > 0 ? _uploadProgress : null,
                color: AppColors.primary,
                strokeWidth: 5,
              ),
            ),
            const SizedBox(height: 28),
            Text(_uploadStatusText, style: AppTextStyles.subtitle1,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            if (_uploadProgress > 0)
              Text('${(_uploadProgress * 100).toInt()}% complete',
                  style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection1BasicInfo(),
            const SizedBox(height: 16),
            _buildSection2Upload(),
            const SizedBox(height: 16),
            _buildSection3HealthDetails(),
            const SizedBox(height: 28),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 1 — Basic Information
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSection1BasicInfo() {
    return _sectionCard(
      sectionNumber: '1',
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          _fieldLabel('Record Title *'),
          TextFormField(
            controller: _titleCtrl,
            decoration: _inputDeco('e.g. Gynecology Prescription – Jan 2026'),
            style: AppTextStyles.body1,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter a title' : null,
          ),

          const SizedBox(height: 16),

          // Type
          _fieldLabel('Record Type *'),
          DropdownButtonFormField<RecordType>(
            initialValue: _type,
            decoration: _inputDeco(null),
            style: AppTextStyles.body1,
            items: RecordType.values
                .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(_typeLabel(t), style: AppTextStyles.body1)))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _type = v); },
          ),

          const SizedBox(height: 16),

          // Date
          _fieldLabel('Record Date *'),
          InkWell(
            onTap: _pickRecordDate,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: _dateField(
              icon: Icons.calendar_today,
              value: _formatDate(_recordDate),
            ),
          ),

          const SizedBox(height: 16),

          // Doctor name
          _fieldLabel('Doctor Name (optional)'),
          TextFormField(
            controller: _doctorCtrl,
            decoration: _inputDeco('e.g. Dr. Priya Sharma'),
            style: AppTextStyles.body1,
          ),

          const SizedBox(height: 16),

          // Hospital
          _fieldLabel('Hospital / Clinic (optional)'),
          TextFormField(
            controller: _hospitalCtrl,
            decoration: _inputDeco('e.g. Apollo Hospitals, Mumbai'),
            style: AppTextStyles.body1,
          ),

          const SizedBox(height: 16),

          // Notes
          _fieldLabel('Additional Notes (optional)'),
          TextFormField(
            controller: _notesCtrl,
            decoration: _inputDeco('Any extra notes about this record'),
            style: AppTextStyles.body1,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 2 — Upload Files
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSection2Upload() {
    return _sectionCard(
      sectionNumber: '2',
      title: 'Upload Files',
      icon: Icons.upload_file_outlined,
      subtitle: 'Optional — attach a photo or document',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle: Photos vs Document
          Row(
            children: [
              Expanded(
                child: _uploadModeToggle(
                  label: 'Photo',
                  icon: Icons.photo_camera_outlined,
                  mode: _UploadMode.photos,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _uploadModeToggle(
                  label: 'Document',
                  icon: Icons.picture_as_pdf_outlined,
                  mode: _UploadMode.document,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content based on mode
          if (_uploadMode == _UploadMode.photos)
            _buildImagePickerSection()
          else
            _buildDocumentPickerSection(),
        ],
      ),
    );
  }

  Widget _uploadModeToggle({
    required String label,
    required IconData icon,
    required _UploadMode mode,
  }) {
    final isSelected = _uploadMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _uploadMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    if (_selectedImage == null) {
      return GestureDetector(
        onTap: _showImageSourceSheet,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 52, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Tap to add a prescription photo',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Camera · Gallery',
                  style: AppTextStyles.caption, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Image.file(
            File(_selectedImage!.path),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _selectedImage = null),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPickerSection() {
    if (_selectedDocument == null) {
      return GestureDetector(
        onTap: _pickDocument,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(Icons.upload_file_outlined,
                  size: 52, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Tap to select a document',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Supports PDF, DOC, DOCX',
                  style: AppTextStyles.caption, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final sizeKB = (_selectedDocument!.size / 1024).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.picture_as_pdf, color: AppColors.info, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedDocument!.name,
                    style: AppTextStyles.subtitle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('$sizeKB KB',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.close, color: AppColors.textMuted, size: 20),
            onPressed: () => setState(() => _selectedDocument = null),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 3 — Health Problem Details
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSection3HealthDetails() {
    return _sectionCard(
      sectionNumber: '3',
      title: 'Health Problem Details',
      icon: Icons.medical_information_outlined,
      subtitle: 'Optional — fill what you know for better records',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symptoms
          _fieldLabel('Symptoms'),
          TextFormField(
            controller: _symptomsCtrl,
            decoration: _inputDeco('e.g. Irregular periods, fatigue, bloating'),
            style: AppTextStyles.body1,
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // Diagnosis
          _fieldLabel('Diagnosis'),
          TextFormField(
            controller: _diagnosisCtrl,
            decoration: _inputDeco('e.g. PCOS, Iron Deficiency Anaemia'),
            style: AppTextStyles.body1,
          ),

          const SizedBox(height: 16),

          // Treatment Plan
          _fieldLabel('Treatment Plan'),
          TextFormField(
            controller: _treatmentCtrl,
            decoration:
                _inputDeco('e.g. Lifestyle changes, hormonal therapy'),
            style: AppTextStyles.body1,
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // Medications
          _fieldLabel('Medications Prescribed'),
          TextFormField(
            controller: _medicationsCtrl,
            decoration: _inputDeco(
                'e.g. Metformin 500mg twice daily, Ferrous Sulphate'),
            style: AppTextStyles.body1,
            maxLines: 2,
          ),

          const SizedBox(height: 20),

          // Severity
          _fieldLabel('Severity'),
          const SizedBox(height: 8),
          Row(
            children: Severity.values.map((s) {
              final isSelected = _severity == s;
              final color = _severityColor(s);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(_severityIcon(s),
                              color: isSelected
                                  ? color
                                  : AppColors.textMuted,
                              size: 20),
                          const SizedBox(height: 4),
                          Text(
                            _severityLabel(s),
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected ? color : AppColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Follow-up date
          _fieldLabel('Follow-up Date (optional)'),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickFollowUpDate,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: _dateField(
              icon: Icons.event_available_outlined,
              value: _followUpDate != null
                  ? _formatDate(_followUpDate!)
                  : 'Select follow-up date',
              muted: _followUpDate == null,
              trailing: _followUpDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: AppColors.textMuted),
                      onPressed: () =>
                          setState(() => _followUpDate = null),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Save button ──────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _onSave,
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('Save & Upload to Health Vault'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }

  // ─── Common widgets ───────────────────────────────────────────────────────

  Widget _sectionCard({
    required String sectionNumber,
    required String title,
    required IconData icon,
    required Widget child,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                topRight: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      sectionNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(title,
                              style: AppTextStyles.subtitle1.copyWith(
                                  color: AppColors.primary)),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: AppTextStyles.subtitle2),
    );
  }

  Widget _dateField({
    required IconData icon,
    required String value,
    bool muted = false,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body1.copyWith(
                color: muted ? AppColors.textMuted : AppColors.textBody,
              ),
            ),
          ),
          trailing ??
              const Icon(Icons.arrow_drop_down,
                  color: AppColors.textMuted),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String? hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: BorderSide(color: AppColors.error),
        ),
      );

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}';

  String _monthName(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  String _typeLabel(RecordType t) {
    switch (t) {
      case RecordType.prescription:  return 'Prescription';
      case RecordType.report:        return 'Lab Report';
      case RecordType.scan:          return 'Scan / Imaging';
      case RecordType.vaccination:   return 'Vaccination Record';
      case RecordType.consultation:  return 'Consultation Notes';
      case RecordType.other:         return 'Other';
    }
  }

  Color _severityColor(Severity s) {
    switch (s) {
      case Severity.mild:     return AppColors.success;
      case Severity.moderate: return AppColors.warning;
      case Severity.severe:   return AppColors.error;
    }
  }

  IconData _severityIcon(Severity s) {
    switch (s) {
      case Severity.mild:     return Icons.sentiment_satisfied_alt;
      case Severity.moderate: return Icons.sentiment_neutral;
      case Severity.severe:   return Icons.sentiment_very_dissatisfied;
    }
  }

  String _severityLabel(Severity s) {
    switch (s) {
      case Severity.mild:     return 'Mild';
      case Severity.moderate: return 'Moderate';
      case Severity.severe:   return 'Severe';
    }
  }
}

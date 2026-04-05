import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/medical_record_model.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  RecordCategory _selectedCategory = RecordCategory.report;
  String? _selectedFileName;
  String? _selectedFilePath;

  static final _uuid = const Uuid();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'heic'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFileName = result.files.first.name;
        _selectedFilePath = result.files.first.path ?? result.files.first.name;
      });
    }
  }

  void _saveRecord() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a document')),
      );
      return;
    }

    final record = MedicalRecord(
      id: _uuid.v4(),
      title: _titleController.text.trim(),
      category: _selectedCategory,
      filePath: _selectedFilePath!,
      dateAdded: DateTime.now(),
      doctorName: _doctorController.text.trim().isNotEmpty
          ? _doctorController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    Navigator.of(context).pop(record);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Record', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text('Title', style: AppTextStyles.subtitle2),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Blood Test Report'),
                style: AppTextStyles.body1,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Category dropdown
              Text('Category', style: AppTextStyles.subtitle2),
              const SizedBox(height: 8),
              DropdownButtonFormField<RecordCategory>(
                initialValue: _selectedCategory,
                decoration: _inputDecoration(null),
                style: AppTextStyles.body1,
                items: RecordCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_categoryLabel(cat)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Doctor name (optional)
              Text('Doctor Name (optional)', style: AppTextStyles.subtitle2),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doctorController,
                decoration: _inputDecoration('e.g. Dr. Priya Sharma'),
                style: AppTextStyles.body1,
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Notes (optional)
              Text('Notes (optional)', style: AppTextStyles.subtitle2),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration('Add any notes about this record'),
                style: AppTextStyles.body1,
                maxLines: 3,
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // File picker
              Text('Upload Document', style: AppTextStyles.subtitle2),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFileName != null
                            ? Icons.check_circle_outline
                            : Icons.cloud_upload_outlined,
                        size: 40,
                        color: _selectedFileName != null
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName != null
                            ? _selectedFileName!
                            : 'Tap to upload PDF or Image',
                        style: AppTextStyles.body2.copyWith(
                          color: _selectedFileName != null
                              ? AppColors.textBody
                              : AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_selectedFileName == null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Supports PDF, JPG, PNG, HEIC',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                  child: const Text('Save Record'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        borderSide: BorderSide(color: AppColors.error),
      ),
    );
  }

  String _categoryLabel(RecordCategory category) {
    switch (category) {
      case RecordCategory.report:
        return 'Lab Report';
      case RecordCategory.prescription:
        return 'Prescription';
      case RecordCategory.scan:
        return 'Scan Report';
      case RecordCategory.other:
        return 'Other';
    }
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String _selectedCity = 'Indore';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: LocalStorageService.userName);
    final age = LocalStorageService.userAge;
    _ageController = TextEditingController(text: age > 0 ? age.toString() : '');
    _selectedCity = LocalStorageService.userCity.isNotEmpty
        ? LocalStorageService.userCity
        : 'Indore';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await LocalStorageService.setUserName(_nameController.text.trim());
    await LocalStorageService.setUserCity(_selectedCity);

    final ageText = _ageController.text.trim();
    if (ageText.isNotEmpty) {
      await LocalStorageService.setUserAge(int.parse(ageText));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully!',
            style: AppTextStyles.body2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // Name Field
              Text('Name', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.body1,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle:
                      AppTextStyles.body1.copyWith(color: AppColors.textLight),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Age Field
              Text('Age', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _ageController,
                style: AppTextStyles.body1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                  hintStyle:
                      AppTextStyles.body1.copyWith(color: AppColors.textLight),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final age = int.tryParse(value.trim());
                    if (age == null || age < 10 || age > 100) {
                      return 'Please enter a valid age (10-100)';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // City Dropdown
              Text('City', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                style: AppTextStyles.body1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textMuted),
                dropdownColor: AppColors.surface,
                items: AppConstants.cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city, style: AppTextStyles.body1),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCity = value);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Save Profile', style: AppTextStyles.button),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../content_pages/content_page_screen.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userCity = '';
  String _userPhone = '';
  String _userEmail = '';
  String _userPhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userName = LocalStorageService.userName;
      _userCity = LocalStorageService.userCity;
      _userPhone = LocalStorageService.userPhone;
      _userEmail = LocalStorageService.userEmail;
      _userPhotoUrl = LocalStorageService.userPhotoUrl;
    });
  }

  String get _userInitial {
    if (_userName.isNotEmpty) return _userName[0].toUpperCase();
    return 'N';
  }

  void _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    _loadUserData();
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContentPageScreen(
          title: 'Privacy Policy',
          assetPath: AssetPaths.privacyPolicy,
        ),
      ),
    );
  }

  void _navigateToTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContentPageScreen(
          title: 'Terms & Conditions',
          assetPath: AssetPaths.termsConditions,
        ),
      ),
    );
  }

  void _showContactEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Write to us at ${AppConstants.contactEmail}',
          style: AppTextStyles.body2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
    );
  }

  void _showRateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thank you for your support! Rating will be available soon.',
          style: AppTextStyles.body2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text('Logout', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.subtitle2.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuthService.signOut();
              await LocalStorageService.clear();
              await LocalStorageService.setLoggedIn(false);
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: Text(
              'Logout',
              style: AppTextStyles.subtitle2.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              color: AppColors.surface,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    backgroundImage: _userPhotoUrl.isNotEmpty
                        ? NetworkImage(_userPhotoUrl)
                        : null,
                    child: _userPhotoUrl.isEmpty
                        ? Text(
                            _userInitial,
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _userName.isNotEmpty ? _userName : 'User',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (_userEmail.isNotEmpty)
                    Text(
                      _userEmail,
                      style: AppTextStyles.subtitle2,
                    ),
                  if (_userCity.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _userCity,
                      style: AppTextStyles.caption,
                    ),
                  ],
                  if (_userPhone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _userPhone,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Settings List
            Container(
              color: AppColors.surface,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: _navigateToEditProfile,
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.folder_shared_outlined,
                    title: 'Medical Records',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.healthVault),
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.flight_takeoff_outlined,
                    title: 'Travel Health',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.travellingHealth),
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Safety',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.safety),
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Naarya',
                    onTap: _navigateToAbout,
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: _navigateToPrivacyPolicy,
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: _navigateToTerms,
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Contact Us',
                    onTap: _showContactEmail,
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 56),
                  _SettingsTile(
                    icon: Icons.star_outline,
                    title: 'Rate App',
                    onTap: _showRateApp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Logout
            Container(
              color: AppColors.surface,
              child: _SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                onTap: _confirmLogout,
                iconColor: AppColors.error,
                textColor: AppColors.error,
              ),
            ),

            // Version
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textBody,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle1.copyWith(
          color: textColor ?? AppColors.textDark,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor ?? AppColors.textLight,
        size: 22,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

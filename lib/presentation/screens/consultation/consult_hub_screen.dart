import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/services/doctor_service.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/doctor_model.dart';

class ConsultHubScreen extends StatelessWidget {
  const ConsultHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Consult a Doctor', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: _DoctorsSection(),
    );
  }
}

// ─── Doctors Section ─────────────────────────────────────────────────────────

class _DoctorsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DoctorModel>>(
      stream: DoctorService.doctorsStream(),
      builder: (context, snapshot) {
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final doctors = snapshot.data ?? [];
        final isEmpty = !isLoading && !hasError && doctors.isEmpty;

        if (isLoading) return _buildSkeletonList();

        if (hasError) {
          return _buildMessageState(
            icon: Icons.wifi_off_outlined,
            message:
                'Could not load doctors.\nCheck Firestore security rules.',
            color: AppColors.warning,
          );
        }

        if (isEmpty) {
          return _buildMessageState(
            icon: Icons.person_add_outlined,
            message:
                'No doctors added yet.\nAdd doctors in Firebase Console → "doctors" collection.',
            color: AppColors.textLight,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: doctors.length,
          separatorBuilder: (_, i) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => _DoctorCard(doctor: doctors[i]),
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: 3,
      separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) => _DoctorCardSkeleton(),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Doctor Card ─────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + info ────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: AppTextStyles.subtitle1.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doctor.degree,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Specialty + mode chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _chip(
                            label: doctor.specialty,
                            bgColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            textColor: AppColors.primary,
                          ),
                          _chip(
                            label: _modeLabel(doctor.mode),
                            bgColor: _modeBgColor(doctor.mode),
                            textColor: _modeTextColor(doctor.mode),
                            icon: _modeIcon(doctor.mode),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Availability ─────────────────────────────────────────
            if (doctor.availableDays.isNotEmpty ||
                doctor.availableSlots.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.schedule_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _availabilityText(),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // ── Cities ───────────────────────────────────────────────
            if (doctor.cities.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      doctor.cities.join(', '),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // ── Consult button ───────────────────────────────────────
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => WhatsappService.openChat(
                  phoneNumber: doctor.whatsappNumber,
                  message:
                      'Hii, need consultation came through Naarya 🌸',
                ),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Consult Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasPhoto =
        doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: hasPhoto
            ? CachedNetworkImage(
                imageUrl: doctor.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, p) => _initialsWidget(),
                errorWidget: (_, e, s) => _initialsWidget(),
              )
            : _initialsWidget(),
      ),
    );
  }

  Widget _initialsWidget() {
    final parts = doctor.name.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : doctor.name.isNotEmpty
            ? doctor.name[0].toUpperCase()
            : 'D';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required Color bgColor,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _availabilityText() {
    final days = doctor.availableDays.join(', ');
    final slots = doctor.availableSlots.join(', ');
    if (days.isNotEmpty && slots.isNotEmpty) return '$days · $slots';
    if (days.isNotEmpty) return days;
    return slots;
  }

  String _modeLabel(ConsultMode mode) {
    switch (mode) {
      case ConsultMode.online:  return 'Online';
      case ConsultMode.offline: return 'In-Person';
      case ConsultMode.both:    return 'Online & In-Person';
    }
  }

  IconData _modeIcon(ConsultMode mode) {
    switch (mode) {
      case ConsultMode.online:  return Icons.videocam_outlined;
      case ConsultMode.offline: return Icons.local_hospital_outlined;
      case ConsultMode.both:    return Icons.swap_horiz_outlined;
    }
  }

  Color _modeBgColor(ConsultMode mode) {
    switch (mode) {
      case ConsultMode.online:  return AppColors.infoLight;
      case ConsultMode.offline: return AppColors.successLight;
      case ConsultMode.both:    return AppColors.secondaryLight;
    }
  }

  Color _modeTextColor(ConsultMode mode) {
    switch (mode) {
      case ConsultMode.online:  return AppColors.info;
      case ConsultMode.offline: return AppColors.success;
      case ConsultMode.both:    return AppColors.secondary;
    }
  }
}

// ─── Skeleton Card ────────────────────────────────────────────────────────────

class _DoctorCardSkeleton extends StatefulWidget {
  @override
  State<_DoctorCardSkeleton> createState() => _DoctorCardSkeletonState();
}

class _DoctorCardSkeletonState extends State<_DoctorCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _box(width: 72, height: 72, radius: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 140, height: 14),
                      const SizedBox(height: 6),
                      _box(width: 100, height: 12),
                      const SizedBox(height: 10),
                      Row(children: [
                        _box(width: 80, height: 22, radius: 20),
                        const SizedBox(width: 6),
                        _box(width: 60, height: 22, radius: 20),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _box(width: double.infinity, height: 44, radius: 12),
          ],
        ),
      ),
    );
  }

  Widget _box(
      {required double width,
      required double height,
      double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: _anim.value),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

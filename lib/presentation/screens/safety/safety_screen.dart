import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../../core/services/local_storage_service.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class _EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  const _EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });
}

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen>
    with SingleTickerProviderStateMixin {
  // SOS pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Trusted contacts
  final List<_EmergencyContact> _contacts = [
    const _EmergencyContact(
      name: 'Mom',
      phone: '+919876543210',
      relation: 'Family',
    ),
    const _EmergencyContact(
      name: 'Best Friend',
      phone: '+919123456789',
      relation: 'Friend',
    ),
  ];
  static const int _maxContacts = 5;

  // Add contact form
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRelation = 'Family';
  final List<String> _relations = [
    'Family',
    'Friend',
    'Partner',
    'Colleague',
    'Other',
  ];

  // Fake call
  int? _selectedFakeCallMinutes;
  Timer? _fakeCallTimer;
  int _fakeCallSecondsLeft = 0;
  bool _fakeCallScheduled = false;

  // Safe route check-in
  final _destinationController = TextEditingController();
  TimeOfDay? _etaTime;
  bool _checkInActive = false;
  Timer? _checkInTimer;
  int _checkInSecondsLeft = 0;

  // Cycle phase
  CyclePhaseInfo? _cyclePhaseInfo;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 16.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadCyclePhase();
  }

  void _loadCyclePhase() {
    final lastPeriodStr = LocalStorageService.lastPeriodDate;
    if (lastPeriodStr != null && lastPeriodStr.isNotEmpty) {
      final lastPeriod = DateTime.tryParse(lastPeriodStr);
      if (lastPeriod != null) {
        setState(() {
          _cyclePhaseInfo = CyclePhaseCalculator.calculate(
            lastPeriodStart: lastPeriod,
            cycleLength: LocalStorageService.cycleLength,
            periodLength: LocalStorageService.periodLength,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _destinationController.dispose();
    _fakeCallTimer?.cancel();
    _checkInTimer?.cancel();
    super.dispose();
  }

  // ─── SOS ───────────────────────────────────────────────────────────────

  void _showSOSConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Text('SOS Alert', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          'Send SOS alert to all emergency contacts?',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'SOS alert sent to ${_contacts.length} contacts',
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                ),
              );
            },
            child: Text('SEND SOS', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSSection() {
    return NaaryaCard(
      padding: const EdgeInsets.all(24),
      color: AppColors.errorLight,
      child: Column(
        children: [
          Text(
            'Emergency SOS',
            style: AppTextStyles.h3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap to alert your emergency contacts immediately',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.4),
                      blurRadius: _pulseAnimation.value + 8,
                      spreadRadius: _pulseAnimation.value / 2,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _showSOSConfirmation,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SOS',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ─── Trusted Contacts ─────────────────────────────────────────────────

  void _showAddContactSheet() {
    _nameController.clear();
    _phoneController.clear();
    _selectedRelation = 'Family';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Add Emergency Contact', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: AppTextStyles.subtitle2,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: AppTextStyles.subtitle2,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    value: _selectedRelation,
                    decoration: InputDecoration(
                      labelText: 'Relation',
                      labelStyle: AppTextStyles.subtitle2,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    items: _relations
                        .map(
                          (r) => DropdownMenuItem(value: r, child: Text(r)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => _selectedRelation = val);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.buttonRadius),
                        ),
                      ),
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final phone = _phoneController.text.trim();
                        if (name.isEmpty || phone.isEmpty) return;
                        setState(() {
                          _contacts.add(_EmergencyContact(
                            name: name,
                            phone: phone,
                            relation: _selectedRelation,
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text('Save Contact', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrustedContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Trusted Contacts',
          actionText: '${_contacts.length}/$_maxContacts contacts',
        ),
        const SizedBox(height: AppSpacing.md),
        ..._contacts.asMap().entries.map((entry) {
          final index = entry.key;
          final contact = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: NaaryaCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      contact.name[0].toUpperCase(),
                      style: AppTextStyles.subtitle1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(contact.name,
                                style: AppTextStyles.subtitle1),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.chipRadius,
                                ),
                              ),
                              child: Text(
                                contact.relation,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(contact.phone, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: contact.phone);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(
                      Icons.call,
                      color: AppColors.success,
                      size: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _contacts.removeAt(index));
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (_contacts.length < _maxContacts) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddContactSheet,
              icon: const Icon(Icons.person_add_alt_1, size: 20),
              label: const Text('Add Contact'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Fake Call ─────────────────────────────────────────────────────────

  void _scheduleFakeCall() {
    if (_selectedFakeCallMinutes == null) return;
    setState(() {
      _fakeCallScheduled = true;
      _fakeCallSecondsLeft = _selectedFakeCallMinutes! * 60;
    });
    _fakeCallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _fakeCallSecondsLeft--;
      });
      if (_fakeCallSecondsLeft <= 0) {
        timer.cancel();
        _showFakeCallDialog();
      }
    });
  }

  void _cancelFakeCall() {
    _fakeCallTimer?.cancel();
    setState(() {
      _fakeCallScheduled = false;
      _fakeCallSecondsLeft = 0;
      _selectedFakeCallMinutes = null;
    });
  }

  void _showFakeCallDialog() {
    setState(() {
      _fakeCallScheduled = false;
      _fakeCallSecondsLeft = 0;
      _selectedFakeCallMinutes = null;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(0),
        backgroundColor: const Color(0xFF1A1A2E),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: Colors.white, size: 50),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Incoming Call',
                style: AppTextStyles.subtitle2.copyWith(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Mom',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  // Accept
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildFakeCallSection() {
    final chipOptions = [1, 3, 5, 10];

    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_callback, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Fake Call', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Schedule a fake incoming call to safely exit uncomfortable situations',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppSpacing.md),
          if (!_fakeCallScheduled) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: chipOptions.map((min) {
                final selected = _selectedFakeCallMinutes == min;
                return ChoiceChip(
                  label: Text('$min min'),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                  labelStyle: AppTextStyles.label.copyWith(
                    color: selected ? Colors.white : AppColors.textBody,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  onSelected: (val) {
                    setState(() {
                      _selectedFakeCallMinutes = val ? min : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed:
                    _selectedFakeCallMinutes != null ? _scheduleFakeCall : null,
                child: Text('Schedule Call', style: AppTextStyles.button),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Column(
                children: [
                  Text(
                    'Call in',
                    style: AppTextStyles.subtitle2,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatSeconds(_fakeCallSecondsLeft),
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _cancelFakeCall,
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.subtitle1.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Safe Route Check-in ──────────────────────────────────────────────

  void _pickETA() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _etaTime = picked);
    }
  }

  void _startCheckIn() {
    if (_destinationController.text.trim().isEmpty || _etaTime == null) return;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final etaMinutes = _etaTime!.hour * 60 + _etaTime!.minute;
    var diff = etaMinutes - nowMinutes;
    if (diff <= 0) diff += 24 * 60; // next day

    setState(() {
      _checkInActive = true;
      _checkInSecondsLeft = diff * 60;
    });

    _checkInTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _checkInSecondsLeft--;
      });
      if (_checkInSecondsLeft <= 0) {
        timer.cancel();
        // Mock: alert not checked in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('You did not check in! Alert sent to contacts.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
        );
        _cancelCheckIn();
      }
    });
  }

  void _cancelCheckIn() {
    _checkInTimer?.cancel();
    setState(() {
      _checkInActive = false;
      _checkInSecondsLeft = 0;
      _etaTime = null;
      _destinationController.clear();
    });
  }

  Widget _buildSafeRouteSection() {
    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Set Check-in', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!_checkInActive) ...[
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: 'Destination',
                labelStyle: AppTextStyles.subtitle2,
                prefixIcon: const Icon(Icons.place, color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _pickETA,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.textMuted, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _etaTime != null
                          ? 'ETA: ${_etaTime!.format(context)}'
                          : 'Select ETA time',
                      style: _etaTime != null
                          ? AppTextStyles.subtitle1
                          : AppTextStyles.subtitle2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Alert will be sent to contacts if not checked in',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _startCheckIn,
                child: Text('Start Check-in', style: AppTextStyles.button),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Column(
                children: [
                  Text(
                    'Check-in to "${_destinationController.text}"',
                    style: AppTextStyles.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatSeconds(_checkInSecondsLeft),
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.warning,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'remaining to check in',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.buttonRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _cancelCheckIn();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Checked in safely!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.sm),
                            ),
                          ),
                        );
                      },
                      child: Text("I'm Safe", style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Period-linked Safety Tips ────────────────────────────────────────

  List<Map<String, String>> _getTipsForPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          {
            'icon': 'medication',
            'tip': 'Keep iron supplements handy during your period.',
          },
          {
            'icon': 'water_drop',
            'tip': 'Stay hydrated, carry water wherever you go.',
          },
          {
            'icon': 'self_improvement',
            'tip': 'Prioritize rest and avoid overexerting yourself.',
          },
        ];
      case CyclePhase.follicular:
        return [
          {
            'icon': 'bolt',
            'tip': 'Great energy phase! Plan outings confidently.',
          },
          {
            'icon': 'groups',
            'tip': 'Good time for social plans - stay aware of surroundings.',
          },
        ];
      case CyclePhase.ovulation:
        return [
          {
            'icon': 'visibility',
            'tip':
                'Stay aware of your surroundings during peak social phase.',
          },
          {
            'icon': 'share_location',
            'tip': 'Share your live location with a trusted contact on outings.',
          },
        ];
      case CyclePhase.luteal:
        return [
          {
            'icon': 'nightlight',
            'tip': 'Wind down, avoid late-night outings if feeling low.',
          },
          {
            'icon': 'spa',
            'tip':
                'Focus on self-care and stick to familiar, safe environments.',
          },
          {
            'icon': 'local_cafe',
            'tip': 'Keep comforting snacks handy for mood stability.',
          },
        ];
    }
  }

  IconData _tipIcon(String name) {
    switch (name) {
      case 'medication':
        return Icons.medication;
      case 'water_drop':
        return Icons.water_drop;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'bolt':
        return Icons.bolt;
      case 'groups':
        return Icons.groups;
      case 'visibility':
        return Icons.visibility;
      case 'share_location':
        return Icons.share_location;
      case 'nightlight':
        return Icons.nightlight_round;
      case 'spa':
        return Icons.spa;
      case 'local_cafe':
        return Icons.local_cafe;
      default:
        return Icons.tips_and_updates;
    }
  }

  Widget _buildSafetyTipsSection() {
    if (_cyclePhaseInfo == null) {
      return NaaryaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text('Safety Tips', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Log your period dates to get personalised safety tips based on your cycle phase.',
              style: AppTextStyles.body2,
            ),
          ],
        ),
      );
    }

    final tips = _getTipsForPhase(_cyclePhaseInfo!.phase);

    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Safety Tips', style: AppTextStyles.h3),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(
                  '${_cyclePhaseInfo!.phaseName} Phase',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Icon(
                      _tipIcon(tip['icon']!),
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(tip['tip']!, style: AppTextStyles.body2),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Nearby Help ──────────────────────────────────────────────────────

  Widget _buildNearbyHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Nearby Help'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _HelpActionCard(
                icon: Icons.phone,
                label: 'Women\nHelpline',
                sublabel: '1091',
                color: AppColors.primary,
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: '1091');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _HelpActionCard(
                icon: Icons.emergency,
                label: 'Emergency',
                sublabel: '112',
                color: AppColors.error,
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: '112');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _HelpActionCard(
                icon: Icons.local_hospital,
                label: 'Nearest\nHospital',
                sublabel: 'Maps',
                color: AppColors.info,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Opening Maps...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Safety', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSOSSection(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildTrustedContactsSection(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildFakeCallSection(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildSafeRouteSection(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildSafetyTipsSection(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildNearbyHelpSection(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildLegalHelpSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Legal Help ──────────────────────────────────────────────────────────

  Widget _buildLegalHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Legal Help'),
        const SizedBox(height: AppSpacing.md),
        NaaryaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Know Your Rights',
                            style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('Legal guidance for women — domestic, workplace & more',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.legalHelp),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text('Read Guide',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => WhatsappService.openChat(
                        phoneNumber: AppConstants.whatsappNumber,
                        message: 'Hi, I need help with a legal matter and would like to speak to a legal expert.',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_rounded, color: Color(0xFF128C7E), size: 16),
                            const SizedBox(width: 6),
                            Text('Talk to Expert',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFF128C7E), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Help Action Card widget ──────────────────────────────────────────────

class _HelpActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _HelpActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NaaryaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.textBody),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

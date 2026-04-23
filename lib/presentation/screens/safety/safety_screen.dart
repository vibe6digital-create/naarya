import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/emergency_contact_service.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../data/models/emergency_contact_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../../../core/routes/app_routes.dart';

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

  // Trusted contacts — populated from Firebase
  List<EmergencyContact> _contacts = [];
  StreamSubscription<List<EmergencyContact>>? _contactsSubscription;
  bool _contactsLoading = true;
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
  final _customMinutesController = TextEditingController();
  final _customSecondsController = TextEditingController();
  String? _customMinutesError;

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
    _contactsSubscription = EmergencyContactService.watchContacts().listen(
      (contacts) {
        if (mounted) {
          setState(() {
            _contacts = contacts;
            _contactsLoading = false;
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _contactsLoading = false);
      },
    );
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
    _customMinutesController.dispose();
    _customSecondsController.dispose();
    _fakeCallTimer?.cancel();
    _contactsSubscription?.cancel();
    super.dispose();
  }

  // ─── SOS ───────────────────────────────────────────────────────────────

  void _showAlert(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        content: Text(message, style: AppTextStyles.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSOSCall() async {
    if (_contacts.isEmpty) {
      _showAlert('Please add at least one emergency contact');
      return;
    }

    final phone = _contacts.first.phone.trim();
    if (phone.isEmpty) {
      _showAlert('Invalid contact number');
      return;
    }

    // Request CALL_PHONE permission
    final status = await Permission.phone.request();

    if (status.isGranted) {
      // Direct call — ACTION_CALL (no dialer UI)
      final called = await FlutterPhoneDirectCaller.callNumber(phone);
      if (called != true) {
        // Fallback: open dialer pre-filled
        final uri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      }
    } else if (status.isPermanentlyDenied) {
      _showAlert('Call permission required for SOS feature. Please enable it in Settings.');
      await openAppSettings();
    } else {
      _showAlert('Call permission required for SOS feature');
    }
  }

  void _showSOSConfirmation() {
    if (_contacts.isEmpty) {
      _showAlert('Please add at least one emergency contact');
      return;
    }

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
          'Call ${_contacts.first.name} (${_contacts.first.phone}) immediately?',
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
              _triggerSOSCall();
            },
            child: Text('CALL NOW', style: AppTextStyles.button),
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
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
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
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        final phone = _phoneController.text.trim();
                        if (name.isEmpty || phone.isEmpty) return;
                        Navigator.pop(ctx);
                        try {
                          await EmergencyContactService.addContact(
                            name: name,
                            phone: phone,
                            relation: _selectedRelation,
                          );
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to save contact. Please try again.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: Text('Save Contact', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
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
        if (_contactsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No emergency contacts added',
              style: AppTextStyles.body2,
            ),
          )
        else
          ..._contacts.map((contact) {
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
                              Flexible(
                                child: Text(contact.name,
                                    style: AppTextStyles.subtitle1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
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
                      onPressed: () async {
                        try {
                          await EmergencyContactService.deleteContact(contact.id);
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to delete contact.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
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
    int totalSeconds;
    final minText = _customMinutesController.text.trim();
    final secText = _customSecondsController.text.trim();

    if (minText.isNotEmpty || secText.isNotEmpty) {
      // Custom input takes priority over preset
      final mins = minText.isEmpty ? 0 : int.tryParse(minText);
      final secs = secText.isEmpty ? 0 : int.tryParse(secText);

      if (mins == null || secs == null ||
          mins < 0 || mins > 120 ||
          secs < 0 || secs > 59) {
        setState(() => _customMinutesError = 'Enter valid time');
        return;
      }

      final total = mins * 60 + secs;
      if (total <= 0) {
        setState(() => _customMinutesError = 'Enter valid time');
        return;
      }

      totalSeconds = total;
    } else if (_selectedFakeCallMinutes != null) {
      totalSeconds = _selectedFakeCallMinutes! * 60;
    } else {
      return;
    }

    final displayMins = totalSeconds ~/ 60;
    final displaySecs = totalSeconds % 60;
    final confirmMsg = displayMins == 0
        ? 'Fake call scheduled in ${displaySecs}s'
        : displaySecs == 0
            ? 'Fake call scheduled in ${displayMins}m'
            : 'Fake call scheduled in ${displayMins}m ${displaySecs}s';

    setState(() {
      _customMinutesError = null;
      _fakeCallScheduled = true;
      _fakeCallSecondsLeft = totalSeconds;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirmMsg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

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
    _customMinutesController.clear();
    _customSecondsController.clear();
    setState(() {
      _fakeCallScheduled = false;
      _fakeCallSecondsLeft = 0;
      _selectedFakeCallMinutes = null;
      _customMinutesError = null;
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
                      _customMinutesError = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            // Custom timer input
            Text('Set Custom Time', style: AppTextStyles.subtitle2),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _customMinutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'min',
                      hintStyle: AppTextStyles.body2.copyWith(
                        color: AppColors.textMuted,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
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
                    onChanged: (_) =>
                        setState(() => _customMinutesError = null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(':', style: AppTextStyles.h2),
                ),
                Expanded(
                  child: TextField(
                    controller: _customSecondsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'sec',
                      hintStyle: AppTextStyles.body2.copyWith(
                        color: AppColors.textMuted,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
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
                    onChanged: (_) =>
                        setState(() => _customMinutesError = null),
                  ),
                ),
              ],
            ),
            if (_customMinutesError != null) ...[
              const SizedBox(height: 4),
              Text(
                _customMinutesError!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
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
                onPressed: (_selectedFakeCallMinutes != null ||
                        _customMinutesController.text.trim().isNotEmpty ||
                        _customSecondsController.text.trim().isNotEmpty)
                    ? _scheduleFakeCall
                    : null,
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
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.legalHelp),
                icon: const Icon(Icons.gavel_rounded, size: 20),
                label: Text('Legal Help', style: AppTextStyles.button),
              ),
            ),
            SizedBox(height: AppSpacing.sectionGap),
            _buildTrustedContactsSection(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildFakeCallSection(),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gavel_rounded, color: Color(0xFF128C7E), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Talk to Expert',
                        style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text('Legal guidance for women — domestic, workplace & more',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => WhatsappService.openChat(
                  phoneNumber: AppConstants.whatsappNumber,
                  message: 'Hi, I need help with a legal matter and would like to speak to a legal expert.',
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_rounded, color: Color(0xFF128C7E), size: 16),
                      const SizedBox(width: 6),
                      Text('Chat',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF128C7E), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
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

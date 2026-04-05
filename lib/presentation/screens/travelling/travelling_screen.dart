import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class TravellingScreen extends StatefulWidget {
  const TravellingScreen({super.key});

  @override
  State<TravellingScreen> createState() => _TravellingScreenState();
}

class _TravellingScreenState extends State<TravellingScreen> {
  bool _isTravelling = false;
  String _selectedCity = AppConstants.cities.first;

  // Checklist state
  final Map<String, bool> _medicationChecks = {
    'Painkillers (Ibuprofen / Paracetamol)': false,
    'Antacids & digestive tablets': false,
    'Period supplies (pads / tampons / cup)': false,
    'First aid kit (band-aids, antiseptic)': false,
    'Prescribed medicines': false,
  };

  final Map<String, bool> _documentChecks = {
    'ID proof (Aadhaar / Passport)': false,
    'Health insurance card': false,
    'Medical prescriptions': false,
  };

  final Map<String, bool> _cyclePackingChecks = {};

  // Expandable state
  bool _medicationsExpanded = true;
  bool _documentsExpanded = false;
  bool _cyclePackingExpanded = false;

  CyclePhaseInfo? _cyclePhaseInfo;

  @override
  void initState() {
    super.initState();
    _selectedCity = LocalStorageService.userCity;
    _loadCyclePhase();
  }

  void _loadCyclePhase() {
    final lastPeriod = LocalStorageService.lastPeriodDate;
    if (lastPeriod != null && lastPeriod.isNotEmpty) {
      final date = DateTime.tryParse(lastPeriod);
      if (date != null) {
        _cyclePhaseInfo = CyclePhaseCalculator.calculate(
          lastPeriodStart: date,
          cycleLength: LocalStorageService.cycleLength,
          periodLength: LocalStorageService.periodLength,
        );
      }
    }
    _buildCyclePackingItems();
  }

  void _buildCyclePackingItems() {
    final phase = _cyclePhaseInfo?.phase ?? CyclePhase.follicular;
    _cyclePackingChecks.clear();

    switch (phase) {
      case CyclePhase.menstrual:
        _cyclePackingChecks['Extra period supplies (double your usual)'] = false;
        _cyclePackingChecks['Heating pad / hot water bottle'] = false;
        _cyclePackingChecks['Iron-rich snacks (dates, nuts)'] = false;
        break;
      case CyclePhase.follicular:
        _cyclePackingChecks['Light workout gear (high energy phase)'] = false;
        _cyclePackingChecks['Healthy snacks for active days'] = false;
        _cyclePackingChecks['Period supplies (period may start soon)'] = false;
        break;
      case CyclePhase.ovulation:
        _cyclePackingChecks['Comfortable clothing for bloating'] = false;
        _cyclePackingChecks['Hydration bottle'] = false;
        _cyclePackingChecks['Light panty liners'] = false;
        break;
      case CyclePhase.luteal:
        _cyclePackingChecks['Period supplies (period is approaching)'] = false;
        _cyclePackingChecks['Comfort snacks for cravings'] = false;
        _cyclePackingChecks['Soothing tea bags (chamomile / ginger)'] = false;
        break;
    }
    if (mounted) setState(() {});
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Travel Health', style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTravelModeCard(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildTravelHealthChecklist(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildDoctorFinder(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildTravelHealthTips(),
            SizedBox(height: AppSpacing.sectionGap),
            _buildEmergencyContacts(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── 1. Travel Mode Toggle ──────────────────────────────────────────

  Widget _buildTravelModeCard() {
    return NaaryaCard(
      border: _isTravelling
          ? Border.all(color: AppColors.primary, width: 2)
          : null,
      color: _isTravelling ? AppColors.primary.withValues(alpha: 0.05) : null,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isTravelling
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  color: _isTravelling ? AppColors.primary : AppColors.textMuted,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "I'm Travelling Now",
                      style: AppTextStyles.subtitle1.copyWith(
                        color: _isTravelling ? AppColors.primary : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isTravelling
                          ? 'Travel mode active'
                          : 'Enable for travel health features',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isTravelling,
                activeColor: AppColors.primary,
                onChanged: (value) => setState(() => _isTravelling = value),
              ),
            ],
          ),
          if (_isTravelling) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Destination:', style: AppTextStyles.subtitle2),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                        style: AppTextStyles.body2.copyWith(color: AppColors.textDark),
                        items: AppConstants.cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Row(
                              children: [
                                Icon(Icons.pin_drop_outlined,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(city),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedCity = value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── 2. Travel Health Checklist ─────────────────────────────────────

  Widget _buildTravelHealthChecklist() {
    final phaseName = _cyclePhaseInfo?.phaseName ?? 'General';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Travel Health Checklist'),
        const SizedBox(height: AppSpacing.md),
        _buildChecklistSection(
          title: 'Essential Medications',
          icon: Icons.medication_rounded,
          color: AppColors.error,
          bgColor: AppColors.errorLight,
          checks: _medicationChecks,
          expanded: _medicationsExpanded,
          onToggle: () =>
              setState(() => _medicationsExpanded = !_medicationsExpanded),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildChecklistSection(
          title: 'Documents',
          icon: Icons.description_rounded,
          color: AppColors.info,
          bgColor: AppColors.infoLight,
          checks: _documentChecks,
          expanded: _documentsExpanded,
          onToggle: () =>
              setState(() => _documentsExpanded = !_documentsExpanded),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildChecklistSection(
          title: 'Cycle-Aware Packing ($phaseName Phase)',
          icon: Icons.backpack_rounded,
          color: AppColors.warning,
          bgColor: AppColors.warningLight,
          checks: _cyclePackingChecks,
          expanded: _cyclePackingExpanded,
          onToggle: () =>
              setState(() => _cyclePackingExpanded = !_cyclePackingExpanded),
        ),
      ],
    );
  }

  Widget _buildChecklistSection({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Map<String, bool> checks,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    final checkedCount = checks.values.where((v) => v).length;
    final totalCount = checks.length;

    return NaaryaCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.subtitle1),
                        const SizedBox(height: 2),
                        Text(
                          '$checkedCount / $totalCount packed',
                          style: AppTextStyles.caption.copyWith(
                            color: checkedCount == totalCount
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (checkedCount == totalCount)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: AppColors.success, size: 16),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Column(
              children: checks.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CheckboxListTile(
                    value: entry.value,
                    title: Text(
                      entry.key,
                      style: AppTextStyles.body2.copyWith(
                        decoration:
                            entry.value ? TextDecoration.lineThrough : null,
                        color: entry.value
                            ? AppColors.textLight
                            : AppColors.textBody,
                      ),
                    ),
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() => checks[entry.key] = value ?? false);
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ── 3. City-wise Doctor Finder ─────────────────────────────────────

  Widget _buildDoctorFinder() {
    final doctors = _getDoctorsForCity(_selectedCity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Doctors in $_selectedCity',
        ),
        const SizedBox(height: AppSpacing.md),
        ...doctors.map((doctor) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildDoctorCard(doctor),
            )),
      ],
    );
  }

  Widget _buildDoctorCard(_DoctorInfo doctor) {
    return NaaryaCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              doctor.initials,
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: AppTextStyles.subtitle1
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(doctor.specialty, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(doctor.clinic, style: AppTextStyles.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: IconButton(
              icon: Icon(Icons.phone, color: AppColors.success, size: 22),
              onPressed: () => _makeCall(doctor.phone),
              tooltip: 'Call ${doctor.name}',
            ),
          ),
        ],
      ),
    );
  }

  List<_DoctorInfo> _getDoctorsForCity(String city) {
    switch (city) {
      case 'Indore':
        return [
          _DoctorInfo(
            name: 'Dr. Niyati Jain Shah',
            specialty: 'Gynecologist',
            clinic: 'Naarya Clinic Indore',
            phone: '+917310000001',
            initials: 'NJ',
          ),
          _DoctorInfo(
            name: 'Dr. Ritu Verma',
            specialty: 'General Physician',
            clinic: 'Naarya Clinic Indore',
            phone: '+917310000002',
            initials: 'RV',
          ),
        ];
      case 'Pune':
        return [
          _DoctorInfo(
            name: 'Dr. Priya Sharma',
            specialty: 'Gynecologist',
            clinic: 'Naarya Clinic Pune',
            phone: '+912000000001',
            initials: 'PS',
          ),
          _DoctorInfo(
            name: 'Dr. Meera Kulkarni',
            specialty: 'General Physician',
            clinic: 'Naarya Clinic Pune',
            phone: '+912000000002',
            initials: 'MK',
          ),
        ];
      case 'Ujjain':
        return [
          _DoctorInfo(
            name: 'Dr. Anjali Desai',
            specialty: 'General Health',
            clinic: 'Naarya Clinic Ujjain',
            phone: '+917340000001',
            initials: 'AD',
          ),
          _DoctorInfo(
            name: 'Dr. Sunita Tiwari',
            specialty: 'Gynecologist',
            clinic: 'Naarya Clinic Ujjain',
            phone: '+917340000002',
            initials: 'ST',
          ),
        ];
      default:
        return [];
    }
  }

  // ── 4. Travel Health Tips ──────────────────────────────────────────

  Widget _buildTravelHealthTips() {
    final tips = [
      _TravelTip(
        title: 'Stay Hydrated',
        icon: Icons.water_drop,
        color: AppColors.info,
        bgColor: AppColors.infoLight,
        description:
            'Drink extra water during flights. Dehydration worsens cramps and fatigue.',
      ),
      _TravelTip(
        title: 'DVT Prevention',
        icon: Icons.airline_seat_flat,
        color: AppColors.warning,
        bgColor: AppColors.warningLight,
        description:
            'Move your legs every hour during long trips. Do ankle circles.',
      ),
      _TravelTip(
        title: 'Cycle Management',
        icon: Icons.calendar_month,
        color: AppColors.primary,
        bgColor: AppColors.primary.withValues(alpha: 0.1),
        description:
            'Carry extra supplies. Travel stress can alter your cycle timing.',
      ),
      _TravelTip(
        title: 'Time Zone Medication',
        icon: Icons.schedule,
        color: AppColors.success,
        bgColor: AppColors.successLight,
        description:
            'Adjust medication reminders for your destination timezone.',
      ),
      _TravelTip(
        title: 'Emergency Kit',
        icon: Icons.medical_services,
        color: AppColors.error,
        bgColor: AppColors.errorLight,
        description:
            'Pack a small first aid kit with ORS, painkillers, and sanitary supplies.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Travel Health Tips'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return SizedBox(
                width: 220,
                child: NaaryaCard(
                  color: tip.bgColor,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tip.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                Icon(tip.icon, color: tip.color, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip.title,
                              style: AppTextStyles.subtitle2.copyWith(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tip.description,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textBody,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 5. Emergency Contacts ──────────────────────────────────────────

  Widget _buildEmergencyContacts() {
    final contacts = [
      _EmergencyContact(
          label: 'Indore Clinic', number: '+91 731-XXXXXXX', icon: Icons.local_hospital),
      _EmergencyContact(
          label: 'Pune Clinic', number: '+91 20-XXXXXXXX', icon: Icons.local_hospital),
      _EmergencyContact(
          label: 'Ujjain Clinic', number: '+91 734-XXXXXXX', icon: Icons.local_hospital),
      _EmergencyContact(
          label: 'National Emergency', number: '112', icon: Icons.emergency),
      _EmergencyContact(
          label: 'Women Helpline', number: '1091', icon: Icons.support_agent),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Emergency Contacts'),
        const SizedBox(height: AppSpacing.md),
        ...contacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: NaaryaCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(contact.icon, color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.label,
                              style: AppTextStyles.subtitle2.copyWith(
                                  color: AppColors.textDark)),
                          const SizedBox(height: 2),
                          Text(contact.number, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.phone,
                            color: AppColors.success, size: 20),
                        onPressed: () {
                          final cleaned = contact.number
                              .replaceAll(' ', '')
                              .replaceAll('-', '');
                          _makeCall(cleaned);
                        },
                        tooltip: 'Call ${contact.label}',
                        constraints:
                            const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────────

class _DoctorInfo {
  final String name;
  final String specialty;
  final String clinic;
  final String phone;
  final String initials;

  const _DoctorInfo({
    required this.name,
    required this.specialty,
    required this.clinic,
    required this.phone,
    required this.initials,
  });
}

class _TravelTip {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String description;

  const _TravelTip({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.description,
  });
}

class _EmergencyContact {
  final String label;
  final String number;
  final IconData icon;

  const _EmergencyContact({
    required this.label,
    required this.number,
    required this.icon,
  });
}

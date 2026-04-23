import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/medical_record_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/medical_record_model.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/naarya_card.dart';
import 'add_record_screen.dart';

class HealthVaultScreen extends StatefulWidget {
  const HealthVaultScreen({super.key});

  @override
  State<HealthVaultScreen> createState() => _HealthVaultScreenState();
}

class _HealthVaultScreenState extends State<HealthVaultScreen> {
  RecordType? _selectedType;
  String _searchQuery = '';
  bool _isSearchVisible = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  List<MedicalRecord> _records = [];
  StreamSubscription<List<MedicalRecord>>? _subscription;
  final bool _useFirebase = FirebaseAuthService.isLoggedIn;

  // Filter labels
  static const List<(RecordType?, String)> _filterCategories = [
    (null, 'All'),
    (RecordType.report, 'Lab Reports'),
    (RecordType.prescription, 'Prescriptions'),
    (RecordType.scan, 'Scans'),
    (RecordType.vaccination, 'Vaccination'),
    (RecordType.consultation, 'Consultation'),
    (RecordType.other, 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    if (_useFirebase) {
      _subscription = MedicalRecordService.recordsStream().listen(
        (records) {
          if (mounted) {
            setState(() {
              _records = records;
              _isLoading = false;
            });
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
      );
    } else {
      _records = _mockRecords();
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Mock data (shown when not signed in) ────────────────────────────────

  List<MedicalRecord> _mockRecords() {
    final now = DateTime.now();
    return [
      MedicalRecord(
        id: '1',
        title: 'Complete Blood Count (CBC)',
        type: RecordType.report,
        date: '05 Apr 2026',
        doctor: 'Dr. Priya Sharma',
        hospital: 'Apollo Hospitals',
        notes: 'All values within normal range. Hemoglobin slightly low.',
        tags: const ['blood test', 'CBC'],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      MedicalRecord(
        id: '2',
        title: 'Gynecology Prescription',
        type: RecordType.prescription,
        date: '01 Apr 2026',
        doctor: 'Dr. Meena Kulkarni',
        notes: 'PCOS management — 3-month follow-up.',
        tags: const ['PCOS', 'prescription'],
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      MedicalRecord(
        id: '3',
        title: 'Pelvic Ultrasound',
        type: RecordType.scan,
        date: '15 Mar 2026',
        doctor: 'Dr. Anjali Desai',
        notes: 'Routine scan, no abnormalities detected.',
        tags: const ['scan', 'ultrasound'],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  // ─── Filtering ───────────────────────────────────────────────────────────

  List<MedicalRecord> get _filteredRecords {
    List<MedicalRecord> results = _records;

    if (_selectedType != null) {
      results = results.where((r) => r.type == _selectedType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((r) {
        return '${r.title} ${r.doctor ?? ''} ${r.notes ?? ''} ${r.typeLabel}'
            .toLowerCase()
            .contains(query);
      }).toList();
    }

    return results;
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _navigateToAddRecord() async {
    final result = await Navigator.of(context).push<MedicalRecord>(
      MaterialPageRoute(builder: (_) => const AddRecordScreen()),
    );
    if (result != null && mounted && !_useFirebase) {
      setState(() => _records.insert(0, result));
    }
  }

  void _deleteRecord(MedicalRecord record) async {
    final idx = _records.indexOf(record);
    setState(() => _records.remove(record));

    if (_useFirebase) {
      await MedicalRecordService.deleteRecord(record);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${record.title} removed'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.phaseOvulation,
            onPressed: () async {
              setState(() => _records.insert(idx, record));
              if (_useFirebase) {
                await MedicalRecordService.saveRecord(record);
              }
            },
          ),
        ),
      );
    }
  }

  void _openRecordDetail(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => _buildRecordDetailSheet(record, scrollCtrl),
      ),
    );
  }

  Widget _buildRecordDetailSheet(
      MedicalRecord record, ScrollController scrollCtrl) {
    final catColor = _colorForType(record.type);
    final h = record.healthDetails;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_iconForType(record.type),
                      color: catColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title,
                          style: AppTextStyles.subtitle1,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text(record.typeLabel,
                          style: AppTextStyles.caption
                              .copyWith(color: catColor)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 20),

          // Scrollable content
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // ── Image ──
                if (record.isImage && record.fileUrl != null) ...[
                  _detailSectionHeader(
                      'Prescription Image', Icons.photo_library_outlined),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: record.fileUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, p) => Container(
                        height: 200,
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (_, e, s) => Container(
                        height: 200,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.broken_image_outlined,
                            color: AppColors.textMuted, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Document ──
                if (record.isPdf && record.fileUrl != null) ...[
                  _detailSectionHeader(
                      'Document', Icons.picture_as_pdf_outlined),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: AppColors.info, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'PDF Document',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Basic details ──
                _detailSectionHeader('Record Details', Icons.info_outline),
                const SizedBox(height: 10),
                _detailRow(Icons.category_outlined, 'Type', record.typeLabel),
                _detailRow(Icons.calendar_today_outlined, 'Date', record.date),
                if (record.doctor != null)
                  _detailRow(Icons.person_outline, 'Doctor', record.doctor!),
                if (record.hospital != null)
                  _detailRow(Icons.local_hospital_outlined, 'Hospital',
                      record.hospital!),
                if (record.notes != null)
                  _detailRow(Icons.notes_outlined, 'Notes', record.notes!),
                if (record.tags.isNotEmpty)
                  _detailRow(Icons.label_outline, 'Tags',
                      record.tags.join(', ')),
                const SizedBox(height: 20),

                // ── Health Problem Details ──
                if (h != null && !h.isEmpty) ...[
                  _detailSectionHeader('Health Problem Details',
                      Icons.medical_information_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          color: _severityColor(h.severity), size: 10),
                      const SizedBox(width: 6),
                      Text(
                        'Severity: ${_severityLabel(h.severity)}',
                        style: AppTextStyles.caption.copyWith(
                          color: _severityColor(h.severity),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (h.symptoms != null)
                    _healthDetailBlock('Symptoms', h.symptoms!,
                        Icons.sick_outlined, AppColors.error),
                  if (h.diagnosis != null)
                    _healthDetailBlock('Diagnosis', h.diagnosis!,
                        Icons.biotech_outlined, AppColors.info),
                  if (h.treatmentPlan != null)
                    _healthDetailBlock('Treatment Plan', h.treatmentPlan!,
                        Icons.healing_outlined, AppColors.success),
                  if (h.medications != null)
                    _healthDetailBlock('Medications', h.medications!,
                        Icons.medication_outlined, AppColors.secondary),
                  if (h.followUpDate != null)
                    _detailRow(Icons.event_available_outlined, 'Follow-up',
                        _formatDate(h.followUpDate!)),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _detailSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title,
            style: AppTextStyles.subtitle2
                .copyWith(color: AppColors.primary)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 90),
            child: Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body2),
          ),
        ],
      ),
    );
  }

  Widget _healthDetailBlock(
      String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption.copyWith(
                        color: color, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.body2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}';

  String _monthName(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  Color _severityColor(Severity s) {
    switch (s) {
      case Severity.mild:     return AppColors.success;
      case Severity.moderate: return AppColors.warning;
      case Severity.severe:   return AppColors.error;
    }
  }

  String _severityLabel(Severity s) {
    switch (s) {
      case Severity.mild:     return 'Mild';
      case Severity.moderate: return 'Moderate';
      case Severity.severe:   return 'Severe';
    }
  }

  void _showShareSheet(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share "${record.title}"',
                style: AppTextStyles.h3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              _buildShareOption(
                icon: Icons.chat,
                color: const Color(0xFF25D366),
                label: 'Share via WhatsApp',
                onTap: () {
                  Navigator.pop(ctx);
                  _showSnack('WhatsApp sharing not available in demo');
                },
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                icon: Icons.email_outlined,
                color: AppColors.info,
                label: 'Share via Email',
                onTap: () {
                  Navigator.pop(ctx);
                  _showSnack('Email sharing not available in demo');
                },
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                icon: Icons.link,
                color: AppColors.primary,
                label: 'Generate Secure Link',
                onTap: () {
                  Navigator.pop(ctx);
                  _showSnack('Secure link generated (mock)');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label, style: AppTextStyles.subtitle1),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ─── UI helpers ──────────────────────────────────────────────────────────

  IconData _iconForType(RecordType type) {
    switch (type) {
      case RecordType.report:         return Icons.science_outlined;
      case RecordType.prescription:   return Icons.medication_outlined;
      case RecordType.scan:           return Icons.image_outlined;
      case RecordType.vaccination:    return Icons.vaccines_outlined;
      case RecordType.consultation:   return Icons.chat_outlined;
      case RecordType.other:          return Icons.folder_outlined;
    }
  }

  Color _colorForType(RecordType type) {
    switch (type) {
      case RecordType.report:         return AppColors.info;
      case RecordType.prescription:   return AppColors.success;
      case RecordType.scan:           return AppColors.warning;
      case RecordType.vaccination:    return AppColors.secondary;
      case RecordType.consultation:   return AppColors.primaryDark;
      case RecordType.other:          return AppColors.textMuted;
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Medical Records', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.search_off : Icons.search,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _navigateToAddRecord,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchVisible) _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddRecord,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_filteredRecords.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.folder_open_outlined,
        title: 'No records found',
        subtitle: _searchQuery.isNotEmpty
            ? 'No records match "$_searchQuery".'
            : _records.isEmpty
                ? 'Your health vault is empty. Tap + to upload your first record.'
                : 'No records in this category yet.',
        actionText: 'Add Record',
        onAction: _navigateToAddRecord,
      );
    }

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        _buildVaultStats(),
        const SizedBox(height: AppSpacing.componentGap),
        _buildEncryptionBadge(),
        const SizedBox(height: AppSpacing.sectionGap),
        ..._filteredRecords.map((record) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.componentGap),
              child: _buildRecordCard(record),
            )),
        _buildReminderNudge(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: AppTextStyles.body2,
        decoration: InputDecoration(
          hintText: 'Search records...',
          hintStyle:
              AppTextStyles.body2.copyWith(color: AppColors.textLight),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filterCategories.map((entry) {
            final (type, label) = entry;
            final isSelected = _selectedType == type;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textBody,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedType = type),
                backgroundColor: AppColors.surfaceVariant,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVaultStats() {
    return NaaryaCard(
      child: Row(
        children: [
          _statItem(Icons.folder_outlined, '${_records.length}', 'Records'),
          _statDivider(),
          _statItem(
            Icons.photo_outlined,
            '${_records.where((r) => r.isImage).length}',
            'Photos',
          ),
          _statDivider(),
          _statItem(
            Icons.picture_as_pdf_outlined,
            '${_records.where((r) => r.isPdf).length}',
            'Docs',
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(count,
              style: AppTextStyles.subtitle1
                  .copyWith(color: AppColors.textDark)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }

  Widget _buildEncryptionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your records are encrypted and stored securely in Firebase',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final catColor = _colorForType(record.type);
    final hasImage = record.isImage && record.fileUrl != null;

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _deleteRecord(record),
      child: NaaryaCard(
        onTap: () => _openRecordDetail(record),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail or category icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: record.fileUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (_, p) => Container(
                            width: 48,
                            height: 48,
                            color: catColor.withValues(alpha: 0.1),
                            child: Icon(_iconForType(record.type),
                                color: catColor, size: 24),
                          ),
                          errorWidget: (_, e, s) => Container(
                            width: 48,
                            height: 48,
                            color: catColor.withValues(alpha: 0.1),
                            child: Icon(_iconForType(record.type),
                                color: catColor, size: 24),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: catColor.withValues(alpha: 0.1),
                          child: Icon(_iconForType(record.type),
                              color: catColor, size: 24),
                        ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: AppTextStyles.subtitle1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              record.typeLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: catColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            record.date,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (record.doctor != null)
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 14,
                                color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                record.doctor!,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Actions
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  color: AppColors.textMuted,
                  onPressed: () => _showShareSheet(record),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 36, minHeight: 36),
                ),
              ],
            ),

            // Tags
            if (record.tags.isNotEmpty || record.doctor != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildTag(AppDateUtils.timeAgo(record.createdAt)),
                  ...record.tags.take(3).map((tag) => _buildTag(tag)),
                  if (hasImage) _buildTag('1 photo'),
                  if (record.isPdf) _buildTag('PDF'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(text,
          style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
    );
  }

  Widget _buildReminderNudge() {
    return NaaryaCard(
      color: AppColors.primaryLight.withValues(alpha: 0.06),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Had a recent consultation?',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload prescriptions to keep your vault updated.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _navigateToAddRecord,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            child: Text(
              'Upload Now',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

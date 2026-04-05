import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/medical_record_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'add_record_screen.dart';

class HealthVaultScreen extends StatefulWidget {
  const HealthVaultScreen({super.key});

  @override
  State<HealthVaultScreen> createState() => _HealthVaultScreenState();
}

class _HealthVaultScreenState extends State<HealthVaultScreen> {
  RecordCategory? _selectedCategory;
  String? _selectedStringFilter;
  String _searchQuery = '';
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  final List<MedicalRecord> _records = [
    MedicalRecord(
      id: '1',
      title: 'Complete Blood Count (CBC)',
      category: RecordCategory.report,
      filePath: 'cbc_report.pdf',
      dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      doctorName: 'Dr. Priya Sharma',
      notes: 'All values within normal range. Hemoglobin slightly low.',
    ),
    MedicalRecord(
      id: '2',
      title: 'Gynecology Prescription',
      category: RecordCategory.prescription,
      filePath: 'gynec_prescription.pdf',
      dateAdded: DateTime.now().subtract(const Duration(days: 12)),
      doctorName: 'Dr. Meena Kulkarni',
      notes: 'PCOS management — 3-month follow-up.',
    ),
    MedicalRecord(
      id: '3',
      title: 'Pelvic Ultrasound',
      category: RecordCategory.scan,
      filePath: 'pelvic_ultrasound.pdf',
      dateAdded: DateTime.now().subtract(const Duration(days: 30)),
      doctorName: 'Dr. Anjali Desai',
      notes: 'Routine scan, no abnormalities detected.',
    ),
    MedicalRecord(
      id: '4',
      title: 'Thyroid Panel (TSH, T3, T4)',
      category: RecordCategory.report,
      filePath: 'thyroid_report.pdf',
      dateAdded: DateTime.now().subtract(const Duration(days: 60)),
      doctorName: 'Dr. Priya Sharma',
    ),
  ];

  // Mock body-part tags per record id
  static const Map<String, String> _bodyPartTags = {
    '1': 'Blood',
    '2': 'Gynecology',
    '3': 'Pelvic',
    '4': 'Thyroid',
  };

  // Mock file sizes per record id
  static const Map<String, String> _fileSizes = {
    '1': '2.4 MB',
    '2': '1.8 MB',
    '3': '4.6 MB',
    '4': '3.2 MB',
  };

  // String-based filter labels including vaccination and consultation
  static const List<(RecordCategory?, String?, String)> _filterCategories = [
    (null, null, 'All'),
    (RecordCategory.report, null, 'Lab Reports'),
    (RecordCategory.prescription, null, 'Prescriptions'),
    (RecordCategory.scan, null, 'Scans'),
    (null, 'vaccination', 'Vaccination'),
    (null, 'consultation', 'Consultation Notes'),
    (RecordCategory.other, null, 'Other'),
  ];

  List<MedicalRecord> get _filteredRecords {
    List<MedicalRecord> results = _records;

    // Apply category or string-based filter
    if (_selectedCategory != null) {
      results = results.where((r) => r.category == _selectedCategory).toList();
    } else if (_selectedStringFilter != null) {
      final filter = _selectedStringFilter!.toLowerCase();
      results = results.where((r) {
        final searchable =
            '${r.title} ${r.notes ?? ''} ${r.doctorName ?? ''} ${r.categoryLabel}'
                .toLowerCase();
        return searchable.contains(filter);
      }).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((r) {
        final searchable =
            '${r.title} ${r.doctorName ?? ''} ${r.notes ?? ''}'.toLowerCase();
        return searchable.contains(query);
      }).toList();
    }

    return results;
  }

  double get _storageUsedMB {
    return _records.length * 3.0; // ~3 MB per record => 4 records = 12 MB
  }

  double get _storageTotalMB => 100.0;

  double get _storagePercent => _storageUsedMB / _storageTotalMB;

  Color get _storageColor {
    if (_storagePercent > 0.9) return AppColors.error;
    if (_storagePercent >= 0.7) return AppColors.warning;
    return AppColors.primary;
  }

  IconData _iconForCategory(RecordCategory category) {
    switch (category) {
      case RecordCategory.report:
        return Icons.science_outlined;
      case RecordCategory.prescription:
        return Icons.medication_outlined;
      case RecordCategory.scan:
        return Icons.image_outlined;
      case RecordCategory.other:
        return Icons.folder_outlined;
    }
  }

  Color _colorForCategory(RecordCategory category) {
    switch (category) {
      case RecordCategory.report:
        return AppColors.info;
      case RecordCategory.prescription:
        return AppColors.success;
      case RecordCategory.scan:
        return AppColors.warning;
      case RecordCategory.other:
        return AppColors.textMuted;
    }
  }

  void _navigateToAddRecord() async {
    final result = await Navigator.of(context).push<MedicalRecord>(
      MaterialPageRoute(builder: (_) => const AddRecordScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _records.insert(0, result);
      });
    }
  }

  void _showShareSheet(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                    _showSnack('WhatsApp sharing is not available in this demo');
                  },
                ),
                const SizedBox(height: 12),
                _buildShareOption(
                  icon: Icons.email_outlined,
                  color: AppColors.info,
                  label: 'Share via Email',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSnack('Email sharing is not available in this demo');
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
        );
      },
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

  void _openDocumentViewer(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Document Viewer',
                        style: AppTextStyles.h3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  record.title,
                  style: AppTextStyles.subtitle1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 64,
                        color: AppColors.error.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        record.filePath,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pinch to zoom',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          // Search bar
          if (_isSearchVisible) _buildSearchBar(),

          // Filter chips
          _buildFilterChips(),

          // Scrollable content
          Expanded(
            child: _filteredRecords.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.folder_open_outlined,
                    title: 'No records found',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'No records match "$_searchQuery". Try a different search term.'
                        : _selectedCategory != null
                            ? 'No ${_selectedCategory!.name} records yet. Add one to get started.'
                            : _selectedStringFilter != null
                                ? 'No $_selectedStringFilter records yet.'
                                : 'Your health vault is empty. Start by adding a record.',
                    actionText: 'Add Record',
                    onAction: _navigateToAddRecord,
                  )
                : ListView(
                    padding: AppSpacing.pagePadding,
                    children: [
                      // Storage indicator
                      _buildStorageIndicator(),
                      const SizedBox(height: AppSpacing.componentGap),

                      // Encryption badge
                      _buildEncryptionBadge(),
                      const SizedBox(height: AppSpacing.sectionGap),

                      // Records
                      ..._filteredRecords.map((record) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.componentGap),
                            child: _buildRecordCard(record),
                          )),

                      // Reminder nudge
                      _buildReminderNudge(),
                      const SizedBox(height: 80), // FAB clearance
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddRecord,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
          hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textLight),
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
            borderSide: const BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
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
            final (category, stringFilter, label) = entry;
            final bool isSelected;
            if (category == null && stringFilter == null) {
              // "All" filter
              isSelected =
                  _selectedCategory == null && _selectedStringFilter == null;
            } else if (stringFilter != null) {
              isSelected = _selectedStringFilter == stringFilter;
            } else {
              isSelected = _selectedCategory == category &&
                  _selectedStringFilter == null;
            }

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
                onSelected: (_) {
                  setState(() {
                    if (category == null && stringFilter == null) {
                      // "All"
                      _selectedCategory = null;
                      _selectedStringFilter = null;
                    } else if (stringFilter != null) {
                      _selectedCategory = null;
                      _selectedStringFilter = stringFilter;
                    } else {
                      _selectedCategory = category;
                      _selectedStringFilter = null;
                    }
                  });
                },
                backgroundColor: AppColors.surfaceVariant,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
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

  Widget _buildStorageIndicator() {
    final usedMB = _storageUsedMB.toInt();
    final totalMB = _storageTotalMB.toInt();
    final percent = _storagePercent;
    final color = _storageColor;

    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text('Storage Used', style: AppTextStyles.subtitle2),
              const Spacer(),
              Text(
                '$usedMB MB of $totalMB MB used',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8,
            percent: percent.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceVariant,
            progressColor: color,
            barRadius: const Radius.circular(4),
            animation: true,
            animationDuration: 800,
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your records are encrypted and private',
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
    final catColor = _colorForCategory(record.category);
    final bodyTag = _bodyPartTags[record.id] ?? '';
    final fileSize = _fileSizes[record.id] ?? '1.0 MB';

    return NaaryaCard(
      onTap: () => _openDocumentViewer(record),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForCategory(record.category),
                  color: catColor,
                  size: 24,
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
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.categoryLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: catColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppDateUtils.formatDate(record.dateAdded),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (record.doctorName != null) ...[
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.doctorName!,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Icon(
                          Icons.insert_drive_file_outlined,
                          size: 12,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          fileSize,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Share button
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                color: AppColors.textMuted,
                onPressed: () => _showShareSheet(record),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),

          // Tags row
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (record.doctorName != null)
                _buildTag(record.doctorName!),
              if (bodyTag.isNotEmpty) _buildTag(bodyTag),
              _buildTag(AppDateUtils.timeAgo(record.dateAdded)),
            ],
          ),
        ],
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
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
      ),
    );
  }

  Widget _buildReminderNudge() {
    return NaaryaCard(
      color: AppColors.primaryLight.withValues(alpha: 0.06),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.primary,
            size: 28,
          ),
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
                  'Upload your new reports to keep your vault updated.',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
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

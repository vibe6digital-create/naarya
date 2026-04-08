import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/firestore_notes_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/todo_item_model.dart';
import '../../widgets/common/empty_state_widget.dart';

// --- Note card colors (pastel palette) ---
const List<Color> kNoteColors = [
  Color(0xFFFFFFFF), // white (default)
  Color(0xFFFFF9C4), // pastel yellow
  Color(0xFFFFCCBC), // pastel coral
  Color(0xFFC8E6C9), // pastel green
  Color(0xFFBBDEFB), // pastel blue
  Color(0xFFE1BEE7), // pastel purple
  Color(0xFFFFE0B2), // pastel orange
  Color(0xFFB2EBF2), // pastel teal
];

const List<Color> kNoteColorsDark = [
  Color(0xFFF5F5F5),
  Color(0xFFFFF176),
  Color(0xFFFF8A65),
  Color(0xFF81C784),
  Color(0xFF64B5F6),
  Color(0xFFCE93D8),
  Color(0xFFFFB74D),
  Color(0xFF4DD0E1),
];

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  List<TodoItem> _notes = [];
  String _selectedCategory = 'all';
  bool _isGridView = true;
  bool _isSearchOpen = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnimController;
  late Animation<double> _searchAnim;

  @override
  void initState() {
    super.initState();
    _isGridView = LocalStorageService.keepNotesGridView;
    _loadNotes();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _searchAnim = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimController.dispose();
    super.dispose();
  }

  // --- Persistence ---

  void _loadNotes() {
    // Load from local storage first for instant UI
    final json = LocalStorageService.keepNotesJson;
    if (json != null && json.isNotEmpty) {
      final list = jsonDecode(json) as List;
      _notes = list
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Then try Firestore and update if available
    if (FirestoreNotesService.isAvailable) {
      FirestoreNotesService.loadNotes().then((firestoreNotes) {
        if (firestoreNotes.isNotEmpty && mounted) {
          setState(() => _notes = firestoreNotes);
          _saveNotesLocal();
        }
      }).catchError((_) {});
    }
  }

  Future<void> _saveNotesLocal() async {
    final json = jsonEncode(_notes.map((e) => e.toJson()).toList());
    await LocalStorageService.setKeepNotesJson(json);
  }

  Future<void> _saveNotes() async {
    await _saveNotesLocal();
  }

  // --- Filtering & sorting ---

  List<TodoItem> get _filteredNotes {
    var list = List<TodoItem>.from(_notes);

    // Category filter
    if (_selectedCategory != 'all') {
      list = list.where((n) => n.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((n) {
        if (n.title.toLowerCase().contains(q)) return true;
        if (n.description != null && n.description!.toLowerCase().contains(q)) {
          return true;
        }
        if (n.checklistItems.any((c) => c.text.toLowerCase().contains(q))) {
          return true;
        }
        return false;
      }).toList();
    }

    // Sort: pinned first, then by updatedAt descending
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return list;
  }

  List<TodoItem> get _pinnedNotes =>
      _filteredNotes.where((n) => n.isPinned).toList();

  List<TodoItem> get _otherNotes =>
      _filteredNotes.where((n) => !n.isPinned).toList();

  // --- CRUD ---

  void _addNote(TodoItem note) {
    setState(() => _notes.insert(0, note));
    _saveNotes();
    FirestoreNotesService.addNote(note).catchError((_) {});
  }

  void _updateNote(TodoItem updated) {
    setState(() {
      final idx = _notes.indexWhere((n) => n.id == updated.id);
      if (idx >= 0) _notes[idx] = updated;
    });
    _saveNotes();
    FirestoreNotesService.updateNote(updated).catchError((_) {});
  }

  void _deleteNote(TodoItem note) {
    final idx = _notes.indexOf(note);
    setState(() => _notes.remove(note));
    _saveNotes();
    FirestoreNotesService.deleteNote(note.id).catchError((_) {});

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${note.title}" deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.phaseOvulation,
          onPressed: () {
            setState(() => _notes.insert(idx.clamp(0, _notes.length), note));
            _saveNotes();
          },
        ),
      ),
    );
  }

  void _togglePin(TodoItem note) {
    _updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  void _changeColor(TodoItem note, int colorIndex) {
    _updateNote(note.copyWith(colorIndex: colorIndex));
  }

  void _toggleChecklistItem(TodoItem note, String itemId) {
    final items = note.checklistItems.map((c) {
      if (c.id == itemId) return c.copyWith(isDone: !c.isDone);
      return c;
    }).toList();
    _updateNote(note.copyWith(checklistItems: items));
  }

  // --- UI helpers ---

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (_isSearchOpen) {
        _searchAnimController.forward();
      } else {
        _searchAnimController.reverse();
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _toggleViewMode() {
    setState(() => _isGridView = !_isGridView);
    LocalStorageService.setKeepNotesGridView(_isGridView);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'personal':
        return Icons.person_outline;
      case 'work':
        return Icons.work_outline;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.favorite_outline;
      case 'diet':
        return Icons.restaurant_outlined;
      case 'exercise':
        return Icons.fitness_center;
      case 'appointment':
        return Icons.calendar_today_outlined;
      case 'self-care':
        return Icons.spa_outlined;
      default:
        return Icons.note_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'personal':
        return AppColors.primary;
      case 'work':
        return AppColors.info;
      case 'shopping':
        return AppColors.phaseOvulation;
      case 'health':
        return AppColors.phaseMenstrual;
      case 'diet':
        return AppColors.phaseFollicular;
      case 'exercise':
        return AppColors.phaseOvulation;
      case 'appointment':
        return AppColors.info;
      case 'self-care':
        return AppColors.phaseLuteal;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    if (s.contains('-')) {
      return s
          .split('-')
          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    }
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  // --- Due date helpers ---

  Color _dueDateColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    if (due.isBefore(today)) return AppColors.error;
    if (due.isAtSameMomentAs(today)) return AppColors.warning;
    return AppColors.phaseFollicular;
  }

  String _dueDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    final diff = due.difference(today).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('MMM d').format(date);
  }

  // ========================
  // BUILD
  // ========================

  @override
  Widget build(BuildContext context) {
    final pinned = _pinnedNotes;
    final others = _otherNotes;
    final hasNotes = pinned.isNotEmpty || others.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Keep Notes',
          style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearchOpen ? 'Close search' : 'Search notes',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          SizeTransition(
            sizeFactor: _searchAnim,
            axisAlignment: -1,
            child: Container(
              color: AppColors.surface,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle:
                      AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: AppTextStyles.body1,
              ),
            ),
          ),

          // Category chips
          _buildCategoryChips(),

          // Notes body
          Expanded(
            child: hasNotes
                ? _buildNotesBody(pinned, others)
                : EmptyStateWidget(
                    icon: Icons.note_add_outlined,
                    title: _searchQuery.isNotEmpty
                        ? 'No matching notes'
                        : _selectedCategory != 'all'
                            ? 'No ${_capitalize(_selectedCategory)} notes'
                            : 'No notes yet',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try a different search term.'
                        : 'Tap + to create your first note.',
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSheet(null),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Category chips ---

  Widget _buildCategoryChips() {
    final cats = <(String, String)>[
      ('all', 'All'),
      ('personal', 'Personal'),
      ('work', 'Work'),
      ('shopping', 'Shopping'),
      ('health', 'Health'),
      ('diet', 'Diet'),
      ('exercise', 'Exercise'),
      ('appointment', 'Appt'),
      ('self-care', 'Self Care'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.pageHorizontal,
        child: Row(
          children: cats.map((cat) {
            final isSelected = _selectedCategory == cat.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.$2),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _selectedCategory = cat.$1),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.body2.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textBody,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                backgroundColor: AppColors.surface,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Notes body with sections ---

  Widget _buildNotesBody(List<TodoItem> pinned, List<TodoItem> others) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (pinned.isNotEmpty) ...[
          _sectionHeader('Pinned', Icons.push_pin),
          _isGridView
              ? _buildGrid(pinned)
              : _buildList(pinned),
        ],
        if (others.isNotEmpty) ...[
          if (pinned.isNotEmpty) _sectionHeader('Others', null),
          _isGridView
              ? _buildGrid(others)
              : _buildList(others),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              fontSize: 12,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // --- Grid view ---

  Widget _buildGrid(List<TodoItem> notes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        children: notes.map((note) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 36) / 2,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _buildGridCard(note),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridCard(TodoItem note) {
    final bgColor = kNoteColors[note.colorIndex.clamp(0, kNoteColors.length - 1)];
    final catColor = _getCategoryColor(note.category);

    return GestureDetector(
      onTap: () => _showAddEditSheet(note),
      onLongPress: () => _showLongPressMenu(note),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: category chip + pin
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getCategoryIcon(note.category),
                          size: 10, color: catColor),
                      const SizedBox(width: 3),
                      Text(
                        _capitalize(note.category),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: catColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (note.isPinned)
                  Icon(Icons.push_pin,
                      size: 14, color: AppColors.textMuted),
              ],
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              note.title,
              style: AppTextStyles.subtitle1.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Content preview
            if (note.noteType == NoteType.checklist &&
                note.checklistItems.isNotEmpty)
              ...note.checklistItems.take(3).map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: GestureDetector(
                      onTap: () => _toggleChecklistItem(note, c.id),
                      child: Row(
                        children: [
                          Icon(
                            c.isDone
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 14,
                            color: c.isDone
                                ? AppColors.textMuted
                                : AppColors.textBody,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.text,
                              style: AppTextStyles.caption.copyWith(
                                color: c.isDone
                                    ? AppColors.textMuted
                                    : AppColors.textBody,
                                decoration: c.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            else if (note.description != null &&
                note.description!.isNotEmpty)
              Text(
                note.description!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textBody,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

            // Due date
            if (note.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 12, color: _dueDateColor(note.dueDate!)),
                  const SizedBox(width: 4),
                  Text(
                    _dueDateLabel(note.dueDate!),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: _dueDateColor(note.dueDate!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- List view ---

  Widget _buildList(List<TodoItem> notes) {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Column(
        children: notes.map((note) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
            child: _buildListCard(note),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListCard(TodoItem note) {
    final bgColor = kNoteColors[note.colorIndex.clamp(0, kNoteColors.length - 1)];
    final catColor = _getCategoryColor(note.category);
    final accentColor =
        kNoteColorsDark[note.colorIndex.clamp(0, kNoteColorsDark.length - 1)];

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child:
            const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _deleteNote(note),
      child: GestureDetector(
        onTap: () => _showAddEditSheet(note),
        onLongPress: () => _showLongPressMenu(note),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border:
                Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: AppColors.cardShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left color bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: note.colorIndex == 0 ? catColor : accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.cardRadius),
                      bottomLeft: Radius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                style: AppTextStyles.subtitle1.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (note.isPinned)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(Icons.push_pin,
                                    size: 16, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Preview
                        if (note.noteType == NoteType.checklist &&
                            note.checklistItems.isNotEmpty)
                          Text(
                            '${note.checklistItems.where((c) => c.isDone).length}/${note.checklistItems.length} completed',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textBody,
                            ),
                          )
                        else if (note.description != null &&
                            note.description!.isNotEmpty)
                          Text(
                            note.description!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textBody,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        // Bottom row: category + due date
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.chipRadius),
                              ),
                              child: Text(
                                _capitalize(note.category),
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  color: catColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (note.dueDate != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule,
                                      size: 12,
                                      color:
                                          _dueDateColor(note.dueDate!)),
                                  const SizedBox(width: 3),
                                  Text(
                                    _dueDateLabel(note.dueDate!),
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10,
                                      color:
                                          _dueDateColor(note.dueDate!),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // LONG-PRESS MENU
  // ========================

  void _showLongPressMenu(TodoItem note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(note.isPinned ? 'Unpin' : 'Pin to top'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _togglePin(note);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.palette_outlined, color: AppColors.primary),
                  title: const Text('Change color'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showColorPicker(note);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deleteNote(note);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker(TodoItem note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 16),
                Text('Pick a color', style: AppTextStyles.subtitle1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(kNoteColors.length, (i) {
                    final isSelected = note.colorIndex == i;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _changeColor(note, i);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kNoteColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 18, color: AppColors.primary)
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========================
  // ADD / EDIT BOTTOM SHEET
  // ========================

  void _showAddEditSheet(TodoItem? existing) {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    var noteType = existing?.noteType ?? NoteType.note;
    var category = existing?.category ?? 'personal';
    var colorIndex = existing?.colorIndex ?? 0;
    var isPinned = existing?.isPinned ?? false;
    DateTime? dueDate = existing?.dueDate;
    var checklistItems =
        List<ChecklistItem>.from(existing?.checklistItems ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void addChecklistItem() {
              setSheetState(() {
                checklistItems.add(ChecklistItem(
                  id: const Uuid().v4(),
                  text: '',
                ));
              });
            }

            void removeChecklistItem(int index) {
              setSheetState(() => checklistItems.removeAt(index));
            }

            void saveNote() {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;

              // Clean up empty checklist items
              final cleanedChecklist = checklistItems
                  .where((c) => c.text.trim().isNotEmpty)
                  .toList();

              final now = DateTime.now();
              if (isEdit) {
                _updateNote(existing.copyWith(
                  title: title,
                  description: descCtrl.text.trim().isNotEmpty
                      ? descCtrl.text.trim()
                      : null,
                  noteType: noteType,
                  category: category,
                  colorIndex: colorIndex,
                  isPinned: isPinned,
                  dueDate: dueDate,
                  clearDueDate: dueDate == null,
                  checklistItems: cleanedChecklist,
                  updatedAt: now,
                ));
              } else {
                _addNote(TodoItem(
                  id: const Uuid().v4(),
                  title: title,
                  description: descCtrl.text.trim().isNotEmpty
                      ? descCtrl.text.trim()
                      : null,
                  noteType: noteType,
                  category: category,
                  colorIndex: colorIndex,
                  isPinned: isPinned,
                  dueDate: dueDate,
                  checklistItems: cleanedChecklist,
                  createdAt: now,
                  updatedAt: now,
                ));
              }
              Navigator.pop(context);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
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
                    const SizedBox(height: 16),

                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Note' : 'New Note',
                          style: AppTextStyles.h2,
                        ),
                        IconButton(
                          icon: Icon(
                            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: isPinned
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          onPressed: () =>
                              setSheetState(() => isPinned = !isPinned),
                          tooltip: isPinned ? 'Unpin' : 'Pin',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: AppTextStyles.body2
                            .copyWith(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.cardRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      style: AppTextStyles.body1,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 12),

                    // Note type toggle
                    Row(
                      children: [
                        _noteTypeChip(
                          'Note',
                          Icons.notes,
                          noteType == NoteType.note,
                          () => setSheetState(() => noteType = NoteType.note),
                        ),
                        const SizedBox(width: 8),
                        _noteTypeChip(
                          'Checklist',
                          Icons.checklist,
                          noteType == NoteType.checklist,
                          () => setSheetState(
                              () => noteType = NoteType.checklist),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description or checklist
                    if (noteType == NoteType.note)
                      TextField(
                        controller: descCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your note...',
                          hintStyle: AppTextStyles.body2
                              .copyWith(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.cardRadius),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: AppTextStyles.body1,
                        textCapitalization: TextCapitalization.sentences,
                      )
                    else ...[
                      // Checklist editor
                      ...List.generate(checklistItems.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    checklistItems[i] = checklistItems[i]
                                        .copyWith(
                                            isDone:
                                                !checklistItems[i].isDone);
                                  });
                                },
                                child: Icon(
                                  checklistItems[i].isDone
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 20,
                                  color: checklistItems[i].isDone
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: checklistItems[i].text,
                                  onChanged: (v) {
                                    checklistItems[i] =
                                        checklistItems[i].copyWith(text: v);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Item ${i + 1}',
                                    hintStyle: AppTextStyles.body2.copyWith(
                                        color: AppColors.textMuted),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 8),
                                  ),
                                  style: AppTextStyles.body2.copyWith(
                                    decoration: checklistItems[i].isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => removeChecklistItem(i),
                                child: const Icon(Icons.close,
                                    size: 18, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: addChecklistItem,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.add,
                                  size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Add item',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Category
                    Text('Category', style: AppTextStyles.subtitle2),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TodoItem.categories.map((cat) {
                        final isSelected = category == cat;
                        return ChoiceChip(
                          label: Text(_capitalize(cat)),
                          selected: isSelected,
                          onSelected: (_) =>
                              setSheetState(() => category = cat),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          labelStyle: AppTextStyles.body2.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textBody,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.chipRadius),
                          ),
                          backgroundColor: AppColors.surface,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Color picker
                    Text('Color', style: AppTextStyles.subtitle2),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(kNoteColors.length, (i) {
                        final isSelected = colorIndex == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () =>
                                setSheetState(() => colorIndex = i),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: kNoteColors[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 16, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Due date
                    Row(
                      children: [
                        Text('Due date', style: AppTextStyles.subtitle2),
                        const Spacer(),
                        if (dueDate != null) ...[
                          Text(
                            DateFormat('MMM d, yyyy').format(dueDate!),
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                setSheetState(() => dueDate = null),
                            child: const Icon(Icons.close,
                                size: 18, color: AppColors.textMuted),
                          ),
                        ],
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: dueDate ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 3)),
                            );
                            if (picked != null) {
                              setSheetState(() => dueDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.chipRadius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  dueDate == null ? 'Set date' : 'Change',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.buttonRadius),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Update Note' : 'Save Note',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _noteTypeChip(
      String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color:
                    isSelected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textBody,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

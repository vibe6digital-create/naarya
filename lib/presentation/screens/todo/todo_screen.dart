import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/todo_item_model.dart';
import '../../widgets/common/naarya_button.dart';
import '../../widgets/common/empty_state_widget.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _selectedCategory = 'all';
  late List<TodoItem> _todos;

  @override
  void initState() {
    super.initState();
    _todos = _buildMockTodos();
  }

  List<TodoItem> _buildMockTodos() {
    final now = DateTime.now();
    return [
      TodoItem(
        id: const Uuid().v4(),
        title: 'Schedule annual gynecologist visit',
        description: 'Book appointment for routine check-up',
        isDone: false,
        category: 'appointment',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TodoItem(
        id: const Uuid().v4(),
        title: 'Drink 8 glasses of water',
        description: 'Stay hydrated throughout the day',
        isDone: true,
        category: 'health',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TodoItem(
        id: const Uuid().v4(),
        title: '30 min morning yoga',
        description: 'Follow the beginner flow routine',
        isDone: false,
        category: 'exercise',
        createdAt: now,
      ),
      TodoItem(
        id: const Uuid().v4(),
        title: 'Prepare iron-rich lunch',
        description: 'Spinach salad with lentils and quinoa',
        isDone: false,
        category: 'diet',
        createdAt: now,
      ),
      TodoItem(
        id: const Uuid().v4(),
        title: 'Evening skincare routine',
        description: 'Cleanse, tone, moisturise, SPF',
        isDone: false,
        category: 'self-care',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }

  List<TodoItem> get _filteredTodos {
    if (_selectedCategory == 'all') return _todos;
    return _todos.where((t) => t.category == _selectedCategory).toList();
  }

  int get _completedCount => _todos.where((t) => t.isDone).length;

  double get _progress => _todos.isEmpty ? 0 : _completedCount / _todos.length;

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'health':
        return Icons.favorite;
      case 'diet':
        return Icons.restaurant;
      case 'exercise':
        return Icons.fitness_center;
      case 'appointment':
        return Icons.calendar_today;
      case 'self-care':
        return Icons.spa;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
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

  void _toggleTodo(TodoItem item) {
    setState(() {
      final idx = _todos.indexOf(item);
      if (idx >= 0) {
        _todos[idx] = item.copyWith(isDone: !item.isDone);
      }
    });
  }

  void _deleteTodo(TodoItem item) {
    final idx = _todos.indexOf(item);
    setState(() => _todos.remove(item));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('\"${item.title}\" removed'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.phaseOvulation,
          onPressed: () {
            setState(() => _todos.insert(idx, item));
          },
        ),
      ),
    );
  }

  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'health';

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
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                  const SizedBox(height: 20),
                  Text('New Health Task', style: AppTextStyles.h2),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Task title',
                      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: AppTextStyles.subtitle1),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TodoItem.categories.map((cat) {
                      final isSelected = category == cat;
                      return ChoiceChip(
                        label: Text(_capitalize(cat)),
                        selected: isSelected,
                        onSelected: (_) {
                          setSheetState(() => category = cat);
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: AppTextStyles.body2.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textBody,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                        ),
                        backgroundColor: AppColors.surface,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  NaaryaButton(
                    text: 'Add Task',
                    icon: Icons.add,
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      setState(() {
                        _todos.add(TodoItem(
                          id: const Uuid().v4(),
                          title: titleController.text.trim(),
                          description: descController.text.trim().isNotEmpty
                              ? descController.text.trim()
                              : null,
                          category: category,
                          createdAt: DateTime.now(),
                        ));
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    if (s.contains('-')) {
      return s.split('-').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    }
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Health Tasks', style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          _buildCategoryChips(),
          Expanded(
            child: _filteredTodos.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.task_alt,
                    title: 'No tasks here',
                    subtitle: _selectedCategory != 'all'
                        ? 'No ${_capitalize(_selectedCategory)} tasks yet.'
                        : 'Tap + to add your first health task.',
                  )
                : ListView.builder(
                    padding: AppSpacing.pagePadding,
                    itemCount: _filteredTodos.length,
                    itemBuilder: (context, index) {
                      return _buildTodoCard(_filteredTodos[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: AppTextStyles.subtitle1,
              ),
              Text(
                '$_completedCount / ${_todos.length} done',
                style: AppTextStyles.subtitle2.copyWith(
                  color: _progress >= 1.0 ? AppColors.success : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(
                    _progress >= 1.0 ? AppColors.success : AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = <(String, String)>[
      ('all', 'All'),
      ('health', 'Health'),
      ('diet', 'Diet'),
      ('exercise', 'Exercise'),
      ('appointment', 'Appointment'),
      ('self-care', 'Self Care'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.pageHorizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.$2),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedCategory = cat.$1);
                },
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
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                backgroundColor: AppColors.surface,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTodoCard(TodoItem item) {
    final catColor = _getCategoryColor(item.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
      child: Dismissible(
        key: ValueKey(item.id),
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
        onDismissed: (_) => _deleteTodo(item),
        child: GestureDetector(
          onTap: () => _toggleTodo(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.isDone
                  ? AppColors.success.withValues(alpha: 0.05)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: item.isDone
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: item.isDone ? null : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                // Animated checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.isDone ? AppColors.success : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.isDone ? AppColors.success : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: item.isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: AppTextStyles.subtitle1.copyWith(
                          decoration: item.isDone ? TextDecoration.lineThrough : null,
                          color: item.isDone ? AppColors.textMuted : AppColors.textDark,
                        ),
                        child: Text(item.title),
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: AppTextStyles.caption.copyWith(
                            color: item.isDone ? AppColors.textMuted : AppColors.textBody,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getCategoryIcon(item.category), size: 12, color: catColor),
                      const SizedBox(width: 4),
                      Text(
                        _capitalize(item.category),
                        style: AppTextStyles.caption.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

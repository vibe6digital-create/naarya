class TodoItem {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final String category;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.category = 'health',
    required this.createdAt,
  });

  TodoItem copyWith({
    String? title,
    String? description,
    bool? isDone,
    String? category,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      createdAt: createdAt,
    );
  }

  static const List<String> categories = [
    'health',
    'diet',
    'exercise',
    'appointment',
    'self-care',
  ];
}

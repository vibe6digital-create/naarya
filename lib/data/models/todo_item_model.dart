enum NoteType { note, checklist }

class ChecklistItem {
  final String id;
  final String text;
  final bool isDone;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  ChecklistItem copyWith({String? text, bool? isDone}) {
    return ChecklistItem(
      id: id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isDone': isDone,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

class TodoItem {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteType noteType;
  final bool isPinned;
  final int colorIndex;
  final DateTime? dueDate;
  final List<ChecklistItem> checklistItems;

  const TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.category = 'personal',
    required this.createdAt,
    DateTime? updatedAt,
    this.noteType = NoteType.note,
    this.isPinned = false,
    this.colorIndex = 0,
    this.dueDate,
    this.checklistItems = const [],
  }) : updatedAt = updatedAt ?? createdAt;

  TodoItem copyWith({
    String? title,
    String? description,
    bool? isDone,
    String? category,
    DateTime? updatedAt,
    NoteType? noteType,
    bool? isPinned,
    int? colorIndex,
    DateTime? dueDate,
    bool clearDueDate = false,
    List<ChecklistItem>? checklistItems,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      noteType: noteType ?? this.noteType,
      isPinned: isPinned ?? this.isPinned,
      colorIndex: colorIndex ?? this.colorIndex,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      checklistItems: checklistItems ?? this.checklistItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isDone': isDone,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'noteType': noteType.name,
        'isPinned': isPinned,
        'colorIndex': colorIndex,
        'dueDate': dueDate?.toIso8601String(),
        'checklistItems': checklistItems.map((e) => e.toJson()).toList(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isDone: json['isDone'] as bool? ?? false,
      category: json['category'] as String? ?? 'personal',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      noteType: json['noteType'] == 'checklist'
          ? NoteType.checklist
          : NoteType.note,
      isPinned: json['isPinned'] as bool? ?? false,
      colorIndex: json['colorIndex'] as int? ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      checklistItems: json['checklistItems'] != null
          ? (json['checklistItems'] as List)
              .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  static const List<String> categories = [
    'personal',
    'work',
    'shopping',
    'health',
    'diet',
    'exercise',
    'appointment',
    'self-care',
  ];
}

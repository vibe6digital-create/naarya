class CommunityPost {
  final String id;
  final String authorName;
  final String title;
  final String body;
  final String category;
  final DateTime timestamp;
  final int likesCount;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.likesCount = 0,
  });
}

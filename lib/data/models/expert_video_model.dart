import 'package:cloud_firestore/cloud_firestore.dart';

enum VideoType { youtube, storage }

/// Firestore structure:
///
///   expertVideos (collection)
///   └── {videoId} (document)
///         ├── title        : string   — "Basic Yoga for Everyday Exercise"
///         ├── instructor   : string   — "with Rupali"
///         ├── type         : string   — "youtube" | "storage"
///         ├── url          : string   — YouTube URL or Firebase Storage URL
///         ├── thumbnailUrl : string?  — custom thumbnail (required for storage videos)
///         ├── isActive     : bool     — set false to hide
///         └── order        : number   — display sort order
///
/// YouTube example:
///   type: "youtube", url: "https://youtu.be/5IfeDR9y7xs"
///
/// Pre-recorded example:
///   type: "storage", url: "https://firebasestorage.googleapis.com/...",
///   thumbnailUrl: "https://firebasestorage.googleapis.com/..."

class ExpertVideoModel {
  final String id;
  final String title;
  final String instructor;
  final VideoType type;
  final String url;
  final String? thumbnailUrl;
  final int order;

  const ExpertVideoModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.order = 0,
  });

  /// For YouTube videos, extracts the video ID for thumbnail lookup.
  String? get youtubeVideoId {
    if (type != VideoType.youtube) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
    if (uri.host.contains('youtube.com')) return uri.queryParameters['v'];
    return null;
  }

  /// Returns the best available thumbnail URL.
  String? get resolvedThumbnail {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) return thumbnailUrl;
    final ytId = youtubeVideoId;
    if (ytId != null) return 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    return null;
  }

  factory ExpertVideoModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ExpertVideoModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      instructor: d['instructor'] as String? ?? '',
      type: (d['type'] as String? ?? 'youtube') == 'storage'
          ? VideoType.storage
          : VideoType.youtube,
      url: d['url'] as String? ?? '',
      thumbnailUrl: (d['thumbnailUrl'] as String?)?.isEmpty == true
          ? null
          : d['thumbnailUrl'] as String?,
      order: (d['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class CancerInfoModel {
  final String id;
  final String title;
  final String category; // cervical, breast, ovarian, endometrial, vulval
  final String summary;
  final String contentAssetPath;
  final List<String> warningSigns;
  final List<String> screeningGuidelines;

  const CancerInfoModel({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.contentAssetPath,
    this.warningSigns = const [],
    this.screeningGuidelines = const [],
  });
}

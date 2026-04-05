import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/community_post_model.dart';
import '../../widgets/common/naarya_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _mainTab = 0; // 0 = Expert Posts, 1 = Community Stories

  static const List<String> _categories = [
    'All', 'PCOS', 'Fertility', 'Menopause', 'Cancer Screening', 'General',
  ];

  // User community stories
  final List<_UserStory> _userStories = [
    _UserStory(
      initials: 'A',
      name: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      body: 'After tracking my cycle for 3 months with this app, I finally understood why I feel so low on energy before my period. Now I plan light activities during luteal phase and feel so much better!',
      likes: 18,
      tag: 'Cycle',
    ),
    _UserStory(
      initials: 'P',
      name: 'Preethi M.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      body: 'The AI assistant helped me understand my PCOS symptoms better. It\'s like having a health friend available 24/7. Highly recommend logging your symptoms regularly!',
      likes: 34,
      tag: 'PCOS',
    ),
    _UserStory(
      initials: 'R',
      name: 'Renu S.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      body: 'I started the yoga sessions from Fitness section during my follicular phase and I cannot believe the difference in my energy and mood. The phase-based workouts actually work!',
      likes: 51,
      tag: 'Fitness',
    ),
    _UserStory(
      initials: 'S',
      name: 'Anonymous',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      body: 'Going through perimenopause and feeling isolated. Found this community and realised so many of us face the same things. Thank you Naarya for creating this safe space.',
      likes: 76,
      tag: 'Menopause',
    ),
    _UserStory(
      initials: 'N',
      name: 'Neha K.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      body: 'Reminder feature saved me from missing my iron supplement for 2 weeks straight! Small things like this make such a big difference to daily health.',
      likes: 22,
      tag: 'General',
    ),
  ];

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: '1',
      authorName: 'Dr. Niyati',
      title: 'Understanding PCOS: Common Myths',
      body:
          'PCOS (Polycystic Ovary Syndrome) affects millions of women worldwide, yet it remains widely misunderstood. '
          'One of the most common myths is that PCOS only affects overweight women. In reality, women of all body types '
          'can have PCOS. Another myth is that you cannot get pregnant with PCOS — while it can make conception more '
          'challenging, many women with PCOS conceive naturally or with treatment. It is also incorrectly believed that '
          'PCOS is caused by something you did wrong. PCOS has a strong genetic component and is influenced by hormonal '
          'imbalances. Understanding the facts helps you make better decisions about your health.',
      category: 'PCOS',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      likesCount: 42,
    ),
    CommunityPost(
      id: '2',
      authorName: 'Dr. Priya',
      title: 'When to Start Fertility Planning',
      body:
          'Fertility planning is a topic that many couples put off until they are ready to conceive, but understanding '
          'your fertility early can be incredibly empowering. Ideally, women should start thinking about fertility in '
          'their late twenties or early thirties. Simple tests like AMH levels can give you a snapshot of your ovarian '
          'reserve. Tracking your menstrual cycle, maintaining a healthy weight, and avoiding smoking are all steps you '
          'can take today. If you have irregular periods or conditions like PCOS or endometriosis, consulting a fertility '
          'specialist sooner rather than later is advisable.',
      category: 'Fertility',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      likesCount: 35,
    ),
    CommunityPost(
      id: '3',
      authorName: 'Dr. Niyati',
      title: 'Managing Menopause Symptoms Naturally',
      body:
          'Menopause is a natural transition that every woman goes through, typically between the ages of 45 and 55. '
          'Common symptoms include hot flashes, night sweats, mood swings, and sleep disturbances. Regular exercise, '
          'particularly yoga and walking, can significantly reduce hot flashes and improve mood. A diet rich in '
          'phytoestrogens may help balance hormones naturally. Always consult your doctor before making significant '
          'changes to your health routine.',
      category: 'Menopause',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 58,
    ),
    CommunityPost(
      id: '4',
      authorName: 'Dr. Priya',
      title: 'Importance of Regular Cancer Screening',
      body:
          'Cancer screening is one of the most powerful tools we have for early detection and prevention. For women, '
          'regular Pap smears starting at age 21 can detect cervical cancer early when it is most treatable. Mammograms '
          'are recommended starting at age 40. HPV vaccination is highly effective at preventing cervical cancer. '
          'Early detection saves lives — talk to your doctor about a screening schedule right for you.',
      category: 'Cancer Screening',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      likesCount: 73,
    ),
    CommunityPost(
      id: '5',
      authorName: 'Dr. Niyati',
      title: 'Best Foods During Your Period',
      body:
          'What you eat during your period can significantly impact how you feel. Iron-rich foods like spinach, lentils, '
          'and lean red meat help replenish iron lost through menstrual bleeding. Dark chocolate contains magnesium which '
          'can help reduce cramps. Bananas are rich in potassium and vitamin B6, which help reduce bloating and cramping. '
          'Ginger tea is a natural anti-inflammatory that can ease period pain.',
      category: 'General',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      likesCount: 91,
    ),
    CommunityPost(
      id: '6',
      authorName: 'Dr. Priya',
      title: 'Yoga for Hormonal Balance',
      body:
          'Yoga has been practiced for thousands of years and modern research supports its benefits for hormonal health. '
          'Poses like Bhujangasana stimulate the adrenal glands, while Setu Bandhasana supports thyroid function. '
          'Pranayama like Nadi Shodhana balances the nervous system and promotes hormonal equilibrium. Practicing yoga '
          'for just 20–30 minutes daily can help regulate menstrual cycles and reduce PMS symptoms.',
      category: 'General',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      likesCount: 64,
    ),
  ];

  final List<bool> _storyLiked = List.filled(5, false);

  // Local comments per story (index → list of comment strings)
  final List<List<String>> _storyComments = List.generate(5, (_) => []);

  void _showCommentSheet(int storyIndex) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Comments', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              if (_storyComments[storyIndex].isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No comments yet. Be the first!',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textMuted)),
                )
              else
                ...(_storyComments[storyIndex].map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.surfaceVariant,
                        child: const Icon(Icons.person_rounded,
                            color: AppColors.textMuted, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(c, style: AppTextStyles.body2),
                        ),
                      ),
                    ],
                  ),
                ))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textLight),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      style: AppTextStyles.body2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      setSheetState(() {
                        _storyComments[storyIndex].add(text);
                      });
                      setState(() {});
                      controller.clear();
                    },
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CommunityPost> get _filteredPosts {
    if (_tabController.index == 0) return _posts;
    final category = _categories[_tabController.index];
    return _posts.where((p) => p.category == category).toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'PCOS':            return AppColors.primary;
      case 'Fertility':       return AppColors.success;
      case 'Menopause':       return AppColors.warning;
      case 'Cancer Screening':return AppColors.error;
      case 'General':         return AppColors.info;
      case 'Cycle':           return AppColors.phaseMenstrual;
      case 'Fitness':         return AppColors.phaseFollicular;
      default:                return AppColors.textMuted;
    }
  }

  void _showPostDetail(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _categoryColor(post.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(post.category,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: _categoryColor(post.category), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(post.title, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(post.authorName[0],
                        style: AppTextStyles.subtitle2.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName, style: AppTextStyles.subtitle1),
                        Text(AppDateUtils.timeAgo(post.timestamp), style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.favorite, color: AppColors.error, size: 18),
                  const SizedBox(width: 4),
                  Text('${post.likesCount}', style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Text(post.body, style: AppTextStyles.body1),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareStory() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Share Your Story', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text('Your experience helps other women. Post anonymously.',
                style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share what helped you, what you learned, or just how you feel...',
                hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your story has been shared! Thank you for inspiring others.',
                          style: AppTextStyles.body2.copyWith(color: Colors.white)),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                ),
                child: Text('Post Anonymously', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAskQuestion() {
    final questionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Ask a Question', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text('Reviewed by our panel of experts.',
                style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: questionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your question here...',
                hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Question submitted! Our experts will respond soon.',
                        style: AppTextStyles.body2.copyWith(color: Colors.white),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                ),
                child: Text('Submit Anonymously', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Community', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // WhatsApp Community Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: () => WhatsappService.openChat(
                phoneNumber: AppConstants.whatsappNumber,
                message: 'Hi! I\'d like to join the Naarya women\'s community.',
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Join Naarya WhatsApp Community',
                              style: AppTextStyles.subtitle2.copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w700)),
                          Text('Connect directly with women & our experts',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tab row: Expert Posts / Community Stories
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildMainTabButton('Expert Posts', 0),
                _buildMainTabButton('Stories', 1),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: _mainTab == 0 ? _buildExpertPostsTab() : _buildStoriesTab(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mainTab == 0 ? _showAskQuestion : _showShareStory,
        backgroundColor: AppColors.primary,
        icon: Icon(_mainTab == 0 ? Icons.help_outline_rounded : Icons.edit_rounded,
            color: Colors.white),
        label: Text(
          _mainTab == 0 ? 'Ask a Question' : 'Share Story',
          style: AppTextStyles.buttonSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMainTabButton(String label, int index) {
    final isActive = _mainTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mainTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle2.copyWith(
              color: isActive ? Colors.white : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpertPostsTab() {
    final filteredPosts = _filteredPosts;
    return Column(
      children: [
        // Category tabs
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.subtitle2,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          dividerColor: AppColors.divider,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
        Expanded(
          child: filteredPosts.isEmpty
              ? const Center(child: Text('No posts in this category yet.'))
              : ListView.separated(
                  padding: AppSpacing.pagePadding,
                  itemCount: filteredPosts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.componentGap),
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    final excerpt = post.body.length > 100
                        ? '${post.body.substring(0, 100)}...'
                        : post.body;
                    return NaaryaCard(
                      onTap: () => _showPostDetail(post),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                child: Text(post.authorName[0],
                                    style: AppTextStyles.subtitle2
                                        .copyWith(color: AppColors.primary)),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.authorName,
                                        style: AppTextStyles.subtitle2.copyWith(
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.w600)),
                                    Text(AppDateUtils.timeAgo(post.timestamp),
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _categoryColor(post.category)
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.chipRadius),
                                ),
                                child: Text(post.category,
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: _categoryColor(post.category),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(post.title,
                              style: AppTextStyles.subtitle1
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(excerpt,
                              style: AppTextStyles.body2
                                  .copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Icon(Icons.favorite, color: AppColors.error, size: 16),
                              const SizedBox(width: 4),
                              Text('${post.likesCount}',
                                  style: AppTextStyles.caption),
                              const Spacer(),
                              Text('Read more',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios, size: 10,
                                  color: AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStoriesTab() {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: _userStories.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.componentGap),
      itemBuilder: (context, index) {
        final story = _userStories[index];
        final liked = _storyLiked[index];
        return NaaryaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                    child: Text(story.initials,
                        style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.primary)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(story.name,
                            style: AppTextStyles.subtitle2.copyWith(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600)),
                        Text(AppDateUtils.timeAgo(story.timestamp),
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _categoryColor(story.tag).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(story.tag,
                        style: AppTextStyles.caption.copyWith(
                            color: _categoryColor(story.tag),
                            fontWeight: FontWeight.w600, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(story.body,
                  style: AppTextStyles.body2.copyWith(color: AppColors.textBody)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _storyLiked[index] = !liked),
                    child: Row(
                      children: [
                        Icon(
                          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: liked ? AppColors.error : AppColors.textLight,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${story.likes + (liked ? 1 : 0)}',
                          style: AppTextStyles.caption.copyWith(
                              color: liked ? AppColors.error : AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showCommentSheet(index),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: AppColors.textLight, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _storyComments[index].isEmpty
                              ? 'Comment'
                              : '${_storyComments[index].length}',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserStory {
  final String initials;
  final String name;
  final DateTime timestamp;
  final String body;
  final int likes;
  final String tag;

  const _UserStory({
    required this.initials,
    required this.name,
    required this.timestamp,
    required this.body,
    required this.likes,
    required this.tag,
  });
}

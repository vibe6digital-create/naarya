import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/services/expert_service.dart';
import '../../../core/services/expert_video_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/expert_model.dart';
import '../../../data/models/expert_video_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../antenatal/story_viewer_screen.dart';
import '../fitness/video_player_screen.dart';
import 'take_a_break_screen.dart';

class MentalFitnessScreen extends StatefulWidget {
  const MentalFitnessScreen({super.key});

  @override
  State<MentalFitnessScreen> createState() => _MentalFitnessScreenState();
}

class _MentalFitnessScreenState extends State<MentalFitnessScreen> {
  static const _mauve = Color(0xFF7B52A8);
  static const _mauveLight = Color(0xFFEDE7F6);
  static const _mauveMid = Color(0xFFAB6DBC);

  // ── Story state ──
  final Set<int> _viewedStories = {};

  // ── Quiz state ──
  int _quizIndex = 0;
  int? _selectedOption;
  bool _quizDone = false;
  int _score = 0;

  // Self-assessment: options are scored 0–4 (Not at all → Nearly every day)
  static const List<String> _quizOptions = [
    'Not at all',
    'Several days',
    'A few days',
    'More than half the days',
    'Nearly every day',
  ];

  static const List<_QuizQuestion> _questions = [
    _QuizQuestion(
      question: 'Over the past 2 weeks, how often have you had little interest or pleasure in doing things you usually enjoy?',
      emoji: '😔',
    ),
    _QuizQuestion(
      question: 'Over the past 2 weeks, how often have you felt down, depressed, hopeless, or empty?',
      emoji: '🌧️',
    ),
    _QuizQuestion(
      question: 'Over the past 2 weeks, how often have you felt nervous, anxious, or on edge?',
      emoji: '😰',
    ),
    _QuizQuestion(
      question: 'Over the past 2 weeks, how often have you had trouble falling or staying asleep, or sleeping too much?',
      emoji: '😴',
    ),
    _QuizQuestion(
      question: 'Over the past 2 weeks, how often have you felt tired, fatigued, or had very little energy?',
      emoji: '🔋',
    ),
    _QuizQuestion(
      question: 'Over the past 2 weeks, how often have you had difficulty concentrating, remembering things, or making decisions?',
      emoji: '🧠',
    ),
  ];

  void _selectOption(int index) {
    if (_selectedOption != null) return;
    setState(() => _selectedOption = index);
  }

  void _nextQuestion() {
    final score = _selectedOption ?? 0;
    if (_quizIndex < _questions.length - 1) {
      setState(() {
        _score += score;
        _quizIndex++;
        _selectedOption = null;
      });
    } else {
      setState(() {
        _score += score;
        _quizDone = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _quizIndex = 0;
      _selectedOption = null;
      _quizDone = false;
      _score = 0;
    });
  }

  void _showVideoBottomSheet(ExpertVideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VideoPreviewSheet(
        video: video,
        onWatch: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(video: video),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mental Fitness', style: AppTextStyles.h2.copyWith(color: AppColors.textDark)),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // ── Hero Banner ──
          _buildHeroBanner(),
          const SizedBox(height: AppSpacing.sectionGap),

          // ── Meet Our Experts ──
          const SectionHeader(title: 'Meet Our Experts'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildExpertsSection(),
          const SizedBox(height: AppSpacing.sectionGap),

          // ── Expert Videos ──
          const SectionHeader(title: 'Expert Videos'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildVideosSection(),
          const SizedBox(height: AppSpacing.sectionGap),

          // ── Mental Health Stories ──
          const SectionHeader(title: 'Mental Health Reads'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildStoriesRow(),
          const SizedBox(height: AppSpacing.sectionGap),

          // ── Mental Health Quiz ──
          const SectionHeader(title: 'How Are You Feeling?'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildQuizSection(),
          const SizedBox(height: AppSpacing.sectionGap),

          // ── Take a Break? ──
          _buildTakeABreakCard(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Hero Banner
  // ────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _mauve.withValues(alpha: 0.92),
            _mauveMid.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Icon(
              Icons.psychology_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your Mind Matters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Mental health is not a destination — it\'s a practice. '
                'Explore expert guidance, educational content, and tools designed just for you.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatChip(label: '1 in 5', sub: 'women affected'),
                  const SizedBox(width: 8),
                  _StatChip(label: '70%', sub: 'go untreated'),
                  const SizedBox(width: 8),
                  _StatChip(label: '100%', sub: 'treatable'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Meet Our Experts (Firebase)
  // ────────────────────────────────────────────
  Widget _buildExpertsSection() {
    return StreamBuilder<List<ExpertModel>>(
      stream: ExpertService.expertsStreamForCategory('Mental Fitness'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => _DoctorCardSkeleton(),
            ),
          );
        }

        final experts = snapshot.data ?? [];

        if (experts.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
          return NaaryaCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _mauveLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_search_rounded, color: _mauve, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No experts available for this category.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: doctors.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _DoctorCard(expert: experts[i]),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────
  // Mental Health Brief
  // ────────────────────────────────────────────
  Widget _buildStoriesRow() {
    final stories = [
      (
        label: 'Mental\nHealth',
        icon: Icons.favorite_rounded,
        color: AppColors.primary,
        slides: [
          StorySlide(
            stepTitle: 'Why Mental Health Matters',
            stepBody:
                'Mental health encompasses our emotional, psychological, and social well-being. '
                'It shapes how we think, feel, and act — and how we handle stress, relate to others, '
                'and make choices.\n\n'
                'For women, hormonal changes across the menstrual cycle, pregnancy, postpartum, and '
                'menopause directly impact mood, cognition, and emotional resilience. Prioritising '
                'mental health is as essential as physical health.',
            backgroundColor: AppColors.primary,
            icon: Icons.favorite_rounded,
          ),
        ],
      ),
      (
        label: 'Warning\nSigns',
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
        slides: [
          StorySlide(
            stepTitle: 'Recognising the Signs',
            stepBody:
                'Common warning signs include persistent sadness, loss of interest in daily activities, '
                'excessive worry, sudden mood swings, sleep disturbances, fatigue, and difficulty '
                'concentrating.\n\n'
                'These are not weaknesses — they are signals from your body asking for care. '
                'Early recognition and intervention significantly improve outcomes.',
            backgroundColor: AppColors.warning,
            icon: Icons.warning_amber_rounded,
          ),
        ],
      ),
      (
        label: 'Coping\nTips',
        icon: Icons.spa_rounded,
        color: AppColors.success,
        slides: [
          StorySlide(
            stepTitle: 'Evidence-Based Coping Strategies',
            stepBody:
                '• Regular physical activity reduces depressive symptoms by up to 30%\n\n'
                '• Mindfulness meditation lowers cortisol (stress hormone) levels measurably\n\n'
                '• 7–9 hours of quality sleep restores emotional regulation\n\n'
                '• Social connection is a protective factor against anxiety and depression\n\n'
                '• Journaling helps process emotions and identify thought patterns',
            backgroundColor: AppColors.success,
            icon: Icons.spa_rounded,
          ),
        ],
      ),
    ];

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final story = stories[i];
          final isViewed = _viewedStories.contains(i);
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewerScreen(
                    slides: story.slides,
                    storyLabel: story.label.replaceAll('\n', ' '),
                  ),
                ),
              );
              setState(() => _viewedStories.add(i));
            },
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isViewed
                        ? null
                        : LinearGradient(
                            colors: [story.color, _mauveMid],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isViewed ? Colors.grey.shade300 : null,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: story.color.withValues(alpha: 0.12),
                      child: Icon(story.icon, color: story.color, size: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  story.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────
  // Expert Videos (Firebase)
  // ────────────────────────────────────────────
  Widget _buildVideosSection() {
    return StreamBuilder<List<ExpertVideoModel>>(
      stream: ExpertVideoService.videosStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Column(children: [
            _VideoCardSkeleton(),
            const SizedBox(height: AppSpacing.componentGap),
            _VideoCardSkeleton(),
          ]);
        }

        final videos = snap.data ?? [];

        if (videos.isEmpty) {
          return NaaryaCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _mauveLight, shape: BoxShape.circle),
                  child: const Icon(Icons.videocam_rounded, color: _mauve, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Expert videos will appear here.\nAdd videos in Firebase Console → "expertVideos" collection.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: videos.map((v) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
            child: _VideoCard(video: v, onTap: () => _showVideoBottomSheet(v)),
          )).toList(),
        );
      },
    );
  }

  // ────────────────────────────────────────────
  // Quiz
  // ────────────────────────────────────────────
  Widget _buildQuizSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: _mauve.withValues(alpha: 0.2)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _mauveLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                topRight: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _mauve.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz_rounded, color: _mauve, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _quizDone
                        ? 'Your Wellness Check'
                        : 'Question ${_quizIndex + 1} of ${_questions.length}',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: _mauve, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!_quizDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _mauve.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Past 2 weeks',
                      style: TextStyle(
                        fontSize: 10, color: _mauve, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: _quizDone ? _buildQuizResult() : _buildQuizBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBody() {
    final q = _questions[_quizIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _quizIndex / _questions.length,
            backgroundColor: _mauveLight,
            color: _mauve,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 18),

        // Emoji + question
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                q.question,
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Frequency options (scored 0–3)
        ...List.generate(_quizOptions.length, (i) {
          final isSelected = _selectedOption == i;
          return GestureDetector(
            onTap: () => _selectOption(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected ? _mauveLight : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _mauve : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? _mauve : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? _mauve : AppColors.textLight,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _quizOptions[i],
                      style: AppTextStyles.body2.copyWith(
                        color: isSelected ? _mauve : AppColors.textBody,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  // Frequency indicator dots
                  Row(
                    children: List.generate(4, (d) => Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: d < i
                            ? _mauve.withValues(alpha: isSelected ? 0.8 : 0.3)
                            : AppColors.border,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          );
        }),

        // Next button — shown after selection
        if (_selectedOption != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _mauve,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              child: Text(
                _quizIndex < _questions.length - 1 ? 'Next →' : 'See My Results',
                style: AppTextStyles.button.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],

        const SizedBox(height: 8),
        Center(
          child: Text(
            'This is a wellness check, not a clinical diagnosis.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight, fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizResult() {
    // Max score = 6 questions × 4 = 24
    // Tiers based on PHQ-9 / GAD-7 adapted ranges
    final String label;
    final String headline;
    final String message;
    final String suggestion;
    final IconData icon;
    final Color color;
    final Color bgColor;

    if (_score <= 6) {
      label = 'Thriving';
      headline = 'You\'re doing well 🌸';
      message =
          'Your responses suggest you\'re managing your emotional well-being effectively. '
          'Keep nurturing your mental health with daily self-care practices.';
      suggestion = 'Maintain your routine, stay connected with loved ones, and keep moving your body.';
      icon = Icons.favorite_rounded;
      color = AppColors.success;
      bgColor = AppColors.successLight;
    } else if (_score <= 12) {
      label = 'Mild Concern';
      headline = 'You\'re carrying some weight 🌤️';
      message =
          'You\'re experiencing some emotional stress in the past two weeks. '
          'This is common and manageable with the right support and habits.';
      suggestion = 'Try mindfulness, light exercise, or journaling. Consider speaking to a trusted person.';
      icon = Icons.wb_sunny_rounded;
      color = AppColors.warning;
      bgColor = AppColors.warningLight;
    } else if (_score <= 18) {
      label = 'Moderate Concern';
      headline = 'You deserve support 💜';
      message =
          'Your responses indicate moderate levels of distress. '
          'These feelings are valid — you don\'t have to navigate them alone.';
      suggestion = 'Speak with a mental health professional or counsellor. Small steps make a big difference.';
      icon = Icons.spa_rounded;
      color = _mauve;
      bgColor = _mauveLight;
    } else {
      label = 'Please Seek Support';
      headline = 'You\'re not alone 🤝';
      message =
          'Your responses suggest you may be experiencing significant distress. '
          'Please reach out to a mental health professional or someone you trust.';
      suggestion = 'Contact a counsellor, therapist, or your doctor. Seeking help is a sign of strength.';
      icon = Icons.support_rounded;
      color = AppColors.primary;
      bgColor = AppColors.surfaceVariant;
    }

    return Column(
      children: [
        // Score visual
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 38),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 12,
          )),
        ),
        const SizedBox(height: 10),
        Text(
          headline,
          style: AppTextStyles.h3.copyWith(color: AppColors.textDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: AppTextStyles.body2.copyWith(color: AppColors.textBody, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_rounded, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: AppTextStyles.caption.copyWith(
                    color: color, fontWeight: FontWeight.w600, height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Score: $_score / 24 · This is not a clinical diagnosis.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textLight, fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text('Retake Check-in', style: AppTextStyles.button.copyWith(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _mauve,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // Take a Break?
  // ────────────────────────────────────────────
  Widget _buildTakeABreakCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TakeABreakScreen()),
      ),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            _mauveMid.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  _mauve.withValues(alpha: 0.12),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.self_improvement_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take a Break?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Step away, breathe, and reset. '
                  'Rest is not a reward — it\'s part of healing.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    ),
    );
  }
}

// ──────────────────── Stat Chip ────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String sub;
  const _StatChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white,
          )),
          Text(sub, style: TextStyle(
            fontSize: 9.5, color: Colors.white.withValues(alpha: 0.82), fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}

// ──────────────────── Doctor Card ────────────────────

class _DoctorCard extends StatelessWidget {
  final ExpertModel expert;
  const _DoctorCard({required this.expert});

  static const _mauve = Color(0xFF7B52A8);
  static const _mauveLight = Color(0xFFEDE7F6);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _mauveLight,
              border: Border.all(color: _mauve.withValues(alpha: 0.25), width: 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: expert.photoUrl != null && expert.photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: expert.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Icon(Icons.person_rounded, color: _mauve, size: 28),
                    errorWidget: (_, _, _) => const Icon(Icons.person_rounded, color: _mauve, size: 28),
                  )
                : const Icon(Icons.person_rounded, color: _mauve, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            expert.name,
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            expert.specialties.isNotEmpty ? expert.specialties.first : '',
            style: AppTextStyles.caption.copyWith(color: _mauve, fontSize: 10),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: _mauveLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, color: _mauve, size: 12),
                SizedBox(width: 4),
                Text('Consult', style: TextStyle(
                  color: _mauve, fontWeight: FontWeight.w600, fontSize: 11,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 10, width: 100, decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(6),
          )),
          const SizedBox(height: 5),
          Container(height: 8, width: 70, decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(6),
          )),
          const Spacer(),
          Container(height: 28, decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          )),
        ],
      ),
    );
  }
}

// ──────────────────── Video Card ────────────────────

class _VideoCard extends StatelessWidget {
  final ExpertVideoModel video;
  final VoidCallback onTap;
  const _VideoCard({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.resolvedThumbnail;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 78,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  thumbnail != null
                      ? Image.network(thumbnail, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFFEDE7F6),
                            child: const Icon(Icons.play_circle_rounded, color: Color(0xFF7B52A8), size: 32),
                          ))
                      : Container(
                          color: const Color(0xFFEDE7F6),
                          child: const Icon(Icons.play_circle_rounded, color: Color(0xFF7B52A8), size: 32),
                        ),
                  Center(
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          video.type == VideoType.youtube
                              ? Icons.smart_display_rounded
                              : Icons.videocam_rounded,
                          size: 12,
                          color: video.type == VideoType.youtube
                              ? const Color(0xFFFF0000)
                              : const Color(0xFF7B52A8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.instructor,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }
}

class _VideoCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(width: 110, color: const Color(0xFFEEEEEE)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 10, decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(6),
                  )),
                  const SizedBox(height: 6),
                  Container(height: 8, width: 80, decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(6),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Video Preview Sheet ────────────────────

class _VideoPreviewSheet extends StatelessWidget {
  final ExpertVideoModel video;
  final VoidCallback onWatch;
  const _VideoPreviewSheet({required this.video, required this.onWatch});

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.resolvedThumbnail;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(thumbnail, height: 160, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 160,
                  color: const Color(0xFFEDE7F6),
                  child: const Icon(Icons.play_circle_rounded, color: Color(0xFF7B52A8), size: 48),
                )),
            ),
          const SizedBox(height: 14),
          Text(video.title, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(video.instructor, style: AppTextStyles.caption),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onWatch,
              icon: const Icon(Icons.play_circle_rounded, color: Colors.white, size: 20),
              label: Text('Watch Now', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B52A8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ──────────────────── Quiz Question Model ────────────────────

class _QuizQuestion {
  final String question;
  final String emoji;

  const _QuizQuestion({
    required this.question,
    required this.emoji,
  });
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/services/expert_video_service.dart';
import '../../../core/services/instructor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/expert_video_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../fitness/video_player_screen.dart';

class NaturopathyScreen extends StatefulWidget {
  const NaturopathyScreen({super.key});

  @override
  State<NaturopathyScreen> createState() => _NaturopathyScreenState();
}

class _NaturopathyScreenState extends State<NaturopathyScreen> {
  static const _green = Color(0xFF2E7D32);
  static const _greenLight = Color(0xFFE8F5E9);
  static const _greenMid = Color(0xFF43A047);

  // ── Quiz state ──
  int _quizIndex = 0;
  int? _selectedOption;
  bool _quizDone = false;
  int _score = 0;

  static const List<String> _quizOptions = [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Always',
  ];

  static const List<_QuizQuestion> _questions = [
    _QuizQuestion(
      question: 'Over the past month, how often do you eat whole, unprocessed foods (fruits, vegetables, whole grains)?',
      emoji: '🥗',
    ),
    _QuizQuestion(
      question: 'How often do you drink at least 8 glasses of water daily?',
      emoji: '💧',
    ),
    _QuizQuestion(
      question: 'How often do you spend time outdoors in natural sunlight for at least 20 minutes?',
      emoji: '☀️',
    ),
    _QuizQuestion(
      question: 'How often do you get 7–9 hours of restful, uninterrupted sleep?',
      emoji: '😴',
    ),
    _QuizQuestion(
      question: 'How often do you engage in moderate physical activity (walking, yoga, swimming)?',
      emoji: '🧘',
    ),
    _QuizQuestion(
      question: 'How often do you practise stress management (meditation, deep breathing, journaling)?',
      emoji: '🌿',
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
            MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
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
        title: Text('Naturopathy', style: AppTextStyles.h2.copyWith(color: AppColors.textDark)),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Meet Our Experts'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildExpertsSection(),
          const SizedBox(height: AppSpacing.sectionGap),

          _buildNaturopathyBrief(),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Expert Videos'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildVideosSection(),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Lifestyle Check-in'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildQuizSection(),
          const SizedBox(height: AppSpacing.sectionGap),

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
            _green.withValues(alpha: 0.90),
            _greenMid.withValues(alpha: 0.75),
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
              Icons.eco_rounded,
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
                    child: const Icon(Icons.spa_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nature Heals',
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
                'Naturopathy works with your body\'s innate healing intelligence — '
                'using food, herbs, water, sunlight, and lifestyle as medicine. '
                'No side effects. Just nature doing what it does best.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatChip(label: '6', sub: 'Core Principles'),
                  const SizedBox(width: 8),
                  _StatChip(label: '100%', sub: 'Natural'),
                  const SizedBox(width: 8),
                  _StatChip(label: '5000+', sub: 'Years of Practice'),
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
    return StreamBuilder<List<DoctorModel>>(
      stream: InstructorService.instructorsStream('Naturopathy'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, i) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _DoctorCardSkeleton(),
            ),
          );
        }

        final doctors = snapshot.data ?? [];

        if (doctors.isEmpty) {
          return NaaryaCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _greenLight, shape: BoxShape.circle),
                  child: const Icon(Icons.person_search_rounded, color: _green, size: 22),
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
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _DoctorCard(doctor: doctors[i]),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────
  // Naturopathy Brief
  // ────────────────────────────────────────────
  Widget _buildNaturopathyBrief() {
    return Column(
      children: [
        _InfoBlock(
          icon: Icons.eco_rounded,
          iconColor: _green,
          iconBg: _greenLight,
          title: 'What is Naturopathy?',
          body:
              'Naturopathy is a system of natural healthcare that views the body as a '
              'self-healing organism. Rather than suppressing symptoms with medications, '
              'naturopathic medicine addresses the root cause of illness — restoring balance '
              'through evidence-based natural therapies.\n\n'
              'Practised for over 5,000 years across Indian, Greek, and Chinese healing traditions, '
              'naturopathy integrates nutrition, hydrotherapy, herbal medicine, fasting therapy, '
              'sunlight exposure, and lifestyle counselling to activate the body\'s innate ability '
              'to heal and regenerate.',
        ),
        const SizedBox(height: AppSpacing.componentGap),
        _buildSixPrinciples(),
        const SizedBox(height: AppSpacing.componentGap),
        _InfoBlock(
          icon: Icons.local_florist_rounded,
          iconColor: _greenMid,
          iconBg: _greenLight,
          title: 'Core Natural Therapies',
          body: '',
          customContent: Column(
            children: const [
              _TherapyRow(
                icon: Icons.restaurant_rounded,
                color: Color(0xFF2E7D32),
                title: 'Dietary Therapy',
                subtitle: 'Whole foods, plant-based eating, and therapeutic fasting to cleanse and nourish the body at a cellular level.',
              ),
              _TherapyRow(
                icon: Icons.water_rounded,
                color: Color(0xFF1976D2),
                title: 'Hydrotherapy',
                subtitle: 'Therapeutic use of hot and cold water applications to stimulate circulation, reduce inflammation, and detoxify.',
              ),
              _TherapyRow(
                icon: Icons.grass_rounded,
                color: Color(0xFF558B2F),
                title: 'Herbal Medicine',
                subtitle: 'Evidence-based use of medicinal plants — Ashwagandha, Shatavari, Triphala — to restore hormonal and systemic balance.',
              ),
              _TherapyRow(
                icon: Icons.wb_sunny_rounded,
                color: Color(0xFFF57C00),
                title: 'Sunlight & Air Therapy',
                subtitle: 'Regulated sun exposure for Vitamin D synthesis and fresh air therapy to strengthen respiratory and immune health.',
              ),
              _TherapyRow(
                icon: Icons.self_improvement_rounded,
                color: Color(0xFF7B52A8),
                title: 'Yoga & Pranayama',
                subtitle: 'Therapeutic movement and breathwork to regulate the nervous system, balance hormones, and improve mental clarity.',
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.componentGap),
        _InfoBlock(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.surfaceVariant,
          title: 'Conditions Naturopathy Can Help',
          body:
              '• Hormonal imbalances — PCOS, irregular periods, thyroid issues\n'
              '• Digestive disorders — IBS, bloating, acidity, constipation\n'
              '• Chronic fatigue and low energy\n'
              '• Skin conditions — acne, eczema, psoriasis\n'
              '• Anxiety, stress, and mild depression\n'
              '• Weight management and metabolic health\n'
              '• Reproductive health and fertility support\n'
              '• Perimenopausal and menopausal symptoms',
          callout: 'Naturopathy complements — but does not replace — conventional medical care. Always consult your doctor for serious conditions.',
          calloutColor: AppColors.warning,
          calloutBg: AppColors.warningLight,
        ),
      ],
    );
  }

  Widget _buildSixPrinciples() {
    const principles = [
      _Principle(number: '01', title: 'First Do No Harm', body: 'Use the gentlest, least invasive therapies possible.', color: Color(0xFF2E7D32)),
      _Principle(number: '02', title: 'The Healing Power of Nature', body: 'Support and stimulate the body\'s self-healing mechanisms.', color: Color(0xFF43A047)),
      _Principle(number: '03', title: 'Identify the Root Cause', body: 'Treat the underlying cause, not just the symptoms.', color: Color(0xFF558B2F)),
      _Principle(number: '04', title: 'Treat the Whole Person', body: 'Address physical, mental, emotional, and spiritual well-being.', color: Color(0xFF388E3C)),
      _Principle(number: '05', title: 'Doctor as Teacher', body: 'Educate and empower patients to take charge of their health.', color: Color(0xFF2E7D32)),
      _Principle(number: '06', title: 'Prevention', body: 'Build health to prevent illness before it occurs.', color: Color(0xFF43A047)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _greenLight,
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
                    color: _green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.format_list_numbered_rounded, color: _green, size: 20),
                ),
                const SizedBox(width: 12),
                Text('6 Principles of Naturopathy',
                  style: AppTextStyles.subtitle1.copyWith(color: _green, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.55,
              children: principles.map((p) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.color.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.number, style: TextStyle(
                      fontSize: 11, color: p.color, fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    )),
                    const SizedBox(height: 4),
                    Text(p.title, style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 11,
                    )),
                    const SizedBox(height: 3),
                    Expanded(
                      child: Text(p.body, style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted, fontSize: 9.5, height: 1.4,
                      ), overflow: TextOverflow.ellipsis, maxLines: 3),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
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
                  decoration: BoxDecoration(color: _greenLight, shape: BoxShape.circle),
                  child: const Icon(Icons.videocam_rounded, color: _green, size: 22),
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
        border: Border.all(color: _green.withValues(alpha: 0.2)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _greenLight,
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
                    color: _green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.checklist_rounded, color: _green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _quizDone ? 'Your Lifestyle Assessment' : 'Question ${_quizIndex + 1} of ${_questions.length}',
                    style: AppTextStyles.subtitle1.copyWith(color: _green, fontWeight: FontWeight.w700),
                  ),
                ),
                if (!_quizDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Past month', style: TextStyle(
                      fontSize: 10, color: _green, fontWeight: FontWeight.w600,
                    )),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _quizIndex / _questions.length,
            backgroundColor: _greenLight,
            color: _green,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                q.question,
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w600, height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_quizOptions.length, (i) {
          final isSelected = _selectedOption == i;
          return GestureDetector(
            onTap: () => _selectOption(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected ? _greenLight : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _green : AppColors.border,
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
                      color: isSelected ? _green : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? _green : AppColors.textLight,
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
                        color: isSelected ? _green : AppColors.textBody,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(4, (d) => Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: d < i
                            ? _green.withValues(alpha: isSelected ? 0.8 : 0.3)
                            : AppColors.border,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          );
        }),
        if (_selectedOption != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
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
            'This helps personalise your naturopathy journey.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight, fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizResult() {
    // Max score = 6 × 4 = 24 (Never=0 … Always=4)
    final String label;
    final String headline;
    final String message;
    final String suggestion;
    final IconData icon;
    final Color color;
    final Color bgColor;

    if (_score <= 6) {
      label = 'Needs Attention';
      headline = 'Your body is asking for care 🌱';
      message =
          'Your lifestyle habits have significant room for improvement. '
          'Naturopathy can make a transformative difference — starting with small, '
          'consistent changes to diet, hydration, and movement.';
      suggestion = 'Start with one change: drink 8 glasses of water daily. Book a naturopathy consultation for a personalised plan.';
      icon = Icons.eco_rounded;
      color = AppColors.error;
      bgColor = AppColors.errorLight;
    } else if (_score <= 12) {
      label = 'Building Habits';
      headline = 'You\'re on the right path 🌿';
      message =
          'You have some healthy habits in place but consistency is key. '
          'Naturopathy can help you identify gaps and build a sustainable, '
          'holistic routine tailored to your body\'s needs.';
      suggestion = 'Focus on improving sleep and adding 15 minutes of outdoor activity daily. A naturopath can guide the next steps.';
      icon = Icons.local_florist_rounded;
      color = AppColors.warning;
      bgColor = AppColors.warningLight;
    } else if (_score <= 18) {
      label = 'Doing Well';
      headline = 'You\'re living naturally 🍃';
      message =
          'Your lifestyle is largely aligned with naturopathic principles. '
          'You\'re investing in your long-term health. '
          'A naturopath can help you optimise further and address any specific concerns.';
      suggestion = 'Consider a seasonal naturopathic detox or targeted herbal support for your hormonal health.';
      icon = Icons.spa_rounded;
      color = _greenMid;
      bgColor = _greenLight;
    } else {
      label = 'Naturally Thriving';
      headline = 'You\'re a natural wellness champion 🌳';
      message =
          'Excellent! Your habits are deeply aligned with naturopathic principles. '
          'You are actively supporting your body\'s self-healing capacity. '
          'Keep it up — your future self will thank you.';
      suggestion = 'Share your wellness journey. Consider deepening your practice with yoga therapy or advanced Ayurvedic support.';
      icon = Icons.emoji_events_rounded;
      color = _green;
      bgColor = _greenLight;
    }

    return Column(
      children: [
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
        Text(headline,
          style: AppTextStyles.h3.copyWith(color: AppColors.textDark),
          textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(message,
          style: AppTextStyles.body2.copyWith(color: AppColors.textBody, height: 1.6),
          textAlign: TextAlign.center),
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
                child: Text(suggestion,
                  style: AppTextStyles.caption.copyWith(
                    color: color, fontWeight: FontWeight.w600, height: 1.5,
                  )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text('Score: $_score / 24',
          style: AppTextStyles.caption.copyWith(color: AppColors.textLight, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text('Retake Check-in', style: AppTextStyles.button.copyWith(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
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
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(sub, style: TextStyle(fontSize: 9.5, color: Colors.white.withValues(alpha: 0.82), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ──────────────────── Doctor Card ────────────────────

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  const _DoctorCard({required this.doctor});

  static const _green = Color(0xFF2E7D32);
  static const _greenLight = Color(0xFFE8F5E9);

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
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _greenLight,
              border: Border.all(color: _green.withValues(alpha: 0.25), width: 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: doctor.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, p) => const Icon(Icons.person_rounded, color: _green, size: 28),
                    errorWidget: (_, p, e) => const Icon(Icons.person_rounded, color: _green, size: 28),
                  )
                : const Icon(Icons.person_rounded, color: _green, size: 28),
          ),
          const SizedBox(height: 8),
          Text(doctor.name,
            style: AppTextStyles.subtitle2.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 12),
            maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(doctor.specialty,
            style: AppTextStyles.caption.copyWith(color: _green, fontSize: 10),
            maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, color: _green, size: 12),
                SizedBox(width: 4),
                Text('Consult', style: TextStyle(color: _green, fontWeight: FontWeight.w600, fontSize: 11)),
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
          Container(width: 56, height: 56, decoration: const BoxDecoration(color: Color(0xFFEEEEEE), shape: BoxShape.circle)),
          const SizedBox(height: 8),
          Container(height: 10, width: 100, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 5),
          Container(height: 8, width: 70, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(6))),
          const Spacer(),
          Container(height: 28, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(8))),
        ],
      ),
    );
  }
}

// ──────────────────── Info Block ────────────────────

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
  final Widget? customContent;
  final String? callout;
  final Color? calloutColor;
  final Color? calloutBg;

  const _InfoBlock({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
    this.customContent,
    this.callout,
    this.calloutColor,
    this.calloutBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                topRight: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.subtitle1.copyWith(color: iconColor, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customContent != null)
                  customContent!
                else
                  Text(body, style: AppTextStyles.body2.copyWith(color: AppColors.textBody, height: 1.65)),
                if (callout != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: calloutBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: calloutColor!.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_rounded, color: calloutColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(callout!,
                            style: AppTextStyles.caption.copyWith(
                              color: calloutColor, fontWeight: FontWeight.w600, height: 1.5,
                            )),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Therapy Row ────────────────────

class _TherapyRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isLast;

  const _TherapyRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 13,
                )),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textBody, height: 1.5)),
              ],
            ),
          ),
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
              width: 110, height: 78,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  thumbnail != null
                      ? Image.network(thumbnail, fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => Container(
                            color: const Color(0xFFE8F5E9),
                            child: const Icon(Icons.play_circle_rounded, color: Color(0xFF2E7D32), size: 32),
                          ))
                      : Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Icon(Icons.play_circle_rounded, color: Color(0xFF2E7D32), size: 32),
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
                    Text(video.title,
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13,
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          video.type == VideoType.youtube ? Icons.smart_display_rounded : Icons.videocam_rounded,
                          size: 12,
                          color: video.type == VideoType.youtube ? const Color(0xFFFF0000) : const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(video.instructor,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis),
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
                  Container(height: 10, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 6),
                  Container(height: 8, width: 80, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(6))),
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
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(thumbnail, height: 160, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Container(
                  height: 160, color: const Color(0xFFE8F5E9),
                  child: const Icon(Icons.play_circle_rounded, color: Color(0xFF2E7D32), size: 48),
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
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ──────────────────── Data Models ────────────────────

class _QuizQuestion {
  final String question;
  final String emoji;
  const _QuizQuestion({required this.question, required this.emoji});
}

class _Principle {
  final String number;
  final String title;
  final String body;
  final Color color;
  const _Principle({required this.number, required this.title, required this.body, required this.color});
}

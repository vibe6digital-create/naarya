import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/chat_message_model.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _uuid = const Uuid();
  final List<ChatMessage> _messages = [];
  bool _isBotTyping = false;

  static const List<String> _quickQuestions = [
    'What should I eat during periods?',
    'When should I see a gynecologist?',
    'How to do breast self-exam?',
    'Tips for managing PCOS',
    'How to improve sleep quality?',
  ];

  static const Map<String, String> _responses = {
    'period|menstrual': '''During your period, focus on iron-rich foods like spinach, lentils, and lean meats to replenish lost iron. Stay hydrated with warm water and herbal teas like chamomile or ginger tea. Include anti-inflammatory foods such as berries, nuts, and fatty fish. Avoid excessive caffeine, salty foods, and refined sugar as they can worsen bloating and cramps. Dark chocolate (70%+ cocoa) in moderation can help with mood and cravings.''',
    'gynecologist|doctor': '''You should see a gynecologist if you experience:
• Irregular or missed periods for more than 3 months
• Extremely heavy bleeding (soaking through a pad/tampon every hour)
• Severe pelvic pain or cramping that interferes with daily life
• Unusual discharge with odor or color changes
• Pain during intercourse
• Any breast lumps or changes

It's also recommended to have an annual well-woman exam starting at age 21, or earlier if you are sexually active.''',
    'breast': '''Breast Self-Exam (BSE) — do this monthly, ideally a few days after your period ends:

1. **Stand before a mirror** — Look for changes in shape, size, or skin texture with arms at your sides, then raised overhead.
2. **Feel while standing** — Use the pads of your 3 middle fingers in small circular motions. Cover the entire breast and armpit area.
3. **Feel while lying down** — Place a pillow under your right shoulder, right arm behind your head. Use your left hand to examine the right breast, and vice versa.
4. **Check for discharge** — Gently squeeze each nipple.

Report any lumps, dimpling, skin changes, or discharge to your doctor promptly.''',
    'pcos': '''Managing PCOS involves a holistic approach:

• **Diet**: Follow a low-glycemic diet rich in whole grains, lean proteins, fruits, and vegetables. Limit refined carbs and sugary foods.
• **Exercise**: Aim for 30 minutes of moderate activity most days — walking, swimming, or yoga are great options.
• **Weight management**: Even a 5-10% weight loss can significantly improve symptoms.
• **Stress management**: Practice mindfulness, deep breathing, or meditation regularly.
• **Sleep**: Maintain a consistent sleep schedule of 7-8 hours.
• **Supplements**: Discuss inositol, vitamin D, and omega-3 supplements with your doctor.

Always work with your healthcare provider to tailor a plan specific to your needs.''',
    'sleep': '''Tips for better sleep:

• **Consistent schedule**: Go to bed and wake up at the same time daily, even on weekends.
• **Wind-down routine**: Start dimming lights 1 hour before bed. Try reading, gentle stretching, or meditation.
• **Limit screens**: Avoid phones and laptops at least 30 minutes before sleep. Use night mode if needed.
• **Bedroom environment**: Keep it cool (18-20°C), dark, and quiet. Use blackout curtains if needed.
• **Watch what you consume**: Avoid caffeine after 2 PM, heavy meals within 3 hours of bedtime, and limit alcohol.
• **Exercise**: Regular physical activity helps, but avoid vigorous exercise close to bedtime.
• **Relaxation**: Try 4-7-8 breathing — inhale for 4 counts, hold for 7, exhale for 8.''',
  };

  static const String _defaultResponse =
      "I'd recommend discussing this with your healthcare provider for personalized advice. You can book a consultation through the app to speak with a specialist.";

  String _getBotResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    for (final entry in _responses.entries) {
      final keywords = entry.key.split('|');
      for (final keyword in keywords) {
        if (lower.contains(keyword)) {
          return entry.value;
        }
      }
    }
    return _defaultResponse;
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isBotTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Simulate bot response after delay
    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      final botMsg = ChatMessage(
        id: _uuid.v4(),
        text: _getBotResponse(text),
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _isBotTyping = false;
        _messages.add(botMsg);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text('Health Assistant', style: AppTextStyles.h3),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.warningLight,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is for general information only. Not a substitute for medical advice.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages area
          Expanded(
            child: _messages.isEmpty
                ? _buildQuickQuestions()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isBotTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildChatBubble(_messages[index]);
                    },
                  ),
          ),

          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Icon(
              Icons.smart_toy_outlined,
              size: 64,
              color: AppColors.secondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Hi! I\'m your health assistant.',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Ask me anything about women\'s health, or try one of these questions:',
              style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickQuestions.map((q) {
              return InkWell(
                onTap: () => _sendMessage(q),
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    q,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.body2.copyWith(
                  color: isUser ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTextStyles.body2,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _sendMessage(_controller.text),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;
        _controllers[i].forward().then((_) {
          if (mounted) _controllers[i].reverse();
        });
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

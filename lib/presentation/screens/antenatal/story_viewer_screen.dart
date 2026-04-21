import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StorySlide {
  final String stepTitle;
  final String stepBody;
  final Color backgroundColor;
  final IconData icon;
  final bool isCover;
  final int? stepNumber;
  final String? coverSubtitle;
  final String? imageUrl;

  const StorySlide({
    required this.stepTitle,
    required this.stepBody,
    required this.backgroundColor,
    required this.icon,
    this.isCover = false,
    this.stepNumber,
    this.coverSubtitle,
    this.imageUrl,
  });
}

class StoryViewerScreen extends StatefulWidget {
  final List<StorySlide> slides;
  final int initialIndex;
  final String storyLabel;

  const StoryViewerScreen({
    super.key,
    required this.slides,
    this.initialIndex = 0,
    required this.storyLabel,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _controller;

  static const _duration = Duration(seconds: 7);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_onDone)
      ..forward();
  }

  void _onDone(AnimationStatus s) {
    if (s == AnimationStatus.completed && mounted) _goNext();
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onDone)
      ..dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex < widget.slides.length - 1) {
      setState(() => _currentIndex++);
      _controller.forward(from: 0);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[_currentIndex];
    final width = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: slide.backgroundColor,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => d.globalPosition.dx < width / 2 ? _goPrev() : _goNext(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _WatermarkPainter(widget.storyLabel.toUpperCase()),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressBars(
                      count: widget.slides.length,
                      current: _currentIndex,
                      controller: _controller,
                    ),
                    _StoryHeader(
                      label: widget.storyLabel,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: slide.isCover
                            ? _CoverSlide(slide: slide, key: ValueKey(_currentIndex))
                            : _ContentSlide(slide: slide, key: ValueKey(_currentIndex)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Progress Bars ────────────────────────────────────────────────────────────

class _ProgressBars extends StatelessWidget {
  final int count;
  final int current;
  final AnimationController controller;

  const _ProgressBars({
    required this.count,
    required this.current,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Row(
        children: List.generate(count, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < count - 1 ? 4 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: i < current
                      ? const LinearProgressIndicator(
                          value: 1,
                          backgroundColor: Colors.black26,
                          valueColor: AlwaysStoppedAnimation(Colors.black87),
                        )
                      : i == current
                          ? AnimatedBuilder(
                              animation: controller,
                              builder: (_, child) => LinearProgressIndicator(
                                value: controller.value,
                                backgroundColor: Colors.black26,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.black87),
                              ),
                            )
                          : const LinearProgressIndicator(
                              value: 0,
                              backgroundColor: Colors.black26,
                              valueColor: AlwaysStoppedAnimation(Colors.transparent),
                            ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _StoryHeader extends StatelessWidget {
  final String label;
  final VoidCallback onClose;

  const _StoryHeader({required this.label, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: _CircleButton(icon: Icons.close),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black45,
              letterSpacing: 1.8,
            ),
          ),
          const Spacer(),
          _CircleButton(icon: Icons.help_outline_rounded),
          const SizedBox(width: 8),
          _CircleButton(icon: Icons.share_rounded),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  const _CircleButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: Colors.black12,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black54, size: 17),
    );
  }
}

// ─── Cover Slide ──────────────────────────────────────────────────────────────

class _CoverSlide extends StatelessWidget {
  final StorySlide slide;
  const _CoverSlide({required this.slide, super.key});

  @override
  Widget build(BuildContext context) {
    final hasImage = slide.imageUrl != null && slide.imageUrl!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: slide.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                errorWidget: (ctx, url, err) => Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(slide.icon,
                      size: 72,
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.15)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            Center(
              child: Icon(
                slide.icon,
                size: 140,
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.07),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            slide.stepTitle,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
              height: 1.1,
            ),
          ),
          if (slide.coverSubtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              slide.coverSubtitle!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF44446A),
                height: 1.6,
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

// ─── Content Slide ────────────────────────────────────────────────────────────

class _ContentSlide extends StatelessWidget {
  final StorySlide slide;
  const _ContentSlide({required this.slide, super.key});

  @override
  Widget build(BuildContext context) {
    final hasImage = slide.imageUrl != null && slide.imageUrl!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: slide.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                errorWidget: (ctx, url, err) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(slide.icon,
                      size: 64,
                      color:
                          const Color(0xFF1A1A2E).withValues(alpha: 0.15)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            Expanded(
              flex: 4,
              child: Center(
                child: Icon(
                  slide.icon,
                  size: 120,
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (slide.stepNumber != null)
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${slide.stepNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          if (slide.stepTitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              slide.stepTitle,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A2E),
                height: 1.15,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            slide.stepBody,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF2A2A4A),
              height: 1.7,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ─── Watermark ────────────────────────────────────────────────────────────────

class _WatermarkPainter extends CustomPainter {
  final String label;
  const _WatermarkPainter(this.label);

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.black.withValues(alpha: 0.04),
          letterSpacing: 3,
        ),
      ),
    )..layout();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.42);
    canvas.translate(-size.width, -size.height * 0.8);

    const colGap = 210.0;
    const rowGap = 78.0;

    for (int row = 0; row < 18; row++) {
      for (int col = 0; col < 7; col++) {
        tp.paint(canvas, Offset(col * colGap, row * rowGap));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter old) => old.label != label;
}

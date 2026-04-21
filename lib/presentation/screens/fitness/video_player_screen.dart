import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expert_video_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final ExpertVideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // YouTube
  YoutubePlayerController? _youtubeController;

  // Storage / direct URL
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _storageError = false;

  @override
  void initState() {
    super.initState();
    if (widget.video.type == VideoType.youtube) {
      _initYoutube();
    } else {
      _initStorage();
    }
  }

  void _initYoutube() {
    final videoId = widget.video.youtubeVideoId ?? '';
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  Future<void> _initStorage() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.url),
      );
      await _videoController!.initialize();
      await _videoController!.setVolume(0);
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(color: Colors.black),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _storageError = true);
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    // Restore UI overlays after YouTube player
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isYoutube = widget.video.type == VideoType.youtube;

    if (isYoutube) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primaryDark,
          ),
        ),
        builder: (context, player) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              widget.video.title,
              style: AppTextStyles.subtitle2
                  .copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              player,
              Expanded(child: _buildInfo(isDark: true)),
            ],
          ),
        ),
      );
    }

    // Storage video
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.video.title,
          style: AppTextStyles.subtitle2.copyWith(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_storageError)
            _buildErrorState()
          else if (_chewieController != null)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Expanded(child: _buildInfo(isDark: true)),
        ],
      ),
    );
  }

  Widget _buildInfo({required bool isDark}) {
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white60 : AppColors.textMuted;

    return Container(
      color: isDark ? const Color(0xFF121212) : AppColors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title,
            style: AppTextStyles.h3.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.video.instructor,
            style: AppTextStyles.body2.copyWith(color: mutedColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                widget.video.type == VideoType.youtube
                    ? Icons.smart_display_rounded
                    : Icons.videocam_rounded,
                size: 16,
                color: widget.video.type == VideoType.youtube
                    ? const Color(0xFFFF0000)
                    : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.video.type == VideoType.youtube
                    ? 'YouTube'
                    : 'Expert Session',
                style: AppTextStyles.caption.copyWith(
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            Text(
              'Could not load video',
              style: AppTextStyles.body2.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

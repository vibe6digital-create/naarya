import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MarkdownContentView extends StatefulWidget {
  final String assetPath;

  const MarkdownContentView({super.key, required this.assetPath});

  @override
  State<MarkdownContentView> createState() => _MarkdownContentViewState();
}

class _MarkdownContentViewState extends State<MarkdownContentView> {
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final data = await rootBundle.loadString(widget.assetPath);
      setState(() {
        _content = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Content could not be loaded.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return MarkdownBody(
      data: _content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: AppTextStyles.h1,
        h2: AppTextStyles.h2,
        h3: AppTextStyles.h3,
        p: AppTextStyles.body2,
        listBullet: AppTextStyles.body2,
        blockquote: AppTextStyles.body2.copyWith(
          fontStyle: FontStyle.italic,
          color: AppColors.primary,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        a: AppTextStyles.body2.copyWith(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
        strong: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
      ),
      onTapLink: (text, href, title) async {
        if (href != null) {
          final url = Uri.parse(href);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }
      },
    );
  }
}

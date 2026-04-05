import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class WhatsappCtaButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const WhatsappCtaButton({
    super.key,
    required this.onPressed,
    this.text = 'Chat on WhatsApp',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.chat, size: 20),
        label: Text(text, style: AppTextStyles.button),
      ),
    );
  }
}

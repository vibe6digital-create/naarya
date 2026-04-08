import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — soft rose, soothing & light
  static const Color primary = Color(0xFFD4688A);       // soft rose pink
  static const Color primaryLight = Color(0xFFF06292);  // light pink (AI bubbles, accents)
  static const Color primaryDark = Color(0xFFB5446E);   // medium rose

  // Backgrounds — blush pink theme
  static const Color background = Color(0xFFFFF5F9);    // blush pink
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFCE4EC); // light pink tint

  // Secondary — softened purple/mauve
  static const Color secondary = Color(0xFFAB6DBC);
  static const Color secondaryLight = Color(0xFFEDD9F0);
  static const Color secondaryDark = Color(0xFF8E44AA);

  // Text
  static const Color textDark = Color(0xFF2D1B2E);
  static const Color textBody = Color(0xFF4A2C3D);
  static const Color textMuted = Color(0xFF7A5C6E);
  static const Color textLight = Color(0xFFB08898);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFF0D6E4);
  static const Color divider = Color(0xFFF8EAF2);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Cycle Phase Colors
  static const Color phaseMenstrual = Color(0xFFE53935);
  static const Color phaseMenstrualBg = Color(0xFFFFEBEE);
  static const Color phaseFollicular = Color(0xFF43A047);
  static const Color phaseFollicularBg = Color(0xFFE8F5E9);
  static const Color phaseOvulation = Color(0xFFFB8C00);
  static const Color phaseOvulationBg = Color(0xFFFFF3E0);
  static const Color phaseLuteal = Color(0xFF7B52A8);   // softened purple
  static const Color phaseLutealBg = Color(0xFFEDE7F6);

  // Cycle Tracker Dark Theme
  static const Color trackerBg = Color(0xFF1A1028);
  static const Color trackerSurface = Color(0xFF241535);
  static const Color trackerPeriod = Color(0xFFC4607C);
  static const Color trackerToday = Color(0xFF7B6FA2);
  static const Color trackerPredicted = Color(0xFFE8A0B0);
  static const Color trackerFertile = Color(0xFFE88CA0);
  static const Color trackerOvulation = Color(0xFF9B59B6);
  static const Color trackerTextMuted = Color(0xFF9B8BA0);
  static const Color trackerBorder = Color(0xFF4D3D5D);
  static const Color trackerButtonText = Color(0xFFB0A0BC);

  // Card shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x10D4688A),
      blurRadius: 14,
      offset: Offset(0, 3),
    ),
  ];
}

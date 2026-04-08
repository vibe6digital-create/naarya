import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/shell/main_shell.dart';
import '../../presentation/screens/cycle_tracker/cycle_tracker_screen.dart';
import '../../presentation/screens/cycle_tracker/cycle_log_screen.dart';
import '../../presentation/screens/cycle_tracker/edit_period_screen.dart';
import '../../presentation/screens/consultation/gynec_consult_screen.dart';
import '../../presentation/screens/consultation/breast_consult_screen.dart';
import '../../presentation/screens/nutrition/nutrition_screen.dart';
import '../../presentation/screens/fitness/fitness_screen.dart';
import '../../presentation/screens/ai_chat/ai_chat_screen.dart';
import '../../presentation/screens/health_vault/health_vault_screen.dart';
import '../../presentation/screens/health_vault/add_record_screen.dart';
import '../../presentation/screens/cancer_hub/cancer_hub_screen.dart';
import '../../presentation/screens/cancer_hub/cancer_detail_screen.dart';
import '../../presentation/screens/todo/todo_screen.dart';
import '../../presentation/screens/reminders/add_reminder_screen.dart';
import '../../presentation/screens/community/community_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/about_screen.dart';
import '../../presentation/screens/content_pages/content_page_screen.dart';
import '../../presentation/screens/travelling/travelling_screen.dart';
import '../../presentation/screens/safety/safety_screen.dart';
import '../../presentation/screens/mental_fitness/mental_fitness_screen.dart';
import '../../presentation/screens/antenatal/antenatal_screen.dart';
import '../../presentation/screens/products/products_screen.dart';
import '../../presentation/screens/reminders/reminders_screen.dart';
import '../../presentation/screens/lab_test/lab_test_screen.dart';
import '../constants/asset_paths.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen());
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen());
      case AppRoutes.login:
        return _buildRoute(const LoginScreen());
      case AppRoutes.otpVerify:
        return _buildRoute(const OtpScreen(), settings: settings);
      case AppRoutes.home:
        return _buildRoute(const MainShell());
      case AppRoutes.cycleTracker:
        return _buildRoute(const CycleTrackerScreen());
      case AppRoutes.cycleLog:
        return _buildRoute(const CycleLogScreen());
      case AppRoutes.editPeriod:
        final dates = settings.arguments as Set<DateTime>? ?? {};
        return _buildRoute(EditPeriodScreen(initialDates: dates));
      case AppRoutes.gynecConsult:
        return _buildRoute(const GynecConsultScreen());
      case AppRoutes.breastConsult:
        return _buildRoute(const BreastConsultScreen());
      case AppRoutes.nutrition:
        return _buildRoute(const NutritionScreen());
      case AppRoutes.fitness:
        return _buildRoute(const FitnessScreen());
      case AppRoutes.aiChat:
        return _buildRoute(const AiChatScreen());
      case AppRoutes.healthVault:
        return _buildRoute(const HealthVaultScreen());
      case AppRoutes.healthVaultAdd:
        return _buildRoute(const AddRecordScreen());
      case AppRoutes.cancerHub:
        return _buildRoute(const CancerHubScreen());
      case AppRoutes.cancerDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(CancerDetailScreen(
          title: args['title'] as String,
          assetPath: args['assetPath'] as String,
          warningSigns: args['warningSigns'] as List<String>? ?? const [],
          screeningGuidelines: args['screeningGuidelines'] as List<String>? ?? const [],
        ));
      case AppRoutes.todo:
        return _buildRoute(const TodoScreen());
      case AppRoutes.reminderAdd:
        return _buildRoute(const AddReminderScreen());
      case AppRoutes.community:
        return _buildRoute(const CommunityScreen());
      case AppRoutes.editProfile:
        return _buildRoute(const EditProfileScreen());
      case AppRoutes.about:
        return _buildRoute(const AboutScreen());
      case AppRoutes.privacyPolicy:
        return _buildRoute(const ContentPageScreen(
          title: 'Privacy Policy',
          assetPath: AssetPaths.privacyPolicy,
        ));
      case AppRoutes.termsConditions:
        return _buildRoute(const ContentPageScreen(
          title: 'Terms & Conditions',
          assetPath: AssetPaths.termsConditions,
        ));
      case AppRoutes.mentalFitness:
        return _buildRoute(const MentalFitnessScreen());
      case AppRoutes.mindBodyHealing:
        return _buildRoute(const ContentPageScreen(
          title: 'Mind & Body Healing',
          assetPath: AssetPaths.mindBodyHealing,
          showWhatsappCta: true,
          whatsappCtaText: 'Talk to Our Guide',
        ));
      case AppRoutes.skinHair:
        return _buildRoute(const ContentPageScreen(
          title: 'Skin & Hair',
          assetPath: AssetPaths.skinHair,
          showWhatsappCta: true,
          whatsappCtaText: 'Consult Dermatologist',
        ));
      case AppRoutes.legalHelp:
        return _buildRoute(const ContentPageScreen(
          title: 'Legal Help',
          assetPath: AssetPaths.legalHelp,
          showWhatsappCta: true,
          whatsappCtaText: 'Talk to a Legal Expert',
        ));
      case AppRoutes.travelling:
        return _buildRoute(const ContentPageScreen(
          title: 'Travelling',
          assetPath: AssetPaths.travelling,
        ));
      case AppRoutes.travellingHealth:
        return _buildRoute(const TravellingScreen());
      case AppRoutes.safety:
        return _buildRoute(const SafetyScreen());
      case AppRoutes.antenatal:
        return _buildRoute(const AntenatalScreen());
      case AppRoutes.products:
        return _buildRoute(const ProductsScreen());
      case AppRoutes.reminders:
        return _buildRoute(const RemindersScreen());
      case AppRoutes.labTest:
        return _buildRoute(const LabTestScreen());
      default:
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, {RouteSettings? settings}) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

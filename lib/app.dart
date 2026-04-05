import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';

class NaaryaApp extends StatelessWidget {
  const NaaryaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

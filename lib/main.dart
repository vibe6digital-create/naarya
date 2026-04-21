import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

/// Background FCM handler — MUST be a top-level function (not inside a class)
/// This runs in an isolate when the app is in background or terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages with a notification payload are shown automatically
  // by FCM on Android. For data-only messages, handle them here:
  // ignore: avoid_print
  print('[FCM Background] ${message.messageId}: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase config may be missing on iOS simulator
  }

  // Register the background message handler before anything else
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await LocalStorageService.init();
  await NotificationService.init();
  await NotificationService.requestPermission(); // ask on first launch

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const NaaryaApp());
}

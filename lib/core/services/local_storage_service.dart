import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  static bool get isOnboardingDone => _prefs.getBool('onboarding_done') ?? false;
  static Future<void> setOnboardingDone() => _prefs.setBool('onboarding_done', true);

  // Auth
  static bool get isLoggedIn => _prefs.getBool('is_logged_in') ?? false;
  static Future<void> setLoggedIn(bool value) => _prefs.setBool('is_logged_in', value);

  // User
  static String get userName => _prefs.getString('user_name') ?? '';
  static Future<void> setUserName(String name) => _prefs.setString('user_name', name);

  static String get userPhone => _prefs.getString('user_phone') ?? '';
  static Future<void> setUserPhone(String phone) => _prefs.setString('user_phone', phone);

  static String get userCity => _prefs.getString('user_city') ?? 'Indore';
  static Future<void> setUserCity(String city) => _prefs.setString('user_city', city);

  static String get userHealthGoal => _prefs.getString('user_health_goal') ?? '';
  static Future<void> setUserHealthGoal(String goal) => _prefs.setString('user_health_goal', goal);

  static int get userAge => _prefs.getInt('user_age') ?? 0;
  static Future<void> setUserAge(int age) => _prefs.setInt('user_age', age);

  // Cycle
  static String? get lastPeriodDate => _prefs.getString('last_period_date');
  static Future<void> setLastPeriodDate(String date) => _prefs.setString('last_period_date', date);

  static int get cycleLength => _prefs.getInt('cycle_length') ?? 28;
  static Future<void> setCycleLength(int length) => _prefs.setInt('cycle_length', length);

  static int get periodLength => _prefs.getInt('period_length') ?? 5;
  static Future<void> setPeriodLength(int length) => _prefs.setInt('period_length', length);

  // Clear all
  static Future<void> clear() => _prefs.clear();
}

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

  static String get userEmail => _prefs.getString('user_email') ?? '';
  static Future<void> setUserEmail(String email) => _prefs.setString('user_email', email);

  static String get userPhotoUrl => _prefs.getString('user_photo_url') ?? '';
  static Future<void> setUserPhotoUrl(String url) => _prefs.setString('user_photo_url', url);

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

  // Period dates (list of yyyy-MM-dd strings)
  static List<String> get periodDates => _prefs.getStringList('period_dates') ?? [];
  static Future<void> setPeriodDates(List<String> dates) => _prefs.setStringList('period_dates', dates);

  // Cycle notes (JSON map: {"yyyy-MM-dd": "note text"})
  static String? get cycleNotesJson => _prefs.getString('cycle_notes');
  static Future<void> setCycleNotesJson(String json) => _prefs.setString('cycle_notes', json);

  // Daily log (JSON map: {"yyyy-MM-dd": { "sexLife": [...], "symptoms": [...], ... }})
  static String? get dailyLogJson => _prefs.getString('daily_log');
  static Future<void> setDailyLogJson(String json) => _prefs.setString('daily_log', json);

  // Keep Notes
  static String? get keepNotesJson => _prefs.getString('keep_notes');
  static Future<void> setKeepNotesJson(String json) => _prefs.setString('keep_notes', json);

  static bool get keepNotesGridView => _prefs.getBool('keep_notes_grid') ?? true;
  static Future<void> setKeepNotesGridView(bool value) => _prefs.setBool('keep_notes_grid', value);

  // Clear all
  static Future<void> clear() => _prefs.clear();
}

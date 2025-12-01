import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _dailyLimitKey = 'srs_daily_limit';
  static const int _defaultDailyLimit = 20;

  /// Get the current daily limit for SRS
  static Future<int> getDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyLimitKey) ?? _defaultDailyLimit;
  }

  /// Set the daily limit for SRS
  static Future<void> setDailyLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyLimitKey, limit);
  }

  /// Get default daily limit
  static int getDefaultDailyLimit() => _defaultDailyLimit;
}

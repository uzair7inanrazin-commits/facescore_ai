import 'package:shared_preferences/shared_preferences.dart';

class RatingsManager {
  static const String _keyDate = 'last_rating_date';
  static const String _keyCount = 'ratings_used_today';
  static const String _keyIsPro = 'is_pro';
  static const int freeRatingsPerDay = 2;

  static Future<int> getRatingsLeft() async {
    final prefs = await SharedPreferences.getInstance();
    final isPro = prefs.getBool(_keyIsPro) ?? false;
    if (isPro) return 999;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_keyDate) ?? '';

    if (lastDate != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 0);
      return freeRatingsPerDay;
    }

    final used = prefs.getInt(_keyCount) ?? 0;
    return (freeRatingsPerDay - used).clamp(0, freeRatingsPerDay);
  }

  static Future<void> useRating() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_keyDate, today);
    final used = prefs.getInt(_keyCount) ?? 0;
    await prefs.setInt(_keyCount, used + 1);
  }

  static Future<void> addBonusRating() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_keyCount) ?? 0;
    if (used > 0) {
      await prefs.setInt(_keyCount, used - 1);
    }
  }

  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPro) ?? false;
  }

  static Future<void> setPro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, value);
  }
}

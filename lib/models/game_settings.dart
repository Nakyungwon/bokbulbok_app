import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  static late SharedPreferences _prefs;
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _soundEffectsKey = 'sound_effects';
  static const String _winnerCountKey = 'winner_count';

  static bool hapticFeedback = true;
  static bool soundEffects = false;
  static int winnerCount = 1; // 당첨 인원 (1~10)

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    hapticFeedback = _prefs.getBool(_hapticFeedbackKey) ?? true;
    soundEffects = _prefs.getBool(_soundEffectsKey) ?? false;
    winnerCount = _prefs.getInt(_winnerCountKey) ?? 1;
  }

  static Future<void> setHapticFeedback(bool enabled) async {
    hapticFeedback = enabled;
    await _prefs.setBool(_hapticFeedbackKey, enabled);
  }

  static Future<void> setSoundEffects(bool enabled) async {
    soundEffects = enabled;
    await _prefs.setBool(_soundEffectsKey, enabled);
  }

  static Future<void> setWinnerCount(int count) async {
    winnerCount = count.clamp(1, 10);
    await _prefs.setInt(_winnerCountKey, winnerCount);
  }
}

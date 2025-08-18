import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  static late SharedPreferences _prefs;
  static const String _animationSpeedKey = 'animation_speed';
  static const String _countdownTimeKey = 'countdown_time';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _soundEffectsKey = 'sound_effects';

  static double animationSpeed = 1.0;
  static double countdownTime = 2.5;
  static bool hapticFeedback = true;
  static bool soundEffects = false;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    animationSpeed = _prefs.getDouble(_animationSpeedKey) ?? 1.0;
    countdownTime = _prefs.getDouble(_countdownTimeKey) ?? 2.5;
    hapticFeedback = _prefs.getBool(_hapticFeedbackKey) ?? true;
    soundEffects = _prefs.getBool(_soundEffectsKey) ?? false;
  }

  static Future<void> setAnimationSpeed(double speed) async {
    animationSpeed = speed;
    await _prefs.setDouble(_animationSpeedKey, speed);
  }

  static Future<void> setCountdownTime(double time) async {
    countdownTime = time;
    await _prefs.setDouble(_countdownTimeKey, time);
  }

  static Future<void> setHapticFeedback(bool enabled) async {
    hapticFeedback = enabled;
    await _prefs.setBool(_hapticFeedbackKey, enabled);
  }

  static Future<void> setSoundEffects(bool enabled) async {
    soundEffects = enabled;
    await _prefs.setBool(_soundEffectsKey, enabled);
  }
}

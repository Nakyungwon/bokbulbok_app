import 'package:shared_preferences/shared_preferences.dart';

enum GameMode {
  defaultMode,   // 기본 모드: 랜덤 선택
  rouletteMode,  // 룰렛 모드: 랜덤 순서로 회전 (1바퀴 = 모든 참여자 1번씩)
}

class GameSettings {
  static late SharedPreferences _prefs;
  static const String _animationSpeedKey = 'animation_speed';
  static const String _countdownTimeKey = 'countdown_time';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _soundEffectsKey = 'sound_effects';
  static const String _gameModeKey = 'game_mode';
  static const String _winnerCountKey = 'winner_count';

  static double animationSpeed = 1.0;
  static double countdownTime = 2.5;
  static bool hapticFeedback = true;
  static bool soundEffects = false;
  static GameMode gameMode = GameMode.defaultMode;
  static int winnerCount = 1; // 당첨 인원 (1~10)

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    animationSpeed = _prefs.getDouble(_animationSpeedKey) ?? 1.0;
    countdownTime = _prefs.getDouble(_countdownTimeKey) ?? 2.5;
    hapticFeedback = _prefs.getBool(_hapticFeedbackKey) ?? true;
    soundEffects = _prefs.getBool(_soundEffectsKey) ?? false;
    gameMode = GameMode.values[_prefs.getInt(_gameModeKey) ?? 0];
    winnerCount = _prefs.getInt(_winnerCountKey) ?? 1;
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

  static Future<void> setGameMode(GameMode mode) async {
    gameMode = mode;
    await _prefs.setInt(_gameModeKey, mode.index);
  }

  static Future<void> setWinnerCount(int count) async {
    winnerCount = count.clamp(1, 10);
    await _prefs.setInt(_winnerCountKey, winnerCount);
  }
}

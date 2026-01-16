import 'package:flutter/material.dart';
import '../models/game_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      // 설정값들이 이미 GameSettings에서 로드되어 있음
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '게임 설정',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '게임 모드',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SegmentedButton<GameMode>(
              segments: const [
                ButtonSegment<GameMode>(
                  value: GameMode.defaultMode,
                  label: Text('기본'),
                  icon: Icon(Icons.touch_app),
                ),
                ButtonSegment<GameMode>(
                  value: GameMode.clockMode,
                  label: Text('시계'),
                  icon: Icon(Icons.access_time),
                ),
                ButtonSegment<GameMode>(
                  value: GameMode.randomMode,
                  label: Text('랜덤'),
                  icon: Icon(Icons.shuffle),
                ),
              ],
              selected: {GameSettings.gameMode},
              onSelectionChanged: (Set<GameMode> selection) async {
                await GameSettings.setGameMode(selection.first);
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            Text(
              GameSettings.gameMode == GameMode.defaultMode
                  ? '랜덤으로 당첨자를 선택합니다'
                  : GameSettings.gameMode == GameMode.clockMode
                      ? '시계방향으로 돌아가며 당첨자를 선택합니다'
                      : '랜덤 순서로 돌아가며 당첨자를 선택합니다 (1바퀴 = 모두 1번씩)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('진동 피드백'),
              subtitle: const Text('승자가 선택될 때 진동을 울립니다'),
              value: GameSettings.hapticFeedback,
              onChanged: (bool value) async {
                await GameSettings.setHapticFeedback(value);
                setState(() {});
              },
            ),
            SwitchListTile(
              title: const Text('사운드 효과'),
              subtitle: const Text('게임 중 소리를 재생합니다'),
              value: GameSettings.soundEffects,
              onChanged: (bool value) async {
                await GameSettings.setSoundEffects(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '애니메이션 속도',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '현재: ${GameSettings.animationSpeed.toStringAsFixed(1)}x',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Slider(
              value: GameSettings.animationSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: GameSettings.animationSpeed.toStringAsFixed(1),
              onChanged: (double value) async {
                await GameSettings.setAnimationSpeed(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '당첨까지 걸리는 시간 (기본 모드)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '현재: ${GameSettings.countdownTime.toStringAsFixed(1)}초 (시계 모드는 3~5초 랜덤)',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Slider(
              value: GameSettings.countdownTime,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              label: GameSettings.countdownTime.toStringAsFixed(1),
              onChanged: (double value) async {
                await GameSettings.setCountdownTime(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '앱 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('버전: 3.0.0'),
            const Text('개발자: Flutter 복불복 팀'),
          ],
        ),
      ),
    );
  }
}

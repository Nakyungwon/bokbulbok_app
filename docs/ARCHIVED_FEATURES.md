# Archived Features

> 삭제된 기능들의 복구 정보. 필요 시 참고하여 복원 가능.

---

## 기본 모드 (defaultMode)

**삭제일:** 2025-03
**삭제 이유:** 룰렛 모드가 더 시각적으로 재미있고, 1명씩 교체 알고리즘으로 더 공평한 랜덤 제공

### 기본 모드 특징

- 맥박 애니메이션: 터치 시 원이 1.0 → 1.4 크기로 반복 펄스
- 카운트다운 후 즉시 랜덤 선택 (`GameSettings.countdownTime` 사용)
- 원 크기: 90.0 (룰렛 모드는 117.0)

---

### 복구 코드

#### 1. GameMode enum (game_settings.dart)

```dart
enum GameMode {
  defaultMode,   // 기본 모드: 랜덤 선택
  rouletteMode,  // 룰렛 모드: 랜덤 순서로 회전
}
```

#### 2. GameSettings 변수/메서드 (game_settings.dart)

```dart
// 상수 추가
static const String _gameModeKey = 'game_mode';

// 변수 추가
static GameMode gameMode = GameMode.rouletteMode;

// initialize()에 추가
gameMode = GameMode.values[_prefs.getInt(_gameModeKey) ?? 1];

// 메서드 추가
static Future<void> setGameMode(GameMode mode) async {
  gameMode = mode;
  await _prefs.setInt(_gameModeKey, mode.index);
}
```

#### 3. GameService 함수들 (game_service.dart)

**onPointerDown에서 맥박 애니메이션 조건 추가:**
```dart
_createParticipantAnimation(id);
// 기본 모드에서만 맥박 애니메이션 실행
if (GameSettings.gameMode == GameMode.defaultMode) {
  _createPulseAnimation(id);
  _startPulseAnimation(id);
}
_resetSelectionTimer();
```

**맥박 애니메이션 함수:**
```dart
void _createPulseAnimation(String id) {
  pulseControllers[id] = AnimationController(
    vsync: vsync,
    duration: Duration(
      milliseconds: (500 / GameSettings.animationSpeed).round(),
    ),
  );
  pulseAnimations[id] = Tween<double>(begin: 1.0, end: 1.4).animate(
    CurvedAnimation(
      parent: pulseControllers[id]!,
      curve: Curves.elasticOut,
    ),
  );
}

void _startPulseAnimation(String id) {
  if (pulseControllers[id] != null) {
    pulseControllers[id]!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        pulseControllers[id]!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (selectedPlayerIds.isEmpty) {
          pulseControllers[id]!.forward();
        }
      }
    });
    pulseControllers[id]!.forward();
  }
}
```

**_startSelection 모드 분기:**
```dart
void _startSelection() {
  isGameInProgress = true;

  if (GameSettings.gameMode == GameMode.defaultMode) {
    // 기본 모드: 타이머 후 당첨자 선정
    selectionTimer = Timer(
      Duration(milliseconds: (GameSettings.countdownTime * 1000).round()),
      _finalizeSelectionDefault,
    );
  } else if (GameSettings.gameMode == GameMode.rouletteMode) {
    // 룰렛 모드: 0.5초 대기 후 룰렛 애니메이션 시작
    _highlightedInRound.clear();
    selectionTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        if (isGameInProgress && touches.isNotEmpty) {
          _startRouletteAnimation();
        }
      },
    );
  }
  onStateChanged();
}
```

**기본 모드 당첨자 선정 함수:**
```dart
void _finalizeSelectionDefault() {
  selectedPlayerIds.clear();

  final winnerCount = GameSettings.winnerCount.clamp(1, touches.length);
  final keys = touches.keys.toList();
  final random = Random();

  while (selectedPlayerIds.length < winnerCount && keys.isNotEmpty) {
    final index = random.nextInt(keys.length);
    selectedPlayerIds.add(keys[index]);
    keys.removeAt(index);
  }

  if (selectedPlayerIds.isEmpty) {
    reset();
    return;
  }

  // 맥박 애니메이션 중단
  for (var controller in pulseControllers.values) {
    controller.stop();
  }

  // 진동 피드백
  if (GameSettings.hapticFeedback) {
    _triggerIntenseVibration();
  }

  // winner 애니메이션 완료 시 바로 gathering 시작
  void onWinnerComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      winnerController?.removeStatusListener(onWinnerComplete);
      if (selectedPlayerIds.isNotEmpty) {
        _startGatheringAnimation();
      }
    }
  }
  winnerController?.addStatusListener(onWinnerComplete);
  winnerController?.forward(from: 0);

  onStateChanged();
}
```

#### 4. GameScreen 원 크기 조건 (game_screen.dart)

```dart
// 현재: const circleSize = 117.0;
// 복구 시:
final circleSize = (GameSettings.gameMode == GameMode.rouletteMode) ? 117.0 : 90.0;
final circleOffset = circleSize / 2;
```

#### 5. SettingsScreen UI (settings_screen.dart)

```dart
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
      value: GameMode.rouletteMode,
      label: Text('룰렛'),
      icon: Icon(Icons.casino),
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
      : '룰렛처럼 돌아가며 당첨자를 선택합니다',
  style: const TextStyle(fontSize: 12, color: Colors.grey),
),
const SizedBox(height: 20),

// 카운트다운 설정 (기본 모드용)
const Text(
  '당첨까지 걸리는 시간 (기본 모드)',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 10),
Text(
  '현재: ${GameSettings.countdownTime.toStringAsFixed(1)}초',
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
```

---

## 복구 체크리스트

- [ ] `game_settings.dart`에 GameMode enum 추가
- [ ] `game_settings.dart`에 gameMode 변수, 키, 메서드 추가
- [ ] `game_service.dart`에 맥박 애니메이션 함수 추가
- [ ] `game_service.dart`의 `_startSelection()`에 모드 분기 추가
- [ ] `game_service.dart`에 `_finalizeSelectionDefault()` 함수 추가
- [ ] `game_screen.dart`에서 원 크기 조건문 복구
- [ ] `settings_screen.dart`에 게임 모드 선택 UI 추가
- [ ] `settings_screen.dart`에 카운트다운 설정 UI 추가
- [ ] `flutter analyze` 통과 확인

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bokbulbok (복불복) is a Flutter-based multi-touch random selection game. Players touch the screen simultaneously, and after a countdown, one is randomly selected as the winner. The app features pulse animations, winner effects, and automatic game restart.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS

# Analyze code for issues
flutter analyze

# Run tests
flutter test
```

## Architecture

The app follows a modular architecture with clear separation of concerns:

- **`lib/main.dart`** - App entry point, initializes GameSettings and sets up dark theme
- **`lib/widgets/main_navigation.dart`** - Bottom navigation between Game, Instructions, and Settings screens
- **`lib/screens/game_screen.dart`** - Main game UI with touch handling via `Listener` widget, delegates all logic to GameService
- **`lib/services/game_service.dart`** - Core game logic: touch tracking, animations, winner selection, vibration feedback
- **`lib/models/game_settings.dart`** - Persistent settings via SharedPreferences (animation speed, countdown time, haptic feedback)
- **`lib/utils/color_utils.dart`** - Color generation and manipulation (15 predefined colors, unique assignment per participant)

### Game Flow

1. Touch events handled by `GameService.onPointerDown/Move/Up`
2. Each participant gets unique color and pulse animation
3. After countdown (default 2.5s), random winner selected
4. Winner animation expands, then gathering animation contracts
5. Game auto-resets for next round

### Key Dependencies

- `vibration: ^3.1.3` - Native vibration support for Android 15 compatibility
- `shared_preferences: ^2.2.2` - Persistent settings storage

---

## Harness Engineering Rules

### Architecture Constraints (DO NOT VIOLATE)

| Layer | Directory | Can Import | Cannot Import |
|-------|-----------|------------|---------------|
| UI | `screens/`, `widgets/` | services, models, utils | - |
| Logic | `services/` | models, utils | screens, widgets |
| Data | `models/` | utils only | screens, widgets, services |
| Utils | `utils/` | dart core only | everything else |

### Coding Conventions

```dart
// State management: Use ChangeNotifier pattern
class GameService extends ChangeNotifier {
  void _updateState() {
    notifyListeners(); // Always call after state changes
  }
}

// Color assignment: Always use ColorUtils.getUniqueColor(index)
// NEVER: Color.fromRGBO(random, random, random, 1)

// Vibration: Always check GameSettings.hapticFeedbackEnabled first
if (GameSettings().hapticFeedbackEnabled) {
  Vibration.vibrate(duration: 50);
}
```

### Common Mistakes to Avoid

| Mistake | Correct Approach |
|---------|------------------|
| Direct color generation | Use `ColorUtils.getUniqueColor(index)` for consistency |
| Hardcoded countdown values | Read from `GameSettings().countdownTime` |
| Missing null checks on touch | Validate pointer ID exists in `_participants` map |
| Forgetting `notifyListeners()` | Call after every state mutation in GameService |
| Platform-specific vibration | Use `vibration` package, not `HapticFeedback` |

### File Modification Checklist

Before modifying any file:
- [ ] Read the existing file completely
- [ ] Check imports follow architecture constraints
- [ ] Run `flutter analyze` after changes
- [ ] Test on at least one platform

### Testing Commands

```bash
# Must pass before committing
flutter analyze          # Zero issues required
flutter test             # All tests pass
flutter build apk --debug  # Build succeeds
```

### When Adding New Features

1. **New Screen** → Add to `screens/`, update `main_navigation.dart`
2. **New Service** → Add to `services/`, inject via constructor
3. **New Setting** → Add to `GameSettings` model with SharedPreferences key
4. **New Animation** → Use existing `AnimationController` patterns from `GameService`

---

## Design Guide

### 디자인 컨셉

> **"직관적이고 즐거운 심플함"**

복불복 게임은 순간적으로 사용되는 앱이다. 복잡한 UI는 게임의 흥미를 떨어뜨리고, 직관적인 터치 반응이 핵심이다.

| 키워드 | 설명 |
|--------|------|
| **Simple** | 한 화면에 하나의 목적. 게임 화면은 터치만 집중 |
| **Responsive** | 터치 즉시 시각적/촉각적 피드백 |
| **Playful** | 색상과 애니메이션으로 재미 요소 강화 |
| **Accessible** | 다크 테마 기본, 고대비 색상으로 가독성 확보 |

### 컬러 팔레트

#### 참가자 색상 (15종)

`ColorUtils.participantColors`에 정의됨. 순서대로 할당하여 중복 방지.

| 인덱스 | 색상명 | HEX |
|--------|--------|-----|
| 0 | Red | `#F44336` |
| 1 | Blue | `#2196F3` |
| 2 | Green | `#4CAF50` |
| 3 | Yellow | `#FFC107` |
| 4 | Purple | `#9C27B0` |
| 5 | Orange | `#FF9800` |
| 6 | Cyan | `#00BCD4` |
| 7 | Pink | `#E91E63` |
| 8 | Teal | `#009688` |
| 9 | Lime | `#CDDC39` |
| 10 | Indigo | `#3F51B5` |
| 11 | Amber | `#FFB300` |
| 12 | Deep Purple | `#673AB7` |
| 13 | Light Blue | `#03A9F4` |
| 14 | Deep Orange | `#FF5722` |

#### 상태 컬러

| 용도 | 색상 | 사용처 |
|------|------|--------|
| 배경 | `#121212` | 다크 테마 기본 배경 |
| 승자 효과 | 참가자 색상 + 펄스 애니메이션 | 당첨자 강조 |
| 비활성 | `Gray 600` | 대기 상태 텍스트 |

---

## Testing Guide

### 원칙

- 기능 코드 작성 시 테스트 파일을 **동시에** 작성한다
- 성공은 조용히, 실패만 표면에 노출

### 테스트 범위

| 레이어 | 테스트 대상 | 도구 |
|--------|-------------|------|
| Service | 게임 로직, 상태 전이, 엣지 케이스 | flutter_test |
| Widget | 렌더링, 터치 인터랙션, 애니메이션 | flutter_test + WidgetTester |
| Utils | 색상 생성, 데이터 변환 | flutter_test |

### 최소 커버리지

| 케이스 | 내용 |
|--------|------|
| Happy Path | 정상 동작 1개 이상 |
| 예외 케이스 | 터치 없음, 단일 참가자, 동시 터치 해제 등 1개 이상 |
| 경계값 | 최대 참가자 수, 빈 상태 |

### 핵심 인터랙션 테스트 필수 항목

| 기능 | 테스트 항목 |
|------|-------------|
| 터치 등록 | 포인터 다운 → 참가자 추가 확인 |
| 터치 해제 | 포인터 업 → 참가자 제거 확인 |
| 카운트다운 | 타이머 시작 → 완료 후 승자 선택 |
| 승자 선택 | 유효한 참가자 중 랜덤 선택 |
| 게임 리셋 | 애니메이션 완료 후 상태 초기화 |

---

## Decisions Log

> 아키텍처 및 기술 결정 기록. 결정의 이유와 맥락을 남겨 같은 고민을 반복하지 않는다.

### 작성 형식

```markdown
## [YYYY-MM-DD] 결정 제목

**결정:** 무엇을 선택했는가
**이유:** 왜 이 선택을 했는가
**고려했던 대안:** 다른 옵션과 탈락 이유
**영향 범위:** 어디에 영향을 주는가
```

### 기록

> 최신 결정이 위로 올라온다.

#### [2025-03] 기본 모드 삭제 — 룰렛 모드만 유지

**결정:** 기본 모드(defaultMode)를 삭제하고 룰렛 모드(rouletteMode)만 유지
**이유:** 룰렛 모드가 더 시각적으로 재미있고, 1명씩 교체 알고리즘으로 더 공평한 랜덤 제공
**고려했던 대안:** 두 모드 모두 유지 — 사용자 혼란, 유지보수 복잡성 증가
**영향 범위:** GameSettings, GameService, GameScreen, SettingsScreen
**복구 정보:** [docs/ARCHIVED_FEATURES.md](docs/ARCHIVED_FEATURES.md)

#### [2025-03] 룰렛 알고리즘 개선 — 1명씩 교체 방식

**결정:** 전체 교체 방식에서 1명씩 교체 방식으로 변경
**이유:** 모든 조합이 공평하게 나올 수 있도록 (N명 중 M명 선택 시 모든 C(N,M) 조합 가능)
**고려했던 대안:** 전체 교체 — 4명 중 2명 뽑을 때 2개 페어만 반복되는 문제
**영향 범위:** GameService._rouletteStep()

#### [2025-01] 진동 패키지 — vibration 사용

**결정:** `vibration` 패키지 사용 (HapticFeedback 대신)
**이유:** Android 15 호환성 이슈 해결, 네이티브 진동 지원
**고려했던 대안:** Flutter 내장 `HapticFeedback` — Android 15에서 작동 불안정
**영향 범위:** GameService, pubspec.yaml

#### [2025-01] 상태 관리 — ChangeNotifier

**결정:** ChangeNotifier 패턴 사용
**이유:** 단순한 앱 구조에 적합, 추가 패키지 불필요
**고려했던 대안:** Riverpod (과도한 복잡성), GetX (커뮤니티 우려)
**영향 범위:** GameService, 모든 UI 위젯

#### [2025-01] 색상 할당 — 고정 팔레트

**결정:** 15개 고정 색상 팔레트에서 순차 할당
**이유:** 랜덤 생성 시 유사 색상 충돌 방지, 일관된 UX
**고려했던 대안:** 랜덤 RGB 생성 — 구분 어려운 색상 발생
**영향 범위:** ColorUtils, GameService

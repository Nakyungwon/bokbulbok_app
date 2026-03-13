import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../models/game_settings.dart';
import '../utils/color_utils.dart';

class GameService {
  final Map<String, Offset> touches = {};
  final Map<String, Color> colors = {};
  final Map<String, AnimationController> participantControllers = {};
  final Map<String, Animation<double>> participantAnimations = {};
  final Map<String, AnimationController> pulseControllers = {};
  final Map<String, Animation<double>> pulseAnimations = {};

  Set<String> selectedPlayerIds = {};
  bool isGameInProgress = false;
  Timer? selectionTimer;
  AnimationController? winnerController;
  Animation<double>? winnerAnimation;
  AnimationController? gatheringController;
  Animation<double>? gatheringAnimation;
  AnimationController? loserImageController;
  Animation<double>? loserImageAnimation;
  bool isGathering = false;
  bool showLoserImage = false;
  int clickCounter = 0;

  // 룰렛 애니메이션 상태
  Set<String> highlightedPlayerIds = {}; // 다중 하이라이트 지원
  Timer? rouletteTimer;
  int rouletteStep = 0;
  int _totalRouletteSteps = 22; // 총 스텝 수 (랜덤 지속 시간에 따라 변경)
  String? _preselectedWinner;

  // 랜덤 모드 상태 (1바퀴 = 모든 참여자가 1번씩 하이라이트)
  final Set<String> _highlightedInRound = {};
  int _currentRound = 0;

  final TickerProvider vsync;
  final VoidCallback onStateChanged;

  GameService({
    required this.vsync,
    required this.onStateChanged,
  }) {
    _initializeControllers();
  }

  void _initializeControllers() {
    winnerController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    // 화면 대각선 길이의 약 2배 (어느 위치에서든 화면을 채울 수 있는 크기)
    winnerAnimation = Tween<double>(begin: 0, end: 2000).animate(
      CurvedAnimation(
        parent: winnerController!,
        curve: Curves.linear,
      ),
    );

    gatheringController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    gatheringAnimation = Tween<double>(begin: 2000, end: 0).animate(
      CurvedAnimation(
        parent: gatheringController!,
        curve: Curves.linear,
      ),
    );

    loserImageController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    // 1.0 -> 0.0: 페이드아웃용 (시작 시 opacity 1.0, forward하면 0.0으로)
    loserImageAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: loserImageController!,
        curve: Curves.easeOut,
      ),
    );
  }

  void onPointerDown(PointerDownEvent event) {
    // print('터치 다운: ${event.pointer} at ${event.position}'); // 디버그 로그
    if (selectedPlayerIds.isNotEmpty) return;
    if (touches.length >= 20) return;

    final id = event.pointer.toString();
    // globalPosition을 사용하거나 기본값 설정
    touches[id] = event.localPosition ?? event.position;
    colors[id] = ColorUtils.generateUniqueColor(colors);
    clickCounter++;

    // print('터치 추가됨: $id, 총 터치 수: ${touches.length}'); // 디버그 로그

    _createParticipantAnimation(id);
    // 기본 모드에서만 맥박 애니메이션 실행
    if (GameSettings.gameMode == GameMode.defaultMode) {
      _createPulseAnimation(id);
      _startPulseAnimation(id);
    }
    _resetSelectionTimer();
    _checkAndStartGame();
    onStateChanged();
  }

  void _createParticipantAnimation(String id) {
    participantControllers[id] = AnimationController(
      vsync: vsync,
      duration: Duration(
        milliseconds: (600 / GameSettings.animationSpeed).round(),
      ),
    );
    participantAnimations[id] = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: participantControllers[id]!,
        curve: Curves.elasticOut,
      ),
    );
    participantControllers[id]?.forward();
  }

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

  void onPointerMove(PointerMoveEvent event) {
    if (selectedPlayerIds.isNotEmpty) return;

    final id = event.pointer.toString();
    if (touches.containsKey(id)) {
      touches[id] = event.localPosition ?? event.position;
      onStateChanged();
    }
  }

  void onPointerUp(PointerUpEvent event) {
    final id = event.pointer.toString();
    // print('[DEBUG] onPointerUp: id=$id, selectedPlayerIds=$selectedPlayerIds, isGameInProgress=$isGameInProgress');

    if (selectedPlayerIds.isNotEmpty) {
      // print('[DEBUG] onPointerUp: selectedPlayerIds is set, returning early');
      return;
    }

    // print('[DEBUG] onPointerUp: removing touch id=$id, _preselectedWinner=$_preselectedWinner');
    touches.remove(id);
    colors.remove(id);

    participantControllers[id]?.dispose();
    participantControllers.remove(id);
    participantAnimations.remove(id);

    pulseControllers[id]?.dispose();
    pulseControllers.remove(id);
    pulseAnimations.remove(id);

    // 룰렛 진행 중이 아닐 때만 타이머 리셋
    if (!isGameInProgress) {
      _resetSelectionTimer();
      _checkAndStartGame();
    } else if (touches.isEmpty) {
      // 룰렛 중 모든 참여자가 나감
      // print('[DEBUG] onPointerUp: all participants left during roulette, resetting');
      rouletteTimer?.cancel();
      reset();
    } else {
      // 룰렛 진행 중 참여자가 나감
      final keys = touches.keys.toList();
      if (_preselectedWinner == id) {
        // 미리 선정된 당첨자가 나감 - 새로운 당첨자 선정
        _preselectedWinner = keys[Random().nextInt(keys.length)];
        // print('[DEBUG] onPointerUp: preselected winner left, new winner=$_preselectedWinner');
      }
      // 하이라이트된 참여자가 나감 - 다른 참여자로 교체
      if (highlightedPlayerIds.contains(id)) {
        highlightedPlayerIds.remove(id);
        // 남은 참여자 중에서 하이라이트되지 않은 참여자로 교체
        final available = keys.where((k) => !highlightedPlayerIds.contains(k)).toList();
        if (available.isNotEmpty) {
          highlightedPlayerIds.add(available[Random().nextInt(available.length)]);
        }
        // print('[DEBUG] onPointerUp: highlighted player left, new highlights=$highlightedPlayerIds');
      }
      // 랜덤 모드: 나간 참여자를 하이라이트 기록에서 제거
      _highlightedInRound.remove(id);
    }

    // print('[DEBUG] onPointerUp: remaining touches=${touches.keys.toList()}');
    onStateChanged();
  }

  void _checkAndStartGame() {
    if (!isGameInProgress && touches.isNotEmpty && selectedPlayerIds.isEmpty) {
      _startSelection();
    }
  }

  void _resetSelectionTimer() {
    selectionTimer?.cancel();
    if (isGameInProgress) {
      isGameInProgress = false;
    }
  }

  void _startSelection() {
    // print('[DEBUG] _startSelection called, touches=${touches.keys.toList()}, mode=${GameSettings.gameMode}');
    isGameInProgress = true;

    if (GameSettings.gameMode == GameMode.defaultMode) {
      // 기본 모드: 미리 당첨자 선정 후 타이머
      if (touches.isNotEmpty) {
        final random = Random();
        final keys = touches.keys.toList();
        _preselectedWinner = keys[random.nextInt(keys.length)];
        // print('[DEBUG] _startSelection (default): _preselectedWinner=$_preselectedWinner');
      }
      selectionTimer = Timer(
        Duration(milliseconds: (GameSettings.countdownTime * 1000).round()),
        _finalizeSelectionDefault,
      );
    } else if (GameSettings.gameMode == GameMode.rouletteMode) {
      // 룰렛 모드: 1초 대기 후 룰렛 애니메이션 시작
      _preselectedWinner = null;
      _highlightedInRound.clear();
      _currentRound = 0;
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

  void _finalizeSelectionDefault() {
    // 기본 모드: 랜덤으로 당첨자 선정
    _preselectedWinner = null;
    selectedPlayerIds.clear();

    // 당첨 인원 수 결정 (참여자보다 많을 수 없음)
    final winnerCount = GameSettings.winnerCount.clamp(1, touches.length);
    final keys = touches.keys.toList();
    final random = Random();

    // 랜덤으로 당첨자들 선정
    while (selectedPlayerIds.length < winnerCount && keys.isNotEmpty) {
      final index = random.nextInt(keys.length);
      selectedPlayerIds.add(keys[index]);
      keys.removeAt(index);
    }

    // print('[DEBUG] _finalizeSelectionDefault: selectedPlayerIds=$selectedPlayerIds');

    if (selectedPlayerIds.isEmpty) {
      // print('[DEBUG] _finalizeSelectionDefault: invalid winners, resetting');
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
    print('[TIMING] 확장 시작: ${DateTime.now().millisecondsSinceEpoch}');
    print('[TIMING] winnerController duration: ${winnerController?.duration}');
    void onWinnerComplete(AnimationStatus status) {
      print('[TIMING] winnerController status changed: $status at ${DateTime.now().millisecondsSinceEpoch}');
      if (status == AnimationStatus.completed) {
        print('[TIMING] 확장 완료 → gathering 호출: ${DateTime.now().millisecondsSinceEpoch}');
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

  void _startRouletteAnimation() {
    // print('[DEBUG] _startRouletteAnimation called');
    rouletteStep = 0;
    _highlightedInRound.clear();
    _currentRound = 1;
    highlightedPlayerIds.clear();

    // 3~5초 사이 랜덤 지속 시간 설정
    final random = Random();
    final durationSeconds = 3.0 + random.nextDouble() * 2.0;
    _totalRouletteSteps = (22 * durationSeconds / 2.7).round();
    // print('[DEBUG] _startRouletteAnimation: duration=${durationSeconds.toStringAsFixed(1)}s, totalSteps=$_totalRouletteSteps');

    // 다중 하이라이트: winnerCount만큼 랜덤 시작점 설정
    if (touches.isNotEmpty) {
      final keys = touches.keys.toList();
      final highlightCount = GameSettings.winnerCount.clamp(1, keys.length);

      // 랜덤으로 highlightCount명 선택
      final shuffled = List<String>.from(keys)..shuffle(random);
      for (int i = 0; i < highlightCount; i++) {
        highlightedPlayerIds.add(shuffled[i]);
        _highlightedInRound.add(shuffled[i]);
      }
      // print('[DEBUG] _startRouletteAnimation: random start at $highlightedPlayerIds, round=$_currentRound');
    }

    _rouletteStep();
  }

  void _rouletteStep() {
    // print('[DEBUG] _rouletteStep called: step=$rouletteStep, totalSteps=$_totalRouletteSteps, round=$_currentRound');
    if (touches.isEmpty) {
      // print('[DEBUG] _rouletteStep: no touches, calling _finalizeSelectionRoulette');
      _finalizeSelectionRoulette();
      return;
    }

    // 간격 계산: 진행률에 따라 점점 느려짐
    final progress = rouletteStep / _totalRouletteSteps;
    int interval;
    if (progress < 0.45) {
      interval = 50;
    } else if (progress < 0.65) {
      interval = 100;
    } else if (progress < 0.80) {
      interval = 166;
    } else if (progress < 0.90) {
      interval = 250;
    } else if (progress < 1.0) {
      interval = 350;
    } else {
      // 마지막 스텝
      if (rouletteStep > _totalRouletteSteps) {
        // print('[DEBUG] _rouletteStep: already past final step, ignoring');
        return;
      }
      rouletteStep = 999;

      // print('[DEBUG] _rouletteStep: FINAL step reached, winners=$highlightedPlayerIds');

      rouletteTimer?.cancel();
      rouletteTimer = Timer(const Duration(milliseconds: 300), () {
        // print('[DEBUG] 300ms timer fired, calling _finalizeSelectionRoulette');
        _finalizeSelectionRoulette();
      });

      onStateChanged();
      return;
    }

    // 다중 하이라이트: 각 하이라이트를 랜덤하게 다른 참여자로 이동
    final keys = touches.keys.toList();
    final highlightCount = GameSettings.winnerCount.clamp(1, keys.length);
    final random = Random();

    if (keys.length > highlightCount) {
      // 현재 바퀴에서 아직 하이라이트되지 않은 참여자들
      final availableKeys =
          keys.where((k) => !_highlightedInRound.contains(k)).toList();

      if (availableKeys.length < highlightCount) {
        // 새 바퀴 시작
        _highlightedInRound.clear();
        _currentRound++;
        // print('[DEBUG] _rouletteStep: new round started, round=$_currentRound');
      }

      // 새로운 하이라이트 선택 (현재 하이라이트 제외)
      final newAvailable = keys.where((k) => !highlightedPlayerIds.contains(k)).toList();
      final newHighlighted = <String>{};

      // 랜덤하게 highlightCount명 선택
      final shuffled = List<String>.from(newAvailable)..shuffle(random);
      for (int i = 0; i < highlightCount && i < shuffled.length; i++) {
        newHighlighted.add(shuffled[i]);
        _highlightedInRound.add(shuffled[i]);
      }

      // 새로운 참여자가 부족하면 기존 하이라이트에서 일부 유지
      if (newHighlighted.length < highlightCount) {
        final remaining = highlightCount - newHighlighted.length;
        final oldHighlighted = highlightedPlayerIds.toList()..shuffle(random);
        for (int i = 0; i < remaining && i < oldHighlighted.length; i++) {
          newHighlighted.add(oldHighlighted[i]);
        }
      }

      highlightedPlayerIds = newHighlighted;
      // print('[DEBUG] _rouletteStep: highlighted=$highlightedPlayerIds, highlightedInRound=$_highlightedInRound');
    } else {
      // 참여자 수가 당첨 인원과 같거나 적으면 모두 하이라이트
      highlightedPlayerIds = keys.toSet();
    }

    onStateChanged();
    rouletteStep++;

    rouletteTimer?.cancel();
    rouletteTimer = Timer(Duration(milliseconds: interval), _rouletteStep);
  }

  void _finalizeSelectionRoulette() {
    // 룰렛 모드: 현재 하이라이트된 참여자들이 당첨자
    rouletteTimer?.cancel();
    rouletteStep = 0;
    _highlightedInRound.clear();
    _currentRound = 0;

    selectedPlayerIds.clear();

    // 당첨 인원 수 결정
    final winnerCount = GameSettings.winnerCount.clamp(1, touches.length);

    // 하이라이트된 참여자들이 당첨자 (유효한 참여자만)
    for (final id in highlightedPlayerIds) {
      if (touches.containsKey(id)) {
        selectedPlayerIds.add(id);
      }
    }
    highlightedPlayerIds.clear();

    // 당첨자 수가 부족하면 추가 선정
    final keys =
        touches.keys.where((k) => !selectedPlayerIds.contains(k)).toList();
    final random = Random();
    while (selectedPlayerIds.length < winnerCount && keys.isNotEmpty) {
      final index = random.nextInt(keys.length);
      selectedPlayerIds.add(keys[index]);
      keys.removeAt(index);
    }

    // print('[DEBUG] _finalizeSelectionRoulette: selectedPlayerIds=$selectedPlayerIds');

    if (selectedPlayerIds.isEmpty) {
      // print('[DEBUG] _finalizeSelectionRoulette: invalid winners, resetting');
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
    // print('[DEBUG] _finalizeSelectionRoulette: starting winnerController animation');
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

  void _startGatheringAnimation() {
    if (gatheringController == null) {
      gatheringController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 500),
      );
      gatheringAnimation = Tween<double>(begin: 2000, end: 0).animate(
        CurvedAnimation(
          parent: gatheringController!,
          curve: Curves.linear,
        ),
      );
    }

    print('[TIMING] gathering 시작: ${DateTime.now().millisecondsSinceEpoch}');
    print('[TIMING] gatheringController duration: ${gatheringController?.duration}');
    isGathering = true;
    showLoserImage = true;
    loserImageController?.reset(); // opacity 1.0 상태로
    gatheringController!.forward(from: 0).then((_) {
      print('[TIMING] gathering 완료: ${DateTime.now().millisecondsSinceEpoch}');
      // gathering 완료 → 2초 유지 후 페이드아웃
      onStateChanged();
      Timer(const Duration(seconds: 2), () {
        loserImageController?.forward(from: 0).then((_) {
          reset();
        });
        onStateChanged();
      });
    });
    onStateChanged();
  }

  void reset() {
    touches.clear();
    colors.clear();
    selectedPlayerIds.clear();
    isGameInProgress = false;
    isGathering = false;
    clickCounter = 0;

    // 룰렛 상태 초기화
    rouletteTimer?.cancel();
    highlightedPlayerIds.clear();
    rouletteStep = 0;
    _totalRouletteSteps = 22;
    _preselectedWinner = null;

    // 랜덤 모드 상태 초기화
    _highlightedInRound.clear();
    _currentRound = 0;

    selectionTimer?.cancel();

    for (var controller in participantControllers.values) {
      controller.dispose();
    }
    participantControllers.clear();
    participantAnimations.clear();

    for (var controller in pulseControllers.values) {
      controller.dispose();
    }
    pulseControllers.clear();
    pulseAnimations.clear();

    winnerController?.reset();
    gatheringController?.reset();
    loserImageController?.reset();
    showLoserImage = false;

    onStateChanged();
  }

  void _triggerIntenseVibration() async {
    // Android에서는 vibration 패키지로 직접 진동 엔진 제어, iOS에서는 HapticFeedback 사용
    try {
      if (await Vibration.hasVibrator() == true) {
        // Android: 강력한 진동 패턴 (1초간 연속 진동)
        // 패턴: [0, 100, 50, 100, 50, 100, 50, 100, 50, 100, 50, 100, 50, 100, 50, 100, 50, 100, 50, 100]
        // 0ms 대기, 100ms 진동, 50ms 대기, 100ms 진동... (총 1초)
        List<int> pattern = [0];
        for (int i = 0; i < 10; i++) {
          pattern.add(100); // 진동 지속시간
          pattern.add(50); // 대기시간
        }

        // 강도 설정 (Android에서 지원하는 경우)
        if (await Vibration.hasAmplitudeControl() == true) {
          Vibration.vibrate(
              pattern: pattern, intensities: List.filled(pattern.length, 255));
        } else {
          Vibration.vibrate(pattern: pattern);
        }
      } else {
        // iOS 또는 진동 미지원 기기: HapticFeedback 사용
        HapticFeedback.heavyImpact();
        for (int i = 1; i <= 5; i++) {
          Future.delayed(Duration(milliseconds: i * 200), () {
            HapticFeedback.heavyImpact();
          });
        }
      }
    } catch (e) {
      // 최종 폴백: 기본 진동
      try {
        HapticFeedback.vibrate();
      } catch (e2) {
        // 모든 진동 방법이 실패한 경우
        // print('진동 기능을 사용할 수 없습니다: $e2');
      }
    }
  }

  void dispose() {
    selectionTimer?.cancel();
    rouletteTimer?.cancel();
    for (var controller in participantControllers.values) {
      controller.dispose();
    }
    for (var controller in pulseControllers.values) {
      controller.dispose();
    }
    winnerController?.dispose();
    gatheringController?.dispose();
    loserImageController?.dispose();
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_settings.dart';
import '../utils/color_utils.dart';

class GameService {
  final Map<String, Offset> touches = {};
  final Map<String, Color> colors = {};
  final Map<String, AnimationController> participantControllers = {};
  final Map<String, Animation<double>> participantAnimations = {};
  final Map<String, AnimationController> pulseControllers = {};
  final Map<String, Animation<double>> pulseAnimations = {};

  String? selectedPlayerId;
  bool isGameInProgress = false;
  Timer? selectionTimer;
  AnimationController? winnerController;
  Animation<double>? winnerAnimation;
  AnimationController? gatheringController;
  Animation<double>? gatheringAnimation;
  bool isGathering = false;
  int clickCounter = 0;

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
      duration: const Duration(seconds: 2),
    );
    winnerAnimation = Tween<double>(begin: 0, end: 2000).animate(
      CurvedAnimation(
        parent: winnerController!,
        curve: Curves.easeOut,
      ),
    );

    gatheringController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );
    gatheringAnimation = Tween<double>(begin: 2000, end: 0).animate(
      CurvedAnimation(
        parent: gatheringController!,
        curve: Curves.easeIn,
      ),
    );
  }

  void onPointerDown(PointerDownEvent event) {
    print('터치 다운: ${event.pointer} at ${event.position}'); // 디버그 로그
    if (selectedPlayerId != null) return;
    if (touches.length >= 15) return;

    final id = event.pointer.toString();
    // globalPosition을 사용하거나 기본값 설정
    touches[id] = event.localPosition ?? event.position;
    colors[id] = ColorUtils.generateUniqueColor(colors);
    clickCounter++;

    print('터치 추가됨: $id, 총 터치 수: ${touches.length}'); // 디버그 로그

    _createParticipantAnimation(id);
    _createPulseAnimation(id);
    _startPulseAnimation(id);
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
          if (selectedPlayerId == null) {
            pulseControllers[id]!.forward();
          }
        }
      });
      pulseControllers[id]!.forward();
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (selectedPlayerId != null) return;

    final id = event.pointer.toString();
    if (touches.containsKey(id)) {
      touches[id] = event.localPosition ?? event.position;
      onStateChanged();
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (selectedPlayerId != null) return;

    final id = event.pointer.toString();
    touches.remove(id);
    colors.remove(id);

    participantControllers[id]?.dispose();
    participantControllers.remove(id);
    participantAnimations.remove(id);

    pulseControllers[id]?.dispose();
    pulseControllers.remove(id);
    pulseAnimations.remove(id);

    _resetSelectionTimer();
    _checkAndStartGame();
    onStateChanged();
  }

  void _checkAndStartGame() {
    if (!isGameInProgress && touches.isNotEmpty && selectedPlayerId == null) {
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
    isGameInProgress = true;
    selectionTimer = Timer(
      Duration(milliseconds: (GameSettings.countdownTime * 1000).round()),
      _selectRandomPlayer,
    );
    onStateChanged();
  }

  void _selectRandomPlayer() {
    if (touches.isEmpty) return;

    final random = Random();
    final keys = touches.keys.toList();
    selectedPlayerId = keys[random.nextInt(keys.length)];

    // 맥박 애니메이션 중단
    for (var controller in pulseControllers.values) {
      controller.stop();
    }

    // 진동 피드백
    if (GameSettings.hapticFeedback) {
      try {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 200), () {
          HapticFeedback.heavyImpact();
        });
      } catch (e) {
        HapticFeedback.vibrate();
      }
    }

    winnerController?.forward(from: 0);

    // 역방향 애니메이션 시작
    Timer(
      Duration(milliseconds: (GameSettings.countdownTime * 1000).round()),
      () {
        if (selectedPlayerId != null) {
          _startGatheringAnimation();
        }
      },
    );

    onStateChanged();
  }

  void _startGatheringAnimation() {
    if (gatheringController == null) {
      gatheringController = AnimationController(
        vsync: vsync,
        duration: const Duration(seconds: 2),
      );
      gatheringAnimation = Tween<double>(begin: 2000, end: 0).animate(
        CurvedAnimation(
          parent: gatheringController!,
          curve: Curves.easeIn,
        ),
      );
    }

    isGathering = true;
    gatheringController!.forward(from: 0).then((_) {
      reset();
    });
    onStateChanged();
  }

  void reset() {
    touches.clear();
    colors.clear();
    selectedPlayerId = null;
    isGameInProgress = false;
    isGathering = false;
    clickCounter = 0;

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

    onStateChanged();
  }

  void dispose() {
    selectionTimer?.cancel();
    for (var controller in participantControllers.values) {
      controller.dispose();
    }
    for (var controller in pulseControllers.values) {
      controller.dispose();
    }
    winnerController?.dispose();
    gatheringController?.dispose();
  }
}

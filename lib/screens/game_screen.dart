import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/game_service.dart';
import '../models/game_settings.dart';
import '../utils/color_utils.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameService _gameService;

  @override
  void initState() {
    super.initState();
    _gameService = GameService(
      vsync: this,
      onStateChanged: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _gameService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복불복'),
        backgroundColor: Colors.grey[900],
      ),
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _gameService.onPointerDown,
        onPointerMove: _gameService.onPointerMove,
        onPointerUp: _gameService.onPointerUp,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Loser 이미지 애니메이션 (중앙에서 퍼져나감, 50% -> 0% 페이드아웃)
              if (_gameService.showLoserImage &&
                  _gameService.loserImageAnimation != null)
                AnimatedBuilder(
                  animation: _gameService.loserImageAnimation!,
                  builder: (context, child) {
                    final size = MediaQuery.of(context).size;
                    // 대각선 길이로 화면 전체를 덮을 수 있는 크기 계산
                    final diagonal = (size.width * size.width + size.height * size.height);
                    final maxSize = diagonal > 0 ? (diagonal * 0.5).clamp(0, 3000).toDouble() : size.width * 2;
                    final animatedSize = maxSize * _gameService.loserImageAnimation!.value;
                    // 불투명도: 0.5에서 시작해서 0으로 페이드아웃
                    final opacity = 0.5 * (1.0 - _gameService.loserImageAnimation!.value);
                    return Center(
                      child: Opacity(
                        opacity: opacity,
                        child: SizedBox(
                          width: animatedSize,
                          height: animatedSize,
                          child: Image.asset(
                            'images/loser.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (_gameService.touches.isNotEmpty &&
                  _gameService.selectedPlayerId == null)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '참여자: ${_gameService.touches.length}명',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (_gameService.selectedPlayerId != null &&
                  _gameService.touches[_gameService.selectedPlayerId!] !=
                      null &&
                  !_gameService.isGathering)
                AnimatedBuilder(
                  animation: _gameService.winnerAnimation!,
                  builder: (context, child) {
                    final selectedId = _gameService.selectedPlayerId;
                    if (selectedId == null) {
                      print('[DEBUG] winnerAnimation: selectedPlayerId became null');
                      return const SizedBox.shrink();
                    }
                    final position = _gameService.touches[selectedId];
                    final color = _gameService.colors[selectedId];
                    if (position == null || color == null) {
                      print('[DEBUG] winnerAnimation: position=$position, color=$color for id=$selectedId');
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      left: position.dx -
                          _gameService.winnerAnimation!.value / 2,
                      top: position.dy -
                          _gameService.winnerAnimation!.value / 2,
                      child: Container(
                        width: _gameService.winnerAnimation!.value,
                        height: _gameService.winnerAnimation!.value,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              if (_gameService.isGathering &&
                  _gameService.gatheringAnimation != null &&
                  _gameService.selectedPlayerId != null &&
                  _gameService.touches[_gameService.selectedPlayerId!] != null)
                AnimatedBuilder(
                  animation: _gameService.gatheringAnimation!,
                  builder: (context, child) {
                    final selectedId = _gameService.selectedPlayerId;
                    if (selectedId == null) {
                      print('[DEBUG] gatheringAnimation: selectedPlayerId became null');
                      return const SizedBox.shrink();
                    }
                    final position = _gameService.touches[selectedId];
                    final color = _gameService.colors[selectedId];
                    if (position == null || color == null) {
                      print('[DEBUG] gatheringAnimation: position=$position, color=$color for id=$selectedId');
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      left: position.dx -
                          _gameService.gatheringAnimation!.value / 2,
                      top: position.dy -
                          _gameService.gatheringAnimation!.value / 2,
                      child: Container(
                        width: _gameService.gatheringAnimation!.value,
                        height: _gameService.gatheringAnimation!.value,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              if (_gameService.selectedPlayerId != null &&
                  _gameService.touches[_gameService.selectedPlayerId!] != null)
                Builder(
                  builder: (context) {
                    final selectedId = _gameService.selectedPlayerId;
                    if (selectedId == null) {
                      print('[DEBUG] winnerCircle: selectedPlayerId became null');
                      return const SizedBox.shrink();
                    }
                    final position = _gameService.touches[selectedId];
                    final color = _gameService.colors[selectedId];
                    if (position == null || color == null) {
                      print('[DEBUG] winnerCircle: position=$position, color=$color for id=$selectedId');
                      return const SizedBox.shrink();
                    }
                    // 시계 모드에서 원 크기 30% 증가
                    final circleSize = (GameSettings.gameMode == GameMode.clockMode || GameSettings.gameMode == GameMode.randomMode) ? 117.0 : 90.0;
                    final circleOffset = circleSize / 2;
                    return Positioned(
                      left: position.dx - circleOffset,
                      top: position.dy - circleOffset,
                      child: IgnorePointer(
                        child: Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorUtils.getDarkerColor(color),
                              width: 8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColorUtils.getDarkerColor(color)
                                    .withOpacity(0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(child: SizedBox()),
                        ),
                      ),
                    );
                  },
                ),
              if (_gameService.selectedPlayerId == null)
                ..._gameService.touches.entries.map((entry) {
                  final color = _gameService.colors[entry.key] ?? Colors.grey;
                  final animation =
                      _gameService.participantAnimations[entry.key];
                  final isHighlighted =
                      _gameService.highlightedPlayerId == entry.key;
                  if (animation == null) return const SizedBox.shrink();
                  // 시계 모드에서 원 크기 30% 증가
                  final circleSize = (GameSettings.gameMode == GameMode.clockMode || GameSettings.gameMode == GameMode.randomMode) ? 117.0 : 90.0;
                  final circleOffset = circleSize / 2;
                  return Positioned(
                    left: entry.value.dx - circleOffset,
                    top: entry.value.dy - circleOffset,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final pulseAnimation =
                              _gameService.pulseAnimations[entry.key];
                          final scale =
                              animation.value * (pulseAnimation?.value ?? 1.0);
                          return Transform.scale(
                            scale: scale * (isHighlighted ? 1.15 : 1.0),
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isHighlighted
                                      ? Colors.white
                                      : ColorUtils.getDarkerColor(color),
                                  width: isHighlighted ? 6 : 8,
                                ),
                                boxShadow: isHighlighted
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.8),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: ColorUtils.getDarkerColor(color)
                                              .withOpacity(0.6),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: const Center(child: SizedBox()),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

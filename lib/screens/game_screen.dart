import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/game_service.dart';
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
                    return Positioned(
                      left: _gameService
                              .touches[_gameService.selectedPlayerId!]!.dx -
                          _gameService.winnerAnimation!.value / 2,
                      top: _gameService
                              .touches[_gameService.selectedPlayerId!]!.dy -
                          _gameService.winnerAnimation!.value / 2,
                      child: Container(
                        width: _gameService.winnerAnimation!.value,
                        height: _gameService.winnerAnimation!.value,
                        decoration: BoxDecoration(
                          color: _gameService
                              .colors[_gameService.selectedPlayerId!]!,
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
                    return Positioned(
                      left: _gameService
                              .touches[_gameService.selectedPlayerId!]!.dx -
                          _gameService.gatheringAnimation!.value / 2,
                      top: _gameService
                              .touches[_gameService.selectedPlayerId!]!.dy -
                          _gameService.gatheringAnimation!.value / 2,
                      child: Container(
                        width: _gameService.gatheringAnimation!.value,
                        height: _gameService.gatheringAnimation!.value,
                        decoration: BoxDecoration(
                          color: _gameService
                              .colors[_gameService.selectedPlayerId!]!,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              if (_gameService.selectedPlayerId != null &&
                  _gameService.touches[_gameService.selectedPlayerId!] != null)
                Positioned(
                  left:
                      _gameService.touches[_gameService.selectedPlayerId!]!.dx -
                          45,
                  top:
                      _gameService.touches[_gameService.selectedPlayerId!]!.dy -
                          45,
                  child: IgnorePointer(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _gameService
                            .colors[_gameService.selectedPlayerId!]!,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorUtils.getDarkerColor(_gameService
                              .colors[_gameService.selectedPlayerId!]!),
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorUtils.getDarkerColor(_gameService
                                    .colors[_gameService.selectedPlayerId!]!)
                                .withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(child: SizedBox()),
                    ),
                  ),
                ),
              if (_gameService.selectedPlayerId == null)
                ..._gameService.touches.entries.map((entry) {
                  final color = _gameService.colors[entry.key] ?? Colors.grey;
                  final animation =
                      _gameService.participantAnimations[entry.key];
                  if (animation == null) return const SizedBox.shrink();
                  return Positioned(
                    left: entry.value.dx - 45,
                    top: entry.value.dy - 45,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final pulseAnimation =
                              _gameService.pulseAnimations[entry.key];
                          final scale =
                              animation.value * (pulseAnimation?.value ?? 1.0);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 90,
                              height: 90,
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

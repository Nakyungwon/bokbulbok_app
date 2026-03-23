import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/game_settings.dart';
import '../utils/color_utils.dart';

// Voronoi 스타일 클리퍼 - 다중 당첨자의 색상이 경계에서 만나도록
class VoronoiClipper extends CustomClipper<Path> {
  final Offset currentPosition;
  final List<Offset> otherPositions;
  final Size screenSize;

  VoronoiClipper({
    required this.currentPosition,
    required this.otherPositions,
    required this.screenSize,
  });

  @override
  Path getClip(Size size) {
    if (otherPositions.isEmpty) {
      // 다른 당첨자가 없으면 전체 화면
      return Path()..addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));
    }

    // 시작: 전체 화면을 포함하는 큰 사각형
    List<Offset> polygon = [
      Offset(-screenSize.width, -screenSize.height),
      Offset(screenSize.width * 2, -screenSize.height),
      Offset(screenSize.width * 2, screenSize.height * 2),
      Offset(-screenSize.width, screenSize.height * 2),
    ];

    // 각 다른 당첨자와의 수직이등분선으로 폴리곤 자르기
    for (final other in otherPositions) {
      polygon = _clipPolygonByBisector(polygon, currentPosition, other);
      if (polygon.isEmpty) break;
    }

    if (polygon.isEmpty) {
      return Path();
    }

    final path = Path();
    path.moveTo(polygon[0].dx, polygon[0].dy);
    for (int i = 1; i < polygon.length; i++) {
      path.lineTo(polygon[i].dx, polygon[i].dy);
    }
    path.close();
    return path;
  }

  // 수직이등분선으로 폴리곤 자르기 (Sutherland-Hodgman 알고리즘)
  List<Offset> _clipPolygonByBisector(List<Offset> polygon, Offset p1, Offset p2) {
    if (polygon.isEmpty) return [];

    // 수직이등분선의 중점과 방향
    final midpoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    // p1에서 p2로의 방향 벡터
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;

    final List<Offset> result = [];

    for (int i = 0; i < polygon.length; i++) {
      final current = polygon[i];
      final next = polygon[(i + 1) % polygon.length];

      // 점이 p1 쪽에 있는지 확인 (내적 사용)
      final currentInside = _isOnP1Side(current, midpoint, dx, dy);
      final nextInside = _isOnP1Side(next, midpoint, dx, dy);

      if (currentInside) {
        result.add(current);
        if (!nextInside) {
          // 교차점 추가
          final intersection = _lineIntersection(current, next, midpoint, dx, dy);
          if (intersection != null) result.add(intersection);
        }
      } else if (nextInside) {
        // 교차점 추가
        final intersection = _lineIntersection(current, next, midpoint, dx, dy);
        if (intersection != null) result.add(intersection);
      }
    }

    return result;
  }

  // 점이 p1 쪽에 있는지 확인
  bool _isOnP1Side(Offset point, Offset midpoint, double dx, double dy) {
    // 점에서 midpoint로의 벡터와 (dx, dy) 방향의 내적
    final vx = point.dx - midpoint.dx;
    final vy = point.dy - midpoint.dy;
    return (vx * dx + vy * dy) <= 0;
  }

  // 선분과 수직이등분선의 교차점
  Offset? _lineIntersection(Offset a, Offset b, Offset midpoint, double dx, double dy) {
    // 선분 방향
    final abx = b.dx - a.dx;
    final aby = b.dy - a.dy;

    // 수직이등분선의 법선 벡터는 (dx, dy)
    final denom = abx * dx + aby * dy;
    if (denom.abs() < 1e-10) return null;

    final t = ((midpoint.dx - a.dx) * dx + (midpoint.dy - a.dy) * dy) / denom;
    if (t < 0 || t > 1) return null;

    return Offset(a.dx + t * abx, a.dy + t * aby);
  }

  @override
  bool shouldReclip(VoronoiClipper oldClipper) {
    return currentPosition != oldClipper.currentPosition ||
        otherPositions.length != oldClipper.otherPositions.length;
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameService _gameService;
  final Set<int> _uiPointerIds = {}; // UI 영역에서 시작된 포인터 ID 추적

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
      appBar: null,
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (_uiPointerIds.contains(event.pointer)) return;
          _gameService.onPointerDown(event);
        },
        onPointerMove: (event) {
          if (_uiPointerIds.contains(event.pointer)) return;
          _gameService.onPointerMove(event);
        },
        onPointerUp: (event) {
          if (_uiPointerIds.contains(event.pointer)) {
            _uiPointerIds.remove(event.pointer);
            return;
          }
          _gameService.onPointerUp(event);
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Loser 이미지 (gathering 시 가장자리부터 드러남, 2초 유지 후 페이드아웃)
              if (_gameService.showLoserImage &&
                  _gameService.loserImageAnimation != null)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _gameService.loserImageAnimation!,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _gameService.loserImageAnimation!.value,
                        child: Image.asset(
                          'images/loser.png',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              if (_gameService.selectedPlayerIds.isEmpty)
                Positioned(
                  top: 50,
                  left: 20,
                  child: Listener(
                    onPointerDown: (event) {
                      _uiPointerIds.add(event.pointer);
                    },
                    onPointerUp: (event) {
                      _uiPointerIds.remove(event.pointer);
                    },
                    onPointerCancel: (event) {
                      _uiPointerIds.remove(event.pointer);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (GameSettings.winnerCount > 1) {
                                GameSettings.setWinnerCount(GameSettings.winnerCount - 1);
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: GameSettings.winnerCount > 1
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove,
                                color: GameSettings.winnerCount > 1
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                size: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '당첨: ${GameSettings.winnerCount}명',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (GameSettings.winnerCount < 10) {
                                GameSettings.setWinnerCount(GameSettings.winnerCount + 1);
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: GameSettings.winnerCount < 10
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: GameSettings.winnerCount < 10
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_gameService.touches.isNotEmpty &&
                  _gameService.selectedPlayerIds.isEmpty)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '참여자: ${_gameService.touches.length}명',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              // 당첨자 애니메이션 (다중 당첨자 지원 - Voronoi 클리핑)
              if (_gameService.selectedPlayerIds.isNotEmpty &&
                  !_gameService.isGathering)
                ..._gameService.selectedPlayerIds.map((selectedId) {
                  final position = _gameService.touches[selectedId];
                  final color = _gameService.colors[selectedId];
                  if (position == null || color == null) {
                    return const SizedBox.shrink();
                  }
                  // 다른 당첨자들의 위치
                  final otherPositions = _gameService.selectedPlayerIds
                      .where((id) => id != selectedId)
                      .map((id) => _gameService.touches[id])
                      .whereType<Offset>()
                      .toList();
                  return Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _gameService.winnerAnimation!,
                      builder: (context, child) {
                        final screenSize = MediaQuery.of(context).size;
                        final animValue = _gameService.winnerAnimation!.value;
                        return ClipPath(
                          clipper: VoronoiClipper(
                            currentPosition: position,
                            otherPositions: otherPositions,
                            screenSize: screenSize,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: position.dx - animValue / 2,
                                top: position.dy - animValue / 2,
                                child: Container(
                                  width: animValue,
                                  height: animValue,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              // Gathering 애니메이션 (다중 당첨자 지원 - Voronoi 클리핑)
              if (_gameService.isGathering &&
                  _gameService.gatheringAnimation != null &&
                  _gameService.selectedPlayerIds.isNotEmpty)
                ..._gameService.selectedPlayerIds.map((selectedId) {
                  final position = _gameService.touches[selectedId];
                  final color = _gameService.colors[selectedId];
                  if (position == null || color == null) {
                    return const SizedBox.shrink();
                  }
                  // 다른 당첨자들의 위치
                  final otherPositions = _gameService.selectedPlayerIds
                      .where((id) => id != selectedId)
                      .map((id) => _gameService.touches[id])
                      .whereType<Offset>()
                      .toList();
                  return Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _gameService.gatheringAnimation!,
                      builder: (context, child) {
                        final screenSize = MediaQuery.of(context).size;
                        final animValue = _gameService.gatheringAnimation!.value;
                        return ClipPath(
                          clipper: VoronoiClipper(
                            currentPosition: position,
                            otherPositions: otherPositions,
                            screenSize: screenSize,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: position.dx - animValue / 2,
                                top: position.dy - animValue / 2,
                                child: Container(
                                  width: animValue,
                                  height: animValue,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              // 당첨자 원 표시 (다중 당첨자 지원)
              if (_gameService.selectedPlayerIds.isNotEmpty)
                ..._gameService.selectedPlayerIds.map((selectedId) {
                  final position = _gameService.touches[selectedId];
                  final color = _gameService.colors[selectedId];
                  if (position == null || color == null) {
                    return const SizedBox.shrink();
                  }
                  const circleSize = 117.0;
                  const circleOffset = circleSize / 2;
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
                                  .withValues(alpha: 0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(child: SizedBox()),
                      ),
                    ),
                  );
                }),
              if (_gameService.selectedPlayerIds.isEmpty)
                ..._gameService.touches.entries.map((entry) {
                  final color = _gameService.colors[entry.key] ?? Colors.grey;
                  final animation =
                      _gameService.participantAnimations[entry.key];
                  final isHighlighted =
                      _gameService.highlightedPlayerIds.contains(entry.key);
                  if (animation == null) return const SizedBox.shrink();
                  const circleSize = 117.0;
                  const circleOffset = circleSize / 2;
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
                                          color: color.withValues(alpha: 0.8),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: ColorUtils.getDarkerColor(color)
                                              .withValues(alpha: 0.6),
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

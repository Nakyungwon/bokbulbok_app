import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BokbulbokApp());
}

class BokbulbokApp extends StatelessWidget {
  const BokbulbokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '복불복',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark, // 다크모드 설정
        scaffoldBackgroundColor: Colors.grey[900], // 배경색을 어두운 회색으로
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const BokbulbokHomePage(),
    const InstructionsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: '게임',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: '도움말',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 방법'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '복불복 게임 방법',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '1. 여러 명이 화면에 손가락을 올려놓고 떼지 않습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '2. 손가락을 드래그하면 원이 따라다닙니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '3. 마지막 참여/취소 이벤트 후 즉시 게임이 시작됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '4. 2초 카운트다운 후 한 명이 랜덤으로 선택됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '5. 당첨자 선정 시 0.2초 진동과 함께 승자 애니메이션이 실행됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '6. "다시 하기" 버튼으로 새 게임을 시작할 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '게임 특징:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '• 최대 15명까지 동시 참여 가능',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• 각 참여자는 고유한 색상으로 구분',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• 손가락을 떼면 즉시 참여 취소',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• 드래그 중에도 참여 상태 유지',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• 다크모드로 눈의 피로도 감소',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• 안드로이드에서 진동 피드백 제공',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _hapticFeedback = true;
  bool _soundEffects = false;
  double _animationSpeed = 1.0;

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
            SwitchListTile(
              title: const Text('진동 피드백'),
              subtitle: const Text('승자가 선택될 때 진동을 울립니다'),
              value: _hapticFeedback,
              onChanged: (bool value) {
                setState(() {
                  _hapticFeedback = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('사운드 효과'),
              subtitle: const Text('게임 중 소리를 재생합니다'),
              value: _soundEffects,
              onChanged: (bool value) {
                setState(() {
                  _soundEffects = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '애니메이션 속도',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _animationSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 3,
              label: _animationSpeed.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  _animationSpeed = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '앱 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('버전: 1.0.0'),
            const Text('개발자: Flutter 복불복 팀'),
          ],
        ),
      ),
    );
  }
}

class BokbulbokHomePage extends StatefulWidget {
  const BokbulbokHomePage({super.key});

  @override
  _BokbulbokHomePageState createState() => _BokbulbokHomePageState();
}

class _BokbulbokHomePageState extends State<BokbulbokHomePage>
    with TickerProviderStateMixin {
  final Map<String, Offset> _touches = {};
  final Map<String, Color> _colors = {};
  final Map<String, AnimationController> _participantControllers = {};
  final Map<String, Animation<double>> _participantAnimations = {};
  final Map<String, AnimationController> _pulseControllers = {}; // 맥박 애니메이션용
  final Map<String, Animation<double>> _pulseAnimations = {}; // 맥박 애니메이션
  String? _selectedPlayerId;
  bool _isGameInProgress = false; // 게임 진행 상태 추가
  Timer? _selectionTimer; // 선택 타이머 추가
  AnimationController? _winnerController;
  Animation<double>? _winnerAnimation;
  AnimationController? _gatheringController; // 색상이 모이는 애니메이션용
  Animation<double>? _gatheringAnimation; // 색상이 모이는 애니메이션
  bool _isGathering = false; // 역방향 애니메이션 상태
  int _clickCounter = 0;

  @override
  void initState() {
    super.initState();
    _winnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _winnerAnimation =
        Tween<double>(begin: 0, end: 2000).animate(CurvedAnimation(
      parent: _winnerController!,
      curve: Curves.easeOut,
    ));

    _gatheringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _gatheringAnimation =
        Tween<double>(begin: 2000, end: 0).animate(CurvedAnimation(
      parent: _gatheringController!,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    for (var controller in _participantControllers.values) {
      controller.dispose();
    }
    for (var controller in _pulseControllers.values) {
      controller.dispose();
    }
    _winnerController?.dispose();
    _gatheringController?.dispose();
    _selectionTimer?.cancel(); // 선택 타이머 정리
    super.dispose();
  }

  void _startSelection() {
    if (_isGameInProgress) return; // 이미 게임이 진행 중이면 중복 실행 방지

    // 기존 타이머 취소
    _selectionTimer?.cancel();

    setState(() {
      _isGameInProgress = true;
    });

    // 새로운 2초 타이머 시작
    _selectionTimer =
        Timer(const Duration(milliseconds: 2500), _selectRandomPlayer);
  }

  void _selectRandomPlayer() {
    if (_touches.isEmpty) return;

    final random = Random.secure();
    final playerIds = _touches.keys.toList();
    final randomId = playerIds[random.nextInt(playerIds.length)];

    print('당첨자 선택: $randomId, 총 참여자: ${_touches.length}명'); // 디버그 로그

    setState(() {
      _selectedPlayerId = randomId;
      _isGameInProgress = false; // 게임 진행 상태 해제
    });

    // 모든 맥박 애니메이션 중단
    print('맥박 애니메이션 중단 시작, 컨트롤러 수: ${_pulseControllers.length}'); // 디버그 로그
    for (var entry in _pulseControllers.entries) {
      print('맥박 컨트롤러 중단: ${entry.key}'); // 디버그 로그
      entry.value.stop();
    }
    print('맥박 애니메이션 중단 완료'); // 디버그 로그

    // 참여자 애니메이션은 중단하지 않고 맥박만 중단
    print('참여자 애니메이션 유지, 맥박만 중단'); // 디버그 로그

    // 진동으로 당첨자 선정 알림 (0.2초 지속)
    try {
      // 0.2초 동안 진동 지속
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
      print('진동 실행됨: 0.2초 지속'); // 디버그 로그 추가
    } catch (e) {
      print('진동 오류: $e'); // 오류 로그 추가
      // 진동이 지원되지 않는 경우 기본 진동 시도
      HapticFeedback.vibrate();
    }
    _winnerController?.forward(from: 0);

    // 2초 후 역방향 애니메이션 시작
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _selectedPlayerId != null) {
        _startGatheringAnimation();
      }
    });
  }

  void _startGatheringAnimation() {
    print('역방향 애니메이션 시작'); // 디버그 로그
    print('_gatheringController: $_gatheringController'); // 디버그 로그
    print('mounted: $mounted'); // 디버그 로그
    print('_selectedPlayerId: $_selectedPlayerId'); // 디버그 로그
    print('_touches 개수: ${_touches.length}'); // 디버그 로그

    if (!mounted) {
      print('위젯이 dispose되었습니다');
      return;
    }

    if (_gatheringController == null) {
      print('_gatheringController가 null입니다. 다시 초기화합니다.');
      _gatheringController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
      _gatheringAnimation =
          Tween<double>(begin: 2000, end: 0).animate(CurvedAnimation(
        parent: _gatheringController!,
        curve: Curves.easeIn,
      ));
    }

    setState(() {
      _isGathering = true; // 역방향 애니메이션 시작
    });
    print('_isGathering = $_isGathering'); // 디버그 로그
    _gatheringController!.forward(from: 0).then((_) {
      // 애니메이션 완료 후 자동으로 게임 리셋
      if (mounted) {
        print('역방향 애니메이션 완료, 자동으로 게임 리셋');
        _reset();
      }
    });
  }
  // void _startGatheringAnimation() {
  //   print('역방향 애니메이션 시작'); // 디버그 로그
  //   print('_gatheringController: $_gatheringController'); // 디버그 로그
  //   print('mounted: $mounted'); // 디버그 로그
  //   print('_selectedPlayerId: $_selectedPlayerId'); // 디버그 로그
  //   print('_touches 개수: ${_touches.length}'); // 디버그 로그

  //   if (!mounted) {
  //     print('위젯이 dispose되었습니다');
  //     return;
  //   }

  //   if (_gatheringController == null) {
  //     print('_gatheringController가 null입니다. 다시 초기화합니다.');
  //     _gatheringController = AnimationController(
  //       vsync: this,
  //       duration: const Duration(seconds: 2),
  //     );
  //     _gatheringAnimation =
  //         Tween<double>(begin: 2000, end: 0).animate(CurvedAnimation(
  //       parent: _gatheringController!,
  //       curve: Curves.easeIn,
  //     ));
  //   }

  //   setState(() {
  //     _isGathering = true; // 역방향 애니메이션 시작
  //   });

  //   _gatheringController!.forward(from: 0).then((_) {
  //     if (!mounted) return;

  //     // 🔴 기존: _reset(); (전체 초기화로 당첨자도 사라짐)
  //     // ✅ 변경: 비당첨자만 정리하고 당첨자 원은 남김
  //     final winnerId = _selectedPlayerId;

  //     setState(() {
  //       _isGathering = false; // 역방향 연출 종료

  //       // 비당첨자만 정리
  //       final toRemove = _touches.keys.where((k) => k != winnerId).toList();
  //       for (final id in toRemove) {
  //         _participantControllers[id]?.dispose();
  //         _participantControllers.remove(id);
  //         _participantAnimations.remove(id);

  //         _pulseControllers[id]?.dispose();
  //         _pulseControllers.remove(id);
  //         _pulseAnimations.remove(id);

  //         _touches.remove(id);
  //         _colors.remove(id);
  //       }

  //       // 당첨자 관련 컨트롤러는 더 이상 필요 없으면 정리(원은 고정 렌더링됨)
  //       if (winnerId != null) {
  //         _participantControllers[winnerId]?.dispose();
  //         _participantControllers.remove(winnerId);
  //         _participantAnimations.remove(winnerId);

  //         _pulseControllers[winnerId]?.dispose();
  //         _pulseControllers.remove(winnerId);
  //         _pulseAnimations.remove(winnerId);
  //       }
  //     });
  //   });
  // }

  void _onPointerDown(PointerDownEvent event) {
    if (_selectedPlayerId != null) return; // 게임이 끝난 후에만 새 참여 막기
    if (_touches.length >= 15) return; // 최대 15명 제한

    final id = event.pointer.toString();

    setState(() {
      _touches[id] = event.localPosition;
      _colors[id] = _generateUniqueColor();
      _clickCounter++;
    });

    // 참여자 애니메이션 컨트롤러 생성
    _participantControllers[id] = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _participantAnimations[id] = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _participantControllers[id]!,
        curve: Curves.elasticOut,
      ),
    );

    // 맥박 애니메이션 컨트롤러 생성
    _pulseControllers[id] = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimations[id] = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _pulseControllers[id]!,
        curve: Curves.elasticOut,
      ),
    );

    // 애니메이션 시작
    _participantControllers[id]?.forward();

    // 맥박 애니메이션 즉시 시작
    _startPulseAnimation(id);

    // 기존 선택 타이머 리셋 후 게임 시작 체크
    _resetSelectionTimer();
    _checkAndStartGame();
  }

  void _startPulseAnimation(String id) {
    if (_pulseControllers[id] != null) {
      _pulseControllers[id]!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseControllers[id]!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          if (_selectedPlayerId == null) {
            // 게임이 끝나지 않았을 때만 반복
            _pulseControllers[id]!.forward();
          }
        }
      });
      _pulseControllers[id]!.forward();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_selectedPlayerId != null) return; // 선택 완료 후에만 드래그 막기

    final id = event.pointer.toString();
    if (_touches.containsKey(id)) {
      setState(() {
        _touches[id] = event.localPosition;
      });
    }
  }

  void _checkAndStartGame() {
    // 게임이 진행 중이 아니고, 참여자가 1명 이상일 때만 시작
    if (!_isGameInProgress &&
        _touches.isNotEmpty &&
        _selectedPlayerId == null) {
      _startSelection();
    }
  }

  void _resetSelectionTimer() {
    // 기존 선택 타이머 취소
    _selectionTimer?.cancel();

    // 게임 진행 상태 초기화
    if (_isGameInProgress) {
      setState(() {
        _isGameInProgress = false;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_selectedPlayerId != null) return; // 게임이 끝난 후에만 터치 취소 막기
    setState(() {
      final id = event.pointer.toString();
      _touches.remove(id);
      _colors.remove(id);

      // 참여자 애니메이션 컨트롤러 정리
      _participantControllers[id]?.dispose();
      _participantControllers.remove(id);
      _participantAnimations.remove(id);

      // 맥박 애니메이션 컨트롤러 정리
      _pulseControllers[id]?.dispose();
      _pulseControllers.remove(id);
      _pulseAnimations.remove(id);
    });

    // 기존 선택 타이머 리셋 후 게임 시작 체크
    _resetSelectionTimer();
    _checkAndStartGame();
  }

  void _onTap(TapDownDetails details) {
    if (_selectedPlayerId != null) return; // 게임이 끝난 후에만 새 참여 막기
    if (_touches.length >= 15) return; // 최대 15명 제한

    final id = "click_$_clickCounter";

    setState(() {
      _touches[id] = details.localPosition;
      _colors[id] = _generateUniqueColor();
      _clickCounter++;
    });

    // 참여자 애니메이션 컨트롤러 생성
    _participantControllers[id] = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _participantAnimations[id] = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _participantControllers[id]!,
        curve: Curves.elasticOut,
      ),
    );

    // 맥박 애니메이션 컨트롤러 생성
    _pulseControllers[id] = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimations[id] = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _pulseControllers[id]!,
        curve: Curves.elasticOut,
      ),
    );

    // 애니메이션 시작
    _participantControllers[id]?.forward();

    // 맥박 애니메이션 즉시 시작
    _startPulseAnimation(id);

    // 기존 선택 타이머 리셋 후 게임 시작 체크
    _resetSelectionTimer();
    _checkAndStartGame();
  }

  void _reset() {
    setState(() {
      _touches.clear();
      _colors.clear();
      _selectedPlayerId = null;
      _isGameInProgress = false; // 게임 진행 상태도 초기화
      _isGathering = false; // 역방향 애니메이션 상태 초기화
      _clickCounter = 0;
    });

    // 선택 타이머 정리
    _selectionTimer?.cancel();

    // 참여자 애니메이션 컨트롤러들 정리
    for (var controller in _participantControllers.values) {
      controller.dispose();
    }
    _participantControllers.clear();
    _participantAnimations.clear();

    // 맥박 애니메이션 컨트롤러들 정리
    for (var controller in _pulseControllers.values) {
      controller.dispose();
    }
    _pulseControllers.clear();
    _pulseAnimations.clear();

    // 승자 애니메이션 컨트롤러들 리셋
    _winnerController?.reset();
    _gatheringController?.reset();
  }

  final List<Color> _predefinedColors = [
    Colors.red, // 빨간색
    Colors.blue, // 파란색
    Colors.green, // 초록색
    Colors.orange, // 주황색
    Colors.purple, // 보라색
    Colors.yellow, // 노란색
    Colors.pink, // 분홍색
    Colors.cyan, // 청록색
    Colors.lime, // 연두색
    Colors.deepOrange, // 진한 주황색
    Colors.indigo, // 남색
    Colors.brown, // 갈색
    Colors.amber, // 황색
    Colors.deepPurple, // 진한 보라색
    Colors.lightGreen, // 연한 초록색
  ];

  Color _generateUniqueColor() {
    // 이미 사용된 색상들
    final usedColors = _colors.values.toSet();

    // 사용되지 않은 색상들 찾기
    final availableColors = _predefinedColors
        .where((color) => !usedColors.contains(color))
        .toList();

    // 사용 가능한 색상이 있으면 그 중에서 랜덤 선택
    if (availableColors.isNotEmpty) {
      final random = Random();
      return availableColors[random.nextInt(availableColors.length)];
    }

    // 모든 색상이 사용되었으면 랜덤 색상 생성
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1.0,
    );
  }

  // 색상을 어둡게 만드는 함수
  Color _getDarkerColor(Color color) {
    // HSL 색상 공간으로 변환하여 명도를 낮춤
    HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor
        .withLightness((hslColor.lightness * 0.4).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복불복'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: '다시 시작',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 전체 화면을 덮는 투명한 GestureDetector
          Positioned.fill(
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // 참여자 수 표시
          if (_touches.isNotEmpty && _selectedPlayerId == null)
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
                  '참여자: ${_touches.length}명',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // 당첨자 퍼져나가는 애니메이션
          if (_selectedPlayerId != null &&
              _touches[_selectedPlayerId!] != null &&
              !_isGathering)
            AnimatedBuilder(
              animation: _winnerAnimation!,
              builder: (context, child) {
                return Positioned(
                  left: _touches[_selectedPlayerId!]!.dx -
                      _winnerAnimation!.value / 2,
                  top: _touches[_selectedPlayerId!]!.dy -
                      _winnerAnimation!.value / 2,
                  child: Container(
                    width: _winnerAnimation!.value,
                    height: _winnerAnimation!.value,
                    decoration: BoxDecoration(
                      color: _colors[_selectedPlayerId!]!,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),

          // 색상이 모이는 역방향 애니메이션
          if (_isGathering &&
              _gatheringAnimation != null &&
              _selectedPlayerId != null &&
              _touches[_selectedPlayerId!] != null)
            AnimatedBuilder(
              animation: _gatheringAnimation!,
              builder: (context, child) {
                return Positioned(
                  left: _touches[_selectedPlayerId!]!.dx -
                      _gatheringAnimation!.value / 2,
                  top: _touches[_selectedPlayerId!]!.dy -
                      _gatheringAnimation!.value / 2,
                  child: Container(
                    width: _gatheringAnimation!.value,
                    height: _gatheringAnimation!.value,
                    decoration: BoxDecoration(
                      color: _colors[_selectedPlayerId!]!,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),

          // 당첨자가 선택된 경우 당첨자 원만 표시
          if (_selectedPlayerId != null && _touches[_selectedPlayerId!] != null)
            Positioned(
              left: _touches[_selectedPlayerId!]!.dx - 45,
              top: _touches[_selectedPlayerId!]!.dy - 45,
              child: IgnorePointer(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: _colors[_selectedPlayerId!]!,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getDarkerColor(_colors[_selectedPlayerId!]!),
                      width: 8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getDarkerColor(_colors[_selectedPlayerId!]!)
                            .withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(),
                  ),
                ),
              ),
            ),

          // 게임 진행 중일 때만 모든 원 표시
          if (_selectedPlayerId == null)
            ..._touches.entries.map((entry) {
              final color = _colors[entry.key] ?? Colors.grey;
              final animation = _participantAnimations[entry.key];

              if (animation == null) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: entry.value.dx - 45,
                top: entry.value.dy - 45,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final pulseAnimation = _pulseAnimations[entry.key];
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
                              color: _getDarkerColor(color),
                              width: 8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getDarkerColor(color).withOpacity(0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

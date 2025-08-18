import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

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
              '4. 설정된 시간(기본 2.5초) 카운트다운 후 한 명이 랜덤으로 선택됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '5. 당첨자 선정 시 0.2초 진동과 함께 승자 애니메이션이 실행됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '6. 역방향 애니메이션 후 자동으로 새 게임이 시작됩니다.',
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
              '• 애니메이션 속도와 카운트다운 시간을 설정에서 조절 가능',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• 다크모드로 눈의 피로도 감소',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• 안드로이드에서 진동 피드백 제공 (설정에서 끌 수 있음)',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

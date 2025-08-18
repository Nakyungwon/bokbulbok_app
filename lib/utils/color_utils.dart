import 'package:flutter/material.dart';
import 'dart:math';

class ColorUtils {
  static final List<Color> predefinedColors = [
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

  static Color generateUniqueColor(Map<String, Color> usedColors) {
    // 이미 사용된 색상들
    final usedColorsSet = usedColors.values.toSet();

    // 사용되지 않은 색상들 찾기
    final availableColors = predefinedColors
        .where((color) => !usedColorsSet.contains(color))
        .toList();

    // 사용 가능한 색상이 있으면 그 중에서 랜덤 선택
    if (availableColors.isNotEmpty) {
      final random = Random();
      return availableColors[random.nextInt(availableColors.length)];
    }

    // 모든 색상이 사용된 경우 랜덤 색상 생성
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1.0,
    );
  }

  static Color getDarkerColor(Color color) {
    HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor
        .withLightness((hslColor.lightness * 0.4).clamp(0.0, 1.0))
        .toColor();
  }
}

import 'package:flutter/material.dart';
import 'models/game_settings.dart';
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameSettings.initialize();
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
      home: const MainNavigation(),
    );
  }
}

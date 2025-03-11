import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:webtoon/screens/home_screen.dart';
import 'package:webtoon/theme/custom_theme.dart';
import 'package:webtoon/theme/custom_theme_mode.dart';

void main() {
  // 1. 앱 시작 시 위젯 바인딩 초기화
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 2. 스플래시 화면 유지
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // 3. 앱 초기화 후 스플래시 화면 제거
    // 데이터 로딩이 필요한 경우 비동기 작업 후 remove() 호출
    _removeSplashScreen();
  }

  // 4. 필요한 초기화 작업 후 스플래시 제거
  Future<void> _removeSplashScreen() async {
    try {
      // 초기화 작업
      await Future.delayed(Duration(seconds: 0));
    } catch (e) {
      print('초기화 중 오류 발생: $e');
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomThemeMode.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          darkTheme: CustomTheme.dark,
          theme: CustomTheme.light,
          themeMode: themeMode,
          home: HomeScreen(),
        );
      },
    );
  }
}

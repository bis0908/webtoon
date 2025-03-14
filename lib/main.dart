import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webtoon/screens/home_screen.dart';
import 'package:webtoon/theme/custom_theme.dart';
import 'package:webtoon/theme/custom_theme_mode.dart';
import 'package:webtoon/common/banner_example.dart';

void main() {
  // 전역 오류 핸들러 등록
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter 오류: ${details.exception}');
    debugPrint('스택 트레이스: ${details.stack}');
  };

  // 비동기 오류 처리
  runZonedGuarded(() {
    // 1. 앱 시작 시 위젯 바인딩 초기화
    WidgetsFlutterBinding.ensureInitialized();
    // 2. 스플래시 화면 유지 (비동기 대기 없이 바로 실행)
    FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

    // 앱 즉시 실행 (초기화 대기 없음)
    runApp(const MainApp());
  }, (error, stack) {
    debugPrint('비동기 오류: $error');
    debugPrint('스택 트레이스: $stack');
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  bool _adsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 앱 초기화 작업 시작 (비동기적으로 실행)
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 앱 상태 변경 감지 (백그라운드에서 포그라운드로 돌아올 때 등)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_adsInitialized && !kIsWeb) {
      // 앱이 다시 활성화되었을 때 광고가 초기화되지 않았다면 다시 시도
      _initializeAds();
    }
  }

  // 앱 초기화 작업을 비동기적으로 처리
  Future<void> _initializeApp() async {
    // 광고 초기화 (웹이 아닌 경우에만)
    if (!kIsWeb) {
      // 광고 초기화를 별도 스레드에서 실행하여 UI 블로킹 방지
      Future.microtask(() => _initializeAds());
    }

    // 스플래시 화면 제거 (광고 초기화 완료를 기다리지 않음)
    _removeSplashScreen();
  }

  // 스플래시 화면 제거
  void _removeSplashScreen() {
    try {
      FlutterNativeSplash.remove();
    } catch (e) {
      debugPrint('스플래시 화면 제거 중 오류 발생: $e');
    }
  }

  // 광고 초기화 (비동기적으로 처리, 실패해도 앱 실행에 영향 없음)
  Future<void> _initializeAds() async {
    if (_adsInitialized) return;

    try {
      bool isInitialized = false;

      // 타임아웃 설정
      Timer? timeoutTimer = Timer(Duration(seconds: 5), () {
        if (!isInitialized) {
          debugPrint('모바일 광고 초기화 타임아웃');
          // 타임아웃 시 초기화 실패로 처리하고 계속 진행
          _adsInitialized = true; // 재시도 방지
        }
      });

      // 간소화된 초기화 방식 사용
      try {
        // 테스트 기기 설정 없이 기본 초기화만 수행
        await MobileAds.instance.initialize();
        isInitialized = true;
        _adsInitialized = true;
        timeoutTimer.cancel();
        debugPrint('모바일 광고 초기화 완료');
      } catch (e) {
        debugPrint('광고 초기화 실패: $e');
        _adsInitialized = true; // 재시도 방지
      }
    } catch (e) {
      debugPrint('모바일 광고 초기화 실패: $e');
      // 초기화 실패해도 앱은 계속 실행
      _adsInitialized = true; // 재시도 방지
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomThemeMode.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          darkTheme: CustomTheme.dark,
          theme: CustomTheme.light,
          themeMode: themeMode,
          home: HomeScreen(),
        );
      },
    );
  }
}

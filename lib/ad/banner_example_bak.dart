import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 배너 광고 컨트롤러 클래스 추가
class BannerAdController {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  int _retryCount = 0;
  static const int MAX_RETRY = 3;

  // 상태 변경 콜백 함수 목록
  final List<Function(bool)> _listeners = [];

  bool get isLoaded => _isLoaded;
  BannerAd? get bannerAd => _bannerAd;

  late final String adUnitId;

  // 생성자에서 초기화
  BannerAdController() {
    adUnitId = _getAdUnitId();
  }

  // 상태 변경 리스너 추가
  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  // 상태 변경 리스너 제거
  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  // 상태 변경 알림
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_isLoaded);
    }
  }

  // 상태 설정
  void _setLoaded(bool loaded) {
    if (_isLoaded != loaded) {
      _isLoaded = loaded;
      _notifyListeners();
    }
  }

  String _getAdUnitId() {
    if (kIsWeb) {
      return '';
    }

    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111' // 안드로이드 테스트 배너 ID (일반 배너)
        : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID
  }

  // 컨텍스트를 매개변수로 받도록 수정
  void loadAd([BuildContext? context]) async {
    if (kIsWeb) {
      debugPrint('웹 환경에서는 모바일 광고가 지원되지 않습니다.');
      return;
    }

    if (adUnitId.isEmpty) {
      debugPrint('광고 ID가 비어 있습니다.');
      return;
    }

    // 이미 로딩 중이면 중복 로드 방지
    if (_isLoading) {
      debugPrint('이미 광고 로드 중입니다.');
      return;
    }

    _isLoading = true;
    _retryCount = 0;

    try {
      await _loadAdWithRetry(context);
    } catch (e) {
      debugPrint('광고 로드 중 예외 발생: $e');
      _isLoading = false;
      _setLoaded(false);
    }
  }

  // 재시도 로직이 포함된 광고 로드 함수
  Future<void> _loadAdWithRetry(BuildContext? context) async {
    if (_retryCount >= MAX_RETRY) {
      debugPrint('최대 재시도 횟수 초과: $_retryCount');
      _isLoading = false;
      return;
    }

    try {
      // 컨텍스트가 제공되지 않은 경우 NavigationService 사용
      BuildContext? currentContext =
          context ?? NavigationService.navigatorKey.currentContext;

      if (currentContext == null) {
        debugPrint('유효한 컨텍스트를 찾을 수 없습니다.');
        _isLoading = false;
        return;
      }

      // 기기 너비에 맞는 배너 크기 가져오기
      AdSize size = AdSize.banner; // 기본값 설정

      try {
        final adaptiveSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
          Orientation.portrait,
          MediaQuery.of(currentContext).size.width.truncate(),
        );

        if (adaptiveSize != null) {
          size = adaptiveSize;
        } else {
          debugPrint('적응형 배너 크기를 가져오지 못했습니다. 기본 크기 사용');
        }
      } catch (e) {
        debugPrint('배너 크기 계산 중 오류 발생: $e');
        // 오류 발생 시 기본 배너 크기 사용
      }

      // 이전 배너가 있으면 정리
      _bannerAd?.dispose();
      _bannerAd = null;
      _setLoaded(false);

      // 새 배너 생성
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('배너 광고 로드 성공');
            _isLoading = false;
            _setLoaded(true);
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('배너 광고 로드 실패: $err');
            ad.dispose();
            _setLoaded(false);

            // 실패 시 재시도
            _retryCount++;
            debugPrint('광고 로드 재시도: $_retryCount/$MAX_RETRY');

            // 지연 후 재시도
            Future.delayed(Duration(seconds: 1), () {
              if (currentContext != null && currentContext.mounted) {
                _loadAdWithRetry(currentContext);
              } else {
                _isLoading = false;
              }
            });
          },
          onAdOpened: (ad) => debugPrint('배너 광고 열림'),
          onAdClosed: (ad) => debugPrint('배너 광고 닫힘'),
        ),
      );

      // 배너 로드 시도
      await _bannerAd!.load();
    } catch (e) {
      debugPrint('배너 로드 중 예외 발생: $e');
      _bannerAd?.dispose();
      _bannerAd = null;
      _setLoaded(false);
      _isLoading = false;
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _setLoaded(false);
    _listeners.clear();
    _isLoading = false;
  }
}

// NavigationService 추가 (전역 context 접근용)
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

// 배너 광고 위젯
class AdBannerWidget extends StatefulWidget {
  final BannerAdController controller;

  const AdBannerWidget({
    super.key,
    required this.controller,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget>
    with WidgetsBindingObserver {
  bool _isAdLoaded = false;
  bool _forceRebuild = false;

  @override
  void initState() {
    super.initState();

    // WidgetsBinding 옵저버 등록
    WidgetsBinding.instance.addObserver(this);

    // 컨트롤러의 상태 변경 리스너 등록
    widget.controller.addListener(_onAdStateChanged);
    _isAdLoaded = widget.controller.isLoaded;

    // 위젯이 생성될 때 컨텍스트를 전달하여 광고 로드
    if (!_isAdLoaded) {
      // 위젯 빌드 후 컨텍스트 전달
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 광고 로드를 별도 스레드에서 실행
          Future.microtask(() {
            if (mounted) {
              widget.controller.loadAd(context);

              // 일정 시간 후 강제로 레이아웃 갱신
              _scheduleRebuild();
            }
          });
        }
      });
    }
  }

  // 일정 시간 간격으로 위젯 갱신 스케줄링
  void _scheduleRebuild() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _forceRebuild = !_forceRebuild; // 상태 변경으로 강제 갱신
        });

        // 광고가 로드되지 않았으면 계속 시도
        if (!_isAdLoaded && mounted) {
          _scheduleRebuild();
        }
      }
    });
  }

  // 앱 생명주기 변경 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 강제 갱신
      if (mounted) {
        setState(() {});
      }
    }
  }

  // 광고 상태 변경 콜백
  void _onAdStateChanged(bool isLoaded) {
    if (mounted && _isAdLoaded != isLoaded) {
      setState(() {
        _isAdLoaded = isLoaded;
      });
    }
  }

  @override
  void dispose() {
    // 리스너 제거
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onAdStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 컨트롤러의 상태와 로컬 상태 모두 확인
    if (widget.controller.bannerAd != null && _isAdLoaded) {
      return Container(
        width: widget.controller.bannerAd!.size.width.toDouble(),
        height: widget.controller.bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: AdWidget(ad: widget.controller.bannerAd!),
      );
    }

    // 광고가 로드되지 않았을 때 최소한의 공간 확보
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              "광고 로드 중...",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 기존 BannerExample 클래스는 유지 (예제용)
class BannerExample extends StatefulWidget {
  const BannerExample({super.key});

  @override
  BannerExampleState createState() => BannerExampleState();
}

class BannerExampleState extends State<BannerExample> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  // TODO: replace this test ad unit with your own ad unit.

  late final String adUnitId;

  @override
  void initState() {
    super.initState();
    adUnitId = _getAdUnitId();
    loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  String _getAdUnitId() {
    if (kIsWeb) {
      // 웹용 테스트 광고 ID 또는 웹에서는 광고를 사용하지 않음을 표시
      return '';
    }

    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111' // 안드로이드 테스트 배너 ID (일반 배너)
        : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID
  }

  /// Loads a banner ad.
  void loadAd() async {
    if (kIsWeb) {
      debugPrint('웹 환경에서는 모바일 광고가 지원되지 않습니다.');
      return;
    }

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      debugPrint('배너 크기를 가져오지 못했습니다.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('배너 광고 예제'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('배너 광고 예제입니다.'),
            const SizedBox(height: 20),
            if (_bannerAd != null && _isLoaded)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}

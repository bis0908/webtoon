import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 배너 광고 컨트롤러 클래스 추가
class BannerAdController {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  BannerAd? get bannerAd => _bannerAd;

  late final String adUnitId;

  // 생성자에서 초기화
  BannerAdController() {
    adUnitId = _getAdUnitId();
  }

  String _getAdUnitId() {
    if (kIsWeb) {
      return '';
    }

    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111' // 안드로이드 테스트 배너 ID
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

    try {
      // 컨텍스트가 제공되지 않은 경우 NavigationService 사용
      BuildContext? currentContext =
          context ?? NavigationService.navigatorKey.currentContext;

      if (currentContext == null) {
        debugPrint('유효한 컨텍스트를 찾을 수 없습니다. 광고 로드를 지연합니다.');
        // 나중에 다시 시도하도록 지연
        Future.delayed(Duration(seconds: 1), () => loadAd());
        return;
      }

      // 기기 너비에 맞는 배너 크기 가져오기
      final size = await AdSize.getAnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        MediaQuery.of(currentContext).size.width.truncate(),
      );

      if (size == null) {
        debugPrint('배너 크기를 가져오지 못했습니다.');
        return;
      }

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            _isLoaded = true;
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('BannerAd failed to load: $err');
            ad.dispose();
            _isLoaded = false;
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      debugPrint('배너 광고 로드 중 오류 발생: $e');
      _isLoaded = false;
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
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

class _AdBannerWidgetState extends State<AdBannerWidget> {
  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 컨텍스트를 전달하여 광고 로드
    if (!widget.controller.isLoaded) {
      // 위젯 빌드 후 컨텍스트 전달
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadAd(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.bannerAd != null && widget.controller.isLoaded) {
      return SizedBox(
        width: widget.controller.bannerAd!.size.width.toDouble(),
        height: widget.controller.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: widget.controller.bannerAd!),
      );
    }

    // 광고가 로드되지 않았을 때 최소한의 공간 확보
    return SizedBox(height: 50);
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
        ? 'ca-app-pub-3940256099942544/6300978111' // 안드로이드 테스트 배너 ID
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

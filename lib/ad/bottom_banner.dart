import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BottomBanner extends StatefulWidget {
  const BottomBanner({
    super.key,
  });

  @override
  State<BottomBanner> createState() => _BottomBannerState();
}

class _BottomBannerState extends State<BottomBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isAdLoading = false; // 광고 로딩 상태 추적

  // 테스트 광고 단위 ID (실제 앱 출시 시 실제 ID로 교체 필요)
  final String adUnitId = kIsWeb
      ? '' // 웹에서는 광고 표시 안 함
      : Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9214589741' // 안드로이드 테스트 ID
          : 'ca-app-pub-3940256099942544/2435281174'; // iOS 테스트 ID

  @override
  void initState() {
    super.initState();
    // initState에서는 MediaQuery 사용하지 않음
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 광고가 아직 로딩 중이 아니고, 웹이 아닌 경우에만 광고 로드
    if (!_isAdLoading && !kIsWeb) {
      _isAdLoading = true;
      loadAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// 배너 광고 로드 함수
  void loadAd() async {
    // 현재 화면 방향과 너비에 맞는 적응형 배너 광고 크기 가져오기
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('광고 크기를 가져올 수 없습니다.');
      setState(() {
        _isAdLoading = false; // 로딩 상태 업데이트
      });
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // 광고가 성공적으로 로드되었을 때 호출
        onAdLoaded: (ad) {
          debugPrint('배너 광고가 로드되었습니다: $ad');
          setState(() {
            _isLoaded = true;
            _isAdLoading = false; // 로딩 상태 업데이트
          });
        },
        // 광고 로드 실패 시 호출
        onAdFailedToLoad: (ad, error) {
          debugPrint('배너 광고 로드 실패: $error');
          // 리소스 해제를 위해 광고 dispose
          ad.dispose();
          setState(() {
            _isAdLoading = false; // 로딩 상태 업데이트
          });
        },
        // 광고가 화면을 덮는 오버레이를 열 때 호출.
        onAdOpened: (Ad ad) {
          debugPrint('배너 광고 열림');
        },
        // 광고가 화면을 덮는 오버레이를 제거할 때 호출.
        onAdClosed: (Ad ad) {
          debugPrint('배너 광고 닫힘');
        },
        // 광고에 노출이 발생하면 호출.
        onAdImpression: (Ad ad) {
          debugPrint('배너 광고 노출됨');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    // 웹이거나 광고가 로드되지 않았을 때 표시할 플레이스홀더
    if (kIsWeb || !_isLoaded) {
      return Container(
        width: double.infinity,
        height: 60, // 광고 로드 전 공간 확보
        alignment: Alignment.center,
        child: kIsWeb
            ? const Text('안드로이드 앱에서만 광고가 표시됩니다.')
            : const Text('광고 로드 중...'),
      );
    }

    // 광고가 로드되었을 때 표시할 위젯
    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

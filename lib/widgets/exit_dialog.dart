import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ExitDialog extends StatefulWidget {
  const ExitDialog({super.key});

  @override
  State<ExitDialog> createState() => _ExitDialogState();
}

class _ExitDialogState extends State<ExitDialog> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // 테스트 광고 ID
  final String adUnitId = 'ca-app-pub-3940256099942544/9214589741';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() async {
    // 기기의 너비에 맞는 적응형 배너 광고 크기 계산
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('광고 크기를 가져올 수 없습니다.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Banner Height: ${_bannerAd?.size.height.toDouble()}');
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 광고 영역
          if (!kIsWeb)
            Container(
              width: double.infinity,
              height: _bannerAd?.size.height.toDouble() ?? 160,
              alignment: Alignment.center,
              child: _isAdLoaded
                  ? AdWidget(ad: _bannerAd!)
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          // 구분선
          const Divider(height: 1),
          // 종료 확인 메시지
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 16,
            ),
            child: Text(
              '앱을 종료하시겠습니까?',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          // 버튼 영역
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 취소 버튼
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                // 세로 구분선
                Container(
                  width: 1,
                  height: 48,
                  color: Theme.of(context).dividerColor,
                ),
                // 종료 버튼
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      SystemNavigator.pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '종료',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

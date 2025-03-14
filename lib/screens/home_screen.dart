import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webtoon/models/webtoon_model.dart';
import 'package:webtoon/screens/favorites_area.dart';
import 'package:webtoon/services/api_service.dart';
import 'package:webtoon/theme/switch_theme.dart';
import 'package:webtoon/common/common_appbar.dart';
import 'package:webtoon/widgets/webtoon_widget.dart';
import 'package:webtoon/common/banner_example.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToon();
  final GlobalKey<FavoritesAreaState> favoritesKey =
      GlobalKey<FavoritesAreaState>();
  BannerAdController? _bannerAdController;
  bool _adInitialized = false;

  @override
  void initState() {
    super.initState();

    // 광고 컨트롤러 초기화 (지연 시작)
    // 앱이 완전히 로드된 후 광고 초기화 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBannerAd();
    });
  }

  // 배너 광고 초기화 (별도 메서드로 분리)
  void _initBannerAd() {
    if (_adInitialized || !mounted) return;

    try {
      _adInitialized = true;

      if (!kIsWeb) {
        _bannerAdController = BannerAdController();

        // 위젯 빌드 후 컨텍스트가 유효할 때 광고 로드
        if (mounted && _bannerAdController != null) {
          // 광고 로드를 별도 스레드에서 실행
          Future.microtask(() {
            if (mounted) {
              _bannerAdController!.loadAd(context);

              // 일정 시간 후 상태 갱신 (광고 표시 확인)
              Future.delayed(Duration(seconds: 3), () {
                if (mounted && !_bannerAdController!.isLoaded) {
                  // 3초 후에도 광고가 로드되지 않았으면 다시 시도
                  setState(() {});
                  _bannerAdController!.loadAd(context);
                }
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('배너 광고 초기화 중 오류: $e');
    }
  }

  @override
  void dispose() {
    _bannerAdController?.dispose();
    _bannerAdController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: '오늘의 웹툰!', actions: [
        switchTheme(),
      ]),
      body: SafeArea(
        // SafeArea로 감싸서 시스템 UI와 겹치지 않도록 함
        bottom: true, // 하단 영역 보호 (배너 광고 표시 영역)
        child: Column(
          children: [
            // 메인 콘텐츠 영역 (스크롤 가능)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // 새로고침 시 광고도 다시 로드
                  if (!_adInitialized) {
                    _initBannerAd();
                  } else if (_bannerAdController != null && mounted) {
                    _bannerAdController!.loadAd(context);
                  }

                  // 상태 갱신
                  setState(() {});
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10), // 상단 여백 줄임
                      // 웹툰 가로 스크롤 리스트 (높이 증가)
                      SizedBox(
                        height: 250, // 높이를 200에서 250으로 증가
                        child: FutureBuilder(
                          future: webtoons,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return _buildWebtoonList(snapshot.data!);
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                      // 즐겨찾기 영역 제목
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 10, 20, 5), // 패딩 줄임
                        child: Row(
                          children: [
                            Icon(Icons.favorite,
                                color: Colors.red, size: 20), // 아이콘 크기 줄임
                            SizedBox(width: 8),
                            Text(
                              "즐겨찾기",
                              style: TextStyle(
                                fontSize: 16, // 폰트 크기 줄임
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 즐겨찾기 영역 (스크롤 가능, 높이 제한)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height *
                              0.3, // 화면 높이의 30%로 제한
                        ),
                        child: FutureBuilder(
                          future: webtoons,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return FavoritesArea(
                                snapshot,
                                key: favoritesKey,
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                      // 배너 광고 아래 여백 확보
                      SizedBox(height: 5), // 여백 줄임
                    ],
                  ),
                ),
              ),
            ),
            // 배너 광고 위젯 (하단에 고정)
            if (!kIsWeb)
              Container(
                width: double.infinity,
                height: 60, // 광고 로드 전 공간 확보
                alignment: Alignment.center,
                child: _bannerAdController != null
                    ? AdBannerWidget(
                        controller: _bannerAdController!,
                      )
                    : SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            "광고 로드 중...",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  // 가로 스크롤 웹툰 리스트
  Widget _buildWebtoonList(List<WebtoonModel> webtoons) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: webtoons.length,
      itemBuilder: (context, index) {
        var webtoon = webtoons[index];
        return Webtoon(
          webtoon: webtoon,
          onDetailClosed: () {
            // DetailScreen에서 돌아오면 FavoritesArea 갱신
            favoritesKey.currentState?.initPrefs();
          },
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          width: 20, // 간격 줄임
        );
      },
    );
  }
}

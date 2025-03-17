import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webtoon/ad/bottom_banner.dart';
import 'package:webtoon/models/webtoon_model.dart';
import 'package:webtoon/screens/favorites_area.dart';
import 'package:webtoon/services/api_service.dart';
import 'package:webtoon/theme/switch_theme.dart';
import 'package:webtoon/common/common_appbar.dart';
import 'package:webtoon/widgets/webtoon_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToon();
  final GlobalKey<FavoritesAreaState> favoritesKey =
      GlobalKey<FavoritesAreaState>();

  @override
  void initState() {
    super.initState();
  }

  // 배너 광고 초기화 (별도 메서드로 분리)

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
            // 메인 콘텐츠 영역 (스크롤 불가능)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 웹툰 가로 리스트 (고정 높이)
                  SizedBox(
                    height: 300,
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
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "즐겨찾기",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 즐겨찾기 영역 (남은 공간 모두 차지)
                  Expanded(
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
                ],
              ),
            ),
            // 배너 광고 위젯 (하단에 고정)
            BottomBanner(),
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

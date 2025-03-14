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
  final BannerAdController _bannerAdController = BannerAdController();

  @override
  void initState() {
    super.initState();

    // 위젯 빌드 후 컨텍스트가 유효할 때 광고 로드
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bannerAdController.loadAd(context);
      });
    }
  }

  @override
  void dispose() {
    _bannerAdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: '오늘의 웹툰!', actions: [
        switchTheme(),
      ]),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: webtoons,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: makeList(snapshot),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: FavoritesArea(
                          key: favoritesKey,
                          snapshot,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return Center(
                    // child: CircularProgressIndicator(),
                    );
              },
            ),
          ),
          if (!kIsWeb)
            AdBannerWidget(
              controller: _bannerAdController,
            ),
        ],
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<WebtoonModel>> snapshot) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        var webtoon = snapshot.data![index];
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
          width: 40,
        );
      },
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webtoon/ad/bottom_banner.dart';
import 'package:webtoon/models/webtoon_episode_model.dart';
import 'package:webtoon/models/webtoon_model.dart';
import 'package:webtoon/models/webtoon_model_detail.dart';
import 'package:webtoon/services/api_service.dart';
import 'package:webtoon/theme/switch_theme.dart';
import 'package:webtoon/common/common_appbar.dart';
import 'package:webtoon/widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.webtoon,
  });

  final WebtoonModel webtoon;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoonDetail;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferencesAsync prefs;

  bool isLiked = false;

  Future initPrefs() async {
    prefs = SharedPreferencesAsync();
    final likedToons = await prefs.getStringList('likedToons');

    if (likedToons != null) {
      if (likedToons.contains(widget.webtoon.id)) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await prefs.setStringList('likedToons', []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoonDetail = ApiService.getToonById(widget.webtoon.id);
    episodes = ApiService.getEpisodesById(widget.webtoon.id);
    initPrefs();
  }

  onFavoriteTap() async {
    final likedToons = await prefs.getStringList('likedToons');
    if (isLiked) {
      likedToons!.remove(widget.webtoon.id);
    } else {
      likedToons!.add(widget.webtoon.id);
    }
    await prefs.setStringList('likedToons', likedToons);
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();

    return Scaffold(
      appBar: appBar(
        title: widget.webtoon.title,
        actions: [
          switchTheme(),
          IconButton(
            onPressed: onFavoriteTap,
            icon: Icon(
              isLiked
                  ? Icons.favorite_outlined
                  : Icons.favorite_outline_outlined,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Hero(
                      tag: widget.webtoon.id,
                      child: Container(
                        width: 250,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20,
                                offset: Offset(10, 10),
                                color: Colors.black26,
                              )
                            ]),
                        child: Image.network(
                          widget.webtoon.thumb,
                          headers: {
                            'Referer': 'https://comic.naver.com',
                            "User-Agent":
                                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36",
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CircularProgressIndicator();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('이미지 로딩 에러: $error');
                            return Container(
                              width: 100,
                              height: 150,
                              color: Colors.grey.shade300,
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    FutureBuilder(
                      future: webtoonDetail,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unescape.convert(snapshot.data!.about),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${snapshot.data!.genre} / ${snapshot.data!.age}",
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    FutureBuilder(
                      future: episodes,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              for (var epi in snapshot.data!)
                                Episode(
                                  unescape: unescape,
                                  epi: epi,
                                  webtoonId: widget.webtoon.id,
                                )
                            ],
                          );
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          BottomBanner(),
        ],
      ),
    );
  }
}

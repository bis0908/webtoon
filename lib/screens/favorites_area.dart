import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webtoon/models/webtoon_model.dart';
import 'package:webtoon/screens/detail_screen.dart';

/// 기능 설계
/// 내가 좋아요 표시를 누른 웹툰의 리스트를 불러온다.
/// 불러온 리스트는 세로로 나열한다.
/// 좋아요 표시를 취소하면 리스트에서도 삭제 되어야 한다.
/// 리스트 항목을 선택하면 해당 웹툰 상세 페이지로 이동한다.

class FavoritesArea extends StatefulWidget {
  final AsyncSnapshot<List<WebtoonModel>> snapshot;
  final GlobalKey<FavoritesAreaState> favoritesKey =
      GlobalKey<FavoritesAreaState>();

  FavoritesArea(
    this.snapshot, {
    super.key,
  });

  @override
  State<FavoritesArea> createState() => FavoritesAreaState();
}

class FavoritesAreaState extends State<FavoritesArea> {
  List<String> likedToons = [];
  List<WebtoonModel> likedWebtoons = [];

  Future<void> initPrefs() async {
    final prefs = SharedPreferencesAsync();
    final likedToonsIds = await prefs.getStringList('likedToons') ?? [];

    setState(() {
      likedToons = likedToonsIds;
      // 좋아요 표시된 웹툰 ID를 기반으로 웹툰 모델 찾기
      if (widget.snapshot.hasData) {
        likedWebtoons = widget.snapshot.data!
            .where((webtoon) => likedToons.contains(webtoon.id))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.favorite,
          color: Colors.red,
          size: 30,
        ),
        for (var webtoon in likedWebtoons)
          Card(
            elevation: 2,
            color: Colors.green.shade100,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(webtoon: webtoon),
                  ),
                );
                // 상세 페이지에서 돌아오면 좋아요 목록 갱신
                initPrefs();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        webtoon.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

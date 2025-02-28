import 'package:flutter/material.dart';

/// 기능 설계
/// 내가 좋아요 표시를 누른 웹툰의 리스트를 불러온다.
/// 불러온 리스트는 세로로 나열한다.
/// 좋아요 표시를 취소하면 리스트에서도 삭제 되어야 한다.
/// 리스트 항목을 선택하면 해당 웹툰 상세 페이지로 이동한다.

class FavoritesArea extends StatefulWidget {
  const FavoritesArea({
    super.key,
  });

  @override
  State<FavoritesArea> createState() => _FavoritesAreaState();
}

class _FavoritesAreaState extends State<FavoritesArea> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Favorites areas'),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webtoon/models/webtoon_model.dart';
import 'package:webtoon/screens/detail_screen.dart';

class Webtoon extends StatelessWidget {
  final WebtoonModel webtoon;
  final VoidCallback? onDetailClosed;

  const Webtoon({
    super.key,
    required this.webtoon,
    this.onDetailClosed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(webtoon: webtoon),
          ),
        );
        // DetailScreen에서 돌아오면 콜백 호출
        onDetailClosed?.call();
      },
      child: Column(
        children: [
          Hero(
            tag: webtoon.id,
            child: Container(
              width: 180,
              height: 180,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      offset: Offset(5, 5),
                      color: Colors.black26,
                    )
                  ]),
              child: Image.network(
                webtoon.thumb,
                headers: {
                  'Referer': 'https://comic.naver.com',
                  "User-Agent":
                      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36",
                },
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  print('이미지 로딩 에러: $error');
                  return Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            webtoon.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

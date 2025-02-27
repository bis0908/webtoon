import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webtoon/models/webtoon_episode_model.dart';
import 'package:webtoon/models/webtoon_model.dart';

class Episode extends StatelessWidget {
  const Episode({
    super.key,
    required this.unescape,
    required this.epi,
    required this.webtoon,
  });

  final HtmlUnescape unescape;
  final WebtoonEpisodeModel epi;
  final WebtoonModel webtoon;

  onButtonTab() async {
    final url = Uri.parse(
        "https://comic.naver.com/webtoon/detail?titleId=${webtoon.id}&no=${epi.id}");
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onButtonTab,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          // margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.green.shade400,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unescape.convert(epi.title),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    overflow: TextOverflow.fade,
                  ),
                ),
                Icon(
                  Icons.chevron_right_sharp,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

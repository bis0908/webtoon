import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:webtoon/models/webtoon_episode_model.dart';
import 'package:webtoon/models/webtoon_model.dart';
import 'package:webtoon/models/webtoon_model_detail.dart';

class ApiService {
  static const String baseUrl =
      "https://webtoon-crawler.nomadcoders.workers.dev";
  static final String today = "/today";

  static Future<List<WebtoonModel>> getTodaysToon() async {
    final Uri url = Uri.parse(baseUrl + today);

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch webtoons(getTodaysToon): ${response.statusCode}',
        );
      }

      final List<dynamic> webtoonsJson = jsonDecode(response.body);

      return webtoonsJson.map((toon) => WebtoonModel.fromJson(toon)).toList();
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  static Future<WebtoonDetailModel> getToonById(String id) async {
    final Uri url = Uri.parse("$baseUrl/$id");

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch webtoons(getToonById): ${response.statusCode}',
        );
      }

      final webtoon = jsonDecode(response.body);

      return WebtoonDetailModel.fromJson(webtoon);
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<List<WebtoonEpisodeModel>> getEpisodesById(String id) async {
    final Uri url = Uri.parse("$baseUrl/$id/episodes");

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch webtoons(getEpisodesById): ${response.statusCode}',
        );
      }
      final List<dynamic> episodesJson = jsonDecode(response.body);

      return episodesJson
          .map((episode) => WebtoonEpisodeModel.fromJson(episode))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }
}

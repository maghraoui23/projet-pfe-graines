import 'Subreddit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'SubredditRequest.dart';

class SubredditService {
  final String baseUrl = "http://192.168.1.5:9090/api/subreddit";

  Future<List<Subreddit>> getAllSubreddits(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((subreddit) => Subreddit.fromJson(subreddit))
          .toList();
    } else {
      throw Exception("Failed to load subreddits");
    }
  }

  Future<List<Subreddit>> searchSubreddits(String query, String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.5:9090/api/subreddit/search?name=$query'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Subreddit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subreddits');
    }
  }

  Future<Subreddit> createSubreddit(
      SubredditRequest subredditRequest, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": subredditRequest.name,
        "description": subredditRequest.description,
      }),
    );

    if (response.statusCode == 201) {
      return Subreddit.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create subreddit");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'PostRequest.dart';
import 'PostResponse.dart';

class PostService {
  final String baseUrl = "http://192.168.1.5:9090/api/posts";

  Future<List<PostResponse>> getAllPosts(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((post) => PostResponse.fromJson(post)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }

  // Modifier la signature de la méthode
  Future<void> createPost(PostRequest postRequest, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(
          postRequest.toJson()), // Utiliser la méthode toJson existante
    );

    if (response.statusCode == 201) {
      return; // Ne plus retourner de Post
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? "Failed to create post");
    }
  }

  Future<PostResponse> getPost(int postId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$postId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return PostResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load post");
    }
  }

  Future<List<PostResponse>> getPostsBySubreddit(
      int subredditId, String token) async {
    final url = Uri.parse(baseUrl)
        .replace(queryParameters: {'subredditId': subredditId.toString()});

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((post) => PostResponse.fromJson(post)).toList();
    } else {
      throw Exception("Failed to load posts by subreddit");
    }
  }

  Future<List<PostResponse>> searchPosts(String query, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?query=$query'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((post) => PostResponse.fromJson(post)).toList();
    } else {
      throw Exception("Failed to search posts");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Commentdto.dart';

class CommentService {
  final String baseUrl = "http://192.168.1.5:9090/api/comments";

  /// 🔹 **Créer un commentaire**
  Future<void> createComment(CommentsDto commentsDto, String token) async {
    final url = Uri.parse(baseUrl);
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    // Créez le corps en fonction du type de commentaire
    final body = jsonEncode({
      "text": commentsDto.text,
      "postId": commentsDto.postId,
      if (commentsDto.parentId != null) "parentId": commentsDto.parentId,
    });

    print("🔵 [POST] Envoi de la requête à $url");
    print("📩 Corps de la requête : $body");

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 201) {
        print("❌ Erreur: ${response.body}");
        throw Exception("Failed to create comment: ${response.body}");
      }
      print("🟢 Commentaire créé avec succès");
    } catch (e) {
      print("⚠️ Exception: $e");
      throw Exception("Error creating comment: $e");
    }
  }

  /// 🔹 **Récupérer tous les commentaires pour un post**
  Future<List<CommentsDto>> getAllCommentsForPost(
      int postId, String token) async {
    final url = Uri.parse('$baseUrl?postId=$postId');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    print("🔵 [GET] Récupération des commentaires pour le post ID: $postId");

    try {
      final response = await http.get(url, headers: headers);

      print("🟢 [GET] Réponse reçue : ${response.statusCode}");
      print("📥 Réponse body : ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        List<CommentsDto> comments =
            jsonData.map((comment) => CommentsDto.fromJson(comment)).toList();

        print("✅ ${comments.length} commentaire(s) récupéré(s)");
        return comments;
      } else {
        print("❌ Erreur: Impossible de récupérer les commentaires");
        throw Exception("Failed to load comments");
      }
    } catch (e) {
      print("⚠️ Exception lors de la récupération des commentaires: $e");
      throw Exception("Error fetching comments: $e");
    }
  }
}

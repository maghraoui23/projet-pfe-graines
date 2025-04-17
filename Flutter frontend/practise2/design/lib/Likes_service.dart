import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Likes.dart';
import 'package:logger/logger.dart';

class LikeService {
  static const String _baseUrl = "http://192.168.1.5:9090/likes";
  final http.Client _client;
  final Logger _logger = Logger();

  LikeService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> toggleLike(int userId, int publicationId) async {
    final url = '$_baseUrl/$userId/$publicationId';
    _logger.i("Envoi de la requête POST à $url");

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      _logger.i("Réponse reçue: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        return 'Action effectuée avec succès';
      }
      throw Exception('Échec du toggle like');
    } catch (e) {
      _logger.e("Erreur lors du toggle like: $e");
      rethrow;
    }
  }

  Future<bool> checkIfUserLiked(int userId, int publicationId) async {
    final url = '$_baseUrl/$userId/$publicationId';
    _logger.i("Envoi de la requête GET à $url");

    try {
      final response = await _client.get(Uri.parse(url));
      _logger.i("Réponse reçue: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Échec de la vérification du like');
    } catch (e) {
      _logger.e("Erreur lors de la vérification du like: $e");
      rethrow;
    }
  }

  Future<List<Like>> getLikesForPublication(int publicationId) async {
    final url = '$_baseUrl/publication/$publicationId';
    _logger.i("Envoi de la requête GET à $url");

    try {
      final response = await _client.get(Uri.parse(url));
      _logger.i("Réponse reçue: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Like.fromJson(json)).toList();
      }
      throw Exception('Échec de la récupération des likes');
    } catch (e) {
      _logger.e("Erreur lors de la récupération des likes: $e");
      rethrow;
    }
  }

  Future<int> getLikesCount(int publicationId) async {
    final url = '$_baseUrl/count/$publicationId';
    _logger.i("Envoi de la requête GET à $url");

    try {
      final response = await _client.get(Uri.parse(url));
      _logger.i("Réponse reçue: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Échec du comptage des likes');
    } catch (e) {
      _logger.e("Erreur lors du comptage des likes: $e");
      rethrow;
    }
  }

  void dispose() {
    _logger.i("Fermeture du client HTTP");
    _client.close();
  }
}

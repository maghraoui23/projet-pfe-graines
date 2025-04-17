import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Commentaire.dart';

class CommentService {
  static const String _baseUrl = 'http://192.168.1.5:9090/commentaires';

  final http.Client client;

  CommentService({required this.client});

  Future<Comment> addComment({
    required int userId,
    required int publicationId,
    required String contenu,
  }) async {
    // Log avant d'envoyer la requête
    print('Tentative d\'ajout d\'un commentaire');
    print('UserID: $userId, PublicationID: $publicationId, Contenu: $contenu');

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/user/$userId/publication/$publicationId'),
        headers: {'Content-Type': 'application/json'},
        body: contenu, // Envoyer le contenu brut (en String)
      );

      // Log de la réponse
      print('Réponse reçue avec le code de statut: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Log si le commentaire a été ajouté avec succès
        print('Commentaire ajouté avec succès');
        return Comment.fromJson(json.decode(response.body));
      } else {
        // Log si la requête échoue avec un autre code de statut
        print(
            'Échec de l\'ajout du commentaire. Code statut: ${response.statusCode}');
        throw Exception('Échec de l\'ajout du commentaire');
      }
    } catch (e) {
      // Log en cas d'exception
      print('Erreur lors de l\'ajout du commentaire: $e');
      rethrow; // Permet de relancer l'exception après l\'avoir loguée
    }
  }

  Future<void> deleteComment(int id) async {
    final response = await client.delete(
      Uri.parse('$_baseUrl/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Échec de la suppression du commentaire');
    }
  }

  Future<List<Comment>> getCommentsByPublication(int publicationId) async {
    // Log avant d'envoyer la requête
    print(
        'Tentative de récupération des commentaires pour la publication ID: $publicationId');

    final response = await client.get(
      Uri.parse('$_baseUrl/publication/$publicationId'),
    );

    // Log de la réponse
    print('Réponse reçue avec le code de statut: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Log du nombre de commentaires récupérés
      print('Nombre de commentaires récupérés: ${data.length}');

      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      print(
          'Échec du chargement des commentaires. Code statut: ${response.statusCode}');
      throw Exception('Échec du chargement des commentaires');
    }
  }
}

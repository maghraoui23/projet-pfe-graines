import 'package:http/http.dart' as http;
import 'dart:convert';
import 'publication.dart';

class PublicationService {
  static const String _baseUrl = 'http://192.168.1.5:9090/publications';

  final http.Client client;

  PublicationService({required this.client});

  // Créer une publication
  Future<Publication> createPublication(
      int userId, Publication publication) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/user/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(publication.toJson()),
    );

    if (response.statusCode == 201) {
      return Publication.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de la création: ${response.reasonPhrase}');
    }
  }

  // Récupérer toutes les publications
  Future<List<Publication>> getAllPublications() async {
    final response = await client.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Publication.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement: ${response.reasonPhrase}');
    }
  }

  Future<List<Publication>> getPublicationsByUserId(int userId) async {
    print(
        'Récupération des publications pour l\'utilisateur ID: $userId'); // Log de l'ID utilisateur

    final response = await client.get(Uri.parse('$_baseUrl/user/$userId'));

    print(
        'Statut de la réponse: ${response.statusCode}'); // Log du statut de la réponse

    if (response.statusCode == 200) {
      // Log des en-têtes de la réponse
      print('En-têtes de la réponse: ${response.headers}');

      // Log du corps de la réponse
      print('Corps de la réponse: ${response.body}');

      List<dynamic> data = json.decode(response.body);
      print('Données décodées: $data'); // Log des données décodées

      return data.map((json) => Publication.fromJson(json)).toList();
    } else {
      print(
          'Erreur lors du chargement des publications: ${response.reasonPhrase}'); // Log de l'erreur
      throw Exception('Échec du chargement: ${response.reasonPhrase}');
    }
  }

  // Ajouter un like
  Future<Publication> likePublication(int publicationId) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/$publicationId/like'),
    );

    if (response.statusCode == 200) {
      return Publication.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec du like: ${response.reasonPhrase}');
    }
  }

  // Retirer un like
  Future<Publication> unlikePublication(int publicationId) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/$publicationId/unlike'),
    );

    if (response.statusCode == 200) {
      return Publication.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec du unlike: ${response.reasonPhrase}');
    }
  }

  // Ajouter un commentaire
  Future<Publication> addComment(int publicationId, String comment) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/$publicationId/comment'),
      headers: {'Content-Type': 'text/plain'},
      body: comment,
    );

    if (response.statusCode == 200) {
      return Publication.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec du commentaire: ${response.reasonPhrase}');
    }
  }

  // Modifier une publication avec logs
  Future<Publication> updatePublication(
      int id, Publication updatedPublication) async {
    print(
        'Début de la mise à jour de la publication ID: $id'); // Log ID publication

    final url = Uri.parse('$_baseUrl/$id');
    print('URL de la requête: $url'); // Log de l'URL de la requête

    final body = json.encode(updatedPublication.toJson());
    print('Données envoyées: $body'); // Log du corps de la requête

    try {
      final response = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print(
          'Statut de la réponse: ${response.statusCode}'); // Log du statut de la réponse
      print(
          'Corps de la réponse: ${response.body}'); // Log du contenu de la réponse

      if (response.statusCode == 200) {
        print('Publication mise à jour avec succès');
        return Publication.fromJson(json.decode(response.body));
      } else {
        print('Erreur lors de la mise à jour: ${response.reasonPhrase}');
        throw Exception('Échec de la mise à jour: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception lors de la mise à jour: $e'); // Log de l'exception
      throw Exception(
          'Erreur inattendue lors de la mise à jour de la publication.');
    }
  }
}

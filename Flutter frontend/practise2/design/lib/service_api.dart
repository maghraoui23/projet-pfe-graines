import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Service.dart';

class ServiceApi {
  static const String _baseUrl = 'http://192.168.1.5:9090/services';

  static Future<List<Service>> fetchServices() async {
    try {
      print('🟢 Début de la requête GET à $_baseUrl');
      final response = await http.get(Uri.parse(_baseUrl));

      print('🔵 Code statut: ${response.statusCode}');
      print('🔵 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('🟢 Réponse réussie');
        final List<dynamic> data = jsonDecode(response.body);

        print('🔵 Nombre de services reçus: ${data.length}');
        if (data.isNotEmpty) print('🔵 Exemple de service: ${data[0]}');

        return data.map((json) {
          try {
            print('🔵 Parsing du JSON: $json');
            final service = Service.fromJson(json);
            print('🟢 Parsing réussi pour le service ${service.id}');
            return service;
          } catch (e) {
            print('🔴 Erreur lors du parsing: $e');
            print('🔴 Structure JSON problématique: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Échec du chargement (${response.statusCode})');
      }
    } catch (e) {
      print('🔴 Erreur réseau: $e');
      rethrow;
    }
  }

  // Récupérer un service par ID
  static Future<Service?> fetchServiceById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        return Service.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Échec du chargement (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Créer un service
  static Future<Service> createService(Service service) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(service.toJson()),
      );
      if (response.statusCode == 201) {
        return Service.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Échec de la création (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Mettre à jour un service
  static Future<Service?> updateService(int id, Service service) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(service.toJson()),
      );
      if (response.statusCode == 200) {
        return Service.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Échec de la mise à jour (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Supprimer un service
  static Future<void> deleteService(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode != 204) {
        throw Exception('Échec de la suppression (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}

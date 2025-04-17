import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Service.dart';

class ServiceService {
  final String baseUrl =
      'http://192.168.1.5:9090/services'; // Remplacez par l'URL de votre API

  // Get all services
  Future<List<Service>> getAllServices() async {
    print('[⚡] Appel API GET à: $baseUrl');
    final response = await http.get(Uri.parse(baseUrl));

    print('[🔧] Code statut: ${response.statusCode}');
    print('[📦] Taille réponse: ${response.bodyBytes.lengthInBytes} bytes');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print('[✅] Nombre de services reçus: ${jsonResponse.length}');

        // Log du premier élément pour vérification
        if (jsonResponse.isNotEmpty) {
          print('[🔍] Exemple de service reçu: ${jsonResponse.first}');
        }

        return jsonResponse.map((jsonItem) {
          try {
            return Service.fromJson(jsonItem);
          } catch (e, stack) {
            print('[❌] Erreur sur un service individuel:');
            print('JSON problématique: $jsonItem');
            print('Erreur: $e');
            print('Stack trace: $stack');
            rethrow;
          }
        }).toList();
      } catch (e, stack) {
        print('[❌] Erreur de décodage globale:');
        print('Erreur: $e');
        print('Stack trace: $stack');
        throw Exception('Échec du décodage JSON');
      }
    } else {
      print('[❌] Réponse serveur anormale:');
      print('Corps de la réponse: ${response.body}');
      throw Exception('Échec du chargement - Code ${response.statusCode}');
    }
  }

  // Get service by ID
  Future<Service?> getService(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Service.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Not found
    } else {
      throw Exception('Failed to load service');
    }
  }

  // Create a new service
  Future<Service> createService(Service service) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(service.toJson()),
    );

    if (response.statusCode == 201) {
      return Service.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create service');
    }
  }

  // Update an existing service
  Future<Service?> updateService(int id, Service updatedService) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(updatedService.toJson()),
    );

    if (response.statusCode == 200) {
      return Service.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Not found
    } else {
      throw Exception('Failed to update service');
    }
  }

  // Delete a service
  Future<void> deleteService(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete service');
    }
  }
}

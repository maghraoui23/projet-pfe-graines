import 'dart:convert';
import 'localUser.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String _baseUrl = 'http://192.168.1.5:9090/users';

  Future<List<LocaUser>> getUsers() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => LocaUser.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des utilisateurs');
    }
  }

  Future<LocaUser> createUser(LocaUser user) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return LocaUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<LocaUser?> updateUser(int id, LocaUser user) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'), // URL pour mettre à jour l'utilisateur
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return LocaUser.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      // L'utilisateur n'a pas été trouvé
      return null;
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<List<LocaUser>> searchUsers(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await http.get(
      Uri.parse('$_baseUrl/search?query=$encodedQuery'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => LocaUser.fromJson(json)).toList();
    } else {
      throw Exception('Échec de la recherche: ${response.statusCode}');
    }
  }

  Future<LocaUser?> getUserByUsername(String username) async {
    final response = await http.get(Uri.parse('$_baseUrl/username/$username'));

    if (response.statusCode == 200) {
      return LocaUser.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // L'utilisateur n'a pas été trouvé
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }
}

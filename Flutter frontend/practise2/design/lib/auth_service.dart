// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'localUser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.1.5:9090/auth";
  final StreamController<LocaUser?> _authController =
      StreamController<LocaUser?>.broadcast();
  // 1. Ajout du stream d'état d'authentification
  Stream<LocaUser?> get authStateChanges => _authController.stream;
  // 2. Méthode pour émettre les changements d'état
  void _emitAuthState(LocaUser? user) {
    if (!_authController.isClosed) {
      _authController.add(user);
    }
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/client'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; // Correction ici
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        // 3. Récupération et émission de l'utilisateur après login
        final user = await getCurrentUser();
        _emitAuthState(user);
        return token;
      }
    }
    return null;
  }

  Future<void> onUserLogin(LocaUser user) async {
    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 1545717237,
      appSign:
          '008a514d6a62631c0214184e31106553bc63f42fc76ce03a952d7c6e42a996a1',
      userID: user.id.toString(),
      userName: user.username,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  Future<bool> register(String username, String email, String password,
      String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/client'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getString('token') != null;
    print('Utilisateur connecté: $isLoggedIn'); // Ajoutez ceci
    return isLoggedIn;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // 4. Émission de l'état déconnecté
    _emitAuthState(null);
  }

  // 5. Vérification initiale au démarrage
  Future<void> checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        final user = await getCurrentUser();
        ZegoUIKitPrebuiltCallInvitationService().init(
          appID: 1545717237, // Conservez votre AppID
          appSign:
              '008a514d6a62631c0214184e31106553bc63f42fc76ce03a952d7c6e42a996a1', // Votre AppSign
          userID: user!.id.toString(),
          userName: user.username,
          plugins: [ZegoUIKitSignalingPlugin()],
        );
        _emitAuthState(user);
      } catch (e) {
        print('Erreur vérification auth state: $e');
        await logout();
      }
    } else {
      _emitAuthState(null);
    }
  }

  // 6. Nettoyage du controller
  void dispose() {
    _authController.close();
  }

  /// Récupérer le profil de l'utilisateur connecté
  Future<LocaUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Aucun token trouvé, utilisateur non connecté.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return LocaUser.fromJson(jsonData); // Correction ici
      } else {
        print('Erreur récupération utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception récupération utilisateur: $e');
    }
    return null;
  }

  //service pour uploader l image
  Future<bool> uploadUserPhoto(int userId, File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.5:9090/users/$userId/uploadPhoto'),
      );

      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final userData = jsonDecode(responseData);

        // Mettre à jour l'utilisateur localement
        final prefs = await SharedPreferences.getInstance();
        final currentUser = await getCurrentUser();
        if (currentUser != null) {
          prefs.setString('currentUser', jsonEncode(userData));
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur upload: $e');
      return false;
    }
  }

  Future<List<LocaUser>> getAllUsers() async {
    print("Début de la récupération des utilisateurs");

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.5:9090/users'),
        headers: {
          "Content-Type": "application/json",
          // Si vous avez besoin d'un token, décommentez la ligne suivante
          // "Authorization": "Bearer ${await _getToken()}", // Si vous avez une méthode pour obtenir le token
        },
      );

      print("Statut de la réponse: ${response.statusCode}");
      print(
          "Corps de la réponse: ${response.body}"); // Imprime le corps de la réponse

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        print("Nombre d'utilisateurs récupérés: ${jsonData.length}");

        List<LocaUser> users =
            jsonData.map((user) => LocaUser.fromJson(user)).toList();
        return users;
      } else {
        print(
            "Erreur lors de la récupération des utilisateurs: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la récupération des utilisateurs: $e");
      return [];
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}

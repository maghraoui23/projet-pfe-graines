import 'package:flutter/foundation.dart';

import 'localUser.dart';

class Professional {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String? phoneNummber; // Respecte la faute de frappe
  final String? photo;
  final Role? role;
  final Localisation? localisation;
  final DateTime dateCreation;
  final String? experience;
  final double? prixService;
  final List<String> diplomes;
  final double moyenneAvis;
  final int nombreEvaluations;
  final int highestRating;
  final String? highestComment;

  Professional({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    this.phoneNummber,
    this.photo,
    this.role,
    this.localisation,
    required this.dateCreation,
    this.experience,
    this.prixService,
    required this.diplomes,
    required this.moyenneAvis,
    required this.nombreEvaluations,
    required this.highestRating,
    this.highestComment,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    try {
      return Professional(
        id: (json['id'] as int?) ?? 0,
        firstName: (json['firstName'] as String?) ?? 'Inconnu',
        lastName: (json['lastName'] as String?) ?? 'Inconnu',
        username: (json['username'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        password: (json['password'] as String?) ??
            '', // Attention à ne pas exposer les mots de passe
        phoneNummber: json['phoneNummber'] as String?,
        photo: json['photo'] as String?,
        role: json['role'] != null
            ? Role.values.firstWhere(
                (e) => e.toString().split('.').last == json['role'],
                orElse: () => Role.PROFESSIONNEL) // Valeur par défaut
            : null,
        localisation: json['localisation'] != null
            ? Localisation.fromJson(json['localisation'])
            : null,
        dateCreation:
            DateTime.tryParse(json['dateCreation'] as String? ?? '') ??
                DateTime.now(),
        experience: json['experience'] as String?,
        prixService: (json['prix_service'] as num?)?.toDouble() ?? 0.0,
        diplomes: List<String>.from(json['diplomes'] ?? []),
        moyenneAvis: (json['moyenneAvis'] as num?)?.toDouble() ?? 0.0,
        nombreEvaluations: (json['nombreEvaluations'] as int?) ?? 0,
        highestRating: (json['highestRating'] as int?) ?? 0,
        highestComment: json['highestComment'] as String?,
      );
    } catch (e) {
      debugPrint('Erreur de parsing Professional: $e');
      throw FormatException('Professional JSON invalide: ${json.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNummber': phoneNummber,
      'photo': photo,
      'role': role?.toString().split('.').last,
      'localisation': localisation?.toJson(),
      'dateCreation': dateCreation.toIso8601String(),
      'experience': experience,
      'prix_service': prixService,
      'diplomes': diplomes,
      'moyenneAvis': moyenneAvis,
    };
  }

  @override
  String toString() {
    return 'Professional{id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, phoneNummber: $phoneNummber, photo: $photo, role: $role, localisation: $localisation, dateCreation: $dateCreation, experience: $experience, prixService: $prixService, diplomes: $diplomes, moyenneAvis: $moyenneAvis}';
  }
}

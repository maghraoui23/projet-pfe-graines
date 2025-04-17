enum Role {
  CLIENT,
  PROFESSIONNEL,
}

class LocaUser {
  final int id;
  final String FirstName;
  final String LastName;
  final String username;
  final String email;
  final String password;
  final String phoneNumber;
  final String Photo;
  final Role role;
  final Localisation? localisation;
  final DateTime dateCreation;

  LocaUser({
    required this.id,
    required this.FirstName,
    required this.LastName,
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.Photo = '',
    Role? role, // Changement ici
    this.localisation,
    required this.dateCreation,
  }) : role = role ?? Role.CLIENT; // Définit le rôle par défaut

  // méthode copyWith

  LocaUser copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? password,
    String? phoneNumber,
    String? photo,
    Role? role,
    Localisation? localisation,
    DateTime? dateCreation,
  }) {
    return LocaUser(
      id: id ?? this.id,
      FirstName: firstName ?? FirstName,
      LastName: lastName ?? LastName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      Photo: photo ?? Photo,
      role: role ?? this.role,
      localisation: localisation ?? this.localisation,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  // Conversion depuis JSON
  factory LocaUser.fromJson(Map<String, dynamic> json) {
    return LocaUser(
      id: json['id'] as int,
      FirstName: json['firstName'] as String,
      LastName: json['lastName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phoneNumber:
          json['phoneNumber'] as String? ?? '', // Gérer les valeurs nulles
      Photo: json['photo'] as String? ?? '', // Gérer les valeurs nulles
      role: (json['role'] as String?) == 'PROFESSIONNEL'
          ? Role.PROFESSIONNEL
          : Role.CLIENT, // Gérer les valeurs nulles
      localisation: json['localisation'] != null
          ? Localisation.fromJson(json['localisation'])
          : null,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': FirstName,
      'lastName': LastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNummber': phoneNumber, // Maintient la clé avec faute de frappe
      'photo': Photo,
      'role': role.toString().split('.').last,
      'localisation': localisation?.toJson(),
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}

class Localisation {
  final int? id;
  final double latitude;
  final double longitude;
  final String address;

  Localisation({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory Localisation.fromJson(Map<String, dynamic> json) {
    return Localisation(
      id: json['id'] as int?,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

// lib/models/user.dart
class User {
  final int id; // L'ID est généré par le backend
  final String username;
  final String firstName;
  final String lastName;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // L'ID est récupéré du backend
      username:
          json['user_name'], // Assurez-vous que cela correspond à votre backend
      firstName: json[
          'first_name'], // Assurez-vous que cela correspond à votre backend
      lastName:
          json['last_name'], // Assurez-vous que cela correspond à votre backend
      email: json['email'], // Assurez-vous que cela correspond à votre backend
    );
  }
}

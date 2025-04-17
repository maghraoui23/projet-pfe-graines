import 'localUser.dart';
import 'Professional.dart';

class Evaluation {
  final int? id;
  final LocaUser user;
  final Professional? professional;
  final int rating;
  final String? comment;
  final DateTime? dateEvaluation;

  Evaluation({
    this.id,
    required this.user,
    this.professional,
    required this.rating,
    this.comment,
    this.dateEvaluation,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      user: LocaUser.fromJson(json['user']),
      professional: json['professional'] != null
          ? Professional.fromJson(json['professional'])
          : null, // Gère le cas où professional est null
      rating: json['rating'],
      comment: json['comment'] as String?, // Accepte null
      dateEvaluation: json['dateEvaluation'] != null
          ? DateTime.tryParse(json['dateEvaluation']) ?? DateTime.now()
          : DateTime.now(), // Gestion du null et des erreurs de parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'professional': professional?.toJson(), // Null safety
      'rating': rating,
      'comment': comment,
      'dateEvaluation': dateEvaluation?.toIso8601String(),
    };
  }
}

import 'localUser.dart';
import 'publication.dart';

class Comment {
  final int id;
  final String contenu;
  final Publication publication;
  final LocaUser auteur;
  final DateTime dateCommentaire;

  Comment({
    required this.id,
    required this.contenu,
    required this.publication,
    required this.auteur,
    required this.dateCommentaire,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      contenu: json['contenu'],
      publication: Publication.fromJson(json['publication']),
      auteur: LocaUser.fromJson(json['auteur']),
      dateCommentaire: _parseDate(json['dateCommentaire']),
    );
  }
  static DateTime _parseDate(dynamic dateValue) {
    try {
      // Gestion des timestamps
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue).toLocal();
      }

      final dateString = dateValue.toString().trim();

      // Gestion des valeurs nulles
      if (dateString.isEmpty || dateString == 'null') {
        return DateTime.now();
      }

      // Parse direct pour le format ISO 8601
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      print('Erreur de parsing: $dateValue → $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contenu': contenu,
        'publication': publication.toJson(),
        'auteur': auteur.toJson(),
        'dateCommentaire': dateCommentaire.toIso8601String(),
      };
}

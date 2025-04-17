import 'Commentaire.dart';
import 'professional.dart';

class Publication {
  final int id;
  final String contenu;
  final String? image;
  final Professional auteur;
  final DateTime datePublication;
  int likes;
  final List<Comment> commentaires;

  Publication({
    required this.id,
    required this.contenu,
    this.image,
    required this.auteur,
    required this.datePublication,
    this.likes = 0,
    this.commentaires = const [],
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] as int,
      contenu: json['contenu'] as String,
      image: json['image'] as String?,
      auteur: Professional.fromJson(json['auteur']),
      datePublication: DateTime.parse(json['datePublication'] as String),
      likes: json['likes'] != null ? json['likes'] as int : 0,
      // Gestion de la nullité uniquement pour 'commentaires'
      // Si 'commentaires' est null, on retourne une liste vide
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenu': contenu,
      'image': image,
      'auteur': auteur.toJson(),
      'datePublication': datePublication.toIso8601String(),
      'likes': likes,
    };
  }

  // Ajoutez cette méthode pour créer une copie modifiée
  Publication copyWith({
    int? id,
    String? contenu,
    String? image,
    Professional? auteur,
    DateTime? datePublication,
    int? likes,
    List<Comment>? commentaires,
  }) {
    return Publication(
      id: id ?? this.id,
      contenu: contenu ?? this.contenu,
      image: image ?? this.image,
      auteur: auteur ?? this.auteur,
      datePublication: datePublication ?? this.datePublication,
      likes: likes ?? this.likes,
      commentaires: commentaires ?? this.commentaires,
    );
  }

  void addLike() {
    likes++;
  }

  void removeLike() {
    if (likes > 0) likes--;
  }
}

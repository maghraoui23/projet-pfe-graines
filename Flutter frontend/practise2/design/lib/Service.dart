import 'Professional.dart';

class Service {
  final int id;
  final String nom;
  final String? description;
  final String? categorie;
  final List<Professional> professionnels;
  final String service_photo;

  Service({
    required this.id,
    required this.nom,
    this.description,
    this.categorie,
    required this.professionnels,
    required this.service_photo,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      nom: json['nom'] as String,
      description:
          json['description'] != null ? json['description'] as String : '',
      categorie: json['categorie'] != null ? json['categorie'] as String : '',
      professionnels: (json['professionnels'] as List?)
              ?.map((proJson) => Professional.fromJson(proJson))
              .toList() ??
          [],
      service_photo: json['service_photo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'categorie': categorie,
      'professionnels': professionnels.map((pro) => pro.toJson()).toList(),
      'service_photo': service_photo,
    };
  }
}

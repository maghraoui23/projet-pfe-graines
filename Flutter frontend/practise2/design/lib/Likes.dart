import 'localUser.dart';
import 'publication.dart';

class Like {
  final String id;
  final LocaUser? user;
  final Publication? publication;

  Like({
    required this.id,
    this.user,
    this.publication,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'].toString(),
      user: json['user'] != null ? LocaUser.fromJson(json['user']) : null,
      publication: json['publication'] != null
          ? Publication.fromJson(json['publication'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(), // Null-aware operator
      'publication': publication?.toJson(),
    };
  }
}

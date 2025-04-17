class CommentsDto {
  final int id;
  final int postId;
  final String text;
  final String userName;
  final DateTime createdDate; // Ajout de l'attribut manquant
  final int? parentId; // Nouveau champ
  final List<CommentsDto> replies; // Nouveau champ

  CommentsDto({
    required this.id,
    required this.postId,
    required this.text,
    required this.userName,
    required this.createdDate, // Ajout du champ manquant
    this.parentId,
    this.replies = const [], // Initialisation par défaut
  });

  factory CommentsDto.fromJson(Map<String, dynamic> json) {
    return CommentsDto(
      id: json['id'],
      postId: json['postId'],
      text: json['text'],
      userName: json['userName'],
      createdDate:
          DateTime.parse(json['createdDate']), // Conversion String -> DateTime
      parentId: json['parentId'],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((reply) => CommentsDto.fromJson(reply))
              .toList() ??
          [],
    );
  }
}

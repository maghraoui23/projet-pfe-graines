class PostResponse {
  final int id;
  final String postName;
  final String url;
  final String description;
  int? voteCount;
  final String userName;
  final String subredditName;
  final String duration;
  final int? commentCount;
  bool upVote; // Ajouté
  bool downVote;

  PostResponse({
    required this.id,
    required this.postName,
    required this.url,
    required this.description,
    this.voteCount,
    required this.userName,
    required this.subredditName, // Toujours une valeur
    required this.duration,
    this.commentCount,
    this.upVote = false, // Ajouté
    this.downVote = false, // Ajouté
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: json['id'],
      postName: json['postName'],
      url: json['url'],
      description: json['description'],
      voteCount: json['voteCount'] != null ? json['voteCount'] as int : null,
      userName: json['userName'],
      subredditName: json['subredditName'] ?? "", // Remplace null
      duration: json['duration'],
      commentCount:
          json['commentCount'] != null ? json['commentCount'] as int : null,
      upVote: json['upVote'] ?? false, // Ajouté
      downVote: json['downVote'] ?? false, // Ajouté
    );
  }
}

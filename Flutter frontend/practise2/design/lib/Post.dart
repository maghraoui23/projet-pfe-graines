class Post {
  final int postId;
  final String postName;
  final String? url;
  final String description;
  final int? voteCount; // Garde la possibilité d'être null
  final String userName;
  final String subredditName;

  Post({
    required this.postId,
    required this.postName,
    this.url,
    required this.description,
    this.voteCount,
    required this.userName,
    required this.subredditName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      postName: json['postName'],
      url: json['url'] as String?, // Garde null si c'est null
      description: json['description'],
      voteCount: json['voteCount'] != null
          ? json['voteCount'] as int
          : null, // Vérifie null avant le cast
      userName: json['userName'],
      subredditName: json['subredditName'],
    );
  }
}

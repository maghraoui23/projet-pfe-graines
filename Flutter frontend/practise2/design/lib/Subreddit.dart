class Subreddit {
  final int id;
  final String name;
  final String description;
  final int? numberOfPosts;

  Subreddit({
    required this.id,
    required this.name,
    required this.description,
    this.numberOfPosts,
  });

  factory Subreddit.fromJson(Map<String, dynamic> json) {
    return Subreddit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      numberOfPosts:
          json['numberOfPosts'] != null ? json['numberOfPosts'] as int : null,
    );
  }
}

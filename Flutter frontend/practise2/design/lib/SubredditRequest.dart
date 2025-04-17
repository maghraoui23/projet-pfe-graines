class SubredditRequest {
  final String name;
  final String description;

  SubredditRequest({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

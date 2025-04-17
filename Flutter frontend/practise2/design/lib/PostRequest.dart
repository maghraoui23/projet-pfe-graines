class PostRequest {
  final String subredditName;
  final String postName;
  final String url;
  final String description;

  PostRequest({
    required this.subredditName,
    required this.postName,
    required this.url,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'subredditName': subredditName,
      'postName': postName,
      'url': url,
      'description': description,
    };
  }
}

class Comment {
  final int id;
  final String text;
  final String userName;

  Comment({
    required this.id,
    required this.text,
    required this.userName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['text'],
      userName: json['userName'],
    );
  }
}

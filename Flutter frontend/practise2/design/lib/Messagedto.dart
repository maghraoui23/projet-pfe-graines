class MessageDto {
  final int receiverId;
  final String content;

  MessageDto({required this.receiverId, required this.content});

  Map<String, dynamic> toJson() => {
        'receiverId': receiverId,
        'content': content,
      };
}

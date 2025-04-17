import 'localUser.dart';

// message.dart
class Message {
  final int id;
  final LocaUser sender;
  final LocaUser receiver;
  final String content;
  bool isRead;
  final DateTime messageTime;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.isRead,
    required this.messageTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        sender: LocaUser.fromJson(json['sender']),
        receiver: LocaUser.fromJson(json['receiver']),
        content: json['message'] ?? '', // Gestion du null ici
        isRead:
            json['vu'] ?? false, // Optionnel : Assurer que 'vu' n'est pas null
        messageTime: json['message_time'] != null
            ? DateTime.parse(json['message_time'])
            : DateTime.now(), // Gestion du null pour la date
      );
}

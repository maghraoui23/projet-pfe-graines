import 'Message.dart';
import 'localUser.dart';

// conversation.dart
class Conversation {
  final int id;
  final LocaUser author;
  final LocaUser recipient;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.author,
    required this.recipient,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'],
        author: LocaUser.fromJson(json['auteur']),
        recipient: LocaUser.fromJson(json['recepteur']),
        messages: (json['messages'] as List)
            .map((msg) => Message.fromJson(msg))
            .toList(),
      );
}

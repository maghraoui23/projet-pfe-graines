import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Conversation.dart';
import 'Message.dart';
import 'Messagedto.dart';
import 'auth_service.dart';

class ChatService {
  final String baseUrl =
      "http://192.168.1.5:9090/chat_messages"; // Remplace par ton URL d'API

  Future<List<Conversation>> getConversations(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/conversations"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des conversations");
    }
  }

  // Nouvelle méthode pour trouver les conversations par utilisateur
  Future<List<Conversation>> getConversationsWithUser(
      int userId, String token) async {
    final allConversations = await getConversations(token);
    return allConversations
        .where(
            (conv) => conv.author.id == userId || conv.recipient.id == userId)
        .toList();
  }

  // Correction de la récupération des messages
  Future<Conversation> getConversationById(
      int conversationId, String token) async {
    final response = await http.get(
        Uri.parse("$baseUrl/conversations/$conversationId"),
        headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      return Conversation.fromJson(json.decode(response.body));
    } else {
      throw Exception("Conversation non trouvée: ${response.body}");
    }
  }

  Future<Conversation> createConversation(
      int receiverId, String content, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations"),
      body: json.encode(
          MessageDto(receiverId: receiverId, content: content).toJson()),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Conversation.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur création conversation: ${response.body}");
    }
  }

  Future<Message> addMessageToConversation(
    int conversationId,
    int receiverId, // Ajout du paramètre manquant
    String content,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations/$conversationId/messages"),
      body: json.encode(
        MessageDto(receiverId: receiverId, content: content).toJson(),
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return Message.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur envoi message: ${response.body}");
    }
  }

  Future<int> _getOtherParticipantId(int conversationId, String token) async {
    final conv = await getConversationById(conversationId, token);
    final currentUser = await AuthService().getCurrentUser();
    return conv.author.id == currentUser?.id
        ? conv.recipient.id
        : conv.author.id;
  }

  Future<void> markMessageAsRead(int messageId, String token) async {
    final response = await http.put(
      Uri.parse("$baseUrl/conversations/messages/$messageId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors du marquage du message comme lu");
    }
  }
}

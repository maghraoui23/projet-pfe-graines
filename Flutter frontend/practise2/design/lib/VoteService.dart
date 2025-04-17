import 'VoteDto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoteService {
  final String baseUrl = "http://192.168.1.5:9090/api/votes";

  Future<void> vote(VoteDto voteDto, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(voteDto.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to cast vote");
    }
  }
}

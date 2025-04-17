import 'package:flutter/material.dart';
import 'comment.dart';
import 'commentService.dart';
import 'auth_service.dart'; // Importez le AuthService

class CommentPage extends StatefulWidget {
  final int postId;

  const CommentPage({super.key, required this.postId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final CommentService commentService = CommentService();
  List<Comment> comments = [];
  String? token; // Assurez-vous d'obtenir le token de l'utilisateur connecté

  @override
  void initState() {
    super.initState();
    _getTokenAndFetchComments();
  }

  Future<void> _getTokenAndFetchComments() async {
    AuthService authService = AuthService();
    token = await authService.getToken(); // Récupérer le token

    if (token != null) {
      _fetchComments();
    } else {
      print("Token is null. User might not be logged in.");
      // Vous pouvez rediriger l'utilisateur vers la page de connexion ici
    }
  }

  void _fetchComments() async {
    try {
      comments =
          (await commentService.getAllCommentsForPost(widget.postId, token!))
              .cast<Comment>();
      setState(() {});
    } catch (e) {
      print("Failed to fetch comments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: comments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(comment.text),
                    subtitle: Text("by ${comment.userName}"),
                  ),
                );
              },
            ),
    );
  }
}

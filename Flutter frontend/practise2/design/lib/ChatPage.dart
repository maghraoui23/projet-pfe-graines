import 'dart:async';

import 'package:flutter/material.dart';
import 'UserService.dart';
import 'auth_service.dart';
import 'localUser.dart';
import 'ChatService.dart';
import 'DisussionPage.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<LocaUser> _chatPartners = [];
  bool _isLoading = true;
  String? _errorMessage;
  List<LocaUser> _searchResults = [];
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception("Non authentifié");

      final conversations = await ChatService().getConversations(token);
      final currentUser = await AuthService().getCurrentUser();
      if (currentUser == null) throw Exception("Utilisateur introuvable");

      // Extraire les interlocuteurs
      final partners = conversations
          .map((conv) {
            return conv.author.id == currentUser.id
                ? conv.recipient
                : conv.author;
          })
          .toSet()
          .toList(); // Éviter les doublons

      setState(() {
        _chatPartners = partners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de chargement: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() => _isSearching = false);
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await _userService.searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de recherche: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    final displayList = _isSearching ? _searchResults : _chatPartners;

    if (displayList.isEmpty) {
      return Center(
        child: Text(
          _isSearching ? "Aucun résultat trouvé" : "Aucune conversation",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final user = displayList[index];
        return _UserListItem(
          user: user,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDiscussionPage(receiver: user),
            ),
          ),
        );
      },
    );
  }
}

class _UserListItem extends StatelessWidget {
  final LocaUser user;
  final VoidCallback onTap;

  const _UserListItem({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: user.Photo.isNotEmpty
                        ? (user.role == Role.PROFESSIONNEL
                            ? NetworkImage(
                                user.Photo) // Si PRO, utilise l'URL complète
                            : NetworkImage(
                                'http://192.168.1.5:9090${user.Photo}')) // Sinon, ajoute le domaine local
                        : null,
                    child: user.Photo.isEmpty
                        ? const Icon(Icons.person,
                            size: 30,
                            color: Colors
                                .grey) // Affiche l'icône si aucune image n'est disponible
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email, // Conserve l'email comme sous-titre
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  '15:30', // Exemple d'horodatage statique
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2', // Exemple de compteur de messages
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

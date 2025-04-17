import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'auth_service.dart';
import 'ChatService.dart';
import 'Conversation.dart';
import 'Message.dart';
import 'localUser.dart';

class ChatDiscussionPage extends StatefulWidget {
  final LocaUser receiver;
  const ChatDiscussionPage({super.key, required this.receiver});

  @override
  _ChatDiscussionPageState createState() => _ChatDiscussionPageState();
}

class _ChatDiscussionPageState extends State<ChatDiscussionPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  final int _appID = 1545717237; // Remplacez par votre AppID ZEGOCLOUD
  final String _appSign =
      '008a514d6a62631c0214184e31106553bc63f42fc76ce03a952d7c6e42a996a1'; // Remplacez par votre AppSign

  List<Message> _messages = [];
  Conversation? _conversation;
  LocaUser? _currentUser;
  String? _token;
  Timer? _refreshTimer;
  bool _shouldScrollToBottom = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _startAutoRefresh();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      // Vérifier l'authentification
      if (!await _authService.isLoggedIn()) {
        await _authService.logout();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Récupérer l'utilisateur actuel
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception("Utilisateur invalide");
      }

      // Récupérer le token
      final token = await _authService.getToken();
      if (token == null) throw Exception("Token manquant");

      setState(() {
        _currentUser = user;
        _token = token;
      });

      // Charger les conversations existantes
      final conversations = await _chatService.getConversations(token);
      _findExistingConversation(conversations);

      // Charger les messages si conversation existe
      if (_conversation != null) await _refreshMessages();
    } catch (e) {
      _handleError("Erreur d'initialisation", e);
    }
  }

  // Ajoutez cette méthode pour démarrer l'appel
  void _startCall(bool isVideoCall) {
    final invitees = [
      ZegoUIKitUser(
        id: widget.receiver.id.toString(),
        name: widget.receiver.username,
      )
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => ZegoSendCallInvitationButton(
        isVideoCall: isVideoCall,
        resourceID: "MaghraouiZego", // À configurer dans la console ZEGO
        invitees: invitees,
        onPressed: (code, message, invitees) {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _findExistingConversation(List<Conversation> conversations) {
    final currentUserId = _currentUser?.id;
    final receiverId = widget.receiver.id;

    if (currentUserId == null) return;

    for (final conv in conversations) {
      final isPair = (conv.author.id == currentUserId &&
              conv.recipient.id == receiverId) ||
          (conv.author.id == receiverId && conv.recipient.id == currentUserId);

      if (isPair) {
        setState(() => _conversation = conv);
        break;
      }
    }
  }

  Future<void> _refreshMessages() async {
    if (_conversation == null || _token == null) return;

    try {
      final updatedConv = await _chatService.getConversationById(
        _conversation!.id,
        _token!,
      );

      if (mounted) {
        setState(() {
          _messages = updatedConv.messages;
          _messages.sort((a, b) => a.messageTime
              .compareTo(b.messageTime)); // ✅ Tri des messages par date
          _markMessagesAsRead();
        });
        _scrollToBottom();
      }
    } catch (e) {
      _handleError("Rafraîchissement échoué", e);
    }
  }

  void _markMessagesAsRead() {
    final unreadMessages = _messages
        .where((msg) => !msg.isRead && msg.receiver.id == _currentUser?.id);

    for (var msg in unreadMessages) {
      _chatService.markMessageAsRead(msg.id, _token!);
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      if (_conversation == null) {
        await _createNewConversation(message);
      } else {
        await _addMessageToConversation(message);
      }
      _messageController.clear();
    } catch (e) {
      _handleError("Envoi échoué", e);
    }
  }

  Future<void> _createNewConversation(String message) async {
    final newConv = await _chatService.createConversation(
      widget.receiver.id,
      message,
      _token!,
    );

    setState(() {
      _conversation = newConv;
      _messages = newConv.messages;
    });
  }

  void _handleScroll() {
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 100) {
      _shouldScrollToBottom = false;
    } else {
      _shouldScrollToBottom = true;
    }
  }

// Modifiez la méthode _addMessageToConversation
  Future<void> _addMessageToConversation(String message) async {
    final newMessage = await _chatService.addMessageToConversation(
      _conversation!.id,
      widget.receiver.id,
      message,
      _token!,
    );

    setState(() => _messages.add(newMessage));
    _scrollToBottom();
  }

  void _startAutoRefresh() {
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _refreshMessages());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    const double scrollThreshold = 100;

    bool isNearBottom =
        position.pixels >= position.maxScrollExtent - scrollThreshold;

    if (isNearBottom || _shouldScrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _handleError(String errorMessage, dynamic error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        // ✅ Utilise le BuildContext du widget
        SnackBar(
          content: Text("$errorMessage: ${error.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiver.Photo.isNotEmpty
                  ? (widget.receiver.role == Role.PROFESSIONNEL
                      ? NetworkImage(widget.receiver.Photo)
                      : NetworkImage(
                          'http://192.168.1.5:9090${widget.receiver.Photo}'))
                  : null,
              child: widget.receiver.Photo.isEmpty
                  ? const Icon(Icons.person, size: 30, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(widget.receiver.username),
          ],
        ),
        actions: [
          // Bouton d'appel vocal
          ZegoSendCallInvitationButton(
            isVideoCall: false,
            resourceID: "MaghraouiZego",
            invitees: [
              ZegoUIKitUser(
                id: widget.receiver.id.toString(),
                name: widget.receiver.username,
              )
            ],
            icon: ButtonIcon(
              icon: const Icon(Icons.call, color: Colors.green, size: 24),
            ),
            iconSize: const Size(40, 40),
            buttonSize: const Size(50, 50),
            timeoutSeconds: 30,
            onPressed: (code, message, invitees) {
              if (code.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $code - $message')),
                );
              }
            },
          ),

          const SizedBox(width: 2),

          // Bouton d'appel vidéo
          ZegoSendCallInvitationButton(
            isVideoCall: true,
            resourceID: "MaghraouiZego",
            invitees: [
              ZegoUIKitUser(
                id: widget.receiver.id.toString(),
                name: widget.receiver.username,
              )
            ],
            icon: ButtonIcon(
              icon: const Icon(Icons.videocam, color: Colors.blue, size: 24),
            ),
            iconSize: const Size(40, 40),
            buttonSize: const Size(50, 50),
            timeoutSeconds: 30,
            onPressed: (code, message, invitees) {
              if (code.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $code - $message')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.sender.id == _currentUser?.id;

                bool showPhoto = false;
                if (!isMe &&
                    (index == _messages.length - 1 ||
                        _messages[index + 1].sender.id != message.sender.id)) {
                  showPhoto = true;
                }

                return MessageBubble(
                  message: message,
                  isMe: isMe,
                  showPhoto: showPhoto,
                  receiverPhoto: widget.receiver.Photo,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Écrire un message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showPhoto;
  final String receiverPhoto;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showPhoto,
    required this.receiverPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            SizedBox(
              width: 40,
              child: Align(
                alignment: Alignment.topCenter,
                child: showPhoto
                    ? CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: receiverPhoto.isNotEmpty
                            ? (Uri.tryParse('http://192.168.1.5:9090$receiverPhoto')
                                        ?.isAbsolute ==
                                    true
                                ? NetworkImage(
                                    'http://192.168.1.5:9090$receiverPhoto') // Essaye avec le serveur local
                                : (Uri.tryParse(receiverPhoto)?.isAbsolute ==
                                        true
                                    ? NetworkImage(
                                        receiverPhoto) // Essaye avec l'URL directe
                                    : null)) // Sinon, passe à l'icône
                            : null,
                        child: receiverPhoto.isEmpty ||
                                (Uri.tryParse('http://192.168.1.5:9090$receiverPhoto')
                                            ?.isAbsolute ==
                                        false &&
                                    Uri.tryParse(receiverPhoto)?.isAbsolute ==
                                        false)
                            ? Icon(Icons.person,
                                size: 20,
                                color: Colors.grey[
                                    600]) // Affiche l'icône si tout échoue
                            : null,
                      )
                    : null,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              margin: EdgeInsets.only(
                left: isMe ? 8.0 : 4.0,
                right: isMe ? 4.0 : 8.0,
                bottom: 4.0,
                top: 2,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMe
                      ? [Colors.blueAccent.shade400, Colors.blueAccent.shade200]
                      : [Colors.grey.shade100, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(6),
                  bottomRight: isMe
                      ? const Radius.circular(6)
                      : const Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(message.messageTime),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (isMe) const SizedBox(width: 6),
                        if (isMe)
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead
                                ? Colors.lightBlueAccent.shade100
                                : Colors.white70,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

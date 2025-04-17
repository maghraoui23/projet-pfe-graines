import 'package:flutter/material.dart';
import 'package:sos_maison/commentService.dart';
import 'Commentdto.dart';
import 'PostResponse.dart';
import 'package:intl/intl.dart';
import 'PostService.dart';
import 'UserService.dart';
import 'auth_service.dart';
import 'VoteDto.dart';
import 'VoteService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'localUser.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final PostService postService = PostService();
  final CommentService commentService = CommentService();
  final VoteService voteService = VoteService();
  PostResponse? post;
  List<CommentsDto> comments = [];
  String? token;
  final UserService userService = UserService();
  LocaUser? user;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getTokenAndFetchPostDetails();
  }

  Future<void> _getTokenAndFetchPostDetails() async {
    AuthService authService = AuthService();
    token = await authService.getToken();

    if (token != null) {
      _fetchPostDetails();
      _fetchComments();
    } else {
      print("Token is null. User might not be logged in.");
    }
  }

  void _fetchPostDetails() async {
    try {
      post = await postService.getPost(widget.postId, token!);
      user = await userService.getUserByUsername(post!.userName);
      setState(() {});
    } catch (e) {
      print("Failed to fetch post details: $e");
    }
  }

  void _fetchComments() async {
    try {
      comments =
          await commentService.getAllCommentsForPost(widget.postId, token!);
      setState(() {});
    } catch (e) {
      print("Failed to fetch comments: $e");
    }
  }

  void _vote(String voteType) async {
    if (token == null || post == null) return;

    setState(() {
      if (voteType == "UPVOTE") {
        if (!post!.upVote) {
          post!.voteCount = (post!.voteCount ?? 0) + 1;
          post!.upVote = true;
          post!.downVote = false;
        }
      } else if (voteType == "DOWNVOTE") {
        if (!post!.downVote) {
          post!.voteCount = (post!.voteCount ?? 0) - 1;
          post!.downVote = true;
          post!.upVote = false;
        }
      }
    });

    VoteDto voteDto = VoteDto(voteType: voteType, postId: widget.postId);
    try {
      await voteService.vote(voteDto, token!);
    } catch (e) {
      print("Failed to cast vote: $e");
      setState(() {
        if (voteType == "UPVOTE") {
          post!.voteCount = (post!.voteCount ?? 0) - 1;
          post!.upVote = false;
        } else if (voteType == "DOWNVOTE") {
          post!.voteCount = (post!.voteCount ?? 0) + 1;
          post!.downVote = false;
        }
      });
    }
  }

  void _addComment() async {
    if (token == null || _commentController.text.isEmpty) return;

    CommentsDto commentDto = CommentsDto(
      id: 0,
      postId: widget.postId,
      text: _commentController.text,
      userName: user?.username ?? 'Unknown',
      createdDate: DateTime.now(),
    );

    try {
      await commentService.createComment(commentDto, token!);
      _commentController.clear();
      _fetchComments();
    } catch (e) {
      print("Failed to add comment: $e");
    }
  }

  // Modifiez la méthode _addReply
  void _addReply(int parentId, String text) async {
    if (token == null || text.isEmpty) return;

    CommentsDto commentDto = CommentsDto(
      id: 0,
      postId: widget.postId,
      text: text, // Utilisez le paramètre text directement
      userName: user?.username ?? 'Unknown',
      createdDate: DateTime.now(),
      parentId: parentId,
    );

    try {
      await commentService.createComment(commentDto, token!);
      _fetchComments(); // Actualisez les commentaires
    } catch (e) {
      print("Failed to add reply: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      body: post == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _PostHeader(user: user, post: post!),
                      const SizedBox(height: 24),
                      Text(
                        post!.postName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post!.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      if (post!.url.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _UrlPreview(post!.url),
                        ),
                      const SizedBox(height: 24),
                      _VotingSection(
                        post: post!,
                        onVote: _vote,
                      ),
                      const Divider(height: 40),
                      _CommentInputSection(
                        controller: _commentController,
                        onPressed: _addComment,
                      ),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _CommentTile(
                        comment: comments[index],
                        depth: 0,
                        onReply: (parentId, text) => _addReply(
                            parentId, text), // Ajoutez le paramètre text
                      ),
                      childCount: comments.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final LocaUser? user;
  final PostResponse post;

  const _PostHeader({required this.user, required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: user?.Photo.isNotEmpty ?? false
              ? NetworkImage("http://192.168.1.5:9090${user!.Photo}")
              : null,
          child:
              (user?.Photo.isEmpty ?? true) ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.username ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'r/${post.subredditName} • ${post.duration} ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UrlPreview extends StatelessWidget {
  final String url;

  const _UrlPreview(this.url);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => launch(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A4B7C).withOpacity(0.1), // Modifié ici
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A4B7C).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_rounded, size: 18, color: Color(0xFF2A4B7C)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                url,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2A4B7C),
                      decoration: TextDecoration.underline,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VotingSection extends StatelessWidget {
  final PostResponse post;
  final Function(String) onVote;

  const _VotingSection({required this.post, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUpvoted = post.upVote;
    final isDownvoted = post.downVote;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A4B7C).withOpacity(0.1), // Modifié ici
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VoteButton(
            icon: Icons.arrow_upward_rounded,
            isActive: isUpvoted,
            activeColor: const Color(0xFF2A4B7C),
            onTap: () => onVote("UPVOTE"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${post.voteCount ?? 0}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _VoteButton(
            icon: Icons.arrow_downward_rounded,
            isActive: isDownvoted,
            activeColor: theme.colorScheme.error,
            onTap: () => onVote("DOWNVOTE"),
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      iconSize: 28,
      style: IconButton.styleFrom(
        backgroundColor:
            isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(
        icon,
        color: isActive ? activeColor : theme.colorScheme.onSurfaceVariant,
      ),
      onPressed: onTap,
    );
  }
}

class _CommentInputSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;

  const _CommentInputSection({
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: 4,
          minLines: 1,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Share your thoughts...',
            filled: true,
            fillColor: const Color(0xFF2A4B7C).withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon:
                const Icon(Icons.edit_rounded, color: Color(0xFF2A4B7C)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2A4B7C),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              Icons.send_rounded,
              color: theme.colorScheme.onPrimary,
            ),
            label: Text(
              'Post Comment',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatefulWidget {
  final CommentsDto comment;
  final int depth;
  final Function(int, String)? onReply;

  const _CommentTile({
    required this.comment,
    this.depth = 0,
    this.onReply,
  });

  @override
  __CommentTileState createState() => __CommentTileState();
}

class __CommentTileState extends State<_CommentTile> {
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();
  bool _isLiked = false;
  int _likeCount = 0;
  bool _showReplies = false;

  @override
  void initState() {
    super.initState();
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} j';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _toggleReply() {
    setState(() {
      _isReplying = !_isReplying;
      if (!_isReplying) {
        _replyController.clear();
      }
    });
  }

  void _submitReply() {
    if (_replyController.text.isNotEmpty) {
      widget.onReply?.call(widget.comment.id, _replyController.text);
      setState(() {
        _isReplying = false;
        _replyController.clear();
      });
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
      // Ici vous devriez aussi appeler une API pour mettre à jour le like en backend
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return FutureBuilder<LocaUser?>(
      future: UserService().getUserByUsername(widget.comment.userName),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  bottom: 12, left: widget.depth * 16.0), // Indentation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            (user?.Photo != null && user!.Photo.isNotEmpty)
                                ? NetworkImage(
                                    "http://192.168.1.5:9090${user.Photo}")
                                : null,
                        child: (user?.Photo == null || user!.Photo.isEmpty)
                            ? Icon(Icons.person,
                                size: 18, color: colors.onPrimaryContainer)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.comment.userName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.comment.text,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                children: [
                                  Text(
                                    _formatDateTime(widget.comment.createdDate),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: _toggleLike,
                                    child: Text(
                                      'J\'aime',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: _isLiked
                                            ? colors.primary
                                            : colors.outline,
                                        fontWeight: _isLiked
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: _toggleReply,
                                    child: Text(
                                      'Répondre',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colors.outline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_likeCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 2),
                                child: Row(
                                  children: [
                                    Icon(Icons.thumb_up_alt_outlined,
                                        size: 14, color: colors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_likeCount',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Reply Input (appears when replying)
                  if (_isReplying)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 32.0, top: 8, bottom: 8, right: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              autofocus: true,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: 'Écrivez votre réponse...',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: colors.outlineVariant, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: colors.outlineVariant, width: 1),
                                ),
                                filled: true,
                                fillColor: colors.surfaceContainerHighest
                                    .withOpacity(0.3),
                              ),
                            ),
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.send_rounded, color: colors.primary),
                            onPressed: _submitReply,
                          ),
                        ],
                      ),
                    ),

                  // Replies list
                  if (widget.comment.replies.isNotEmpty)
                    Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _showReplies = !_showReplies),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32.0, top: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 1,
                                  width: 24,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _showReplies
                                      ? 'Masquer les réponses'
                                      : 'Voir ${widget.comment.replies.length} réponse${widget.comment.replies.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  _showReplies
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 18,
                                  color: Colors.blue.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showReplies)
                          ...widget.comment.replies.map((reply) => _CommentTile(
                                comment: reply,
                                depth: widget.depth + 1,
                                onReply: widget.onReply,
                              )),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

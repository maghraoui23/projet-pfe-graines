import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'PostDetailPage.dart';
import 'PostResponse.dart';
import 'localUser.dart';

class PostWidget extends StatefulWidget {
  final PostResponse post;
  final Function(int, String) onVote;
  final Future<LocaUser?> Function(String) getUserInfo;

  const PostWidget({
    super.key,
    required this.post,
    required this.onVote,
    required this.getUserInfo,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return FutureBuilder<LocaUser?>(
      future: widget.getUserInfo(widget.post.userName),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            setState(() => _isPressed = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(postId: widget.post.id),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2A4B7C)
                    .withOpacity(0.1), // Bordure assombrie
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A4B7C)
                      .withOpacity(_isPressed ? 0.05 : 0.08),
                  blurRadius: _isPressed ? 4 : 8,
                  offset: Offset(0, _isPressed ? 1 : 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserHeader(
                    user: user,
                    isLoading: isLoading,
                    subreddit: widget.post.subredditName),
                const SizedBox(height: 12),
                Text(widget.post.postName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 8),
                Text(widget.post.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withOpacity(0.9),
                      height: 1.4,
                    )),
                if (widget.post.url.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _UrlPreview(widget.post.url),
                  ),
                const SizedBox(height: 16),
                _VoteSection(
                  post: widget.post,
                  onVote: (voteType) {
                    widget.onVote(widget.post.id, voteType);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserHeader extends StatelessWidget {
  final LocaUser? user;
  final bool isLoading;
  final String subreddit;

  const _UserHeader(
      {required this.user, required this.isLoading, required this.subreddit});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        _UserAvatar(user: user, isLoading: isLoading),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.username ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
              Text('r/$subreddit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2A4B7C)
                            .withOpacity(0.6), // Couleur subreddit
                      )),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final LocaUser? user;
  final bool isLoading;

  const _UserAvatar({required this.user, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF2A4B7C).withOpacity(0.1),
      backgroundImage: (user?.Photo.isNotEmpty ?? false)
          ? NetworkImage("http://192.168.1.5:9090${user!.Photo}")
          : null,
      child: isLoading
          ? CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            )
          : (user?.Photo.isEmpty ?? true)
              ? Icon(Icons.person,
                  color: const Color(0xFF2A4B7C).withOpacity(0.6), size: 24)
              : null,
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
          color: const Color(0xFF2A4B7C).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A4B7C).withOpacity(0.1)),
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

class _VoteSection extends StatelessWidget {
  final PostResponse post;
  final Function(String) onVote;

  const _VoteSection({required this.post, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A4B7C).withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Section des votes
          Row(
            children: [
              _VoteButton(
                icon: Icons.arrow_upward_rounded,
                isActive: post.upVote,
                activeColor: const Color(0xFF2A4B7C),
                onPressed: () => onVote("UPVOTE"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${post.voteCount ?? 0}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _VoteButton(
                icon: Icons.arrow_downward_rounded,
                isActive: post.downVote,
                activeColor: colors.error,
                onPressed: () => onVote("DOWNVOTE"),
              ),
            ],
          ),

          // Nombre de commentaires
          Row(
            children: [
              Icon(Icons.comment_rounded,
                  color: const Color(0xFF2A4B7C).withOpacity(0.6), size: 20),
              const SizedBox(width: 6),
              Text('${post.commentCount ?? 0}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),

          // Date du post
          Text(
            'Posted ${post.duration}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.outline),
          ),
        ],
      ),
    );
  }
}

// Bouton de vote stylisé
class _VoteButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onPressed;

  const _VoteButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onPressed,
  });

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.isActive
              ? widget.activeColor.withOpacity(0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.activeColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          widget.icon,
          color: widget.isActive
              ? widget.activeColor
              : Theme.of(context).colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }
}

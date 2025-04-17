import 'package:flutter/material.dart';
import 'package:sos_maison/PostResponse.dart';
import 'CreatePostPage.dart';
import 'PostService.dart';
import 'Postwidget.dart';

import 'UserService.dart';
import 'auth_service.dart';
import 'VoteDto.dart';
import 'VoteService.dart';

import 'localUser.dart';

class PostPage extends StatefulWidget {
  final int subredditId;

  const PostPage({super.key, required this.subredditId});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final PostService postService = PostService();
  final UserService userService = UserService();
  final VoteService voteService = VoteService();
  List<PostResponse> posts = [];
  List<PostResponse> filteredPosts = [];
  String? token;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getTokenAndFetchPosts();
  }

  Future<void> _getTokenAndFetchPosts() async {
    AuthService authService = AuthService();
    token = await authService.getToken();

    if (token != null) {
      _fetchPosts();
    } else {
      print("Token is null. User might not be logged in.");
    }
  }

  void _fetchPosts() async {
    try {
      posts = await postService.getPostsBySubreddit(widget.subredditId, token!);
      filteredPosts = posts; // Initialize filtered list
      setState(() {});
    } catch (e) {
      print("Failed to fetch posts: $e");
    }
  }

  void _searchPosts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPosts = posts; // Reset to all posts if query is empty
      });
    } else {
      setState(() {
        filteredPosts = posts.where((post) {
          return post.postName.toLowerCase().contains(query.toLowerCase()) ||
              post.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Future<LocaUser?> _getUserInfo(String username) async {
    return await userService.getUserByUsername(username);
  }

  void _vote(int postId, String voteType) async {
    if (token == null) return;

    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    setState(() {
      if (voteType == "UPVOTE") {
        if (!posts[postIndex].upVote) {
          posts[postIndex].voteCount = (posts[postIndex].voteCount ?? 0) + 1;
          posts[postIndex].upVote = true;
          posts[postIndex].downVote = false;
        }
      } else if (voteType == "DOWNVOTE") {
        if (!posts[postIndex].downVote) {
          posts[postIndex].voteCount = (posts[postIndex].voteCount ?? 0) - 1;
          posts[postIndex].downVote = true;
          posts[postIndex].upVote = false;
        }
      }
    });

    VoteDto voteDto = VoteDto(voteType: voteType, postId: postId);
    try {
      await voteService.vote(voteDto, token!);
    } catch (e) {
      print("Failed to cast vote: $e");
      setState(() {
        if (voteType == "UPVOTE") {
          posts[postIndex].voteCount = (posts[postIndex].voteCount ?? 0) - 1;
          posts[postIndex].upVote = false;
        } else if (voteType == "DOWNVOTE") {
          posts[postIndex].voteCount = (posts[postIndex].voteCount ?? 0) + 1;
          posts[postIndex].downVote = false;
        }
      });
    }
  }

  void _navigateToCreatePost() {
    if (posts.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostPage(
            subredditName: posts.first.subredditName,
          ),
        ),
      ).then((_) => _fetchPosts());
    } else {
      print("No posts available to get subreddit name.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'r/${posts.isNotEmpty ? posts.first.subredditName : "Subreddit"}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            const Color(0xFF2A4B7C).withOpacity(0.95), // Couleur principale
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer,
                border: Border.all(
                    color: colors.onPrimary.withOpacity(0.2), width: 1),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF2A4B7C),
                size: 24,
              ),
            ),
            onPressed: _navigateToCreatePost,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2A4B7C).withOpacity(0.015), // opacité très légère
              colors.surface
                  .withOpacity(0.95), // un peu plus de transparence ici aussi
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF2A4B7C).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2A4B7C).withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged:
                      _searchPosts, // Garde la logique de recherche originale
                  style: const TextStyle(
                    color: Color(0xFF2A4B7C),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher des publications...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF2A4B7C).withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    // Couleur du premier code
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16, // Padding vertical du premier code
                      horizontal: 24, // Padding horizontal du premier code
                    ),
                    prefixIcon: Icon(
                      Icons.search, // Icône du premier code
                      color: const Color(0xFF2A4B7C).withOpacity(0.8),
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons
                                  .close_rounded, // Garde la logique de fermeture
                              color: const Color(0xFF2A4B7C).withOpacity(0.8),
                              size: 20,
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : Icon(
                            Icons.tune, // Design du premier code
                            color: const Color(0xFF2A4B7C).withOpacity(0.6),
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: posts.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2A4B7C),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPosts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2A4B7C).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PostWidget(
                            post: post,
                            onVote: _vote,
                            getUserInfo: _getUserInfo,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: const Color(0xFF2A4B7C),
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
    );
  }
}

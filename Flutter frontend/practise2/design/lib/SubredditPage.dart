import 'package:flutter/material.dart';
import 'CreateSubredditPage.dart';
import 'Subreddit.dart';
import 'SubredditService.dart';
import 'auth_service.dart';
import 'PostPage.dart';

class SubredditPage extends StatefulWidget {
  const SubredditPage({super.key});

  @override
  _SubredditPageState createState() => _SubredditPageState();
}

class _SubredditPageState extends State<SubredditPage> {
  final SubredditService _subredditService = SubredditService();
  List<Subreddit> _subreddits = [];
  List<Subreddit> _filteredSubreddits = [];
  String? _token;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getTokenAndFetchSubreddits();
  }

  Future<void> _getTokenAndFetchSubreddits() async {
    final authService = AuthService();
    _token = await authService.getToken();
    if (_token != null) {
      await _fetchSubreddits();
    }
  }

  Future<void> _fetchSubreddits() async {
    try {
      final subreddits = await _subredditService.getAllSubreddits(_token!);
      setState(() {
        _subreddits = subreddits;
        _filteredSubreddits = subreddits; // Initialize filtered list
      });
    } catch (e) {
      print("Failed to fetch subreddits: $e");
    }
  }

  Future<void> _searchSubreddits(String query) async {
    if (query.length < 2) {
      setState(() {
        _filteredSubreddits =
            _subreddits; // Reset to all subreddits if query is less than 2 characters
      });
      return;
    }

    try {
      final searchResults =
          await _subredditService.searchSubreddits(query, _token!);
      setState(() {
        _filteredSubreddits = searchResults;
      });
    } catch (e) {
      print("Failed to search subreddits: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Communautés',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Color(0xFF2A4B7C),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.surface,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A4B7C).withOpacity(0.1), // Changement

                  border: Border.all(
                    color:
                        const Color(0xFF2A4B7C).withOpacity(0.3), // Changement
                    width: 1.5,
                  ),
                ),
                child:
                    const Icon(Icons.add, color: Color(0xFF2A4B7C), size: 22),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateSubredditPage(),
                ),
              ).then((_) => _fetchSubreddits()),
              splashColor: colors.primary.withOpacity(0.1),
              enableFeedback: true,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colors.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _searchSubreddits(value),
                decoration: InputDecoration(
                  hintText: 'Rechercher des communautés...',
                  hintStyle: TextStyle(
                    color: colors.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colors.onSurface.withOpacity(0.6),
                    size: 22,
                  ),
                  suffixIcon: Icon(
                    Icons.tune,
                    color: colors.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(colors, theme),
    );
  }

  Widget _buildBody(ColorScheme colors, ThemeData theme) {
    if (_filteredSubreddits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchSubreddits,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _filteredSubreddits.length,
        itemBuilder: (context, index) {
          final subreddit = _filteredSubreddits[index];
          return _buildSubredditCard(subreddit, colors, theme);
        },
      ),
    );
  }

  Widget _buildSubredditCard(
      Subreddit subreddit, ColorScheme colors, ThemeData theme) {
    return SizedBox(
      height: 200, // Hauteur fixe
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostPage(subredditId: subreddit.id),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCommunityIcon(colors),
                const SizedBox(height: 12),
                Text(
                  'r/${subreddit.name}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    subreddit.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPostCount(subreddit.numberOfPosts, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityIcon(ColorScheme colors) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF2A4B7C).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2A4B7C).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.people_alt_rounded,
        color: Color(0xFF2A4B7C),
        size: 24,
      ),
    );
  }

  Widget _buildPostCount(int? count, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A4B7C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.post_add_rounded,
            color: Color(0xFF2A4B7C),
            size: 19,
          ),
          const SizedBox(width: 6),
          Text(
            '${count ?? 0}',
            style: const TextStyle(
              color: Color(0xFF2A4B7C),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

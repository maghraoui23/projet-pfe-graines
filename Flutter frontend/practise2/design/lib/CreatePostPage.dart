import 'package:flutter/material.dart';
import 'PostRequest.dart';
import 'PostService.dart';
import 'auth_service.dart';

class CreatePostPage extends StatefulWidget {
  final String subredditName;

  const CreatePostPage({super.key, required this.subredditName});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final PostService _postService = PostService();
  final TextEditingController _postNameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _token;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  Future<void> _getToken() async {
    final authService = AuthService();
    _token = await authService.getToken();
    if (_token == null) {
      _showError("User not logged in");
      if (mounted) Navigator.pop(context);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_token == null) return;

    setState(() => _isLoading = true);

    try {
      final postRequest = PostRequest(
        subredditName: widget.subredditName,
        postName: _postNameController.text,
        url: _urlController.text,
        description: _descriptionController.text,
      );

      await _postService.createPost(postRequest, _token!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      _showError("Error: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF2A4B7C);
    final colors = Theme.of(context).colorScheme.copyWith(
          primary: mainColor,
          onPrimary: Colors.white,
        );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("New Post", style: textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('r/${widget.subredditName}',
                  style: textTheme.headlineSmall?.copyWith(
                      color: colors.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(_postNameController, 'Post Title',
                  isRequired: true),
              const SizedBox(height: 16),
              _buildTextField(_urlController, 'URL (optional)',
                  keyboardType: TextInputType.url),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description',
                  isRequired: true, maxLines: 5),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text('PUBLISH POST',
                        style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: colors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: isRequired ? '$label*' : label,
        labelStyle: TextStyle(
          color: colors.onSurface.withOpacity(0.6),
        ),
        floatingLabelStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        prefixIcon: _getPrefixIcon(label),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      validator: (value) => (isRequired && (value == null || value.isEmpty))
          ? 'Required field'
          : null,
    );
  }

  Widget? _getPrefixIcon(String label) {
    final Map<String, IconData> iconMap = {
      'Post Title': Icons.title_rounded,
      'URL (optional)': Icons.link_rounded,
      'Description': Icons.description_rounded,
    };

    return iconMap.containsKey(label)
        ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              iconMap[label],
              size: 24,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          )
        : null;
  }
}

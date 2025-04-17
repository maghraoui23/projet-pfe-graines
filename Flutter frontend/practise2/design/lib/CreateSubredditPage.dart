import 'package:flutter/material.dart';
import 'SubredditRequest.dart';
import 'SubredditService.dart';
import 'auth_service.dart';

class CreateSubredditPage extends StatefulWidget {
  const CreateSubredditPage({super.key});

  @override
  State<CreateSubredditPage> createState() => _CreateSubredditPageState();
}

class _CreateSubredditPageState extends State<CreateSubredditPage> {
  final _formKey = GlobalKey<FormState>();
  final SubredditService _subredditService = SubredditService();
  final TextEditingController _nameController = TextEditingController();
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
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _createSubreddit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_token == null) return;

    setState(() => _isLoading = true);

    try {
      final request = SubredditRequest(
        name: _nameController.text,
        description: _descriptionController.text,
      );

      await _subredditService.createSubreddit(request, _token!);
      Navigator.pop(context);
    } catch (e) {
      _showError("Creation error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Subreddit"),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 2,
        shadowColor: colors.shadow.withOpacity(0.1),
        iconTheme: IconThemeData(color: colors.onSurface),
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Subreddit",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Fill in the details to create your subreddit.",
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                // 🌟 Champ "Subreddit Name" amélioré
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Subreddit Name*",
                    floatingLabelStyle: TextStyle(color: colors.primary),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: colors.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.group_rounded,
                        color: colors.onSurface.withOpacity(0.8),
                      ),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    hintText: "Nom de votre communauté",
                    hintStyle: TextStyle(
                      color: colors.onSurface.withOpacity(0.4),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 24),
                // 🌟 Champ "Description" amélioré
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description*",
                    floatingLabelStyle: TextStyle(color: colors.primary),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: colors.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: colors.onSurface.withOpacity(0.8),
                      ),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    hintText: "Décrivez votre communité...",
                    hintStyle: TextStyle(
                      color: colors.onSurface.withOpacity(0.4),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 40),
                // 🌟 Bouton premium
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createSubreddit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A4B7C),
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: const Color(0xFF2A4B7C).withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Text(
                            "CREATE SUBREDDIT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

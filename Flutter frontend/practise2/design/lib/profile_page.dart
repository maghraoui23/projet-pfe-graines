import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'localUser.dart';
import 'auth_service.dart';
import 'UserService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  LocaUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        print("Utilisateur récupéré : ${user.toJson()}");

        // Définir le rôle à 'CLIENT' si le rôle est null ou 'USER'
        setState(() {
          _currentUser = user.copyWith(
            role: user.role ?? Role.CLIENT,
          );
        });
      } else {
        print("Aucun utilisateur trouvé ou réponse API vide.");
      }
    } catch (e) {
      print("Erreur lors de la récupération du user : $e");
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.exit_to_app, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 15),
              const Text(
                "Se déconnecter",
                style: TextStyle(
                  // Remplacement simple si GoogleFonts pose problème
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Êtes-vous sûr de vouloir vous déconnecter ?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Déconnexion",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, size: 60, color: Colors.blueAccent),
                const SizedBox(height: 15),
                const Text(
                  "Historique des commandes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Vous n'avez pas encore commandé.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                  ),
                  child: const Text(
                    "Fermer",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A4B7C), // Nouvelle couleur principale
                Color(0xFF3A6B9C), // Variation plus claire
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A4B7C).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, (1 - value) * 15)
                  ..scale(value),
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
          child: Text(
            'Profil Utilisateur',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: const Color(0xFF2A4B7C).withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 20),
                _buildInfoTile('Prénom', _currentUser!.FirstName, 'firstName'),
                _buildInfoTile('Nom', _currentUser!.LastName, 'lastName'),
                _buildInfoTile(
                    'Pseudonyme', _currentUser!.username, 'username'),
                _buildInfoTile('Email', _currentUser!.email, 'email'),
                _buildInfoTile(
                    'Téléphone', _currentUser!.phoneNumber, 'phoneNumber'),
                _buildRoleTile(
                    'Rôle',
                    _currentUser!.role.toString().split('.').last,
                    'role'), // Affiche le rôle
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.blueAccent),
                  title: const Text("Historique des commandes"),
                  onTap: _showOrderHistory,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Coins arrondis modernes
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    elevation: 5, // Ajoute une légère ombre
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout,
                          color: Colors.white,
                          size: 22), // Icône de déconnexion
                      SizedBox(
                          width: 8), // Espacement entre l'icône et le texte
                      Text(
                        "Se déconnecter",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildRoleTile(String title, String value, String field) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Coins arrondis modernes
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // Ajustement de l’espace
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A4B7C)
                .withOpacity(0.1), // Fond léger pour l'icône
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.security,
              color: Color(0xFF2A4B7C), size: 24), // Icône modernisée
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit,
              color: Colors.grey[600],
              size: 22), // Bouton d’édition plus discret
          onPressed: _editUserRole,
          splashRadius: 20, // Effet de clic plus propre
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: _getProfileImage(),
          child: (_currentUser!.Photo.isEmpty)
              ? const Icon(Icons.person, size: 50, color: Colors.black)
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          _currentUser!.username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: _changeProfilePhoto,
        ),
      ],
    );
  }

  void _editUserRole() async {
    if (_currentUser == null) return;

    String? newRole = await _showRoleSelectionDialog(context);

    if (newRole != null && ['CLIENT', 'PROFESSIONNEL'].contains(newRole)) {
      setState(() {
        _currentUser = _currentUser!.copyWith(
            role: newRole == 'CLIENT' ? Role.CLIENT : Role.PROFESSIONNEL);
      });

      try {
        await _userService.updateUser(_currentUser!.id, _currentUser!);
        print("✅ Rôle mis à jour avec succès !");
      } catch (e) {
        print("❌ Erreur lors de la mise à jour du rôle : $e");
      }
    } else {
      print("❌ Rôle invalide !");
    }
  }

  Future<String?> _showRoleSelectionDialog(BuildContext context) async {
    String selectedRole =
        _currentUser?.role.toString().split('.').last ?? 'CLIENT';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le rôle'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: selectedRole,
                items: ['CLIENT', 'PROFESSIONNEL']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedRole),
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  ImageProvider? _getProfileImage() {
    if (_currentUser == null || _currentUser!.Photo.isEmpty) {
      return null;
    }

    // Utilisez l'URL complète du serveur
    final imageUrl = 'http://192.168.1.5:9090${_currentUser!.Photo}';

    try {
      return CachedNetworkImageProvider(imageUrl);
    } catch (e) {
      print("Erreur de chargement: $e");
      return null;
    }
  }

  Widget _buildInfoTile(String title, String value, String field) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            12), // Coins arrondis pour un look plus premium
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10), // Espace ajusté pour l’esthétique
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A4B7C)
                .withOpacity(0.1), // Fond doux pour l'icône
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForTitle(title),
            color: const Color(0xFF2A4B7C),
            size: 24, // Taille légèrement augmentée
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit,
              color: Colors.grey[600],
              size: 22), // Design plus sobre et élégant
          onPressed: () => _editUserInfo(field),
          splashRadius: 20, // Effet de clic plus propre
        ),
      ),
    );
  }

  void _editUserInfo(String field) async {
    if (_currentUser == null) return;

    String? newValue = await _showInputDialog(
      context,
      'Modifier $field',
      _getUserFieldValue(field),
    );

    if (newValue != null && newValue.isNotEmpty) {
      setState(() {
        _currentUser = _currentUser!.copyWith(
          firstName: field == 'firstName' ? newValue : _currentUser!.FirstName,
          lastName: field == 'lastName' ? newValue : _currentUser!.LastName,
          username: field == 'username' ? newValue : _currentUser!.username,
          email: field == 'email' ? newValue : _currentUser!.email,
          phoneNumber:
              field == 'phoneNumber' ? newValue : _currentUser!.phoneNumber,
          role: field == 'role'
              ? (_currentUser!.role == Role.CLIENT
                  ? Role.CLIENT
                  : Role.PROFESSIONNEL)
              : _currentUser!.role,
        );
      });

      try {
        await _userService.updateUser(_currentUser!.id, _currentUser!);
      } catch (e) {
        print("❌ Erreur lors de la mise à jour de l'utilisateur : $e");
      }
    }
  }

  Future<String?> _showInputDialog(
      BuildContext context, String title, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    return showDialog<String>(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.3), // Léger fondu en arrière-plan
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white, // Fond épuré
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Entrez la nouvelle valeur",
              hintStyle:
                  GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
              filled: true,
              fillColor: Colors.grey.shade100, // Fond léger pour le champ
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF2A4B7C), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                textStyle: GoogleFonts.poppins(fontSize: 16),
              ),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A4B7C), // Couleur premium assortie
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _changeProfilePhoto() async {
    if (_currentUser == null) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la Galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) return;

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null || _currentUser == null) return;

    try {
      final imageFile = File(pickedFile.path);
      final success =
          await _authService.uploadUserPhoto(_currentUser!.id, imageFile);

      if (success) {
        // Rafraîchir les données utilisateur
        final updatedUser = await _authService.getCurrentUser();
        setState(() {
          _currentUser = updatedUser;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo mise à jour avec succès !')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Échec de la mise à jour de la photo')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  String _getUserFieldValue(String field) {
    switch (field) {
      case 'firstName':
        return _currentUser!.FirstName;
      case 'lastName':
        return _currentUser!.LastName;
      case 'username':
        return _currentUser!.username;
      case 'email':
        return _currentUser!.email;
      case 'phoneNumber':
        return _currentUser!.phoneNumber;
      case 'role':
        return _currentUser!.role
            .toString()
            .split('.')
            .last; // Récupère le nom de l'énumération
      default:
        return '';
    }
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Prénom':
        return Icons.person;
      case 'Nom':
        return Icons.person_outline;
      case 'Pseudonyme':
        return Icons.alternate_email;
      case 'Email':
        return Icons.email;
      case 'Téléphone':
        return Icons.phone;
      case 'Rôle':
        return Icons.security;
      default:
        return Icons.info;
    }
  }
}

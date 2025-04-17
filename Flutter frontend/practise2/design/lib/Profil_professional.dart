// profile_professional_page.dart
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Commentaire.dart';
import 'Evaluation.dart';
import 'Likes.dart';
import 'Likes_service.dart';
import 'Professional.dart';
import 'auth_service.dart';
import 'comment_service.dart';
import 'evaluation_service.dart';
import 'localUser.dart';
import 'publication.dart';
import 'publication_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileProfessionalPage extends StatefulWidget {
  final Professional professional;

  const ProfileProfessionalPage({super.key, required this.professional});

  @override
  _ProfileProfessionalPageState createState() =>
      _ProfileProfessionalPageState();
}

class _ProfileProfessionalPageState extends State<ProfileProfessionalPage> {
  late PublicationService _publicationService;
  late EvaluationService _evaluationService;
  late Future<List<Publication>> _publicationsFuture;
  late Future<List<Evaluation>> _evaluationsFuture;
  late Future<double> _moyenneAvisFuture;
  LocaUser? _currentUser;

  @override
  void initState() {
    super.initState();

    // Initialisation SYNCHRONE de tous les services et futures
    _publicationService = PublicationService(client: http.Client());
    _evaluationService = EvaluationService();

    // Initialisation directe des futures
    _publicationsFuture = _loadPublications();
    _moyenneAvisFuture =
        _evaluationService.getMoyenneAvis(widget.professional.id);
    _evaluationsFuture =
        _evaluationService.getEvaluations(widget.professional.id);

    // Chargement asynchrone de l'utilisateur seulement
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _evaluationService.dispose();
    super.dispose();
  }

  Future<List<Publication>> _loadPublications() async {
    try {
      return await _publicationService
          .getPublicationsByUserId(widget.professional.id);
    } catch (e) {
      print('Erreur de chargement des publications: $e');
      print('Détails du professionnel: ${widget.professional}');
      throw Exception('Erreur de chargement des publications: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    final authService = AuthService();
    if (await authService.isLoggedIn()) {
      _currentUser = await authService.getCurrentUser();
      setState(() {}); // Rafraîchit l'UI après obtention de l'utilisateur
    }
  }

  Widget _buildEvaluationSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<double>(
            future: _moyenneAvisFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Erreur de chargement des avis',
                    style: TextStyle(color: Colors.red));
              }
              return Row(
                children: [
                  Text(
                    'Note moyenne: ${snapshot.data!.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A4B7C), // ← PrimaryColor
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A4B7C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _handleEvaluationButtonPress,
            icon: const Icon(Icons.rate_review, size: 20),
            label: FutureBuilder<bool>(
              future: _currentUser == null
                  ? Future.value(false)
                  : _evaluationService.hasUserEvaluatedProfessional(
                      userId: _currentUser!.id,
                      professionalId: widget.professional.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Chargement...');
                }
                if (snapshot.hasData && snapshot.data!) {
                  return const Text('Modifier mon évaluation');
                }
                return const Text('Ajouter une évaluation');
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Avis clients:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6572),
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Evaluation>>(
            stream:
                _evaluationService.getEvaluationsStream(widget.professional.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Erreur technique : ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                );
              }

              final evaluations = snapshot.data;
              if (evaluations == null || evaluations.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Aucun avis pour le moment.',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic),
                  ),
                );
              }

              // Afficher seulement les 3 premières évaluations
              final displayedEvaluations = evaluations.take(3).toList();

              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedEvaluations.length,
                    itemBuilder: (context, index) {
                      return _buildEvaluationCard(displayedEvaluations[index]);
                    },
                  ),
                  if (evaluations.length >
                      3) // Si + de 3 avis, afficher le bouton "Voir tout"
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                              const Color(0xFF2A4B7C), // ← PrimaryColor

                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                        onPressed: () =>
                            _showAllEvaluations(context, evaluations),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.list,
                                size: 20, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text("Voir tous les avis",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

// Ouvre une boîte de dialogue avec toutes les évaluations
  void _showAllEvaluations(BuildContext context, List<Evaluation> evaluations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Effet de flou
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFFF8F8F8), // ✅ Fond premium proche du blanc
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        "Toutes les évaluations",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A4B7C),
                        ),
                      ),
                      Divider(thickness: 1.5, color: Colors.grey.shade300),
                      const SizedBox(height: 10),

                      // Liste des évaluations
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: evaluations.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildEvaluationCard(evaluations[index]);
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bouton de fermeture
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A4B7C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Fermer",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// 📌 Version améliorée de `_buildEvaluationCard` avec un design premium
  Widget _buildEvaluationCard(Evaluation evaluation) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: child,
        ),
      ),
      child: Container(
        margin:
            const EdgeInsets.symmetric(vertical: 6), // ✅ Espacement équilibré
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC), // ✅ Fond premium légèrement crème
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300, // ✅ Bordure fine et moderne
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: evaluation.user.Photo.isNotEmpty
                      ? CachedNetworkImageProvider(
                          'http://192.168.1.5:9090${evaluation.user.Photo}')
                      : null,
                  child: evaluation.user.Photo.isEmpty
                      ? const Icon(Icons.person, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    evaluation.user.username,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(
                          0xFF4A6572), // ← SecondaryColor // ✅ Texte contrasté et lisible
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Étoiles d'évaluation
            RatingBarIndicator(
              rating: evaluation.rating.toDouble(),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 22,
            ),

            // Commentaire (si disponible)
            if (evaluation.comment != null && evaluation.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  evaluation.comment!,
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEvaluationButtonPress() async {
    if (_currentUser == null) return;

    final bool hasEvaluated =
        await _evaluationService.hasUserEvaluatedProfessional(
      userId: _currentUser!.id,
      professionalId: widget.professional.id,
    );

    int? currentRating;
    String? currentComment;

    if (hasEvaluated) {
      final evaluations = await _evaluationsFuture;
      final existingEvaluation = evaluations.firstWhere(
        (e) => e.user.id == _currentUser!.id,
      );
      currentRating = existingEvaluation.rating;
      currentComment = existingEvaluation.comment;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6), // Fond semi-transparent
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Effet glassmorphism
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasEvaluated ? 'Modifier votre avis' : 'Donner votre avis',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A6572), // ← SecondaryColor
                ),
              ),
              const SizedBox(height: 15),
              RatingBar.builder(
                initialRating: currentRating?.toDouble() ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 40,
                glow: true,
                glowColor: Colors.amber.withOpacity(0.5),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF5A623), // ← AccentColor
                  size: 40,
                ),
                onRatingUpdate: (rating) => currentRating = rating.toInt(),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  labelStyle: GoogleFonts.poppins(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor:
                      Colors.white.withOpacity(0.8), // Effet de transparence
                ),
                onChanged: (value) => currentComment = value,
                controller: TextEditingController(text: currentComment),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.poppins(
                          color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (currentRating == null || currentRating! < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Veuillez donner une note')),
                        );
                        return;
                      }

                      try {
                        if (hasEvaluated) {
                          final evaluations = await _evaluationsFuture;
                          final existingEvaluation = evaluations.firstWhere(
                            (e) => e.user.id == _currentUser!.id,
                          );
                          await _evaluationService.updateEvaluation(
                            evaluationId: existingEvaluation.id!,
                            newRating: currentRating!,
                            professionalId: widget.professional.id,
                            newComment: currentComment,
                          );
                        } else {
                          await _evaluationService.addEvaluation(
                            userId: _currentUser!.id,
                            professionalId: widget.professional.id,
                            rating: currentRating!,
                            comment: currentComment,
                          );
                        }
                        // Mise à jour en temps réel
                        setState(() {
                          _evaluationsFuture = _evaluationService
                              .getEvaluations(widget.professional.id);
                          _moyenneAvisFuture = _evaluationService
                              .getMoyenneAvis(widget.professional.id);
                        });

                        _loadCurrentUser();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A4B7C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shadowColor: Colors.blueAccent.withOpacity(0.4),
                      elevation: 5,
                    ),
                    child: Text(
                      'Envoyer',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
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
            'Profil de ${widget.professional.firstName}',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            _buildEvaluationSection(),

            // Section Divider (inchangée)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(thickness: 1.5, color: Colors.grey.shade300),
            ),

            // Titre Publications (inchangé)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "📚 Publications",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.grey.shade400,
                      offset: const Offset(1, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Conteneur Publications (inchangé)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<Publication>>(
                  future: _publicationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Aucune publication disponible'));
                    }
                    return _buildPublicationsList(snapshot.data!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    const Color primaryColor = Color(0xFF2A4B7C); // Nouvelle couleur principale
    const Color secondaryColor = Color(0xFF4A6572); // Couleur secondaire
    const Color accentColor = Color(0xFFF5A623); // Couleur d'accentuation

    return FutureBuilder<double>(
      future: _evaluationService.getMoyenneAvis(widget.professional.id),
      builder: (context, snapshot) {
        // [Logique inchangée]
        double moyenneText;
        bool isLoading = false;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF3A6B9C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundImage: widget.professional.photo != null
                        ? CachedNetworkImageProvider(widget.professional.photo!)
                        : null,
                    backgroundColor: Colors.grey[100],
                    child: widget.professional.photo == null
                        ? const Icon(Icons.person,
                            size: 50, color: primaryColor)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${widget.professional.firstName} ${widget.professional.lastName}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: secondaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '@${widget.professional.username}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn(
                      Icons.star_rate_rounded,
                      'Note',
                      widget.professional.moyenneAvis.toStringAsFixed(1) ??
                          'N/A',
                      isLoading: isLoading,
                      color: accentColor,
                    ),
                    _buildInfoColumn(
                      Icons.euro_symbol_rounded,
                      'Prix',
                      widget.professional.prixService?.toStringAsFixed(2) ??
                          'N/A',
                      color: primaryColor,
                    ),
                    _buildInfoColumn(
                      Icons.work_history_rounded,
                      'Expérience',
                      '${widget.professional.experience ?? 'N/A'} ans',
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildContactInfo(primaryColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String value,
      {bool isLoading = false, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
      ],
    );
  }

  Widget _buildContactInfo(Color primaryColor) {
    return Column(
      children: [
        _buildContactTile(
          icon: Icons.email_rounded,
          text: widget.professional.email,
          color: primaryColor,
        ),
        if (widget.professional.phoneNummber != null)
          _buildContactTile(
            icon: Icons.phone_rounded,
            text: widget.professional.phoneNummber!,
            color: primaryColor,
          ),
        if (widget.professional.localisation != null)
          _buildContactTile(
            icon: Icons.location_on_rounded,
            text: widget.professional.localisation!.toString(),
            color: primaryColor,
          ),
      ],
    );
  }

  Widget _buildContactTile(
      {required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4A6572),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicationsList(List<Publication> publications) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: publications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildPublicationCard(publications[index]);
      },
    );
  }

  Widget _buildPublicationCard(Publication publication) {
    CommentService commentService = CommentService(client: http.Client());
    LikeService likeService = LikeService(client: http.Client());

    return FutureBuilder<int>(
      future: commentService
          .getCommentsByPublication(publication.id)
          .then((comments) => comments.length),
      builder: (context, snapshot) {
        int commentCount = snapshot.data ?? 0;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: publication.auteur.photo != null
                            ? CachedNetworkImageProvider(
                                publication.auteur.photo!)
                            : null,
                        child: publication.auteur.photo == null
                            ? const Icon(Icons.person,
                                color: Colors.black, size: 29)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${publication.auteur.firstName} ${publication.auteur.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _timeAgo(publication.datePublication),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, size: 20),
                      color: Colors.black,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              if (publication.contenu.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0)
                      .copyWith(bottom: 8),
                  child: Text(
                    publication.contenu,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                ),
              if (publication.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: publication.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 375,
                    memCacheHeight: 1000,
                    maxWidthDiskCache: 1080,
                    placeholder: (context, url) => Container(
                      height: 375,
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 375,
                      color: Colors.grey[100],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: FutureBuilder<LocaUser?>(
                  future: AuthService().getCurrentUser(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    int userId = userSnapshot.data!.id;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FutureBuilder<bool>(
                              future: likeService.checkIfUserLiked(
                                  userId, publication.id),
                              builder: (context, likeSnapshot) {
                                bool isLiked = likeSnapshot.data ?? false;
                                return IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
                                    color:
                                        isLiked ? Colors.red : Colors.black87,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    await likeService.toggleLike(
                                        userId, publication.id);
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                            GestureDetector(
                              onTap: () => _showCommentsDialog(publication),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/comment.png',
                                    width: 23,
                                    height: 23,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$commentCount',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        FutureBuilder<List<Like>>(
                          future: likeService
                              .getLikesForPublication(publication.id),
                          builder: (context, likeSnapshot) {
                            List<Like> likes = likeSnapshot.data ?? [];
                            return GestureDetector(
                              onTap: () => _showLikesDialog(context, likes),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.favorite,
                                        size: 20, color: Colors.black87),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${likes.length} j\'aime',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (commentCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, top: 4),
                            child: GestureDetector(
                              onTap: () => _showCommentsDialog(publication),
                              child: Text(
                                'Voir les $commentCount commentaires',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLikesDialog(BuildContext context, List<Like> likes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Personnes ayant aimé",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: likes.isEmpty
                    ? const Center(child: Text("Aucun like pour l’instant"))
                    : ListView.builder(
                        itemCount: likes.length,
                        itemBuilder: (context, index) {
                          final like = likes[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: like.user!.Photo != null
                                  ? CachedNetworkImageProvider(
                                          'http://192.168.1.5:9090${like.user!.Photo}')
                                      as ImageProvider
                                  : const AssetImage(
                                      "assets/default_avatar.png"),
                            ),
                            title: Text(
                              like.user!.username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing:
                                const Icon(Icons.favorite, color: Colors.red),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentsDialog(Publication publication) {
    TextEditingController commentController = TextEditingController();
    AuthService authService = AuthService();
    CommentService commentService = CommentService(client: http.Client());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<bool>(
              future: authService.isLoggedIn(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool isLoggedIn = snapshot.data!;

                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Commentaires",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: FutureBuilder<List<Comment>>(
                            future: commentService
                                .getCommentsByPublication(publication.id),
                            builder: (context, commentsSnapshot) {
                              if (commentsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (commentsSnapshot.hasError ||
                                  !commentsSnapshot.hasData) {
                                return const Center(
                                    child: Text("Erreur de chargement"));
                              }

                              List<Comment> comments = commentsSnapshot.data!;

                              return comments.isEmpty
                                  ? const Center(
                                      child: Text("Aucun commentaire"))
                                  : ListView.builder(
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        Comment comment = comments[index];
                                        return FutureBuilder<LocaUser?>(
                                          future: authService.getCurrentUser(),
                                          builder: (context, userSnapshot) {
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: comment
                                                        .auteur.Photo.isNotEmpty
                                                    ? CachedNetworkImageProvider(
                                                        'http://192.168.1.5:9090${comment.auteur.Photo}')
                                                    : const AssetImage(
                                                            'assets/default_avatar.png')
                                                        as ImageProvider,
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    comment.auteur.username,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    comment.contenu,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Text(
                                                _timeAgo(
                                                    comment.dateCommentaire),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                            },
                          ),
                        ),
                        if (isLoggedIn)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: commentController,
                                    decoration: InputDecoration(
                                      hintText: "Ajouter un commentaire...",
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    final user =
                                        await authService.getCurrentUser();
                                    if (user != null) {
                                      try {
                                        await commentService.addComment(
                                          userId: user.id,
                                          publicationId: publication.id,
                                          contenu: commentController.text,
                                        );
                                        setState(() {}); // Rafraîchir la liste
                                        commentController.clear();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text("Erreur: $e")),
                                        );
                                      }
                                    }
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child:
                                        Icon(Icons.send, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Vous devez vous connecter pour commenter."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text("Se connecter pour commenter"),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      // Gestion des dates futures
      if (difference.isNegative) {
        final futureDifference = date.difference(now);
        if (futureDifference.inDays > 30) {
          return 'Dans ${(futureDifference.inDays / 30).floor()} mois';
        } else if (futureDifference.inDays > 0) {
          return 'Dans ${futureDifference.inDays}j';
        } else if (futureDifference.inHours > 0) {
          return 'Dans ${futureDifference.inHours}h';
        } else {
          return 'Bientôt';
        }
      }

      // Calcul pour les dates passées
      if (difference.inDays >= 30) {
        return '${(difference.inDays / 30).floor()}mois';
      } else if (difference.inDays >= 1) {
        return '${difference.inDays}j';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes}min';
      } else if (difference.inSeconds >= 10) {
        return '${difference.inSeconds}s';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      print('Erreur timeAgo: $e');
      return '--';
    }
  }

  void _handleLike(Publication publication) async {
    try {
      final authService = AuthService();
      final currentUser = await authService.getCurrentUser();

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour aimer')),
        );
        return;
      }

      final likeService = LikeService();

      // Vérification initiale du like
      final isLiked =
          await likeService.checkIfUserLiked(currentUser.id, publication.id);

      // Toggle du like
      await likeService.toggleLike(currentUser.id, publication.id);

      // Mise à jour optimiste
      setState(() {
        publication = publication.copyWith(
          likes: publication.likes + (isLiked ? -1 : 1),
        );
      });

      // Vérification finale avec le serveur
      final updatedCount = await likeService.getLikesCount(publication.id);
      setState(() {
        publication = publication.copyWith(likes: updatedCount);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}

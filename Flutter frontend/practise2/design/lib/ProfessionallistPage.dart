import 'package:flutter/material.dart';
import 'Professional.dart';
import 'Profil_professional.dart';
import 'Service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfessionalsListPage extends StatefulWidget {
  final Service service;

  const ProfessionalsListPage({super.key, required this.service});

  @override
  _ProfessionalsListPageState createState() => _ProfessionalsListPageState();
}

class _ProfessionalsListPageState extends State<ProfessionalsListPage> {
  late TextEditingController _searchController;
  final Color _accentColor = const Color(0xFF2A4B7C); // Couleur principale
  final Color _secondaryColor = const Color(0xFF4A6572); // Couleur secondaire
  final Color _backgroundColor = const Color(0xFFF5F7FA); // Fond de page

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.service.nom);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accentColor,
        title: _buildSearchBar(),
        elevation: 0,
        toolbarHeight: 80,
      ),
      backgroundColor: _backgroundColor,
      body: _buildProfessionalList(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher dans ${widget.service.nom}',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: _accentColor),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildProfessionalList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: widget.service.professionnels.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "🔧 Trouvez votre expert",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _accentColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Text(
                "Spécialistes en ${widget.service.nom}",
                style: TextStyle(
                  fontSize: 16,
                  color: _secondaryColor.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withOpacity(0.15),
              ),
              const SizedBox(height: 12),
            ],
          );
        }
        return ProfessionalCard(
          professional: widget.service.professionnels[index - 1],
          accentColor: _accentColor,
          secondaryColor: _secondaryColor,
        );
      },
    );
  }
}

class ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final Color accentColor;
  final Color secondaryColor;

  const ProfessionalCard({
    super.key,
    required this.professional,
    required this.accentColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileProfessionalPage(
                professional: professional,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildReviewSection(),
                const SizedBox(height: 16),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
          ),
          child: ClipOval(
            child: professional.photo != null
                ? CachedNetworkImage(
                    imageUrl: professional.photo!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildPlaceholder(),
                    errorWidget: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${professional.firstName} ${professional.lastName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.verified, color: accentColor, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '@${professional.username}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: accentColor.withOpacity(0.1),
      child: Icon(Icons.person, size: 36, color: accentColor),
    );
  }

  Widget _buildStatsRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildStatBadge(Icons.verified_user, 'Identité vérifiée'),
        _buildStatBadge(Icons.trending_up, '67%'),
        _buildStatBadge(Icons.thumb_up, 'Populaires'),
      ],
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Note moyenne + compteur
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStarRating(professional.moyenneAvis),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${professional.moyenneAvis.toStringAsFixed(1)}/5',
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Sur ${professional.nombreEvaluations} avis',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Section "Meilleur avis" intégrée
        if (professional.highestRating > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              // <<< tu avais oublié la parenthèse ici
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '⭐ Avis exceptionnel',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${professional.highestRating}/5)',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (professional.highestComment != null)
                  Text(
                    '"${professional.highestComment!}"',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

// Widget étoiles simplifié
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star_rounded,
          color: index < rating.floor()
              ? const Color(0xFFFFD700)
              : Colors.grey.shade300,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDistanceBadge(),
        _buildPriceBadge(),
      ],
    );
  }

  Widget _buildDistanceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Text(
            '17 KM',
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${professional.prixService?.toStringAsFixed(2) ?? 'N/A'} DT',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

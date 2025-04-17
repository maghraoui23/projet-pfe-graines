import 'package:sos_maison/SubredditPage.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'login_page.dart';
import 'profile_page.dart';
import 'package:flutter/material.dart';

import 'ChatPage.dart';
import 'ProfessionallistPage.dart';
import 'Service.dart';
import 'auth_service.dart';
import 'service_api.dart';
import 'signup_page.dart';
import 'splash.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'localUser.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser la clé de navigation pour Zego
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  // Initialiser les logs et l'UI système
  await ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(MyApp(navigatorKey: navigatorKey));
  });
}

class MyApp extends StatefulWidget {
  final AuthService _authService = AuthService();
  final GlobalKey<NavigatorState> navigatorKey;

  MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    widget._authService.checkAuthState();
  }

  void _setupAuthListener() {
    widget._authService.authStateChanges.listen((user) {
      if (user != null) {
        _initializeCallService(user);
      } else {
        _disposeCallService();
      }
    });
  }

  void _initializeCallService(LocaUser user) async {
    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 1545717237, // Conservez votre AppID
      appSign:
          '008a514d6a62631c0214184e31106553bc63f42fc76ce03a952d7c6e42a996a1', // Votre AppSign
      userID: user.id.toString(),
      userName: user.username,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  void _disposeCallService() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: widget.navigatorKey,
      home: const SplashPage(), // Assurez-vous que SplashPage est défini
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // Changez en StatefulWidget
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  final Color mainColor = const Color(0xFF1976D2
  );//487CFF  bleu electrique good   00A8E8 good bleu oxygene 2A5C82 green 8ama9 moderne 006D77 bleu digital 1976D2

  //Color(0xff641BB4) mauve le9dim
  // Un seul endroit à modifier !
  final double _cardElevation = 4.0; // Plus prononcé
  final double _cardRadius = 16.0; // Plus arrondi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSectionTitle('Popular Services on SOS'),
                  _buildHorizontalList([
                    _buildServiceCard('Cleaning the house', 'assets/2000.webp'),
                    _buildServiceCard('Painting the house', 'assets/2001.jpg'),
                    _buildServiceCard('Plumbing Service', 'assets/2000.webp'),
                    _buildServiceCard('Electric Work', 'assets/2001.jpg'),
                  ]),
                  _buildSectionTitle('Browse all categories'),
                  _buildCategoryList(),
                  _buildSectionTitle('Handyman Services'),
                  _buildHorizontalList([
                    _buildServiceCardWithPrice(
                        'Starts @ NGN5000/hr', 'assets/2002.jpg'),
                    _buildServiceCardWithPrice(
                        'Starts @ NGN3000/hr', 'assets/2003.jpg'),
                    _buildServiceCardWithPrice(
                        'Starts @ NGN7000/hr', 'assets/2002.jpg'),
                    _buildServiceCardWithPrice(
                        'Starts @ NGN2500/hr', 'assets/2003.jpg'),
                  ]),
                  _buildSectionTitle('Professional Services'),
                  _buildProfessionalCleaningBanner(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: mainColor, // Application de la nouvelle couleur
        borderRadius: const BorderRadius.only(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  flex: 6,
                  child: Container(
                      child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.build,
                        color: Colors.white,
                        size: 29,
                      ),
                      Text(
                        'SOS Maison',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ))),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FutureBuilder<bool>(
                      future: _authService.isLoggedIn(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!) {
                          return IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 29,
                            ),
                            onPressed: () => _showLogoutDialog(context),
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                              size: 29,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          );
                        }
                      },
                    ),
                    const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 29,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    //////
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for "Painting"',
                 // Ajout ici
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: mainColor,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.0,
                  color: mainColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<Widget> items) {
    //////
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items,
      ),
    );
  }

  Widget _buildServiceCard(String title, String imagePath) {
    /////////
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(imagePath,
                    height: 120, width: 180, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  radius: 16,
                  child: const Icon(Icons.favorite_border,
                      color: Colors.red, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildServiceCardWithPrice(String price, String imagePath) {
    ///////////
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath,
                height: 120, width: 120, fit: BoxFit.cover),
          ),
          Container(
            color: const Color(0xFF2A4B7C).withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: 120,
            child: Text(price,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    /////////
    return FutureBuilder<List<Service>>(
      future: ServiceApi.fetchServices(),
      builder: (context, snapshot) {
        // Gestion de l'état de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Gestion des erreurs
        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }

        // Vérification de la nullité des données
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print(snapshot.data);
          return const Text('Aucun service disponible');
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: snapshot.data!
                  .map((service) => ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 120),
                        child: _buildServiceCategory(service),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCategory(Service service) {
    return GestureDetector(
      onTap: () => _navigateToProfessionalsPage(context, service),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: _cardElevation,
            shape: const CircleBorder(),
            child: Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: service.service_photo,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: mainColor,
                      strokeWidth: 2.0,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.category_rounded,
                    size: 28.0,
                    color: mainColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: 100.0,
            child: Text(
              service.nom,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

// 2. Méthode de navigation
  void _navigateToProfessionalsPage(BuildContext context, Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalsListPage(service: service),
      ),
    );
  }

  Widget _buildProfessionalCleaningBanner() {
    ////////
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/house2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      width: double.infinity,
      height: 180,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withOpacity(0.1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Professional\ncleaning services',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23334A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child:
                  const Text('Explore', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        // La logique originale est conservée
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubredditPage()),
          );
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      selectedItemColor: mainColor,
      unselectedItemColor: mainColor,
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        height: 1.5,
      ),
      items: [
        BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedIndex == 0
                ? const Icon(Icons.explore, size: 26)
                : const Icon(Icons.explore_outlined, size: 24),
          ),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedIndex == 1
                ? const Icon(Icons.work, size: 26)
                : const Icon(Icons.work_outline, size: 24),
          ),
          label: 'Projects',
        ),
        BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedIndex == 2
                ? const Icon(Icons.message, size: 26)
                : const Icon(Icons.message_outlined, size: 24),
          ),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedIndex == 3
                ? const Icon(Icons.more_horiz, size: 26)
                : const Icon(Icons.more_horiz_outlined, size: 24),
          ),
          label: 'More',
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, size: 30, color: const Color(0xff641BB4))),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.3), // Léger fondu en arrière-plan
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white, // Fond opaque élégant
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.exit_to_app,
                  size: 50, color: Color(0xFF2A4B7C)), // Icône moderne
              const SizedBox(height: 15),
              Text(
                "Se déconnecter",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Êtes-vous sûr de vouloir vous déconnecter ?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      textStyle: GoogleFonts.poppins(fontSize: 16),
                    ),
                    child: const Text("Annuler"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2A4B7C), // Couleur assortie au thème
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      "Déconnexion",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
}  //
//Color(0xff641BB4) mauve le9dim
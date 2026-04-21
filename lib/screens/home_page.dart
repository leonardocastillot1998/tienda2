import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import '../theme/prestige_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.username,
    required this.puntos,
    required this.authService,
  });

  final String username;
  final int puntos;
  final AuthService authService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _puntos;
  int _currentIndex = 1; // Start in Catalog

  @override
  void initState() {
    super.initState();
    _puntos = widget.puntos;
  }

  Future<void> _logout() async {
    await widget.authService.logout();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginPage(authService: widget.authService),
      ),
    );
  }

  Future<void> _agregarPuntos(int valor) async {
    setState(() {
      _puntos += valor;
    });

    await widget.authService.savePoints(
      username: widget.username,
      points: _puntos,
    );

    if (valor < 0 && mounted) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Felicidades'),
          content: const Text('Has ganado un premio.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${widget.username}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Puntos acumulados: $_puntos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _agregarPuntos(10),
              icon: const Icon(Icons.add_circle),
              label: const Text('Ganar 10 puntos'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _puntos >= 50 ? () => _agregarPuntos(-50) : null,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Canjear premio (50 puntos)'),
            ),
            if (_puntos < 50)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Necesitas 50 puntos para canjear.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalog() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(
            top: 100,
            bottom: 120,
            left: 24,
            right: 24,
          ),
          children: [
            _buildHeroSection(),
            const SizedBox(height: 48),
            _buildSearchAndFilters(),
            const SizedBox(height: 48),
            _buildRewardsGrid(),
          ],
        ),
        _buildGlassAppBar(),
      ],
    );
  }

  Widget _buildGlassAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.white.withOpacity(0.8),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            bottom: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA2Zzi4ylBX1kv0mjWHSB-tEp5Zv44c8lB-JlmuZY7syhVSistsK4mgHAawaM4_dPINdbP5xokbhFNLQR3RJUF9y0iktgnc0eJe7fs9SHGv6j1IKrxVAaneuYqSiZN8AVG5CQfhnLXX1Z9I9SRKG2aPhXEt__g35c55iSdH4e7NZkAkxAxHhQUA1k4RtB8OUtKn7YcTfTBceN59mjbPxVRRzvBn4rD2_fcMy9IzNZAjHDkXFpvOqBpzu7-iYcm1b41XMxbTeRr-vA',
                    ),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Client Loyalty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: PrestigeColors.primaryContainer,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR REWARD CURRENCY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _puntos.toString(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'pts',
                style: TextStyle(
                  fontSize: 24,
                  color: PrestigeColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Elevate your lifestyle with curated experiences and premium products from our global concierge network.',
          style: TextStyle(
            fontSize: 14,
            color: PrestigeColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDFlbiw8tyQJvbJU04Yv1FO6RF0h4WYf16oPIPmiP3fPD5FqxBHQD0oeqpqeM54zjXSZtYvVyJuAbNa_N2UACUMqXjWWBksHZ5tDVl2UpZRc0O3wwBpEKb_zobs_6Ed96Cx8d60c7Q3r68DAN6NWj0DZpuSDSFV3QeIX0E_FGh5d1DRi7UqKjtlTfvhLSMYI2I4sHwvzC1dQKG9kQMq4i8R96vuDWEcbdCOWiYT-vfzXIpB90mUh5tZLjRRE-Zmy_1AC_EGvpj4YA',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  PrestigeColors.primaryContainer.withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PrestigeColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'FEATURED REWARD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PrestigeColors.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Expanded(
                      child: Text(
                        'The Amalfi Coast Getaway',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '25,000 pts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Rewards', true),
              const SizedBox(width: 12),
              _buildFilterChip('Travel', false),
              const SizedBox(width: 12),
              _buildFilterChip('Luxe Tech', false),
              const SizedBox(width: 12),
              _buildFilterChip('Dining', false),
              const SizedBox(width: 12),
              _buildFilterChip('Limited', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search catalog...',
            prefixIcon: const Icon(
              Icons.search,
              color: PrestigeColors.outlineVariant,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: PrestigeColors.outlineVariant),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: PrestigeColors.outlineVariant.withOpacity(0.5),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: PrestigeColors.secondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? PrestigeColors.primaryContainer
            : PrestigeColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : PrestigeColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildRewardsGrid() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 24,
      crossAxisSpacing: 16,
      childAspectRatio: 0.65,
      children: [
        _buildRewardCard(
          'Prestige Chronograph V1',
          '12,500 pts',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDM0QX3Q3pZ3eYT52DvC5RHSUjQSgHqcHMe_q6eLmwXPBbC9MjgTDFOlX3llhF4CyVPVpu6yCPx9I0Ajfeq41dLfYVsJ1Xe7IJAC2AV1e4rybcBlONRVZEtUYBfmKuqz34KJk1a50xWdByShoFwHguPURSZ1Z0LJbXTeLdFB1d3H-wwFxfhREZSiRmcyCAQJ9MFsq5Ji01Fqm-APyhoz9EiMfdp-c0jalhksqUeI4R2HcNF0OYc1oIHDWqC7IjuE4HZG9pLGhZ-Jw',
          tag: 'Luxe Tech',
          tagColor: PrestigeColors.primaryContainer.withOpacity(0.2),
          tagTextColor: PrestigeColors.primary,
        ),
        _buildRewardCard(
          'Masterclass: Artisan Brewing',
          '4,200 pts',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCPeb1qY-jZeZTE-gnMZf4q7mHAnVYmwJ2QanaBwT41X6KncgHG38CxUUnL-YNYBfbQ8-rU8SZH6FemR1-UENkzXMaK8hL0hgKh7hW17fy_7_puJ_HckKRJtPJAfcZ41gzGHQGF4G7Hs_sMuzyWkVGNm63uHvjWGdWkI6cd9cJwAFLc91wonakZwJ1wXj1OELwg2uElx8m-KDHN_rG3zPTUoR2IxIY1DDK69Fx6kQtV7RoFH6ha_0LTSl4WdTERe9ub71YmWH2T7w',
        ),
        _buildRewardCard(
          'Elite Audio Horizon S',
          '8,900 pts',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA0gS0UkLY0dXg94AipFVj8p6rjCq2rBvOGi00cQj5_NIbIay6MWE1Xyrwg0ZeLyazSQ8bvEU3JS0JkvX9m0dOWbhx9COIg8oBroi1P3NdhAXRmkOcsWc7dI6kxZeKnIXkyM8MZi_J5_4KWikmopYMOmt0SJxxatNARNijGtHAw1dGN8eYalgqlGWWzL6O6V76asC__xNEcCNJ-ada4PgbOUD2HFof61jMQciEAAEGWStD6I_J0ACf0x7m3zP5VZc2y37JPY8eX7A',
          tag: 'Low Stock',
          tagColor: const Color(0xFFFFDAD6),
          tagTextColor: const Color(0xFF93000A),
        ),
        _buildRewardCard(
          'Michelin Tasting Experience',
          '15,000 pts',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBwPMva_bzgp4r5vHwttE5M3_V43A8nRPk42fva-8J7TIYwC8QwMHaU-_RxAfpDVr9izS0pd9CTpfkmvWKmo7UUlJpUxZ8GCTJ48yFRNNfMUVDFXBJbVyKjmrkgSgcNr-QycLBq1yJR6JbnfW1UL67yJ_tlbPGwauA3qYa5le-dtmCss4oDs3yjGMSTb7m7fnVRBztCz7GDNyohabNp9DYyysg0Hjb93vY6AzFQFZawbqqfEXsfZ9UDHyB3Dv-20pMZSPp-SrwCGA',
        ),
      ],
    );
  }

  Widget _buildRewardCard(
    String title,
    String points,
    String imageUrl, {
    String? tag,
    Color? tagColor,
    Color? tagTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: PrestigeColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                if (tag != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    left: tag == 'Low Stock' ? 12 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              points,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFBA20),
                fontSize: 12,
              ),
            ),
            const Text(
              'VIEW DETAILS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16).copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(
                  1,
                  Icons.local_mall,
                  'Catalog',
                  isActiveStyle: true,
                ),
                _buildNavItem(2, Icons.receipt_long, 'History'),
                _buildNavItem(3, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    bool isActiveStyle = false,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (isActiveStyle
              ? PrestigeColors.primaryContainer
              : PrestigeColors.secondaryContainer)
        : Colors.grey;
    final textColor = isSelected
        ? (isActiveStyle ? Colors.white : PrestigeColors.primaryContainer)
        : Colors.grey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
              )
            : const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: _currentIndex == 1 ? _buildCatalog() : _buildDashboard(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

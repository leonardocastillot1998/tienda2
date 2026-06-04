import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'reward_details_page.dart';
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

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(authService: widget.authService),
      ),
      (route) => false,
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
            _buildWelcomeAndHero(),
            const SizedBox(height: 32),
            _buildQuickActionsGrid(),
            const SizedBox(height: 32),
            _buildRecentActivity(),
            const SizedBox(height: 32),
            _buildRecommendedReward(),
          ],
        ),
        _buildGlassAppBar(),
      ],
    );
  }

  Widget _buildWelcomeAndHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido, ${widget.username}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: PrestigeColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PrestigeColors.primary, PrestigeColors.primaryContainer],
            ),
            boxShadow: [
              BoxShadow(
                color: PrestigeColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT BALANCE',
                style: TextStyle(
                  color: PrestigeColors.secondaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_puntos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PTS',
                    style: TextStyle(
                      color: PrestigeColors.secondaryContainer,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Tier: Platinum',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '500 pts to go',
                    style: TextStyle(
                      color: PrestigeColors.secondaryContainer.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.8,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    PrestigeColors.secondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrestigeColors.secondaryContainer,
                  foregroundColor: PrestigeColors.onSecondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  elevation: 4,
                  shadowColor: PrestigeColors.secondaryContainer.withOpacity(
                    0.5,
                  ),
                ),
                onPressed: _puntos >= 50 ? () => _agregarPuntos(-50) : null,
                icon: const Icon(Icons.redeem, size: 20),
                label: const Text(
                  'Canjear premio (50 puntos)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              if (_puntos < 50)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Necesitas 50 puntos para canjear.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PrestigeColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PrestigeColors.outlineVariant.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore the Boutique',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: PrestigeColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover curated rewards from luxury tech to five-star escapes.',
                style: TextStyle(
                  fontSize: 14,
                  color: PrestigeColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: PrestigeColors.secondary,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => _agregarPuntos(10),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'GANAR 10 PUNTOS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PrestigeColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDEA8), // secondary-fixed
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: PrestigeColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Gold Member',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PrestigeColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Since October 2023',
                style: TextStyle(
                  fontSize: 14,
                  color: PrestigeColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.black12),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(
                    Icons.auto_awesome,
                    color: PrestigeColors.secondary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '3 EXCLUSIVE OFFERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: PrestigeColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: PrestigeColors.primary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: PrestigeColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: PrestigeColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                Icons.shopping_bag,
                'Signature Tech Bundle',
                'Redemption • 2 hours ago',
                '-1,200',
                true,
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildActivityItem(
                Icons.add_task,
                'Quarterly Bonus',
                'Reward • Yesterday',
                '+500',
                false,
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildActivityItem(
                Icons.restaurant,
                'Dining Experience',
                'Purchase Reward • Oct 12',
                '+150',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    String points,
    bool isNegative,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PrestigeColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: PrestigeColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: PrestigeColors.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PrestigeColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isNegative
                      ? const Color(0xFFBA1A1A)
                      : const Color(0xFF1A8A3D),
                ),
              ),
              const Text(
                'POINTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: PrestigeColors.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedReward() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Pick For You',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: PrestigeColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: PrestigeColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDK90Kt4WkhwDA4Mcz3DfaZlSh1EQtvFie_dQUdGkIrm3DFgEIRTpTG3zsWgTNHYFDtYNYR7ez6Xjmp6kJrjEUvbKMkSmpOq78eYa4YlnRgMdnGbjzetIjaRc7iqqi1ra_-VSmeUpKgsHcn1YAxeueAzVy4quCecc3E7fMDsbzzO1Qcwjbq32S6HEfPduLs-HSVDcxXIIgx84RJuZE-YCJX4-BMmeU0aj71g9BkNKT6vMyQ1AymXNr5cBXgCSqnBPni6FTcGkUMeA',
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: PrestigeColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'LIMITED OFFER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Retreat & Renew Spa Day',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: PrestigeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escape for a full day of curated wellness treatments at our flagship partner sanctuary.',
                      style: TextStyle(
                        fontSize: 14,
                        color: PrestigeColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'REDEMPTION VALUE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: PrestigeColors.onSurfaceVariant,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '1,800 ',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: PrestigeColors.secondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'pts',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: PrestigeColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: PrestigeColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client.from('productos').select(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Error loading catalog',
                style: TextStyle(color: PrestigeColors.onSurfaceVariant),
              ),
            ),
          );
        }

        final records = snapshot.data;
        if (records == null || records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No products available',
                style: TextStyle(color: PrestigeColors.onSurfaceVariant),
              ),
            ),
          );
        }

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65,
          children: records.map((product) {
            final title = product['title']?.toString() ?? 'Producto sin título';
            final points = '${product['points']?.toString() ?? '0'} pts';
            final imageUrl = product['image_url']?.toString() ?? '';
            final tag = product['tag']?.toString();

            return _buildRewardCard(
              title,
              points,
              imageUrl,
              tag: tag,
              tagColor: tag != null
                  ? PrestigeColors.primaryContainer.withOpacity(0.2)
                  : null,
              tagTextColor: tag != null ? PrestigeColors.primary : null,
              onTap: () {
                Navigator.of(context)
                    .push<int?>(
                      MaterialPageRoute(
                        builder: (context) =>
                            RewardDetailsPage(product: product),
                      ),
                    )
                    .then((newBalance) {
                      if (!mounted || newBalance == null) {
                        return;
                      }

                      setState(() {
                        _puntos = newBalance;
                      });
                    });
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRewardCard(
    String title,
    String points,
    String imageUrl, {
    String? tag,
    Color? tagColor,
    Color? tagTextColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Ensures tap covers the whole area
        child: Column(
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
        ),
      ),
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
        ? PrestigeColors.primaryContainer
        : Colors.transparent;
    final textColor = isSelected ? Colors.white : Colors.grey;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBody() {
      if (_currentIndex == 1) return _buildCatalog();
      if (_currentIndex == 2) return const HistoryPage();
      if (_currentIndex == 3) {
        return ProfilePage(
          username: widget.username,
          authService: widget.authService,
        );
      }
      return _buildDashboard();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

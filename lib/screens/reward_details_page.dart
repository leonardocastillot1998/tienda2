import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/prestige_theme.dart';

class RewardDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const RewardDetailsPage({super.key, required this.product});

  @override
  State<RewardDetailsPage> createState() => _RewardDetailsPageState();
}

class _RewardDetailsPageState extends State<RewardDetailsPage> {
  bool _isLoading = false;
  int _userPoints = 0;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    final session = await AuthService().checkSavedSession();
    if (session != null) {
      final profile = await AuthService().getUserProfile(session.username);
      if (profile != null && mounted) {
        setState(() {
          _username = session.username;
          _userPoints = profile['points'] ?? 0;
        });
      }
    }
  }

  Future<void> _handleRedeem() async {
    final cost = widget.product['points'] as int? ?? 0;

    if (_userPoints >= cost) {
      setState(() => _isLoading = true);

      final newPoints = _userPoints - cost;
      await AuthService().savePoints(username: _username, points: newPoints);

      setState(() {
        _userPoints = newPoints;
        _isLoading = false;
      });

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Redeemed Successfully!'),
          content: Text(
            'You have successfully redeemed ${widget.product['title']}. It will be shipped soon.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true); // Return generic success
              },
              child: const Text(
                'OK',
                style: TextStyle(color: PrestigeColors.secondaryContainer),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Insufficient Points'),
          content: const Text(
            'You do not have enough points to redeem this item.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: PrestigeColors.secondaryContainer),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _confirmRedeem() async {
    final cost = widget.product['points'] as int? ?? 0;

    if (!mounted) return;

    final shouldRedeem = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar canje'),
        content: Text(
          'Vas a canjear ${widget.product['title'] ?? 'esta recompensa'} por $cost puntos. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PrestigeColors.secondaryContainer,
              foregroundColor: PrestigeColors.onSecondaryContainer,
            ),
            child: const Text('Canjear'),
          ),
        ],
      ),
    );

    if (shouldRedeem == true) {
      await _handleRedeem();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product['title']?.toString() ?? 'Unknown Product';
    final pointsCost = widget.product['points'] as int? ?? 0;
    final imageUrl = widget.product['image_url']?.toString() ?? '';
    final tag = widget.product['tag']?.toString();
    final description =
        widget.product['description']?.toString() ??
        'A masterpiece of precision engineering and timeless design. The Chronograph Prestige Edition blends classic aesthetics with modern horological advancements, ensuring unparalleled accuracy.';

    return Scaffold(
      backgroundColor: PrestigeColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: PrestigeColors.primaryContainer,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Reward Details',
          style: TextStyle(
            color: PrestigeColors.primaryContainer,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: PrestigeColors.primaryContainer,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image Hero
            Container(
              decoration: BoxDecoration(
                color: PrestigeColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1, // Square or adjust based on design
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(color: Colors.grey.shade200),
                    ),
                  ),
                  if (tag != null && tag.isNotEmpty)
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details Section
            const Text(
              'Catalog > Timepieces',
              style: TextStyle(
                color: PrestigeColors.onSurfaceVariant,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: PrestigeColors.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Aura Horology', // Subtitle placeholder
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: PrestigeColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Points Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PrestigeColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: PrestigeColors.outlineVariant.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'POINTS REQUIRED',
                        style: TextStyle(
                          color: PrestigeColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Your Balance: $_userPoints pts',
                        style: const TextStyle(
                          color: PrestigeColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        pointsCost.toString(),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: PrestigeColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'pts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: PrestigeColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: PrestigeColors.onSurface,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Features
            const Divider(color: Colors.black12),
            const SizedBox(height: 16),
            _buildFeatureRow(
              'Movement:',
              'Automatic Swiss-made caliber with 48-hour power reserve.',
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              'Case:',
              '42mm surgical-grade stainless steel with polished bevels.',
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              'Crystal:',
              'Domed sapphire with anti-reflective coating.',
            ),
            const SizedBox(height: 48),

            // Redeem Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrestigeColors.secondaryContainer,
                  foregroundColor: PrestigeColors.onSecondaryContainer,
                  elevation: 8,
                  shadowColor: PrestigeColors.secondaryContainer.withOpacity(
                    0.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isLoading ? null : _confirmRedeem,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: PrestigeColors.onSecondaryContainer,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Redeem Now',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Free insured shipping included. Expected delivery: 3-5 business days.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PrestigeColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          size: 20,
          color: PrestigeColors.secondaryContainer,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: PrestigeColors.onSurface,
                fontSize: 14,
                fontFamily: 'Inter',
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/prestige_theme.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final AuthService authService;

  const ProfilePage({
    super.key,
    required this.username,
    required this.authService,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int _points = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileData = await widget.authService.getUserProfile(
      widget.username,
    );
    if (profileData != null && mounted) {
      setState(() {
        _nameController.text = profileData['nombre_completo'] ?? '';
        _emailController.text = profileData['email'] ?? '';
        _phoneController.text = profileData['numero_de_telefono'] ?? '';
        _dobController.text = profileData['fecha_de_nacimiento'] ?? '';
        _addressController.text = profileData['address'] ?? '';
        _points = profileData['points'] ?? 0;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    final success = await widget.authService.updateUserProfile(
      username: widget.username,
      nombreCompleto: _nameController.text,
      email: _emailController.text,
      telefono: _phoneController.text,
      fechaNacimiento: _dobController.text,
      address: _addressController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile updated successfully'
                : 'Failed to update profile',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrestigeColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.06),
        title: Text(
          'Client Loyalty',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: const Color(0xFF0A192F),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0A192F)),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24.0, left: 8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PrestigeColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: PrestigeColors.secondaryContainer,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: PrestigeColors.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 896), // max-w-4xl
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Profile',
                        style: GoogleFonts.manrope(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          color: PrestigeColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 40),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 800;
                          if (isDesktop) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 4, child: _buildLeftColumn()),
                                const SizedBox(width: 32),
                                Expanded(flex: 8, child: _buildRightColumn()),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _buildLeftColumn(),
                              const SizedBox(height: 32),
                              _buildRightColumn(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 100), // Bottom padding for nav
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: PrestigeColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 64,
                    offset: const Offset(0, 32),
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: PrestigeColors.primaryContainer,
                ),
              ),
            ),
            Positioned(
              bottom: -16,
              right: -16,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PrestigeColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: PrestigeColors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PrestigeColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                'AVAILABLE POINTS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: PrestigeColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_points',
                    style: GoogleFonts.manrope(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: PrestigeColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PTS',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: PrestigeColors.secondary,
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

  Widget _buildRightColumn() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: PrestigeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 64,
            offset: const Offset(0, 32),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildFormField('FULL NAME', _nameController),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildFormField('EMAIL ADDRESS', _emailController),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _buildFormField('FULL NAME', _nameController),
                  const SizedBox(height: 32),
                  _buildFormField('EMAIL ADDRESS', _emailController),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildFormField('PHONE NUMBER', _phoneController),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildFormField('DATE OF BIRTH', _dobController),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _buildFormField('PHONE NUMBER', _phoneController),
                  const SizedBox(height: 32),
                  _buildFormField('DATE OF BIRTH', _dobController),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          _buildFormField('MAILING ADDRESS', _addressController),
          const SizedBox(height: 32),
          ResponsiveButtons(onSave: _saveProfile, onDiscard: _loadProfile),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: PrestigeColors.onSurfaceVariant,
            ),
          ),
        ),
        TextField(
          controller: controller,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PrestigeColors.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 4,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: PrestigeColors.outlineVariant.withOpacity(0.2),
                width: 2,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: PrestigeColors.outlineVariant.withOpacity(0.2),
                width: 2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: PrestigeColors.secondaryContainer,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ResponsiveButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const ResponsiveButtons({
    super.key,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrestigeColors.secondaryContainer,
                    foregroundColor: PrestigeColors.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save Changes',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.check_circle_outline),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: onDiscard,
                style: TextButton.styleFrom(
                  backgroundColor: PrestigeColors.surfaceContainerLow,
                  foregroundColor: PrestigeColors.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  'Discard',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: PrestigeColors.secondaryContainer,
                foregroundColor: PrestigeColors.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save Changes',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle_outline),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onDiscard,
              style: TextButton.styleFrom(
                backgroundColor: PrestigeColors.surfaceContainerLow,
                foregroundColor: PrestigeColors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Discard',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

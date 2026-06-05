import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/prestige_theme.dart';
import '../services/auth_service.dart';

// Loads history entries saved locally per user and displays them.

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _entries = [];
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final session = await AuthService().checkSavedSession();
    if (session == null) return;

    _username = session.username;
    final entries = await AuthService().getHistory(_username);
    if (mounted) {
      setState(() {
        _entries = entries;
      });
    }
  }

  Future<void> _clearHistory() async {
    if (_username.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar historial'),
          content: const Text(
            'Esta acción eliminará todas las entradas del historial de forma permanente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await AuthService().clearHistory(_username);
    if (!mounted) return;

    setState(() {
      _entries = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial borrado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrestigeColors.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: PrestigeColors.surface.withOpacity(0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: PrestigeColors.primaryContainer.withOpacity(0.1),
                  height: 1.0,
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: PrestigeColors.primaryContainer,
                ),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              centerTitle: true,
              title: Text(
                'History',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: PrestigeColors.primaryContainer,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: PrestigeColors.primaryContainer,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: 'Borrar historial',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: PrestigeColors.primaryContainer,
                  ),
                  onPressed: _entries.isEmpty ? null : _clearHistory,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: kToolbarHeight + 32,
          left: 24,
          right: 24,
          bottom: 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              'Your Ledger'.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: PrestigeColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Redemption History',
              style: GoogleFonts.manrope(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: PrestigeColors.primaryContainer,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),

            // History List (dynamic)
            if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'No hay entradas en el historial aún.',
                  style: GoogleFonts.manrope(
                    color: PrestigeColors.onSurfaceVariant,
                  ),
                ),
              )
            else
              ..._entries.map((e) {
                final date = e['date']?.toString() ?? '';
                final dateStr = date.isNotEmpty
                    ? DateTime.tryParse(
                        date,
                      )?.toLocal().toString().split(' ').first
                    : '';

                return Column(
                  children: [
                    _buildHistoryItem(
                      status: e['status']?.toString() ?? 'Confirmed',
                      date: dateStr ?? '',
                      title: e['title']?.toString() ?? '',
                      description: e['description']?.toString() ?? '',
                      pointsSpent: e['pointsSpent']?.toString() ?? '',
                      imageSource: _extractImageSource(e),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),

            const SizedBox(height: 32),

            if (_entries.isNotEmpty)
              Center(
                child: OutlinedButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Borrar historial completo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),

            if (_entries.isNotEmpty) const SizedBox(height: 16),

            // Load Older History Button
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: PrestigeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: PrestigeColors.outlineVariant.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Load Older History',
                      style: GoogleFonts.inter(
                        color: PrestigeColors.primaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String status,
    required String date,
    required String title,
    required String description,
    required String pointsSpent,
    String? imageSource,
    bool isIconFallback = false,
    IconData? fallbackIcon,
    Color? statusColor,
    Color? statusBgColor,
    Color? statusBorderColor,
    IconData? statusIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: PrestigeColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Main content (Image + Details)
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image/Icon Container
                  Container(
                    width: isMobile ? double.infinity : 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: PrestigeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isIconFallback
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  PrestigeColors.primary,
                                  PrestigeColors.primaryContainer,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                fallbackIcon,
                                color: PrestigeColors.surface,
                                size: 48,
                              ),
                            ),
                          )
                        : _buildImageWidget(imageSource),
                  ),

                  SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 16 : 0),

                  // Details
                  isMobile
                      ? _buildDetailsCol(
                          date,
                          title,
                          description,
                          pointsSpent,
                          isMobile,
                        )
                      : Expanded(
                          child: _buildDetailsCol(
                            date,
                            title,
                            description,
                            pointsSpent,
                            isMobile,
                          ),
                        ),
                ],
              ),

              // Status Chip (Absolute Positioned)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor ?? PrestigeColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          statusBorderColor ??
                          PrestigeColors.outlineVariant.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusIcon != null) ...[
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor ?? PrestigeColors.primaryContainer,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor ?? PrestigeColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailsCol(
    String date,
    String title,
    String description,
    String pointsSpent,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          date,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: PrestigeColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: PrestigeColors.primaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: PrestigeColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POINTS SPENT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PrestigeColors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              pointsSpent,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PrestigeColors.primaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _extractImageSource(Map<String, dynamic> entry) {
    final candidates = [
      entry['imageUrl'],
      entry['imageData'],
      entry['image_url'],
      entry['imageSource'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  Widget _buildImageWidget(String? imageSource) {
    if (imageSource == null || imageSource.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PrestigeColors.primary, PrestigeColors.primaryContainer],
          ),
        ),
        child: const Center(
          child: Icon(Icons.image, color: PrestigeColors.surface, size: 48),
        ),
      );
    }

    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PrestigeColors.primary,
                  PrestigeColors.primaryContainer,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: PrestigeColors.surface,
                size: 48,
              ),
            ),
          );
        },
      );
    }

    try {
      final normalized = imageSource.startsWith('data:')
          ? imageSource.split(',').last
          : imageSource;

      return Image.memory(
        base64Decode(normalized),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PrestigeColors.primary,
                  PrestigeColors.primaryContainer,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: PrestigeColors.surface,
                size: 48,
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PrestigeColors.primary, PrestigeColors.primaryContainer],
          ),
        ),
        child: const Center(
          child: Icon(Icons.error, color: PrestigeColors.surface, size: 48),
        ),
      );
    }
  }
}

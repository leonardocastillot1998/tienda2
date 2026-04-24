import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/prestige_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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
                  // Usually back button doesn't do much in a tab, but we keep it for visual fidelity
                  if (Navigator.canPop(context)) {
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

            // History List
            _buildHistoryItem(
              status: 'Delivered',
              date: 'Oct 12, 2023',
              title: 'Chronograph Prestige Edition',
              description:
                  'Exclusive Swiss-made timepiece from the Artisan Collection.',
              pointsSpent: '-125,000 pts',
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDWqrL3VREt_PSwGLEmawYzY-1mAeFQUWGWxXpklJMqBC9wOsWNYg802M6WGjojdbj8EG4_D5_SFUOKMidUs7ee0m20HnKmMZefgoeW3mS0_yH8E8cJJnN3YOOJqAvTAP-ULqLpX_nx9q9DSGZctdyQ_90UtYJN1xiH-guTl1GVNzZy96WgHNI-I6yrIv_jH1wCr41EuVvY29I_iz1PwVbWfB77p9nZJgjzDn5IAywsTQLdMFNSNSzUlXRGtDpfVFQC1O_hGa-QpA',
            ),
            const SizedBox(height: 24),

            _buildHistoryItem(
              status: 'Processing',
              date: 'Nov 04, 2023',
              title: 'Weekend Retreat for Two',
              description:
                  'A curated 2-night stay at the Azure Coastal Resort including spa access.',
              pointsSpent: '-45,000 pts',
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDPSuKTH_EDoqez-1rmTRkuuPxVSSmYYPllI4c2en3ILnJULx--8giSaZMn-m4j0lmbagSAlIumq6wh4kZIAkvy3Hwvub-CmKUtJwbFr0fQUO4qsgJDHivuX1DRjUvK37a0-q-PkwuD_97AIsXSfYtO6m0hiFMuST0Qk22vu1yL3S7XBPySbRZBNCcMIk7cYBHFYJUtraclfGAPl4Fb46P3dtI1RG8trU_kskq8rwRSS7PvkMP9_UNxG4VSD0eHM5uBqk5toSvZGQ',
              statusColor: PrestigeColors.secondaryContainer,
              statusBgColor: const Color(
                0xFFFFDEA8,
              ).withOpacity(0.2), // secondary-fixed/20
              statusBorderColor: const Color(0xFFFFDEA8), // secondary-fixed
              statusIcon: Icons.sync,
            ),
            const SizedBox(height: 24),

            _buildHistoryItem(
              status: 'Confirmed',
              date: 'Nov 15, 2023',
              title: 'Chef\'s Tasting Menu',
              description:
                  'Exclusive dining experience at L\'Orangerie featuring a 7-course seasonal menu.',
              pointsSpent: '-15,000 pts',
              isIconFallback: true,
              fallbackIcon: Icons.restaurant,
            ),

            const SizedBox(height: 32),

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
    String? imageUrl,
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
                        : Image.network(
                            imageUrl ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                      : null,
                                  color: PrestigeColors.primaryContainer,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error));
                            },
                          ),
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
}

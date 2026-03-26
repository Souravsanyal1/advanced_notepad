import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../widgets/loading_widget.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 10, end: 40).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String cryptoAddress = '0x48de9a54c2a69aac138dce2afc2da0e7c9437ec9';
    const String binanceId = '549323070';

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> networks = [
      {
        'name': 'BSC',
        'symbol': 'BNB',
        'color': const Color(0xFFF3BA2F),
        'logo': 'https://cryptologos.cc/logos/binance-coin-bnb-logo.png?v=040'
      },
      {
        'name': 'Optimism',
        'symbol': 'OP',
        'color': const Color(0xFFFF0420),
        'logo': 'https://cryptologos.cc/logos/optimism-ethereum-op-logo.png?v=040'
      },
      {
        'name': 'Ethereum',
        'symbol': 'ETH',
        'color': const Color(0xFF627EEA),
        'logo': 'https://cryptologos.cc/logos/ethereum-eth-logo.png?v=040'
      },
      {
        'name': 'Aptos',
        'symbol': 'APT',
        'color': const Color(0xFF2DD4BF),
        'logo': 'https://cryptologos.cc/logos/aptos-apt-logo.png?v=040'
      },
      {
        'name': 'Polygon',
        'symbol': 'POL',
        'color': const Color(0xFF8247E5),
        'logo': 'https://cryptologos.cc/logos/polygon-matic-logo.png?v=040'
      },
      {
        'name': 'Solana',
        'symbol': 'SOL',
        'color': const Color(0xFF14F195),
        'logo': 'https://cryptologos.cc/logos/solana-sol-logo.png?v=040'
      },
      {
        'name': 'opBNB',
        'symbol': 'BNB',
        'color': const Color(0xFFF3BA2F),
        'logo': 'https://cryptologos.cc/logos/binance-coin-bnb-logo.png?v=040'
      },
      {
        'name': 'Arbitrum',
        'symbol': 'ARB',
        'color': const Color(0xFF28A0F0),
        'logo': 'https://cryptologos.cc/logos/arbitrum-arb-logo.png?v=040'
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Support Us',
          style: GoogleFonts.outfit(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF0F0C29),
                    const Color(0xFF302B63),
                    const Color(0xFF24243E),
                  ]
                : [
                    const Color(0xFFF3E5F5),
                    const Color(0xFFE1BEE7),
                    const Color(0xFFD1C4E9),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Animated Heart Icon (Pulsing)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDarkMode ? Colors.white : Colors.deepPurple).withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: isDarkMode ? 0.2 : 0.15),
                              blurRadius: _glowAnimation.value,
                              spreadRadius: _glowAnimation.value / 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.redAccent.withValues(alpha: 0.8 + (0.2 * _pulseController.value)),
                          size: 80,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  'Enjoying Advanced Notepad?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your support helps us maintain and improve the app. We accept donations via multiple crypto networks.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Networks Grid
                Wrap(
                  spacing: 20,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: networks
                      .map((net) => _buildTokenIcon(
                          net['name'], net['symbol'], net['color'], net['logo'], isDarkMode))
                      .toList(),
                ),

                const SizedBox(height: 40),

                // Wallet Address Card (Glassmorphism)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: isDarkMode ? 0.05 : 0.02),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: isDarkMode ? 0.1 : 0.05),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet_rounded,
                                  color: isDarkMode ? Colors.blueAccent : Colors.blue, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Wallet Address',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: (isDarkMode ? Colors.black : Colors.white).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cryptoAddress,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy_rounded,
                                      color: isDarkMode ? Colors.white70 : Colors.black54, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(const ClipboardData(text: cryptoAddress));
                                    HapticFeedback.lightImpact();
                                    Get.snackbar(
                                      'Copied!',
                                      'Wallet Address copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
                                      colorText: colorScheme.onSurface,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Icon(Icons.qr_code_2_rounded,
                                  color: isDarkMode ? Colors.orangeAccent : Colors.orange, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Binance ID',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: (isDarkMode ? Colors.black : Colors.white).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    binanceId,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy_rounded,
                                      color: isDarkMode ? Colors.white70 : Colors.black54, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(const ClipboardData(text: binanceId));
                                    HapticFeedback.lightImpact();
                                    Get.snackbar(
                                      'Copied!',
                                      'Binance ID copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
                                      colorText: colorScheme.onSurface,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Why Support Us Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why Support Us?',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSupportPoint(
                      Icons.update_rounded,
                      'Regular Updates',
                      'We constantly improve features and fix bugs.',
                      isDarkMode,
                    ),
                    _buildSupportPoint(
                      Icons.security_rounded,
                      'Privacy Focused',
                      'No ads, no trackers, just your notes.',
                      isDarkMode,
                    ),
                    _buildSupportPoint(
                      Icons.code_rounded,
                      'Open Source Support',
                      'Help maintain the server and infrastructure.',
                      isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  'Thanks for being part of our journey!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenIcon(String name, String symbol, Color color, String logoUrl, bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: logoUrl,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: AppLoadingWidget(
                  size: 24,
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(
                  symbol,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '($symbol)',
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: isDarkMode ? Colors.white38 : Colors.black38,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportPoint(IconData icon, String title, String desc, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

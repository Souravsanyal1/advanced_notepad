import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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

    final List<Map<String, dynamic>> networks = [
      {'name': 'BSC', 'symbol': 'BNB', 'color': const Color(0xFFF3BA2F)},
      {'name': 'Optimism', 'symbol': 'OP', 'color': const Color(0xFFFF0420)},
      {'name': 'Ethereum', 'symbol': 'ETH', 'color': const Color(0xFF627EEA)},
      {'name': 'Aptos', 'symbol': 'APT', 'color': const Color(0xFF2DD4BF)},
      {'name': 'Polygon', 'symbol': 'POL', 'color': const Color(0xFF8247E5)},
      {'name': 'Solana', 'symbol': 'SOL', 'color': const Color(0xFF14F195)},
      {'name': 'opBNB', 'symbol': 'BNB', 'color': const Color(0xFFF3BA2F)},
      {'name': 'Arbitrum', 'symbol': 'ARB', 'color': const Color(0xFF28A0F0)},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Support Us',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
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
                          color: Colors.white.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.2),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your support helps us maintain and improve the app. We accept donations via multiple crypto networks.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Networks Grid
                Wrap(
                  spacing: 16,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: networks.map((net) => _buildTokenIcon(net['name'], net['symbol'], net['color'])).toList(),
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
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_rounded, color: Colors.blueAccent, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Wallet Address',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cryptoAddress,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(const ClipboardData(text: cryptoAddress));
                                    HapticFeedback.lightImpact();
                                    Get.snackbar(
                                      'Copied!',
                                      'Wallet Address copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                                      colorText: Colors.white,
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
                              const Icon(Icons.qr_code_2_rounded, color: Colors.orangeAccent, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Binance ID',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
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
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(const ClipboardData(text: binanceId));
                                    HapticFeedback.lightImpact();
                                    Get.snackbar(
                                      'Copied!',
                                      'Binance ID copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                                      colorText: Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSupportPoint(
                      Icons.update_rounded,
                      'Regular Updates',
                      'We constantly improve features and fix bugs.',
                    ),
                    _buildSupportPoint(
                      Icons.security_rounded,
                      'Privacy Focused',
                      'No ads, no trackers, just your notes.',
                    ),
                    _buildSupportPoint(
                      Icons.code_rounded,
                      'Open Source Support',
                      'Help maintain the server and infrastructure.',
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  'Thanks for being part of our journey!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white38,
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

  Widget _buildTokenIcon(String name, String symbol, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              symbol,
              style: GoogleFonts.outfit(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportPoint(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white60,
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

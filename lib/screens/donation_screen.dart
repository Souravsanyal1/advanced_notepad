import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/loading_widget.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 10, end: 30).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String cryptoAddress = '0x48de9a54c2a69aac138dce2afc2da0e7c9437ec9';
    const String binanceId = '549323070';

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> networks = [
      {'name': 'BSC', 'symbol': 'BNB', 'logo': 'https://cryptologos.cc/logos/binance-coin-bnb-logo.png?v=040'},
      {'name': 'Optimism', 'symbol': 'OP', 'logo': 'https://cryptologos.cc/logos/optimism-ethereum-op-logo.png?v=040'},
      {'name': 'Ethereum', 'symbol': 'ETH', 'logo': 'https://cryptologos.cc/logos/ethereum-eth-logo.png?v=040'},
      {'name': 'Aptos', 'symbol': 'APT', 'logo': 'https://cryptologos.cc/logos/aptos-apt-logo.png?v=040'},
      {'name': 'Polygon', 'symbol': 'POL', 'logo': 'https://cryptologos.cc/logos/polygon-matic-logo.png?v=040'},
      {'name': 'Solana', 'symbol': 'SOL', 'logo': 'https://cryptologos.cc/logos/solana-sol-logo.png?v=040'},
      {'name': 'opBNB', 'symbol': 'BNB', 'logo': 'https://cryptologos.cc/logos/binance-coin-bnb-logo.png?v=040'},
      {'name': 'Arbitrum', 'symbol': 'ARB', 'logo': 'https://cryptologos.cc/logos/arbitrum-arb-logo.png?v=040'},
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
        title: Text('SUPPORT US', style: GoogleFonts.outfit(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        )),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDarkMode ? Colors.black : Colors.white,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        RotationTransition(
                          turns: _rotationController,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.black,
                                  Colors.grey,
                                  Colors.white,
                                  Colors.grey,
                                  Colors.black,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
                                      blurRadius: _glowAnimation.value,
                                      spreadRadius: _glowAnimation.value / 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  size: 60,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'FUEL THE INNOVATION',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your support keeps our advanced features free and open for everyone. Join us in building the next generation of note-taking.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.6),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: networks.length,
                      itemBuilder: (context, index) {
                        return _buildMonochromeToken(networks[index], isDarkMode);
                      },
                    ),
                    const SizedBox(height: 40),
                    _buildAddressCard('WALLET ADDRESS', cryptoAddress, Icons.account_balance_wallet_rounded, isDarkMode),
                    const SizedBox(height: 20),
                    _buildAddressCard('BINANCE ID', binanceId, Icons.qr_code_scanner_rounded, isDarkMode),
                    const SizedBox(height: 40),
                    _buildFeaturePoints(isDarkMode),
                    const SizedBox(height: 40),
                    Text(
                      'PREMIUM EXPERIENCE • ZERO ADS',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonochromeToken(Map<String, dynamic> token, bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1)),
          ),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: CachedNetworkImage(
              imageUrl: token['logo'],
              placeholder: (context, url) => const AppLoadingWidget(size: 15),
              errorWidget: (context, url, error) => const Icon(Icons.token_rounded),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(token['symbol'], style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        )),
      ],
    );
  }

  Widget _buildAddressCard(String label, String value, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.4)),
              const SizedBox(width: 10),
              Text(label, style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.4),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(value, style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                )),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Get.snackbar('COPIED', '$label COPIED TO CLIPBOARD', 
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                    colorText: isDarkMode ? Colors.black : Colors.white,
                    margin: const EdgeInsets.all(20),
                    borderRadius: 10,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePoints(bool isDarkMode) {
    final points = [
      {'icon': Icons.bolt_rounded, 'title': 'LATEST TECH', 'desc': 'Built with cutting-edge Flutter tools.'},
      {'icon': Icons.security_rounded, 'title': 'ULTRA SECURE', 'desc': 'Locally encrypted and cloud synced.'},
      {'icon': Icons.palette_rounded, 'title': 'ELITE DESIGN', 'desc': 'Crafted for productivity and style.'},
    ];

    return Column(
      children: points.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(p['icon'] as IconData, size: 24, color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['title'] as String, style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
                  const SizedBox(height: 4),
                  Text(p['desc'] as String, style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.5),
                  )),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

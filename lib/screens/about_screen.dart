import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Information', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple, Colors.pink],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/logo.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Advanced Notepad',
                      style: GoogleFonts.outfit(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.deepPurple[800],
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Version 1.0.1+2',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    _buildPremiumCard(
                      context,
                      title: 'Our Mission',
                      content: 'To provide a seamless, beautiful, and powerful note-taking experience that keeps your thoughts organized and accessible locally on your device.',
                      icon: Icons.lightbulb_rounded,
                      iconColor: Colors.amber,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildPremiumCard(
                      context,
                      title: 'Premium Features',
                      content: 'Offline-first architecture, local image attachments, advanced gallery access, modern staggered UI, and personalized user profiles.',
                      icon: Icons.auto_awesome_rounded,
                      iconColor: Colors.blueAccent,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildPremiumCard(
                      context,
                      title: 'Developed By',
                      content: 'Built with ❤️ by Sourav Sanyal for the modern thinker.',
                      icon: Icons.code_rounded,
                      iconColor: Colors.greenAccent,
                      onTap: () => Navigator.pushNamed(context, '/developer-info'),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    Text(
                      '© 2026 Advanced Notepad',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'All rights reserved.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white24 : Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, {
    required String title, 
    required String content, 
    required IconData icon, 
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: isDarkMode ? 0.05 : 0.03),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              height: 1.5,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          if (onTap != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Meet Creator',
                                    style: GoogleFonts.outfit(
                                      color: isDarkMode ? iconColor : Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded, 
                                    size: 10, 
                                    color: isDarkMode ? iconColor : Colors.deepPurple
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

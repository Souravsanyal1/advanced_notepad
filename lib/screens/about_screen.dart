import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Hero(
              tag: 'app_logo',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/logo.png'),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Advanced Notepad',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0+1',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              context,
              title: 'Our Mission',
              content: 'To provide a seamless, beautiful, and powerful note-taking experience that keeps your thoughts organized and synchronized across the cloud.',
              icon: Icons.lightbulb_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Premium Features',
              content: 'Real-time Firebase sync, Cloudinary image attachments, modern staggered UI, and personalized user profiles.',
              icon: Icons.star_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Developed By',
              content: 'Built with ❤️ by Sourav Sanyal for the modern thinker.',
              icon: Icons.code,
            ),
            const SizedBox(height: 48),
            Text(
              '© 2026 Advanced Notepad. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String content, required IconData icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

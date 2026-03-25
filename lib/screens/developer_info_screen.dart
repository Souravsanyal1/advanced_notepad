import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DeveloperInfoScreen extends StatefulWidget {
  const DeveloperInfoScreen({super.key});

  @override
  State<DeveloperInfoScreen> createState() => _DeveloperInfoScreenState();
}

class _DeveloperInfoScreenState extends State<DeveloperInfoScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 1.0),
                      theme.colorScheme.secondary.withValues(alpha: 0.9),
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Moving ambient blobs for a modern look
                    _buildAmbientBlob(theme, 160, -20, -40, Colors.white.withValues(alpha: 0.1)),
                    _buildAmbientBlob(theme, 120, 100, 200, theme.colorScheme.secondary.withValues(alpha: 0.1)),
                    
                    // Static Rainbow Border
                    Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Color(0xFF833AB4), Color(0xFFC13584), Color(0xFFE1306C),
                            Color(0xFFFD1D1D), Color(0xFFF56040), Color(0xFFF77737),
                            Color(0xFFFCB045), Color(0xFFFFDC80), Color(0xFF833AB4),
                          ],
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'dev_avatar',
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            )
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/dev_photo.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Skills'),
                  Tab(text: 'Socials'),
                ],
              ),
              theme.colorScheme.surface,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(theme),
            _buildSkillsTab(theme),
            _buildSocialsTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientBlob(ThemeData theme, double size, double top, double left, Color color) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAboutTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 500),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              Text(
                'Sourav Sanyal',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Full-Stack Flutter Developer',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                theme,
                title: 'BIO',
                content: 'A passionate software engineer specializing in building high-performance, beautiful, and user-centric mobile applications using Flutter and Firebase. I love creating seamless experiences that delight users and solve real-world problems through clean code and modern architecture.',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard(theme, 'Experience', '4+ Years')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(theme, 'Projects', '50+')),
                ],
              ),
              const SizedBox(height: 40),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsTab(ThemeData theme) {
    final skills = [
      {'name': 'Flutter', 'icon': Icons.bolt, 'color': Colors.blue},
      {'name': 'Dart', 'icon': Icons.code, 'color': Colors.cyan},
      {'name': 'Firebase', 'icon': Icons.cloud, 'color': Colors.orange},
      {'name': 'Node.js', 'icon': Icons.javascript, 'color': Colors.green},
      {'name': 'UI/UX Design', 'icon': Icons.brush, 'color': Colors.pink},
      {'name': 'Git/GitHub', 'icon': Icons.hub, 'color': Colors.black},
      {'name': 'REST API', 'icon': Icons.api, 'color': Colors.purple},
      {'name': 'State Mgmt', 'icon': Icons.layers, 'color': Colors.indigo},
    ];

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Technical Expertise',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Icon(skill['icon'] as IconData, color: skill['color'] as Color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                skill['name'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialsTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 500),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildSocialTile(
                theme,
                icon: Icons.alternate_email_rounded,
                label: 'Email',
                value: 'sourav.sanyal.dev@gmail.com',
                gradient: const [Color(0xFFEA4335), Color(0xFFC5221F)],
                onTap: () => _launchURL('mailto:sourav.sanyal.dev@gmail.com?subject=Advanced%20Notepad%20Feedback'),
              ),
              _buildSocialTile(
                theme,
                icon: Icons.code_rounded,
                label: 'GitHub',
                value: 'github.com/Souravsanyal1',
                gradient: const [Color(0xFF24292E), Color(0xFF404448)],
                onTap: () => _launchURL('https://github.com/Souravsanyal1'),
              ),
              _buildSocialTile(
                theme,
                icon: Icons.language_rounded,
                label: 'Portfolio',
                value: 'sourav-sanyal.pro.bd',
                gradient: const [Color(0xFF4285F4), Color(0xFF34A853)],
                onTap: () => _launchURL('https://sourav-sanyal.pro.bd'),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                theme,
                title: 'COLLABORATION',
                content: 'Interesed in working together? Feel free to reach out for projects, consultations, or just a tech chat! I\'m always open to discussing new ideas and opportunities.',
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, {required String title, required String content, Color? backgroundColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2.0, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 12),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.8, color: theme.colorScheme.onSurface, letterSpacing: 0.2)),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSocialTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.w500)),
                    Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Text('Crafted with passion using', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on, size: 18, color: Color(0xFF4285F4)),
                const SizedBox(width: 8),
                Text('Flutter & Firebase', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.child, this.backgroundColor);

  final Widget child;
  final Color backgroundColor;

  @override
  double get minExtent {
    if (child is PreferredSizeWidget) {
      return (child as PreferredSizeWidget).preferredSize.height;
    }
    return 48; // Default fallback
  }

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: shrinkOffset > 0 ? 0.3 : 0.0),
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

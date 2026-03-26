import 'package:flutter/material.dart';
import 'dart:ui';

class PremiumFab extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const PremiumFab({
    super.key,
    required this.onTap,
    required this.label,
  });

  @override
  State<PremiumFab> createState() => _PremiumFabState();
}

class _PremiumFabState extends State<PremiumFab> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Chrome Aura
            RotationTransition(
              turns: _rotationController,
              child: Container(
                height: 64,
                width: 169,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF666666),
                      Color(0xFFFFFFFF),
                      Color(0xFF666666),
                      Color(0xFF000000),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 60,
              width: 165,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isDark ? Colors.black : Colors.white,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFE5E5E5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: isDark ? Colors.white : Colors.black,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.label.toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
}

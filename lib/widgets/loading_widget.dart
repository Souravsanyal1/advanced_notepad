import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingWidget({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LoadingAnimationWidget.threeRotatingDots(
      color: color ?? theme.colorScheme.primary,
      size: size,
    );
  }
}

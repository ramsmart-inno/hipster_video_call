import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  final bool showBackground;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.primaryColor;

    Widget loadingWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitDoubleBounce(
            color: loadingColor,
            size: size ?? 50.0,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: AppTheme.bodyMedium.copyWith(
              color: loadingColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (showBackground) {
      return Container(
        decoration: AppTheme.backgroundGradientDecoration,
        child: loadingWidget,
      );
    }

    return loadingWidget;
  }
}

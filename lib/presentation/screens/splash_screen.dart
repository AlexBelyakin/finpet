import 'package:flutter/material.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';

/// Первый кадр: фон загрузки и полоса запуска.
class SplashView extends StatelessWidget {
  const SplashView({super.key, this.progress = 0});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final asset =
        AppLayout.isTablet(context) ? AppAssets.bgLaunchTablet : AppAssets.bgLaunch;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            cacheWidth: AppLayout.imageCacheWidth(context),
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 22),
                child: LaunchStripeBar(progress: progress),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LaunchStripeBar extends StatelessWidget {
  const LaunchStripeBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          height: 16,
          width: double.infinity,
          child: CustomPaint(
            painter: _StripeBarPainter(progress: value),
          ),
        );
      },
    );
  }
}

class _StripeBarPainter extends CustomPainter {
  const _StripeBarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    canvas.clipRRect(track);
    _paintStripes(
      canvas,
      size,
      light: const Color(0xFFE8FFF4),
      dark: const Color(0xFFB7EED4),
    );
    if (progress > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
      _paintStripes(
        canvas,
        size,
        light: AppTheme.playGreen,
        dark: const Color(0xFF24985F),
      );
      canvas.restore();
    }

    canvas.drawRRect(
      track,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintStripes(
    Canvas canvas,
    Size size, {
    required Color light,
    required Color dark,
  }) {
    const step = 14.0;
    final paint = Paint();
    var i = 0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      paint.color = i.isEven ? light : dark;
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 8, 0)
        ..lineTo(x + 8 + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
      i += 1;
    }
  }

  @override
  bool shouldRepaint(covariant _StripeBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
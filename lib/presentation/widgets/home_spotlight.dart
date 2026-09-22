import 'package:flutter/material.dart';

import 'package:finpet/app/home_hints.dart';
import 'package:finpet/app/theme/app_theme.dart';

class HomeSpotlight extends StatelessWidget {
  const HomeSpotlight({
    super.key,
    this.paintKey,
    required this.hint,
    required this.hole,
    required this.step,
    required this.total,
    required this.onOk,
  });

  final Key? paintKey;

  final HomeHint hint;
  final Rect? hole;
  final int step;
  final int total;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          CustomPaint(
            key: paintKey,
            size: Size.infinite,
            painter: _DimPainter(hole: hole),
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: Align(
              alignment: hint.card,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Material(
                  color: Colors.white,
                  elevation: 10,
                  shadowColor: AppTheme.ink.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hint.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hint.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$step из $total',
                            style: TextStyle(
                              color: AppTheme.ink.withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.playGreen,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: onOk,
                              child: const Text('Ок'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpotGlow extends StatelessWidget {
  const SpotGlow({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: active ? Colors.white : Colors.transparent,
          width: active ? 3 : 0,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
      child: child,
    );
  }
}

class _DimPainter extends CustomPainter {
  const _DimPainter({this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Path()..addRect(Offset.zero & size);
    final holeRect = hole;
    if (holeRect != null) {
      final local = holeRect.inflate(8);
      dim
        ..addRRect(
          RRect.fromRectAndRadius(local, const Radius.circular(24)),
        )
        ..fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(
      dim,
      Paint()..color = const Color(0x73000000),
    );
  }

  @override
  bool shouldRepaint(covariant _DimPainter oldDelegate) =>
      oldDelegate.hole != hole;
}

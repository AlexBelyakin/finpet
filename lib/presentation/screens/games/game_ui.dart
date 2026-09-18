import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class SoftPlayField extends StatelessWidget {
  const SoftPlayField({
    super.key,
    required this.child,
    this.colors = const [Color(0xFFE8F6FF), Color(0xFFFFF0E0)],
  });

  final Widget child;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: _blob(90, AppTheme.peach.withValues(alpha: 0.22)),
            ),
            Positioned(
              left: -20,
              bottom: -10,
              child: _blob(110, AppTheme.mint.withValues(alpha: 0.2)),
            ),
            Positioned(
              right: 40,
              bottom: 30,
              child: _blob(54, AppTheme.sky.withValues(alpha: 0.28)),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class GameResultBody extends StatelessWidget {
  const GameResultBody({
    super.key,
    required this.title,
    required this.scoreLine,
    required this.coinsLine,
    required this.onAgain,
    required this.onDone,
  });

  final String title;
  final String scoreLine;
  final String coinsLine;
  final VoidCallback onAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return FinniScaffold(
      title: title,
      body: Center(
        child: SoftPlayField(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FinniIcons.sparkle, size: 64, color: AppTheme.gold),
                const SizedBox(height: 12),
                Text(scoreLine, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(coinsLine),
                const SizedBox(height: 20),
                FilledButton(onPressed: onAgain, child: const Text('Ещё раз')),
                TextButton(onPressed: onDone, child: const Text('Готово')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

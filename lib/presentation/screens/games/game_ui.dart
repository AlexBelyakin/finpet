import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class SoftPlayField extends StatelessWidget {
  const SoftPlayField({
    super.key,
    required this.child,
    this.colors = const [Color(0xFFE8F6FF), Color(0xFFFFF6E8)],
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
            const Positioned.fill(
              child: RepaintBoundary(
                child: _SoftPlayDecor(),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

}

class _SoftPlayDecor extends StatelessWidget {
  const _SoftPlayDecor();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: _SoftBlob(90, Color(0x2EFFB59A)),
          ),
          Positioned(
            left: -20,
            bottom: -10,
            child: _SoftBlob(110, Color(0x292EC8A0)),
          ),
          Positioned(
            right: 40,
            bottom: 30,
            child: _SoftBlob(54, Color(0x384EA2FF)),
          ),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

enum CatchMark { coin, gem, spend }

class CatchDot {
  CatchDot({
    required this.x,
    required this.y,
    required this.fill,
    required this.mark,
  });

  double x;
  double y;
  final Color fill;
  final CatchMark mark;
}

class CatchDotsPainter extends CustomPainter {
  CatchDotsPainter({required this.dots, required Listenable tick})
      : super(repaint: tick);

  final List<CatchDot> dots;

  static final _ruble = _label('₽');
  static final _white = Paint()..color = Colors.white;

  static TextPainter _label(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const r = 22.0;
    for (final dot in dots) {
      final c = Offset(dot.x * size.width, dot.y * size.height);
      canvas.drawCircle(c, r, Paint()..color = dot.fill);
      switch (dot.mark) {
        case CatchMark.coin:
          _ruble.paint(canvas, c - Offset(_ruble.width / 2, _ruble.height / 2));
        case CatchMark.gem:
          final path = Path()
            ..moveTo(c.dx, c.dy - 12)
            ..lineTo(c.dx + 10, c.dy)
            ..lineTo(c.dx, c.dy + 12)
            ..lineTo(c.dx - 10, c.dy)
            ..close();
          canvas.drawPath(path, _white);
        case CatchMark.spend:
          final x = Paint()
            ..color = Colors.white
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(c + const Offset(-8, -8), c + const Offset(8, 8), x);
          canvas.drawLine(c + const Offset(8, -8), c + const Offset(-8, 8), x);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CatchDotsPainter oldDelegate) => false;
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SoftPlayField(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleGlyph(
                    icon: Icons.emoji_events_rounded,
                    color: Color(0xFFE8B84A),
                    size: 88,
                    iconSize: 44,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scoreLine,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(coinsLine, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onAgain,
                      child: const Text('Ещё раз'),
                    ),
                  ),
                  TextButton(onPressed: onDone, child: const Text('Готово')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum MiniDifficulty { easy, medium, hard }

extension MiniDifficultyX on MiniDifficulty {
  String get label => switch (this) {
        MiniDifficulty.easy => 'Легко',
        MiniDifficulty.medium => 'Средне',
        MiniDifficulty.hard => 'Сложно',
      };
}

class DifficultyStart extends StatelessWidget {
  const DifficultyStart({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.howTo,
    required this.onPick,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String howTo;
  final ValueChanged<MiniDifficulty> onPick;

  @override
  Widget build(BuildContext context) {
    return FinniScaffold(
      title: title,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleGlyph(icon: icon, color: color, size: 96, iconSize: 48),
              const SizedBox(height: 16),
              Text(
                howTo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Выбери уровень',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              for (final level in MiniDifficulty.values) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: level == MiniDifficulty.easy
                          ? AppTheme.playGreen
                          : level == MiniDifficulty.medium
                              ? const Color(0xFF4EA2FF)
                              : const Color(0xFFE36A8A),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => onPick(level),
                    child: Text(level.label),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

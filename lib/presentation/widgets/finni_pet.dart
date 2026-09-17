import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';

class RoomBackground extends StatelessWidget {
  const RoomBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB9E4F0),
            Color(0xFFFFF1D6),
            Color(0xFFE7F6EE),
          ],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 28,
            right: 28,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4B0).withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 64,
            left: 20,
            child: Container(
              width: 92,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF8EC5E8).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 4),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFD8B48A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.72),
            child: Container(
              width: 210,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF7BC6A6).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class FinniPetView extends StatelessWidget {
  const FinniPetView({
    super.key,
    required this.pet,
    this.size = 180,
    this.showCaption = true,
  });

  final Pet pet;
  final double size;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    final scale = switch (pet.stage) {
      1 => 0.82,
      2 => 1.0,
      _ => 1.16,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: Size.square(size),
            painter: _PetPainter(pet.look),
          ),
        ),
        if (showCaption) ...[
          const SizedBox(height: 8),
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          Text(
            '${pet.look.speciesLabel} · ${pet.stageLabel}',
            style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.7)),
          ),
        ],
      ],
    );
  }
}

class _PetPainter extends CustomPainter {
  _PetPainter(this.look);

  final PetLook look;

  Color get fill => switch (look.color) {
        PetColor.peach => const Color(0xFFFFB38A),
        PetColor.mint => const Color(0xFF7BC6A6),
        PetColor.sky => const Color(0xFF8EC5E8),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = fill;
    final dark = Paint()..color = const Color(0xFF3A2F2A);
    final white = Paint()..color = Colors.white;
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 18), width: 118, height: 100),
      body,
    );
    canvas.drawCircle(Offset(cx, cy - 18), 48, body);

    if (look.species == PetSpecies.fox) {
      final path = Path()
        ..moveTo(cx - 38, cy - 40)
        ..lineTo(cx - 58, cy - 78)
        ..lineTo(cx - 10, cy - 50)
        ..moveTo(cx + 38, cy - 40)
        ..lineTo(cx + 58, cy - 78)
        ..lineTo(cx + 10, cy - 50);
      canvas.drawPath(path, body);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 70, cy + 28), width: 50, height: 22),
        body,
      );
    } else if (look.species == PetSpecies.bird) {
      final beak = Path()
        ..moveTo(cx + 40, cy - 18)
        ..lineTo(cx + 68, cy - 8)
        ..lineTo(cx + 40, cy);
      canvas.drawPath(beak, Paint()..color = const Color(0xFFFFC857));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 56, cy + 8), width: 36, height: 18),
        body,
      );
    } else {
      canvas.drawCircle(Offset(cx - 32, cy - 58), 16, body);
      canvas.drawCircle(Offset(cx + 32, cy - 58), 16, body);
    }

    canvas.drawCircle(Offset(cx - 16, cy - 22), 7, white);
    canvas.drawCircle(Offset(cx + 16, cy - 22), 7, white);
    canvas.drawCircle(Offset(cx - 16, cy - 22), 3.5, dark);
    canvas.drawCircle(Offset(cx + 16, cy - 22), 3.5, dark);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - 6), width: 22, height: 16),
      0.2,
      2.7,
      false,
      Paint()
        ..color = const Color(0xFF3A2F2A)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PetPainter oldDelegate) =>
      oldDelegate.look.id != look.id;
}

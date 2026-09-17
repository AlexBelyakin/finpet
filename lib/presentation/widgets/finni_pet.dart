import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';

class RoomBackground extends StatelessWidget {
  const RoomBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.bgRoom),
          fit: BoxFit.cover,
          alignment: Alignment(0, -0.12),
        ),
      ),
      child: child,
    );
  }
}

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.bgSplash),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

class PetImage extends StatelessWidget {
  const PetImage({
    super.key,
    required this.look,
    this.size = 180,
    this.circle = true,
  });

  final PetLook look;
  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppAssets.pet(look),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
    if (!circle) {
      return SizedBox(width: size, height: size, child: image);
    }
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.petTint(look.color).withValues(alpha: 0.18),
        ),
        child: ClipOval(child: image),
      ),
    );
  }
}

/// PNG-питомец с объёмом: перспектива, дыхание, тень, лёгкий поворот.
class LivingPet extends StatefulWidget {
  const LivingPet({
    super.key,
    required this.look,
    this.size = 220,
    this.mood = 80,
    this.onTap,
  });

  final PetLook look;
  final double size;
  final int mood;
  final VoidCallback? onTap;

  @override
  State<LivingPet> createState() => _LivingPetState();
}

class _LivingPetState extends State<LivingPet> with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _tap;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
  }

  @override
  void dispose() {
    _idle.dispose();
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final energy = (0.55 + widget.mood / 220).clamp(0.55, 1.0);
    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : () {
              _tap.forward(from: 0);
              widget.onTap!();
            },
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _tap]),
        builder: (context, child) {
          final t = _idle.value * math.pi * 2;
          final bounce = math.sin(t) * 7 * energy;
          final tilt = math.sin(t * 0.5) * 0.18;
          final squash = 1 + math.sin(t) * 0.025 * energy;
          final tapLift = Curves.easeOut.transform(_tap.value);
          final pop = 1 + math.sin(tapLift * math.pi) * 0.08;
          final shadow = (1.05 - bounce.abs() / 28).clamp(0.72, 1.1);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0016)
                  ..rotateX(0.16)
                  ..rotateY(tilt)
                  ..translateByDouble(0, -bounce - tapLift * 10, 0, 1)
                  ..scaleByDouble(squash * pop, (2 - squash) * pop, 1, 1),
                child: child,
              ),
              Transform.scale(
                scaleX: 1.15 * shadow,
                scaleY: 0.55 * shadow,
                child: Container(
                  width: widget.size * 0.62,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * 0.86,
                height: widget.size * 0.86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      AppTheme.petTint(widget.look.color).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.65, 1],
                  ),
                ),
              ),
              PetImage(look: widget.look, size: widget.size, circle: false),
            ],
          ),
        ),
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
    this.onTap,
  });

  final Pet pet;
  final double size;
  final bool showCaption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scale = switch (pet.stage) {
      1 => 0.9,
      2 => 1.0,
      _ => 1.12,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: scale,
          child: LivingPet(
            look: pet.look,
            size: size,
            mood: pet.mood,
            onTap: onTap,
          ),
        ),
        if (showCaption) ...[
          const SizedBox(height: 2),
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          Text(
            '${pet.look.speciesLabel} · ${pet.stageLabel}',
            style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.72)),
          ),
        ],
      ],
    );
  }
}

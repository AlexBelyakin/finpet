import 'package:finpet/app/assets.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class RoomBackground extends StatelessWidget {
  const RoomBackground({
    super.key,
    required this.child,
    this.alignment,
  });

  final Widget child;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(AppAssets.bgRoom),
          fit: BoxFit.cover,
          alignment: alignment ?? AppLayout.roomFocus(context),
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

bool get _inWidgetTest => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

/// Одна GLB-модель на всех экранах. PNG-питомцы больше не показываем.
class LivingPet extends StatelessWidget {
  const LivingPet({
    super.key,
    required this.look,
    this.size = 220,
    this.mood = 80,
    this.onTap,
    this.interactive = true,
  });

  final PetLook look;
  final double size;
  final int mood;
  final VoidCallback? onTap;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final tint = AppTheme.petTint(look.color);
    final sleepy = mood < 40;
    final bounce = sleepy ? 4.0 : 10.0;
    final duration = sleepy ? 1400.ms : 900.ms;

    Widget body = SizedBox(
      width: size,
      height: size + 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    tint.withValues(alpha: 0.28),
                    tint.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: IgnorePointer(
                  ignoring: !interactive,
                  child: _PetModel(
                    interactive: interactive,
                    sleepy: sleepy,
                  ),
                ),
              ),
            ),
          ),
          Transform.scale(
            scaleY: 0.38,
            child: Container(
              width: size * 0.72,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: const Color(0xFF4A372C).withValues(alpha: 0.28),
              ),
            ),
          ),
        ],
      ),
    );

    if (!_inWidgetTest) {
      body = body
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: 0, end: -bounce, duration: duration, curve: Curves.easeInOut);
    }

    return GestureDetector(
      onTap: onTap,
      child: body,
    );
  }
}

class _PetModel extends StatelessWidget {
  const _PetModel({required this.interactive, required this.sleepy});

  final bool interactive;
  final bool sleepy;

  @override
  Widget build(BuildContext context) {
    if (_inWidgetTest) {
      return const FittedBox(
        child: Icon(Icons.pets_rounded, color: AppTheme.mint),
      );
    }
    return ModelViewer(
      src: AppAssets.petModelSrc,
      alt: 'Питомец Финни',
      backgroundColor: const Color(0x00000000),
      autoRotate: true,
      autoRotateDelay: sleepy ? 1800 : 200,
      rotationPerSecond: sleepy ? '10deg' : '32deg',
      autoPlay: true,
      cameraControls: interactive,
      disableZoom: true,
      disablePan: true,
      shadowIntensity: 1,
      shadowSoftness: 0.85,
      interactionPrompt: InteractionPrompt.none,
      cameraOrbit: '25deg 72deg 105%',
      fieldOfView: '28deg',
      loading: Loading.eager,
      debugLogging: false,
      relatedCss: '''
model-viewer {
  width: 100%;
  height: 100%;
  --poster-color: transparent;
  --progress-bar-color: #7BC6A6;
}
''',
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
      1 => 0.92,
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
          GestureDetector(
            onTap: onTap,
            child: Text(
              pet.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
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

class SpeciesChip extends StatelessWidget {
  const SpeciesChip({
    super.key,
    required this.species,
    required this.selected,
    required this.onTap,
  });

  final PetSpecies species;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final look = PetLook(species: species, color: PetColor.mint);
    final icon = switch (species) {
      PetSpecies.cat => Icons.pets_rounded,
      PetSpecies.fox => Icons.cruelty_free_rounded,
      PetSpecies.bird => Icons.flutter_dash_rounded,
    };
    return Material(
      color: selected ? AppTheme.mint.withValues(alpha: 0.22) : AppTheme.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppTheme.mint : Colors.transparent,
              width: 3,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppTheme.ink),
              const SizedBox(height: 6),
              Text(
                look.speciesLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter/material.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size + 18,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.55),
                    radius: 0.82,
                    colors: [
                      tint.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: IgnorePointer(
                  ignoring: true,
                  child: const _PetModel(),
                ),
              ),
            ),
            Transform.scale(
              scaleY: 0.38,
              child: Container(
                width: size * 0.62,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: const Color(0xFF4A372C).withValues(alpha: 0.22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetModel extends StatelessWidget {
  const _PetModel();

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
      autoRotate: false,
      autoPlay: false,
      cameraControls: false,
      disableZoom: true,
      disablePan: true,
      disableTap: true,
      shadowIntensity: 1,
      shadowSoftness: 0.6,
      interactionPrompt: InteractionPrompt.none,
      cameraOrbit: '0deg 88deg 118%',
      minCameraOrbit: '0deg 88deg 118%',
      maxCameraOrbit: '0deg 88deg 118%',
      fieldOfView: '26deg',
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

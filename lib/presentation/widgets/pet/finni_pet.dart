import 'package:finpet/app/assets.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/widgets/pet/finni_model_view.dart';
import 'package:flutter/material.dart';

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

/// Biped-модель Meshy. Idle крутится, без вращения камеры.
class LivingPet extends StatelessWidget {
  const LivingPet({
    super.key,
    required this.look,
    this.size = 220,
    this.mood = 80,
    this.clip = PetClip.idleGood,
    this.onTap,
    this.onOneShotFinished,
    this.interactive = true,
  });

  final PetLook look;
  final double size;
  final int mood;
  final PetClip clip;
  final VoidCallback? onTap;
  final VoidCallback? onOneShotFinished;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Semantics(
        label: look.speciesLabel,
        child: SizedBox(
          width: size,
          height: size,
          child: IgnorePointer(
            ignoring: true,
            child: RepaintBoundary(
              child: buildPetModel(
                clip: clip,
                onOneShotFinished: onOneShotFinished,
              ),
            ),
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
    this.clip,
    this.onTap,
    this.onOneShotFinished,
  });

  final Pet pet;
  final double size;
  final bool showCaption;
  final PetClip? clip;
  final VoidCallback? onTap;
  final VoidCallback? onOneShotFinished;

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
            clip: clip ?? PetClips.idleFor(pet),
            onTap: onTap,
            onOneShotFinished: onOneShotFinished,
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

import 'dart:async';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/day_period.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/widgets/pet/finni_model_view.dart';
import 'package:flutter/material.dart';

class RoomBackground extends StatefulWidget {
  const RoomBackground({
    super.key,
    required this.child,
    this.place = PetPlace.room,
    this.alignment,
  });

  final Widget child;
  final PetPlace place;
  final AlignmentGeometry? alignment;

  @override
  State<RoomBackground> createState() => _RoomBackgroundState();
}

class _RoomBackgroundState extends State<RoomBackground>
    with WidgetsBindingObserver {
  Timer? _tick;
  late RoomDaytime _period;

  @override
  void initState() {
    super.initState();
    _period = RoomDaytimes.of(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => _syncPeriod());
  }

  @override
  void dispose() {
    _tick?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncPeriod();
  }

  void _syncPeriod() {
    final next = RoomDaytimes.of(DateTime.now());
    if (next == _period || !mounted) return;
    setState(() => _period = next);
  }

  @override
  Widget build(BuildContext context) {
    final tablet = AppLayout.isTablet(context);
    final asset = AppAssets.placeBackdrop(
      place: widget.place,
      period: _period,
      tablet: tablet,
    );
    final fallback = AppAssets.placeBackdrop(
      place: PetPlace.room,
      period: _period,
      tablet: tablet,
    );
    final align = widget.alignment ?? AppLayout.roomFocus(context);
    final cacheW = AppLayout.imageCacheWidth(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: SizedBox.expand(
            key: ValueKey(asset),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: align,
              cacheWidth: cacheW,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              errorBuilder: (context, error, stack) {
                return Image.asset(
                  fallback == asset ? AppAssets.bgRoom : fallback,
                  fit: BoxFit.cover,
                  alignment: align,
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: cacheW,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stack) {
                    return Image.asset(
                      AppAssets.bgRoom,
                      fit: BoxFit.cover,
                      alignment: align,
                      width: double.infinity,
                      height: double.infinity,
                      cacheWidth: cacheW,
                      filterQuality: FilterQuality.medium,
                    );
                  },
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.bgSplash,
          fit: BoxFit.cover,
          cacheWidth: AppLayout.imageCacheWidth(context),
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
        ),
        child,
      ],
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
                body: look.body,
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
                fontFamily: AppFonts.display,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
          ),
          Text(
            '${pet.look.bodyLabel} · ${pet.stageLabel}',
            style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.72)),
          ),
        ],
      ],
    );
  }
}


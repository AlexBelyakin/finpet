import 'dart:async';

import 'package:flutter/material.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/day_period.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/audio/music_service.dart';
import 'package:finpet/data/pet/pet_model_runtime.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/screens/create_pet_screen.dart';
import 'package:finpet/presentation/screens/home_screen.dart';
import 'package:finpet/presentation/screens/onboarding_screen.dart';
import 'package:finpet/presentation/screens/place_screen.dart';
import 'package:finpet/presentation/screens/splash_screen.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/pet/finni_model_view.dart';

class FinniApp extends StatelessWidget {
  const FinniApp({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Питомец Финни',
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      theme: AppTheme.data(),
      home: _SplashGate(controller: controller),
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.controller});

  final GameController controller;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> with WidgetsBindingObserver {
  var _progress = 0.08;
  var _bootDone = false;
  var _releaseViewer = false;
  bool? _musicOn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.controller.applyNeedsDrift());
    }
  }

  Future<void> _boot() async {
    final started = DateTime.now();
    if (!mounted) return;
    setState(() => _progress = 0.16);
    await MusicService.instance.loadPrefs();
    if (!mounted) return;
    setState(() => _progress = 0.38);
    if (!widget.controller.loaded) {
      await widget.controller.load();
    }
    if (!mounted) return;
    setState(() => _progress = 0.58);
    await PetModelRuntime.instance.start();
    if (!mounted) return;
    final pet = widget.controller.profile.pet;
    if (pet != null) {
      await PetModelRuntime.instance.ensureBody(
        pet.look.body,
        idle: PetClips.idleFor(pet),
      );
    } else {
      await PetModelRuntime.instance.ensureBody(PetBody.finni);
    }
    if (!mounted) return;
    await preparePetViewer();
    if (!mounted) return;
    setState(() => _progress = 0.72);
    if (pet != null) {
      await primePetViewer(PetClips.idleFor(pet), pet.look.body);
    } else {
      await primePetViewer(PetClip.idleGood, PetBody.finni);
    }
    if (!mounted) return;
    setState(() => _progress = 0.86);
    final left = AppSplash.hold - DateTime.now().difference(started);
    final wait = left > Duration.zero ? left : Duration.zero;
    await Future.wait([
      _precacheRoom(),
      _fillBar(from: 0.86, to: 1, over: wait),
    ]);
    if (!mounted) return;
    setState(() => _progress = 1);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() => _releaseViewer = true);
    await Future<void>.delayed(const Duration(milliseconds: 32));
    if (mounted) setState(() => _bootDone = true);
  }

  Future<void> _fillBar({
    required double from,
    required double to,
    required Duration over,
  }) async {
    if (over <= Duration.zero) {
      if (mounted) setState(() => _progress = to);
      return;
    }
    const steps = 5;
    final slice = over ~/ steps;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(slice);
      if (!mounted) return;
      setState(() => _progress = from + (to - from) * (i / steps));
    }
  }

  Future<void> _precacheRoom() async {
    if (!mounted) return;
    final place = widget.controller.profile.place;
    if (place == null) return;
    final tablet = AppLayout.isTablet(context);
    final asset = AppAssets.placeBackdrop(
      place: place,
      period: RoomDaytimes.of(DateTime.now()),
      tablet: tablet,
    );
    try {
      await precacheImage(
        ResizeImage.resizeIfNeeded(
          AppLayout.imageCacheWidth(context),
          null,
          AssetImage(asset),
        ),
        context,
      );
    } catch (_) {}
  }

  void _syncMusic(bool inGame) {
    if (_musicOn == inGame) return;
    _musicOn = inGame;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MusicService.instance.setInGame(inGame);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!_bootDone || !widget.controller.loaded) {
          _syncMusic(false);
          final warm = _releaseViewer ? null : petViewerWarmup();
          if (warm == null) return SplashView(progress: _progress);
          return Stack(
            fit: StackFit.expand,
            children: [
              warm,
              SplashView(progress: _progress),
            ],
          );
        }
        final p = widget.controller.profile;
        if (!p.seenIntro) {
          _syncMusic(false);
          return OnboardingScreen(controller: widget.controller);
        }
        if (p.pet == null) {
          _syncMusic(false);
          return CreatePetScreen(controller: widget.controller);
        }
        if (p.place == null) {
          _syncMusic(false);
          return PlaceScreen(controller: widget.controller);
        }
        _syncMusic(true);
        return HomeScreen(controller: widget.controller);
      },
    );
  }
}

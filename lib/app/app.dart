import 'package:flutter/material.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/pet/pet_model_runtime.dart';
import 'package:finpet/data/audio/music_service.dart';
import 'package:finpet/presentation/screens/create_pet_screen.dart';
import 'package:finpet/presentation/screens/home_screen.dart';
import 'package:finpet/presentation/screens/onboarding_screen.dart';
import 'package:finpet/presentation/screens/splash_screen.dart';
import 'package:finpet/presentation/state/game_controller.dart';

class FinniApp extends StatelessWidget {
  const FinniApp({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Питомец Финни',
      debugShowCheckedModeBanner: false,
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

class _SplashGateState extends State<_SplashGate> {
  bool _minTimeDone = false;
  bool? _musicOn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MusicService.instance.loadPrefs();
      widget.controller.load();
      PetModelRuntime.instance.start();
    });
    Future<void>.delayed(AppSplash.hold, () {
      if (mounted) setState(() => _minTimeDone = true);
    });
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
        if (!widget.controller.loaded || !_minTimeDone) {
          _syncMusic(false);
          return const SplashView();
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
        _syncMusic(true);
        return HomeScreen(controller: widget.controller);
      },
    );
  }
}

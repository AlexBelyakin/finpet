import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _minTimeDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!widget.controller.loaded || !_minTimeDone) {
          return const SplashView();
        }
        final p = widget.controller.profile;
        if (!p.seenIntro) {
          return OnboardingScreen(controller: widget.controller);
        }
        if (p.pet == null) {
          return CreatePetScreen(controller: widget.controller);
        }
        return HomeScreen(controller: widget.controller);
      },
    );
  }
}

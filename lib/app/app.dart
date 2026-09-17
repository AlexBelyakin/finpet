import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/create_pet_screen.dart';
import 'package:finpet/presentation/screens/home_screen.dart';
import 'package:finpet/presentation/screens/onboarding_screen.dart';
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
      home: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (!controller.loaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final p = controller.profile;
          if (!p.seenIntro) {
            return OnboardingScreen(controller: controller);
          }
          if (p.pet == null) {
            return CreatePetScreen(controller: controller);
          }
          return HomeScreen(controller: controller);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/glossary_screen.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/pet/finni_pet.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const GlossaryScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.help_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Image.asset(AppAssets.logo, height: 96),
                        const SizedBox(height: 20),
                        SurfaceCard(
                          child: Column(
                            children: [
                              Text(
                                'Привет! Это игра про заботу о питомце и монетах.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Дели монеты на нужное, желаемое и копилку. Помогай питомцу заданиями и покупками. Настоящие деньги не нужны: если что-то пошло не так, питомец останется — сложи новый план и попробуй снова.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Готов играть?',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 280.ms),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.playGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => controller.markIntroSeen(),
                    child: const Text('Играть!'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

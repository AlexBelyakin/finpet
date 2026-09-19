import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/screens/glossary_screen.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/finni_pet.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    (
      'Это игра про монеты',
      'Ты заботишься о питомце Финни. Настоящие деньги сюда не нужны.',
    ),
    (
      'Три решения',
      'Потратить на нужное. Потратить на желаемое. Отложить в копилку.',
    ),
    (
      'Ошибки можно чинить',
      'Если потратил не так — питомец не пропадёт. Сложи новый план и попробуй снова.',
    ),
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    final pet = AppLayout.petSize(context, phone: 168, tablet: 240);
    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                const Spacer(),
                LivingPet(
                  look: const PetLook(
                    species: PetSpecies.cat,
                    color: PetColor.mint,
                  ),
                  size: pet,
                  interactive: false,
                ),
                const SizedBox(height: 20),
                SurfaceCard(
                  child: Column(
                    children: [
                      Text(
                        page.$1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        page.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, height: 1.35),
                      ),
                    ],
                  ),
                ).animate(key: ValueKey(_index)).fadeIn(duration: 280.ms),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (_index < _pages.length - 1) {
                        setState(() => _index += 1);
                        return;
                      }
                      await widget.controller.markIntroSeen();
                    },
                    child: Text(
                      _index < _pages.length - 1 ? 'Дальше' : 'Создать питомца',
                    ),
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

import 'package:flutter/material.dart';

import 'package:finpet/presentation/screens/glossary_screen.dart';
import 'package:finpet/presentation/state/game_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = const [
    (
      '👋',
      'Это игра про карманные деньги',
      'Ты заботишься о питомце Финни. Настоящие деньги сюда не нужны.',
    ),
    (
      '🎯',
      'Три решения',
      'Потратить на нужное. Потратить на желаемое. Отложить в копилку.',
    ),
    (
      '🌱',
      'Ошибки можно чинить',
      'Если потратил не так — питомец не пропадёт. Сложи новый план и попробуй снова.',
    ),
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              Text(page.$1, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                page.$2,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                page.$3,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.35),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  if (_index < _pages.length - 1) {
                    setState(() => _index += 1);
                    return;
                  }
                  await widget.controller.markIntroSeen();
                },
                child: Text(_index < _pages.length - 1 ? 'Дальше' : 'Создать питомца'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

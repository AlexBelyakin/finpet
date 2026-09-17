import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/finni_pet.dart';
import '../widgets/shell.dart';

class CreatePetScreen extends StatefulWidget {
  const CreatePetScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _player = TextEditingController();
  final _pet = TextEditingController(text: 'Финни');
  PetLook _look = Catalog.looks.first;

  @override
  void dispose() {
    _player.dispose();
    _pet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = Pet(
      name: _pet.text.trim().isEmpty ? 'Финни' : _pet.text.trim(),
      look: _look,
      satiety: 70,
      mood: 80,
      stage: 1,
      growthPoints: 0,
      moodReason: '',
    );
    return FinniScaffold(
      title: 'Твой питомец',
      body: ListView(
        children: [
          const Text('Игровое имя — любое. Настоящие фамилию и телефон писать не нужно.'),
          const SizedBox(height: 12),
          TextField(
            controller: _player,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Как тебя зовут в игре',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pet,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Имя питомца',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Внешний вид — 9 комбинаций: вид и цвет.'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: [
              for (final look in Catalog.looks)
                InkWell(
                  onTap: () => setState(() => _look = look),
                  borderRadius: BorderRadius.circular(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _look.id == look.id
                            ? AppTheme.mint
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 64,
                          child: FittedBox(
                            child: FinniPetView(
                              pet: preview.copyWith(look: look),
                              size: 90,
                              showCaption: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final player = _player.text.trim();
              final petName = _pet.text.trim();
              if (player.isEmpty || petName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Напиши игровые имена.')),
                );
                return;
              }
              await widget.controller.createPet(
                playerName: player,
                petName: petName,
                look: _look,
              );
            },
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }
}

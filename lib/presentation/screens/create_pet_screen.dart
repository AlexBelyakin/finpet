import 'package:flutter/material.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/screens/glossary_screen.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/pet/finni_pet.dart';
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
  PetLook _look = const PetLook(
    species: PetSpecies.cat,
    color: PetColor.peach,
  );

  @override
  void dispose() {
    _player.dispose();
    _pet.dispose();
    super.dispose();
  }

  Pet get _preview => Pet(
        name: _pet.text.trim().isEmpty ? 'Финни' : _pet.text.trim(),
        look: _look,
        satiety: 70,
        mood: 80,
        stage: 1,
        growthPoints: 0,
        moodReason: '',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Text(
                    'Твой питомец',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Подсказка',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GlossaryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline),
                  ),
                ],
              ),
              SurfaceCard(
                child: Column(
                  children: [
                    FinniPetView(pet: _preview, size: AppLayout.petSize(context, phone: 180, tablet: 260)),
                    const SizedBox(height: 8),
                    Text(
                      '${_look.speciesLabel} · ${_look.colorLabel}',
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Кто будет другом?',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final species in PetSpecies.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SpeciesChip(
                          species: species,
                          selected: _look.species == species,
                          onTap: () => setState(() {
                            _look = PetLook(
                              species: species,
                              color: _look.color,
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Цвет',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final color in PetColor.values)
                    _ColorDot(
                      color: color,
                      selected: _look.color == color,
                      onTap: () => setState(() {
                        _look = PetLook(
                          species: _look.species,
                          color: color,
                        );
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  children: [
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
                    const SizedBox(height: 8),
                    Text(
                      'Игровое имя — любое. Настоящие фамилию и телефон писать не нужно.',
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
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
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final PetColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = AppTheme.petTint(color);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: color == PetColor.wave
                  ? const LinearGradient(
                      colors: [AppTheme.peach, AppTheme.mint, AppTheme.sky],
                    )
                  : null,
              color: color == PetColor.wave ? null : fill,
              border: Border.all(
                color: selected ? AppTheme.ink : Colors.white,
                width: selected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.ink.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          PetLook(species: PetSpecies.cat, color: color).colorLabel,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

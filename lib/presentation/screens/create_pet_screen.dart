import 'dart:async';

import 'package:flutter/material.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/pet/pet_model_bridge.dart';
import 'package:finpet/data/pet/pet_model_runtime.dart';
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
    body: PetBody.finni,
    species: PetSpecies.cat,
    color: PetColor.peach,
  );
  var _starting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_prefetchBodies());
  }

  Future<void> _prefetchBodies() async {
    await Future.wait([
      PetModelRuntime.instance.ensureBody(
        PetBody.finni,
        idle: PetClip.idleGood,
        warm: false,
      ),
      PetModelRuntime.instance.ensureBody(
        PetBody.nori,
        idle: PetClip.idleGood,
        warm: false,
      ),
    ]);
  }

  @override
  void dispose() {
    _player.dispose();
    _pet.dispose();
    super.dispose();
  }

  Pet get _preview => Pet(
        name: _pet.text.trim().isEmpty ? _look.bodyLabel : _pet.text.trim(),
        look: _look,
        satiety: 70,
        mood: 80,
        stage: 1,
        growthPoints: 0,
        moodReason: '',
      );

  void _select(PetLook look) {
    final previous = _look.bodyLabel;
    setState(() {
      _look = look;
      if (_pet.text.trim().isEmpty || _pet.text.trim() == previous) {
        _pet.text = look.bodyLabel;
      }
    });
  }

  Future<void> _play() async {
    final player = _player.text.trim();
    final petName = _pet.text.trim();
    if (player.isEmpty || petName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Напиши игровые имена.')),
      );
      return;
    }
    if (_starting) return;
    setState(() => _starting = true);
    await widget.controller.createPet(
      playerName: player,
      petName: petName,
      look: _look,
    );
    if (mounted) setState(() => _starting = false);
  }

  @override
  Widget build(BuildContext context) {
    final previewSize = AppLayout.petSize(context, phone: 180, tablet: 200);
    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Выбери персонажа',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 12),
                    children: [
                      SurfaceCard(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                FinniPetView(
                                  pet: _preview,
                                  size: previewSize,
                                ),
                                ListenableBuilder(
                                  listenable: PetModelBridge.applying,
                                  builder: (context, _) {
                                    if (!PetModelBridge.applying.value) {
                                      return const SizedBox.shrink();
                                    }
                                    return const ColoredBox(
                                      color: Color(0x66FFFFFF),
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _look.bodyLabel,
                              style: TextStyle(
                                fontFamily: AppFonts.display,
                                color: AppTheme.ink.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Кто будет другом?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final look in [
                            const PetLook(
                              body: PetBody.finni,
                              species: PetSpecies.cat,
                              color: PetColor.peach,
                            ),
                            const PetLook(
                              body: PetBody.nori,
                              species: PetSpecies.fox,
                              color: PetColor.mint,
                            ),
                          ])
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: _BodyCard(
                                  look: look,
                                  selected: _look.body == look.body,
                                  onTap: () => _select(look),
                                ),
                              ),
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
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.playGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _starting ? null : _play,
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

class _BodyCard extends StatelessWidget {
  const _BodyCard({
    required this.look,
    required this.selected,
    required this.onTap,
  });

  final PetLook look;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.playGreen.withValues(alpha: 0.18) : AppTheme.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppTheme.playGreen : Colors.transparent,
              width: 3,
            ),
          ),
          child: Text(
            look.bodyLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}

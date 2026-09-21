import 'package:flutter/material.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/pet/finni_pet.dart';

class PlaceScreen extends StatelessWidget {
  const PlaceScreen({
    super.key,
    required this.controller,
    this.firstPick = true,
  });

  final GameController controller;
  final bool firstPick;

  Future<void> _pick(BuildContext context, PetPlace place) async {
    final ok = await controller.setPlace(place);
    if (!context.mounted) return;
    if (!ok) {
      final done = controller.profile.doneTaskIds.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Усадьба откроется после ${GameProfile.room2TasksNeeded} заданий. Сейчас $done из ${GameProfile.room2TasksNeeded}.',
          ),
        ),
      );
      return;
    }
    if (!firstPick) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tablet = AppLayout.isTablet(context);
    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final profile = controller.profile;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!firstPick)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Назад',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    Text(
                      'Где будете играть?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Локацию можно сменить позже в меню — задания и монеты останутся. Фон сам станет утренним, вечерним или ночным. Усадьбу откроешь после ${GameProfile.room2TasksNeeded} заданий.',
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final place in PetPlace.values) ...[
                            _PlaceCard(
                              place: place,
                              preview: AppAssets.placePreview(
                                place,
                                tablet: tablet,
                              ),
                              locked: !profile.canUsePlace(place),
                              done: profile.doneTaskIds.length,
                              selected: profile.place == place,
                              onTap: () => _pick(context, place),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.preview,
    required this.locked,
    required this.done,
    required this.selected,
    required this.onTap,
  });

  final PetPlace place;
  final String preview;
  final bool locked;
  final int done;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Material(
        color: AppTheme.card,
        elevation: selected ? 6 : 4,
        shadowColor: AppTheme.ink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 148,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _previewImage(context),
                        if (locked)
                          const ColoredBox(
                            color: Color(0x66000000),
                            child: Center(
                              child: Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          ),
                        if (selected && !locked)
                          const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.mint,
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  place.label,
                  style: const TextStyle(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locked
                      ? 'Откроется после ${GameProfile.room2TasksNeeded} заданий. Сейчас $done из ${GameProfile.room2TasksNeeded}.'
                      : place.blurb,
                  style: TextStyle(
                    color: AppTheme.ink.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewImage(BuildContext context) {
    final image = Image.asset(
      preview,
      fit: BoxFit.cover,
      cacheWidth: AppLayout.imageCacheWidth(context, max: 900),
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, error, stack) {
        return ColoredBox(
          color: place == PetPlace.room
              ? const Color(0xFFD9F3FF)
              : const Color(0xFFD9F7E8),
          child: Icon(
            place == PetPlace.room
                ? Icons.weekend_rounded
                : Icons.chair_rounded,
            size: 64,
            color: AppTheme.ink.withValues(alpha: 0.45),
          ),
        );
      },
    );
    if (!locked) return image;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.3, 0.6, 0.1, 0, 0,
        0.3, 0.6, 0.1, 0, 0,
        0.3, 0.6, 0.1, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: image,
    );
  }
}

import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter/material.dart';

Widget buildPetModelImpl({
  required PetClip clip,
  PetBody body = PetBody.finni,
  VoidCallback? onOneShotFinished,
}) {
  return const FittedBox(
    child: Icon(Icons.pets_rounded, color: AppTheme.mint),
  );
}

Future<void> preparePetViewerImpl() async {}

Future<void> primePetViewerImpl(PetClip clip, PetBody body) async {}

Widget? petViewerWarmupImpl() => null;

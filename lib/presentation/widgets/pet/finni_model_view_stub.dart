import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildPetModelImpl({
  required PetClip clip,
  VoidCallback? onOneShotFinished,
}) {
  return const FittedBox(
    child: Icon(Icons.pets_rounded, color: AppTheme.mint),
  );
}

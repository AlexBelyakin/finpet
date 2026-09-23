import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter/widgets.dart';

import 'finni_model_view_stub.dart'
    if (dart.library.io) 'finni_model_view_io.dart';

Widget buildPetModel({
  required PetClip clip,
  PetBody body = PetBody.finni,
  PetColor? color,
  bool tint = true,
  VoidCallback? onOneShotFinished,
}) {
  return buildPetModelImpl(
    clip: clip,
    body: body,
    color: color,
    tint: tint,
    onOneShotFinished: onOneShotFinished,
  );
}

Future<void> preparePetViewer() => preparePetViewerImpl();

Future<void> primePetViewer(PetClip clip, PetBody body) =>
    primePetViewerImpl(clip, body);

Widget? petViewerWarmup() => petViewerWarmupImpl();

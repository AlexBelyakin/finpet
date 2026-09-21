import 'package:finpet/app/pet_clips.dart';
import 'package:flutter/widgets.dart';

import 'finni_model_view_stub.dart'
    if (dart.library.io) 'finni_model_view_io.dart';

Widget buildPetModel({
  required PetClip clip,
  VoidCallback? onOneShotFinished,
}) {
  return buildPetModelImpl(
    clip: clip,
    onOneShotFinished: onOneShotFinished,
  );
}

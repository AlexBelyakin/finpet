import 'package:finpet/app/pet_clips.dart';

/// Связь контроллера с WebView: готовим клип, пока игрок ещё не на доме.
abstract final class PetModelBridge {
  static void Function(PetClip clip)? onPrepare;
  static void Function()? onResume;

  static void prepare(PetClip clip) => onPrepare?.call(clip);

  static void resume() => onResume?.call();
}

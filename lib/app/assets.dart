import 'package:finpet/domain/models.dart';

abstract final class AppAssets {
  static const logo = 'assets/images/logo_finni.png';
  static const bgSplash = 'assets/images/bg_splash.png';
  static const bgRoom = 'assets/images/bg_room.png';

  static String pet(PetLook look) =>
      'assets/images/pet_${look.species.name}_${look.color.name}.png';
}

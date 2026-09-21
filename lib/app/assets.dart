import 'package:flutter/foundation.dart';

import 'package:finpet/app/day_period.dart';
import 'package:finpet/domain/models.dart';

abstract final class AppSplash {
  static const hold = Duration(seconds: 8);
}

abstract final class AppAssets {
  static const logo = 'assets/images/logo_finni.jpg';
  static const bgLaunch = 'assets/images/fon_zagruzki_fast.jpg';
  static const bgLaunchTablet = 'assets/images/fon_zagruzki_planshet_fast.jpg';
  static const bgSplash = 'assets/images/bg_splash.jpg';
  static const bgRoom = 'assets/images/bg_room_morning.jpg';

  static String placeBackdrop({
    required PetPlace place,
    required RoomDaytime period,
    required bool tablet,
  }) {
    final suffix = tablet ? '_planshet' : '';
    switch (place) {
      case PetPlace.room:
        return 'assets/images/bg_room_${period.name}$suffix.jpg';
      case PetPlace.room2:
        return 'assets/images/room2_${period.name}$suffix.jpg';
    }
  }

  static String placePreview(PetPlace place, {required bool tablet}) {
    return placeBackdrop(
      place: place,
      period: RoomDaytime.morning,
      tablet: tablet,
    );
  }
  static const petModel = 'assets/models/finni.glb';
  static const petIdle = 'assets/models/finni/idle_good.glb';
  static const track1 = 'assets/audio/track_1.mp3';
  static const track2 = 'assets/audio/track_2.mp3';

  /// На вебе Flutter кладёт ассеты под `/assets/<pubspec path>`.
  static String modelSrc(String assetPath) {
    if (kIsWeb) {
      return Uri.base.resolve('assets/$assetPath').toString();
    }
    return assetPath;
  }

  static String get petModelSrc => modelSrc(petIdle);
}

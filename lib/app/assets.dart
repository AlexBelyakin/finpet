import 'package:flutter/foundation.dart';

abstract final class AppSplash {
  static const hold = Duration(seconds: 5);
}

abstract final class AppAssets {
  static const logo = 'assets/images/logo_finni.png';
  static const bgLaunch = 'assets/images/fon_zagruzki.png';
  static const bgLaunchTablet = 'assets/images/fon_zagruzki_planshet.png';
  static const bgSplash = 'assets/images/bg_splash.png';
  static const bgRoom = 'assets/images/bg_room.png';
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

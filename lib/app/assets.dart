import 'package:flutter/foundation.dart';

abstract final class AppAssets {
  static const logo = 'assets/images/logo_finni.png';
  static const bgLaunch = 'assets/images/fon_zagruzki.png';
  static const bgSplash = 'assets/images/bg_splash.png';
  static const bgRoom = 'assets/images/bg_room.png';
  static const petModel = 'assets/models/finni.glb';
  static const track1 = 'assets/audio/track_1.mp3';
  static const track2 = 'assets/audio/track_2.mp3';

  /// На вебе Flutter кладёт ассеты под `/assets/<pubspec path>`.
  static String get petModelSrc {
    if (kIsWeb) {
      return Uri.base.resolve('assets/assets/models/finni.glb').toString();
    }
    return petModel;
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool get _inWidgetTest => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

/// Фоновые треки по кругу после создания питомца.
class MusicService extends ChangeNotifier {
  MusicService._();
  static final instance = MusicService._();

  static const _mutedKey = 'finni_music_muted';
  static const _volumeKey = 'finni_music_volume';
  static const _tracks = ['audio/track_1.mp3', 'audio/track_2.mp3'];
  static const volumeStep = 0.1;

  AudioPlayer? _player;
  bool muted = false;
  double volume = 0.8;
  bool _inGame = false;
  int _index = 0;

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    muted = prefs.getBool(_mutedKey) ?? false;
    volume = (prefs.getDouble(_volumeKey) ?? 0.8).clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> setInGame(bool value) async {
    _inGame = value;
    if (value) {
      await _ensurePlaying();
    } else {
      await _stop();
    }
  }

  Future<void> toggleMuted() async {
    muted = !muted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutedKey, muted);
    if (muted) {
      await _player?.pause();
    } else if (_inGame) {
      await _ensurePlaying();
    }
    notifyListeners();
  }

  Future<void> nudgeVolume(double delta) async {
    if (delta > 0 && muted) {
      await toggleMuted();
    }
    volume = (volume + delta).clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
    await _player?.setVolume(volume);
    notifyListeners();
  }

  Future<void> _ensurePlaying() async {
    if (_inWidgetTest || muted || !_inGame) return;
    try {
      if (_player == null) {
        final player = AudioPlayer();
        await player.setVolume(volume);
        player.onPlayerComplete.listen((_) {
          _index = (_index + 1) % _tracks.length;
          if (_inGame && !muted) {
            _playCurrent();
          }
        });
        _player = player;
      }
      await _playCurrent();
    } catch (error, stack) {
      debugPrint('MusicService: $error\n$stack');
    }
  }

  Future<void> _playCurrent() async {
    final player = _player;
    if (player == null) return;
    await player.setVolume(volume);
    await player.play(AssetSource(_tracks[_index]));
  }

  Future<void> _stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }
}

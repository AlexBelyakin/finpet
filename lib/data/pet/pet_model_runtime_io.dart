import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/domain/models.dart';

class PetModelRuntime {
  PetModelRuntime._();
  static final instance = PetModelRuntime._();

  static const _maxCached = 5;

  HttpServer? _server;
  String? baseUrl;
  PetBody _body = PetBody.finni;
  String? _pinnedKey;
  final _bytes = <String, Uint8List>{};
  final _order = <String>[];
  final _loading = <String, Future<Uint8List>>{};
  Uint8List? _viewerJs;
  Future<void>? _starting;

  bool get _inTest => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  Future<void> start() {
    if (_inTest) return Future.value();
    return _starting ??= _start();
  }

  Future<void> _start() async {
    _viewerJs = await _loadAsset(
      'packages/model_viewer_plus/assets/model-viewer.min.js',
    );
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    baseUrl = 'http://${_server!.address.address}:${_server!.port}/';
    _server!.listen(_onRequest);
  }

  Future<void> ensureBody(PetBody body, {PetClip? idle}) async {
    if (_inTest) {
      _body = body;
      return;
    }
    await start();
    final clip = idle ?? PetClip.idleGood;
    final changed = _body != body;
    _body = body;
    if (changed) _dropOtherBodies(body);
    _pinnedKey = PetClips.fileKey(clip, body);
    await _loadClip(clip, body);
    unawaited(_warmLikely(body));
  }

  Future<void> prefetch(PetClip clip) async {
    if (_inTest) return;
    await start();
    await _loadClip(clip, _body);
  }

  Future<void> _warmLikely(PetBody body) async {
    for (final clip in PetClips.warmClips) {
      if (_body != body) return;
      await _loadClip(clip, body);
    }
  }

  void _dropOtherBodies(PetBody body) {
    final prefix = '${body.name}/';
    _bytes.removeWhere((key, _) => !key.startsWith(prefix));
    _order.removeWhere((key) => !key.startsWith(prefix));
    _loading.removeWhere((key, _) => !key.startsWith(prefix));
    if (_pinnedKey != null && !_pinnedKey!.startsWith(prefix)) {
      _pinnedKey = null;
    }
  }

  Future<void> _loadClip(PetClip clip, PetBody body) async {
    final key = PetClips.fileKey(clip, body);
    if (_bytes.containsKey(key)) {
      _touch(key);
      return;
    }
    final pending = _loading[key];
    if (pending != null) {
      await pending;
      return;
    }
    final future = _loadAsset(PetClips.asset(clip, body));
    _loading[key] = future;
    try {
      _bytes[key] = await future;
      _touch(key);
      _trim();
    } finally {
      _loading.remove(key);
    }
  }

  void _touch(String key) {
    _order.remove(key);
    _order.add(key);
  }

  void _trim() {
    if (_bytes.length <= _maxCached) return;
    for (final key in List<String>.from(_order)) {
      if (_bytes.length <= _maxCached) return;
      if (key == _pinnedKey) continue;
      _bytes.remove(key);
      _order.remove(key);
    }
  }

  Future<Uint8List> _loadAsset(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> _onRequest(HttpRequest request) async {
    final response = request.response;
    try {
      final path = request.uri.path;
      if (path == '/' || path == '/index.html') {
        await _write(
          response,
          utf8Html(),
          'text/html; charset=utf-8',
        );
        return;
      }
      if (path == '/model-viewer.min.js') {
        final js = _viewerJs;
        if (js == null) {
          response.statusCode = HttpStatus.notFound;
          await response.close();
          return;
        }
        await _write(response, js, 'application/javascript; charset=utf-8');
        return;
      }
      if (path.startsWith('/clips/') && path.endsWith('.glb')) {
        final key = path.substring('/clips/'.length, path.length - 4);
        var data = _bytes[key];
        data ??= await _loadMissing(key);
        if (data == null) {
          response.statusCode = HttpStatus.notFound;
          await response.close();
          return;
        }
        response.headers.set('Cache-Control', 'public, max-age=86400');
        await _write(response, data, 'model/gltf-binary');
        return;
      }
      response.statusCode = HttpStatus.notFound;
      await response.close();
    } catch (_) {
      try {
        response.statusCode = HttpStatus.internalServerError;
        await response.close();
      } catch (_) {}
    }
  }

  Future<Uint8List?> _loadMissing(String key) async {
    final parts = key.split('/');
    if (parts.length != 2) return null;
    final body = PetBody.values.asNameMap()[parts.first];
    if (body == null) return null;
    for (final clip in PetClip.values) {
      if (PetClips.clipName(clip) == parts.last) {
        await _loadClip(clip, body);
        return _bytes[key];
      }
    }
    return null;
  }

  Future<void> _write(
    HttpResponse response,
    List<int> bytes,
    String contentType,
  ) async {
    response.statusCode = HttpStatus.ok;
    response.headers
      ..set('Content-Type', contentType)
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Cache-Control', 'public, max-age=86400')
      ..contentLength = bytes.length;
    response.add(bytes);
    await response.close();
  }

  List<int> utf8Html() => utf8.encode(_html);
}

const _html = r'''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
html, body {
  margin: 0;
  width: 100%;
  height: 100%;
  background: transparent !important;
  overflow: hidden;
}
#stage { position: relative; width: 100%; height: 100%; }
model-viewer {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  background-color: transparent !important;
  --poster-color: transparent;
  --progress-bar-color: transparent;
  --progress-bar-height: 0px;
  opacity: 0;
  pointer-events: none;
}
</style>
<script type="module" src="/model-viewer.min.js"></script>
</head>
<body>
<div id="stage">
  <model-viewer id="layer0"
    alt="Finni"
    shadow-intensity="0"
    interaction-prompt="none"
    disable-zoom
    disable-pan
    disable-tap
    touch-action="none"
    camera-orbit="0deg 70deg 98%"
    min-camera-orbit="0deg 70deg 98%"
    max-camera-orbit="0deg 70deg 98%"
    field-of-view="30deg"
    interpolation-decay="50"
    animation-crossfade-duration="0"
    environment-image="neutral">
  </model-viewer>
  <model-viewer id="layer1"
    alt="Finni"
    shadow-intensity="0"
    interaction-prompt="none"
    disable-zoom
    disable-pan
    disable-tap
    touch-action="none"
    camera-orbit="0deg 70deg 98%"
    min-camera-orbit="0deg 70deg 98%"
    max-camera-orbit="0deg 70deg 98%"
    field-of-view="30deg"
    interpolation-decay="50"
    animation-crossfade-duration="0"
    environment-image="neutral">
  </model-viewer>
</div>
<script>
const layers = [
  document.getElementById('layer0'),
  document.getElementById('layer1')
];

let front = 0;
let mode = 'idle';
let idleName = 'idle_good';
let playGen = 0;
let pendingAction = null;
let liveAction = null;

window.FinniBody = 'finni';

function url(name) {
  return '/clips/' + (window.FinniBody || 'finni') + '/' + name + '.glb';
}

function isReady(el, name) {
  return el.dataset.clip === name && el.dataset.ready === '1';
}

function afterPaint(fn) {
  requestAnimationFrame(function () {
    requestAnimationFrame(fn);
  });
}

function hide(el) {
  el.style.opacity = '0';
}

function playIdleLoop(el) {
  try { el.timeScale = 1; } catch (e) {}
  try {
    el.play({repetitions: Infinity, pingpong: true});
  } catch (e) {}
}

function loadClip(el, name, onReady) {
  if (isReady(el, name)) {
    onReady();
    return;
  }
  el.dataset.clip = name;
  el.dataset.ready = '0';
  const onLoad = function () {
    el.removeEventListener('load', onLoad);
    if (el.dataset.clip !== name) return;
    el.dataset.ready = '1';
    requestAnimationFrame(onReady);
  };
  el.addEventListener('load', onLoad);
  el.src = url(name);
}

function showIncoming(incoming, startPlay) {
  const outgoing = incoming === layers[0] ? layers[1] : layers[0];
  front = incoming === layers[0] ? 0 : 1;
  incoming.style.zIndex = '2';
  outgoing.style.zIndex = '1';
  startPlay(incoming);
  incoming.style.opacity = '1';
  afterPaint(function () {
    hide(outgoing);
  });
}

function playIdle(name) {
  idleName = name;
  pendingAction = null;
  liveAction = null;
  const shown = layers[front];
  if (mode === 'idle' && isReady(shown, name) && shown.style.opacity === '1') {
    return;
  }
  playGen += 1;
  const gen = playGen;
  mode = 'idle';

  if (isReady(shown, name)) {
    playIdleLoop(shown);
    shown.style.opacity = '1';
    return;
  }

  const incoming = layers[1 - front];
  loadClip(incoming, name, function () {
    if (playGen !== gen) return;
    showIncoming(incoming, playIdleLoop);
  });
}

function playAction(name, loop) {
  playGen += 1;
  const gen = playGen;
  pendingAction = name;
  liveAction = null;
  const incoming = layers[1 - front];
  loadClip(incoming, name, function () {
    if (playGen !== gen || pendingAction !== name) return;
    mode = 'action';
    liveAction = name;
    pendingAction = null;
    showIncoming(incoming, function (el) {
      try { el.timeScale = 1; } catch (e) {}
      try { el.currentTime = 0; } catch (e) {}
      try {
        el.play({
          repetitions: loop ? Infinity : 1,
          pingpong: !!loop
        });
      } catch (e) {}
    });
  });
}

function prepare(name) {
  if (pendingAction) return;
  loadClip(layers[1 - front], name, function () {});
}

function setBody(body) {
  if (window.FinniBody === body) return;
  window.FinniBody = body;
  playGen += 1;
  pendingAction = null;
  liveAction = null;
  layers.forEach(function (el) {
    el.dataset.clip = '';
    el.dataset.ready = '0';
  });
}

layers.forEach(function (el) {
  el.addEventListener('finished', function () {
    if (mode === 'action' && liveAction && el === layers[front] && el.dataset.clip === liveAction) {
      try { FinniPet.postMessage('finished'); } catch (e) {}
    }
    if (mode === 'idle' && !pendingAction && el === layers[front]) {
      playIdleLoop(el);
    }
  });
});

window.Finni = { setBody: setBody, playIdle: playIdle, playAction: playAction, prepare: prepare };
customElements.whenDefined('model-viewer').then(function () {
  try { FinniPet.postMessage('ready'); } catch (e) {}
});
</script>
</body>
</html>
''';

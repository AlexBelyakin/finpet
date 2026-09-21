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

  HttpServer? _server;
  String? baseUrl;
  PetBody _body = PetBody.finni;
  final _bytes = <String, Uint8List>{};
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
    await _loadClip(PetClip.idleGood, PetBody.finni);
    _viewerJs = await _loadAsset(
      'packages/model_viewer_plus/assets/model-viewer.min.js',
    );
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    baseUrl = 'http://${_server!.address.address}:${_server!.port}/';
    _server!.listen(_onRequest);
  }

  Future<void> ensureBody(PetBody body) async {
    if (_inTest) {
      _body = body;
      return;
    }
    await start();
    _body = body;
    await _loadClip(PetClip.idleGood, body);
    unawaited(_warmRest(body));
  }

  Future<void> _warmRest(PetBody body) async {
    for (final clip in PetClip.values) {
      if (_body != body) return;
      await _loadClip(clip, body);
    }
    _bytes.removeWhere((key, _) => !key.startsWith('${body.name}/'));
  }

  Future<void> _loadClip(PetClip clip, PetBody body) async {
    final key = PetClips.fileKey(clip, body);
    if (_bytes.containsKey(key)) return;
    _bytes[key] = await _loadAsset(PetClips.asset(clip, body));
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
}
.hidden { visibility: hidden; pointer-events: none; }
</style>
<script type="module" src="/model-viewer.min.js"></script>
</head>
<body>
<div id="stage">
  <model-viewer id="idle"
    src="/clips/finni/idle_good.glb"
    alt="Finni"
    autoplay
    shadow-intensity="0"
    interaction-prompt="none"
    disable-zoom
    disable-pan
    disable-tap
    touch-action="none"
    camera-orbit="8deg 78deg 105%"
    min-camera-orbit="8deg 78deg 105%"
    max-camera-orbit="8deg 78deg 105%"
    field-of-view="30deg"
    interpolation-decay="50"
    environment-image="neutral">
  </model-viewer>
  <model-viewer id="action"
    class="hidden"
    alt="Finni"
    shadow-intensity="0"
    interaction-prompt="none"
    disable-zoom
    disable-pan
    disable-tap
    touch-action="none"
    camera-orbit="8deg 78deg 105%"
    min-camera-orbit="8deg 78deg 105%"
    max-camera-orbit="8deg 78deg 105%"
    field-of-view="30deg"
    interpolation-decay="50"
    environment-image="neutral">
  </model-viewer>
</div>
<script>
const idle = document.getElementById('idle');
const action = document.getElementById('action');

window.FinniBody = 'finni';

function url(name) {
  return '/clips/' + (window.FinniBody || 'finni') + '/' + name + '.glb';
}

function setBody(body) {
  if (window.FinniBody === body) return;
  window.FinniBody = body;
  idle.dataset.clip = '';
  action.dataset.clip = '';
  action.loaded = false;
}

function showIdleLayer() {
  idle.classList.remove('hidden');
  action.classList.add('hidden');
  try { action.pause(); } catch (e) {}
  try { idle.play({repetitions: Infinity}); } catch (e) {}
}

function showActionLayer() {
  action.classList.remove('hidden');
  idle.classList.add('hidden');
  try { idle.pause(); } catch (e) {}
}

function playIdle(name) {
  showIdleLayer();
  if (idle.dataset.clip === name) {
    try { idle.play({repetitions: Infinity}); } catch (e) {}
    return;
  }
  idle.dataset.clip = name;
  idle.src = url(name);
}

function playAction(name, loop) {
  const start = function () {
    showActionLayer();
    try { action.play({repetitions: loop ? Infinity : 1}); } catch (e) {}
  };
  if (action.dataset.clip === name && action.loaded) {
    start();
    return;
  }
  action.dataset.clip = name;
  const onLoad = function () {
    action.removeEventListener('load', onLoad);
    start();
  };
  action.addEventListener('load', onLoad);
  action.src = url(name);
}

function prepare(name) {
  if (action.dataset.clip === name && action.loaded) return;
  action.dataset.clip = name;
  action.src = url(name);
}

idle.dataset.clip = 'idle_good';
idle.addEventListener('load', function () {
  try { idle.play({repetitions: Infinity}); } catch (e) {}
}, {once: true});

action.addEventListener('finished', function () {
  try { FinniPet.postMessage('finished'); } catch (e) {}
});

window.Finni = { setBody: setBody, playIdle: playIdle, playAction: playAction, prepare: prepare };
customElements.whenDefined('model-viewer').then(function () {
  try { FinniPet.postMessage('ready'); } catch (e) {}
});
</script>
</body>
</html>
''';

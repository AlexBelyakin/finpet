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

  Future<void> ensureBody(
    PetBody body, {
    PetClip? idle,
    bool warm = true,
  }) async {
    if (_inTest) {
      _body = body;
      return;
    }
    await start();
    final clip = idle ?? PetClip.idleGood;
    _body = body;
    _pinnedKey = PetClips.fileKey(clip, body);
    await _loadClip(clip, body);
    if (warm) unawaited(_warmLikely(body));
  }

  bool hasClip(PetClip clip, PetBody body) =>
      _bytes.containsKey(PetClips.fileKey(clip, body));

  Future<void> prefetch(PetClip clip, [PetBody? body]) async {
    if (_inTest) return;
    await start();
    await _loadClip(clip, body ?? _body);
  }

  Future<void> _warmLikely(PetBody body) async {
    for (final clip in PetClips.warmClips) {
      if (_body != body) return;
      await _loadClip(clip, body);
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

  bool _keep(String key) {
    if (key == _pinnedKey) return true;
    return key.endsWith('/idle_good');
  }

  void _trim() {
    if (_bytes.length <= _maxCached) return;
    for (final key in List<String>.from(_order)) {
      if (_bytes.length <= _maxCached) return;
      if (_keep(key)) continue;
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
let loadSeq = 0;
let pendingAction = null;
let liveAction = null;

window.FinniBody = 'finni';

function bodyName() {
  return window.FinniBody || 'finni';
}

function urlFor(body, name) {
  return '/clips/' + body + '/' + name + '.glb';
}

function srcIs(el, next) {
  const src = el.getAttribute('src') || '';
  return src === next || src.endsWith(next);
}

function isReady(el, body, name) {
  return el.dataset.clip === name &&
    el.dataset.body === body &&
    el.dataset.ready === '1';
}

function findLayer(body, name) {
  const next = urlFor(body, name);
  for (let i = 0; i < layers.length; i++) {
    const el = layers[i];
    if (isReady(el, body, name)) return el;
    if (srcIs(el, next) && (el.loaded || el.dataset.ready === '1')) return el;
  }
  return null;
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

function loadClip(el, name, onReady, bodyOpt) {
  const body = bodyOpt || bodyName();
  const next = urlFor(body, name);
  if (isReady(el, body, name) || (srcIs(el, next) && (el.loaded || el.dataset.ready === '1'))) {
    el.dataset.clip = name;
    el.dataset.body = body;
    el.dataset.ready = '1';
    onReady();
    return;
  }
  el.dataset.clip = name;
  el.dataset.body = body;
  const token = body + ':' + name + ':' + String(++loadSeq);
  el.dataset.load = token;
  const finish = function () {
    if (el.dataset.load !== token) return;
    if (el.dataset.clip !== name || el.dataset.body !== body) return;
    el.dataset.ready = '1';
    requestAnimationFrame(function () {
      paintTint();
      onReady();
    });
  };
  if (srcIs(el, next)) {
    if (el.loaded) {
      finish();
      return;
    }
    el.dataset.ready = '0';
    const onLoad = function () {
      el.removeEventListener('load', onLoad);
      finish();
    };
    el.addEventListener('load', onLoad);
    return;
  }
  el.dataset.ready = '0';
  const onLoad = function () {
    el.removeEventListener('load', onLoad);
    finish();
  };
  el.addEventListener('load', onLoad);
  el.src = next;
}

const tintRgb = {
  peach: [1.00, 0.58, 0.34],
  mint: [0.32, 0.84, 0.62],
  sky: [0.32, 0.70, 0.98],
  wave: [0.95, 0.62, 0.48],
  lilac: [0.78, 0.58, 0.98]
};

let tintGen = 0;
const albedoCache = {};

function hueDiff(a, b) {
  let d = Math.abs(a - b) % 360;
  return d > 180 ? 360 - d : d;
}

function rgbToHsl(r, g, b) {
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const l = (max + min) / 2;
  if (max === min) return { h: 0, s: 0, l: l };
  const d = max - min;
  const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
  let h = 0;
  if (max === r) h = (g - b) / d + (g < b ? 6 : 0);
  else if (max === g) h = (b - r) / d + 2;
  else h = (r - g) / d + 4;
  return { h: h * 60, s: s, l: l };
}

function hslToRgb(h, s, l) {
  h = ((h % 360) + 360) % 360;
  const c = (1 - Math.abs(2 * l - 1)) * s;
  const x = c * (1 - Math.abs((h / 60) % 2 - 1));
  const m = l - c / 2;
  let r = 0, g = 0, b = 0;
  if (h < 60) { r = c; g = x; }
  else if (h < 120) { r = x; g = c; }
  else if (h < 180) { g = c; b = x; }
  else if (h < 240) { g = x; b = c; }
  else if (h < 300) { r = x; b = c; }
  else { r = c; b = x; }
  return [r + m, g + m, b + m];
}

function saveMat(mat) {
  if (mat._finniSaved) return;
  const pbr = mat.pbrMetallicRoughness;
  let tex = null;
  try {
    tex = pbr.baseColorTexture && pbr.baseColorTexture.texture;
  } catch (e) {}
  let factor = [1, 1, 1, 1];
  try {
    if (pbr.baseColorFactor) factor = Array.from(pbr.baseColorFactor);
  } catch (e) {}
  mat._finniSaved = { factor: factor, tex: tex };
}

function restoreLayer(el) {
  const model = el.model;
  if (!model) return;
  model.materials.forEach(function (mat) {
    if (!mat._finniSaved) return;
    const pbr = mat.pbrMetallicRoughness;
    try {
      if (pbr.baseColorTexture) {
        pbr.baseColorTexture.setTexture(mat._finniSaved.tex || null);
      }
    } catch (e) {}
    try {
      pbr.setBaseColorFactor(mat._finniSaved.factor);
    } catch (e) {}
  });
}

function readGlbChunks(buf) {
  const dv = new DataView(buf);
  let o = 12;
  let json = null;
  let bin = null;
  while (o + 8 <= buf.byteLength) {
    const len = dv.getUint32(o, true);
    const type = String.fromCharCode(
      dv.getUint8(o + 4), dv.getUint8(o + 5),
      dv.getUint8(o + 6), dv.getUint8(o + 7)
    );
    const start = o + 8;
    if (type.indexOf('JSON') === 0) {
      json = JSON.parse(new TextDecoder().decode(new Uint8Array(buf, start, len)));
    } else if (type.indexOf('BIN') === 0) {
      bin = buf.slice(start, start + len);
    }
    o = start + len;
    if (o % 4) o += 4 - (o % 4);
  }
  return { json: json, bin: bin };
}

function blobToImage(blob) {
  return new Promise(function (resolve, reject) {
    const img = new Image();
    img.onload = function () { resolve(img); };
    img.onerror = reject;
    img.src = URL.createObjectURL(blob);
  });
}

async function albedoFromGlb(url) {
  if (albedoCache[url]) return albedoCache[url];
  const buf = await fetch(url).then(function (r) { return r.arrayBuffer(); });
  const chunks = readGlbChunks(buf);
  const json = chunks.json;
  const texIndex = json.materials[0].pbrMetallicRoughness.baseColorTexture.index;
  const imgIndex = json.textures[texIndex].source;
  const image = json.images[imgIndex];
  const view = json.bufferViews[image.bufferView];
  const bytes = new Uint8Array(chunks.bin, view.byteOffset || 0, view.byteLength);
  const img = await blobToImage(new Blob([bytes], {
    type: image.mimeType || 'image/jpeg'
  }));
  albedoCache[url] = img;
  return img;
}

async function albedoImage(tex) {
  if (!tex || !tex.source) return null;
  const src = tex.source;
  if (typeof src.createThumbnail === 'function') {
    try { return await src.createThumbnail(1024, 1024); } catch (e) {}
  }
  if (src.element && (src.element.naturalWidth || src.element.width)) {
    return src.element;
  }
  return src.element || null;
}

function recolorAlbedo(img, rgb) {
  const srcW = img.naturalWidth || img.width;
  const srcH = img.naturalHeight || img.height;
  if (!srcW || !srcH) return null;
  const scale = Math.min(1, 1024 / Math.max(srcW, srcH));
  const w = Math.max(1, Math.round(srcW * scale));
  const h = Math.max(1, Math.round(srcH * scale));
  const canvas = document.createElement('canvas');
  canvas.width = w;
  canvas.height = h;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(img, 0, 0, w, h);
  const data = ctx.getImageData(0, 0, w, h);
  const px = data.data;
  const bins = new Array(36).fill(0);
  for (let i = 0; i < px.length; i += 4) {
    const hsl = rgbToHsl(px[i] / 255, px[i + 1] / 255, px[i + 2] / 255);
    if (hsl.l > 0.18 && hsl.l < 0.84 && hsl.s > 0.12) {
      bins[Math.floor(hsl.h / 10) % 36] += 1;
    }
  }
  let best = 0;
  let bin = 0;
  for (let i = 0; i < 36; i++) {
    if (bins[i] > best) {
      best = bins[i];
      bin = i;
    }
  }
  const bodyHue = bin * 10 + 5;
  const tgt = rgbToHsl(rgb[0], rgb[1], rgb[2]);
  for (let i = 0; i < px.length; i += 4) {
    const hsl = rgbToHsl(px[i] / 255, px[i + 1] / 255, px[i + 2] / 255);
    if (hsl.l < 0.15) continue;
    if (hsl.l > 0.86 && hsl.s < 0.22) continue;
    if (hueDiff(hsl.h, bodyHue) > 46 && hsl.s > 0.16) continue;
    const out = hslToRgb(
      tgt.h,
      Math.min(1, tgt.s * 0.78 + hsl.s * 0.22),
      hsl.l * 0.58 + tgt.l * 0.42
    );
    px[i] = Math.round(out[0] * 255);
    px[i + 1] = Math.round(out[1] * 255);
    px[i + 2] = Math.round(out[2] * 255);
  }
  ctx.putImageData(data, 0, 0);
  return canvas.toDataURL('image/png');
}

async function paintLayer(el, rgb) {
  const model = el.model;
  if (!model || !model.materials || !model.materials.length) return;
  const key = el.dataset.body + ':' + el.dataset.clip + ':' + rgb.join(',');
  if (el._tintKey === key && el._tintTex) {
    return applyTintTex(el, el._tintTex);
  }
  const clipKey = el.dataset.body + ':' + el.dataset.clip;
  if (el._tintClip !== clipKey) {
    el._tintClip = clipKey;
    el._albedoImg = null;
    el._tintTex = null;
    el._tintKey = '';
  }
  let img = el._albedoImg;
  if (!img) {
    const clipUrl = urlFor(el.dataset.body || bodyName(), el.dataset.clip || idleName);
    try { img = await albedoFromGlb(clipUrl); } catch (e) {}
    if (!img) {
      const mat0 = model.materials[0];
      saveMat(mat0);
      try { img = await albedoImage(mat0._finniSaved && mat0._finniSaved.tex); } catch (e) {}
    }
    el._albedoImg = img || null;
  }
  if (!img || typeof el.createTexture !== 'function') return;
  const url = recolorAlbedo(img, rgb);
  if (!url) return;
  const tex = await el.createTexture(url);
  el._tintTex = tex;
  el._tintKey = key;
  applyTintTex(el, tex);
}

function applyTintTex(el, tex) {
  const model = el.model;
  if (!model) return;
  model.materials.forEach(function (mat) {
    saveMat(mat);
    const pbr = mat.pbrMetallicRoughness;
    try {
      if (pbr.baseColorTexture) pbr.baseColorTexture.setTexture(tex);
    } catch (e) {}
    try {
      pbr.setBaseColorFactor([1, 1, 1, 1]);
    } catch (e) {}
  });
}

function clearCssTint() {
  const stage = document.getElementById('stage');
  if (stage) stage.style.filter = 'none';
  layers.forEach(function (el) {
    el.style.filter = 'none';
  });
}

function paintTint() {
  const gen = ++tintGen;
  const rgb = tintRgb[window.FinniTint || ''];
  clearCssTint();
  layers.forEach(function (el) {
    if (!rgb) {
      restoreLayer(el);
      return;
    }
    paintLayer(el, rgb).then(function () {
      if (gen !== tintGen) return;
    });
  });
}

function setTint(color) {
  window.FinniTint = color || '';
  paintTint();
}

function showIncoming(incoming, startPlay) {
  const outgoing = incoming === layers[0] ? layers[1] : layers[0];
  front = incoming === layers[0] ? 0 : 1;
  incoming.style.zIndex = '2';
  outgoing.style.zIndex = '1';
  startPlay(incoming);
  incoming.style.opacity = '1';
  paintTint();
  afterPaint(function () {
    hide(outgoing);
  });
}

function playIdle(name) {
  idleName = name;
  pendingAction = null;
  liveAction = null;
  const body = bodyName();
  playGen += 1;
  const gen = playGen;
  mode = 'idle';
  const have = findLayer(body, name);
  if (have) {
    have.dataset.clip = name;
    have.dataset.body = body;
    have.dataset.ready = '1';
    if (have === layers[front]) {
      playIdleLoop(have);
      have.style.opacity = '1';
      return;
    }
    showIncoming(have, playIdleLoop);
    return;
  }
  const incoming = layers[1 - front];
  loadClip(incoming, name, function () {
    if (playGen !== gen) return;
    showIncoming(incoming, playIdleLoop);
  }, body);
}

function playAction(name, loop) {
  const body = bodyName();
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
  }, body);
}

function prepare(name) {
  if (pendingAction) return;
  loadClip(layers[1 - front], name, function () {}, bodyName());
}

function preload(name, body) {
  if (findLayer(body, name)) return;
  const hidden = layers[1 - front];
  if (hidden.dataset.body === bodyName() && hidden.dataset.ready === '1') return;
  loadClip(hidden, name, function () {}, body);
}

function setBody(body) {
  window.FinniBody = body;
}

function show(body, name, asAction, loop, color) {
  window.FinniBody = body;
  if (color !== undefined) window.FinniTint = color || '';
  pendingAction = null;
  liveAction = null;
  paintTint();
  if (asAction) playAction(name, !!loop);
  else playIdle(name);
}

layers.forEach(function (el) {
  el.addEventListener('load', function () {
    paintTint();
  });
  el.addEventListener('finished', function () {
    if (mode === 'action' && liveAction && el === layers[front] && el.dataset.clip === liveAction) {
      try { FinniPet.postMessage('finished'); } catch (e) {}
    }
    if (mode === 'idle' && !pendingAction && el === layers[front]) {
      playIdleLoop(el);
    }
  });
});

window.Finni = { setBody: setBody, playIdle: playIdle, playAction: playAction, prepare: prepare, show: show, preload: preload, setTint: setTint };
customElements.whenDefined('model-viewer').then(function () {
  try { FinniPet.postMessage('ready'); } catch (e) {}
});
</script>
</body>
</html>
''';

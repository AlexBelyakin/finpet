import 'dart:async';
import 'dart:convert';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/pet/pet_model_bridge.dart';
import 'package:finpet/data/pet/pet_model_runtime.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

bool get _inWidgetTest => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

class PetViewerSession {
  PetViewerSession._();
  static final instance = PetViewerSession._();

  WebViewController? controller;
  VoidCallback? onFinished;
  PetClip? currentClip;
  PetClip? _wantClip;
  PetBody? _wantBody;
  PetColor? _wantColor;
  var _wantTint = true;
  Future<void>? _preparing;
  Completer<void>? _ready;
  var _applyGen = 0;
  var _warmingOther = false;

  Future<void> ensure() {
    if (_inWidgetTest) return Future.value();
    return _preparing ??= _prepare();
  }

  Future<void> _prepare() async {
    await PetModelRuntime.instance.start();
    final url = PetModelRuntime.instance.baseUrl;
    if (url == null) return;

    final ready = Completer<void>();
    _ready = ready;
    final web = WebViewController();
    controller = web;
    await web.setBackgroundColor(const Color(0x00000000));
    await web.setJavaScriptMode(JavaScriptMode.unrestricted);
    final platform = web.platform;
    if (platform is AndroidWebViewController) {
      await platform.setMediaPlaybackRequiresUserGesture(false);
    }
    await web.addJavaScriptChannel(
      'FinniPet',
      onMessageReceived: (message) {
        if (message.message == 'ready') {
          if (!ready.isCompleted) ready.complete();
          return;
        }
        if (message.message == 'finished') {
          final clip = currentClip;
          if (clip != null && PetClips.returnsToIdle(clip)) {
            onFinished?.call();
          }
        }
      },
    );
    await web.loadRequest(Uri.parse(url));
  }

  Future<void> _awaitReady() async {
    final ready = _ready;
    if (ready == null || ready.isCompleted) return;
    await ready.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
  }

  Future<void> apply(
    PetClip clip,
    PetBody body, {
    PetColor? color,
    bool tint = true,
  }) async {
    _wantClip = clip;
    _wantBody = body;
    _wantColor = color;
    _wantTint = tint;
    final gen = ++_applyGen;
    try {
      await ensure();
      if (gen != _applyGen) return;
      await _awaitReady();
      if (gen != _applyGen) return;
      final web = controller;
      if (web == null) return;
      final need = _wantClip ?? clip;
      final who = _wantBody ?? body;
      if (!PetModelRuntime.instance.hasClip(need, who)) {
        PetModelBridge.applying.value = true;
        await PetModelRuntime.instance.ensureBody(
          who,
          idle: PetClips.returnsToIdle(need) ? null : need,
          warm: false,
        );
        if (gen != _applyGen) return;
      }
      final shownClip = _wantClip ?? clip;
      final shownBody = _wantBody ?? body;
      currentClip = shownClip;
      final bodyJs = jsonEncode(shownBody.name);
      final nameJs = jsonEncode(PetClips.clipName(shownClip));
      final asAction = PetClips.returnsToIdle(shownClip);
      final colorJs = jsonEncode(
        _wantTint && _wantColor != null && _wantColor != PetColor.natural
            ? _wantColor!.name
            : '',
      );
      await web.runJavaScript(
        'Finni.show($bodyJs, $nameJs, ${asAction ? 'true' : 'false'}, ${PetClips.isLoop(shownClip)}, $colorJs);',
      );
      if (gen == _applyGen && !asAction) {
        unawaited(_preloadOther(shownBody));
      }
    } finally {
      if (gen == _applyGen) PetModelBridge.applying.value = false;
    }
  }

  Future<void> tintOnly(PetColor? color, {required bool tint}) async {
    _wantColor = color;
    _wantTint = tint;
    await _awaitReady();
    final web = controller;
    if (web == null) return;
    final colorJs = jsonEncode(
      tint && color != null && color != PetColor.natural ? color.name : '',
    );
    await web.runJavaScript('Finni.setTint($colorJs);');
  }

  Future<void> _preloadOther(PetBody shown) async {
    if (_warmingOther) return;
    _warmingOther = true;
    try {
      final other = shown == PetBody.finni ? PetBody.nori : PetBody.finni;
      await PetModelRuntime.instance.ensureBody(
        other,
        idle: PetClip.idleGood,
        warm: false,
      );
      final web = controller;
      if (web == null) return;
      final bodyJs = jsonEncode(other.name);
      await web.runJavaScript('Finni.preload("idle_good", $bodyJs);');
    } finally {
      _warmingOther = false;
    }
  }

  Future<void> prepareClip(PetClip clip, PetBody body) async {
    await ensure();
    await _awaitReady();
    final web = controller;
    if (web == null) return;
    await PetModelRuntime.instance.ensureBody(body);
    await PetModelRuntime.instance.prefetch(clip, body);
    final bodyJs = jsonEncode(body.name);
    final nameJs = jsonEncode(PetClips.clipName(clip));
    await web.runJavaScript('Finni.setBody($bodyJs); Finni.prepare($nameJs);');
  }

  Widget? view() {
    final web = controller;
    if (web == null) return null;
    return WebViewWidget(controller: web);
  }
}

Future<void> preparePetViewerImpl() => PetViewerSession.instance.ensure();

Future<void> primePetViewerImpl(PetClip clip, PetBody body) {
  return PetViewerSession.instance.apply(clip, body);
}

Widget? petViewerWarmupImpl() {
  final view = PetViewerSession.instance.view();
  if (view == null) return null;
  return Builder(
    builder: (context) {
      final size = AppLayout.petSize(context, phone: 300, tablet: 440);
      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: IgnorePointer(child: view),
        ),
      );
    },
  );
}

Widget buildPetModelImpl({
  required PetClip clip,
  PetBody body = PetBody.finni,
  PetColor? color,
  bool tint = true,
  VoidCallback? onOneShotFinished,
}) {
  if (_inWidgetTest) {
    return const FittedBox(
      child: Icon(Icons.pets_rounded, color: AppTheme.mint),
    );
  }
  return _HostedPetModel(
    clip: clip,
    body: body,
    color: color,
    tint: tint,
    onOneShotFinished: onOneShotFinished,
  );
}

class _HostedPetModel extends StatefulWidget {
  const _HostedPetModel({
    required this.clip,
    required this.body,
    this.color,
    this.tint = true,
    this.onOneShotFinished,
  });

  final PetClip clip;
  final PetBody body;
  final PetColor? color;
  final bool tint;
  final VoidCallback? onOneShotFinished;

  @override
  State<_HostedPetModel> createState() => _HostedPetModelState();
}

class _HostedPetModelState extends State<_HostedPetModel> {
  @override
  void initState() {
    super.initState();
    PetModelBridge.onPrepare = _prepare;
    PetModelBridge.onResume = _resume;
    PetViewerSession.instance.onFinished = widget.onOneShotFinished;
    _attach();
  }

  @override
  void dispose() {
    if (PetModelBridge.onPrepare == _prepare) {
      PetModelBridge.onPrepare = null;
    }
    if (PetModelBridge.onResume == _resume) {
      PetModelBridge.onResume = null;
    }
    if (PetViewerSession.instance.onFinished == widget.onOneShotFinished) {
      PetViewerSession.instance.onFinished = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _HostedPetModel oldWidget) {
    super.didUpdateWidget(oldWidget);
    PetViewerSession.instance.onFinished = widget.onOneShotFinished;
    if (oldWidget.clip != widget.clip || oldWidget.body != widget.body) {
      unawaited(_apply());
    } else if (oldWidget.color != widget.color || oldWidget.tint != widget.tint) {
      unawaited(
        PetViewerSession.instance.tintOnly(widget.color, tint: widget.tint),
      );
    }
  }

  Future<void> _apply() {
    return PetViewerSession.instance.apply(
      widget.clip,
      widget.body,
      color: widget.color,
      tint: widget.tint,
    );
  }

  Future<void> _attach() async {
    await PetViewerSession.instance.ensure();
    if (!mounted) return;
    setState(() {});
    await _apply();
  }

  Future<void> _prepare(PetClip clip) {
    return PetViewerSession.instance.prepareClip(clip, widget.body);
  }

  Future<void> _resume() {
    return _apply();
  }

  @override
  Widget build(BuildContext context) {
    return PetViewerSession.instance.view() ?? const SizedBox.expand();
  }
}

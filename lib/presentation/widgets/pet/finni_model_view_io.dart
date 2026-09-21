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
  Future<void>? _preparing;
  Completer<void>? _ready;

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

  Future<void> apply(PetClip clip, PetBody body) async {
    await ensure();
    await _awaitReady();
    final web = controller;
    if (web == null) return;
    await PetModelRuntime.instance.ensureBody(
      body,
      idle: PetClips.returnsToIdle(clip) ? null : clip,
    );
    currentClip = clip;
    final bodyJs = jsonEncode(body.name);
    final nameJs = jsonEncode(PetClips.clipName(clip));
    await web.runJavaScript('Finni.setBody($bodyJs);');
    if (PetClips.returnsToIdle(clip)) {
      await web.runJavaScript(
        'Finni.playAction($nameJs, ${PetClips.isLoop(clip)});',
      );
    } else {
      await web.runJavaScript('Finni.playIdle($nameJs);');
    }
  }

  Future<void> prepareClip(PetClip clip, PetBody body) async {
    await ensure();
    await _awaitReady();
    final web = controller;
    if (web == null) return;
    await PetModelRuntime.instance.ensureBody(body);
    await PetModelRuntime.instance.prefetch(clip);
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
    onOneShotFinished: onOneShotFinished,
  );
}

class _HostedPetModel extends StatefulWidget {
  const _HostedPetModel({
    required this.clip,
    required this.body,
    this.onOneShotFinished,
  });

  final PetClip clip;
  final PetBody body;
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
      unawaited(PetViewerSession.instance.apply(widget.clip, widget.body));
    }
  }

  Future<void> _attach() async {
    await PetViewerSession.instance.ensure();
    if (!mounted) return;
    setState(() {});
    await PetViewerSession.instance.apply(widget.clip, widget.body);
  }

  Future<void> _prepare(PetClip clip) {
    return PetViewerSession.instance.prepareClip(clip, widget.body);
  }

  Future<void> _resume() {
    return PetViewerSession.instance.apply(widget.clip, widget.body);
  }

  @override
  Widget build(BuildContext context) {
    return PetViewerSession.instance.view() ?? const SizedBox.expand();
  }
}

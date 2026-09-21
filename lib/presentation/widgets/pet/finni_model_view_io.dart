import 'dart:convert';

import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/pet/pet_model_bridge.dart';
import 'package:finpet/data/pet/pet_model_runtime.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

bool get _inWidgetTest => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

Widget buildPetModelImpl({
  required PetClip clip,
  VoidCallback? onOneShotFinished,
}) {
  if (_inWidgetTest) {
    return const FittedBox(
      child: Icon(Icons.pets_rounded, color: AppTheme.mint),
    );
  }
  return _HostedPetModel(clip: clip, onOneShotFinished: onOneShotFinished);
}

class _HostedPetModel extends StatefulWidget {
  const _HostedPetModel({required this.clip, this.onOneShotFinished});

  final PetClip clip;
  final VoidCallback? onOneShotFinished;

  @override
  State<_HostedPetModel> createState() => _HostedPetModelState();
}

class _HostedPetModelState extends State<_HostedPetModel> {
  WebViewController? _web;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    PetModelBridge.onPrepare = _prepare;
    _boot();
  }

  @override
  void dispose() {
    if (PetModelBridge.onPrepare == _prepare) {
      PetModelBridge.onPrepare = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _HostedPetModel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clip != widget.clip) {
      _apply(widget.clip);
    }
  }

  Future<void> _boot() async {
    await PetModelRuntime.instance.start();
    final url = PetModelRuntime.instance.baseUrl;
    if (!mounted || url == null) return;

    final controller = WebViewController();
    _web = controller;
    await controller.setBackgroundColor(const Color(0x00000000));
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      await platform.setMediaPlaybackRequiresUserGesture(false);
    }
    await controller.addJavaScriptChannel(
      'FinniPet',
      onMessageReceived: (message) {
        if (message.message == 'ready') {
          _apply(widget.clip);
          return;
        }
        if (message.message == 'finished' &&
            PetClips.returnsToIdle(widget.clip)) {
          widget.onOneShotFinished?.call();
        }
      },
    );
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          if (!mounted) return;
          setState(() => _ready = true);
        },
      ),
    );
    await controller.loadRequest(Uri.parse(url));
  }

  Future<void> _apply(PetClip clip) async {
    final web = _web;
    if (web == null) return;
    final name = jsonEncode(PetClips.fileKey(clip));
    if (PetClips.returnsToIdle(clip)) {
      final loop = PetClips.isLoop(clip);
      await web.runJavaScript('Finni.playAction($name, $loop);');
    } else {
      await web.runJavaScript('Finni.playIdle($name);');
    }
  }

  Future<void> _prepare(PetClip clip) async {
    final web = _web;
    if (web == null) return;
    final name = jsonEncode(PetClips.fileKey(clip));
    await web.runJavaScript('Finni.prepare($name);');
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _web == null) {
      return const SizedBox.expand();
    }
    return WebViewWidget(controller: _web!);
  }
}

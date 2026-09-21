import 'package:flutter/material.dart';

abstract final class AppLayout {
  static const tabletShortest = 600.0;
  static const wideWidth = 840.0;

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isTablet(BuildContext context) =>
      sizeOf(context).shortestSide >= tabletShortest;

  static bool isWide(BuildContext context) => sizeOf(context).width >= wideWidth;

  static double petSize(
    BuildContext context, {
    double phone = 210,
    double tablet = 320,
  }) =>
      isTablet(context) ? tablet : phone;

  static int columns(BuildContext context, {int phone = 1, int tablet = 2}) =>
      isTablet(context) ? tablet : phone;

  static EdgeInsets pagePadding(BuildContext context) {
    final pad = isWide(context) ? 28.0 : 16.0;
    return EdgeInsets.fromLTRB(pad, 8, pad, 16);
  }

  static double iconBox(BuildContext context) => isTablet(context) ? 56 : 48;

  /// Нижняя часть комнаты (пол), чтобы питомец не висел на стене.
  static Alignment roomFocus(BuildContext context) {
    if (isWide(context)) return const Alignment(0, 0.38);
    if (isTablet(context)) return const Alignment(0, 0.52);
    return const Alignment(0, 0.66);
  }

  static double petFloorPad(BuildContext context) =>
      isWide(context) ? 28 : (isTablet(context) ? 16 : 8);

  /// Декод картинки под ширину экрана, а не в исходных 4–7 МБ.
  static int imageCacheWidth(BuildContext context, {int max = 1600}) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (sizeOf(context).width * dpr).round().clamp(320, max);
  }
}

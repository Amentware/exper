import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // For vertical scrolling, use BouncingScrollPhysics
    // For horizontal scrolling, the parent ScrollConfiguration will use ClampingScrollPhysics
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Color getGlowColor(BuildContext context) {
    return Colors.transparent;
  }

  @override
  bool shouldNotify(ScrollBehavior oldDelegate) {
    return true;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

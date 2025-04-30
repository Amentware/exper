import 'package:flutter/material.dart';

class AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
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
}

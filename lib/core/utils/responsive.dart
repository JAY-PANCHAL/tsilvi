import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 700;
  }

  static int gridCount(BuildContext context, {int mobile = 1, int tablet = 2}) {
    return isTablet(context) ? tablet : mobile;
  }
}

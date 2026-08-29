import 'package:flutter/material.dart';

import 'constants.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class Responsive {
  Responsive._();

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < AppConstants.mobileBreakpoint) {
      return DeviceType.mobile;
    }

    if (width < AppConstants.tabletBreakpoint) {
      return DeviceType.tablet;
    }

    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) {
    return deviceType(context) == DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return deviceType(context) == DeviceType.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return deviceType(context) == DeviceType.desktop;
  }

  static bool isMobileOrTablet(BuildContext context) {
    final type = deviceType(context);

    return type == DeviceType.mobile ||
        type == DeviceType.tablet;
  }
}
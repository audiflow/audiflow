import '../constants/layout_constants.dart';

/// Device form factor classification.
enum DeviceFormFactor {
  /// Phone-sized device (portrait only).
  phone,

  /// Tablet-sized device (portrait + landscape).
  tablet,
}

/// Utilities for device form factor detection.
class DeviceUtils {
  DeviceUtils._();

  /// Returns the [DeviceFormFactor] based on the screen's shortest side.
  static DeviceFormFactor formFactor(double shortestSide) {
    if (LayoutConstants.tabletBreakpoint <= shortestSide) {
      return DeviceFormFactor.tablet;
    }
    return DeviceFormFactor.phone;
  }

  /// Returns true if [shortestSide] indicates a tablet.
  static bool isTablet(double shortestSide) {
    return formFactor(shortestSide) == DeviceFormFactor.tablet;
  }
}

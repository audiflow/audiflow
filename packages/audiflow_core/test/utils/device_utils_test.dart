import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceFormFactor', () {
    test('has phone and tablet values', () {
      expect(DeviceFormFactor.values, contains(DeviceFormFactor.phone));
      expect(DeviceFormFactor.values, contains(DeviceFormFactor.tablet));
    });
  });

  group('DeviceUtils.formFactor', () {
    test('returns phone for shortestSide below breakpoint', () {
      expect(DeviceUtils.formFactor(599), DeviceFormFactor.phone);
    });
    test('returns tablet for shortestSide at breakpoint', () {
      expect(DeviceUtils.formFactor(600), DeviceFormFactor.tablet);
    });
    test('returns tablet for shortestSide above breakpoint', () {
      expect(DeviceUtils.formFactor(744), DeviceFormFactor.tablet);
    });
    test('returns phone for zero', () {
      expect(DeviceUtils.formFactor(0), DeviceFormFactor.phone);
    });
  });

  group('DeviceUtils.isTablet', () {
    test('returns false for phone-sized screen', () {
      expect(DeviceUtils.isTablet(390), false);
    });
    test('returns true for tablet-sized screen', () {
      expect(DeviceUtils.isTablet(744), true);
    });
  });
}

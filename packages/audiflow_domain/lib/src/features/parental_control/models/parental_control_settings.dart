import 'package:isar_community/isar.dart';

part 'parental_control_settings.g.dart';

@collection
class ParentalControlSettings {
  Id id = 0; // singleton

  String? pinHashBase64;
  String? pinSaltBase64;
  int pinIterations = 100000;

  bool restrictedModeEnabled = false;
  int unlockTimeoutSeconds = 300;
  bool biometricUnlockEnabled = false;

  int failedAttempts = 0;
  DateTime? lockoutUntil;
}

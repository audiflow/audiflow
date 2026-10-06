import 'package:permission_handler/permission_handler.dart';

/// Current notification permission, asking for it when still undecided.
///
/// Android reports a permanently denied permission as plain `denied` from
/// `status`; only `request()` reveals it (and resolves instantly, without a
/// dialog). So it always requests unless the status is already conclusive.
Future<PermissionStatus> resolveNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isGranted || status.isPermanentlyDenied) return status;
  return Permission.notification.request();
}

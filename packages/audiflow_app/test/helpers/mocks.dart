import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

// Generate mocks with: dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([SharedPreferences, PackageInfo, Dio, Logger])
void main() {}

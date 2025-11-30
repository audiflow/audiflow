import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';

/// Provider for Dio HTTP client
final dioProvider = Provider<Dio>((ref) {
  throw UnimplementedError('dioProvider must be overridden at startup');
});

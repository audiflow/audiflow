import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/analytics_service.dart';

part 'analytics_providers.g.dart';

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => throw UnimplementedError(
  'analyticsServiceProvider must be overridden in app bootstrap',
);

import 'dart:async';
import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';

/// Whether [error] is an expected runtime condition rather than a defect:
/// the device is offline or the network stalled, or the user cancelled.
///
/// These happen routinely on mobile networks and are not actionable, so
/// error monitoring keeps them out of the issue stream (at most a
/// breadcrumb). HTTP status failures are not included: a server answering
/// with an error is worth seeing.
bool isExpectedFailure(Object error) => switch (error) {
  TimeoutException() || SocketException() || HttpException() => true,
  NetworkException() => true,
  DownloadException(:final type) =>
    type == DownloadErrorType.cancelled ||
        type == DownloadErrorType.networkUnavailable,
  // Transport-level failures carry no status code; see
  // PodcastException.network.
  PodcastException(:final code) => code == _podcastTransportFailureCode,
  DioException(:final type, error: final cause) =>
    type == DioExceptionType.cancel ||
        isConnectivityFailure(error) ||
        (cause != null && isExpectedFailure(cause)),
  _ => false,
};

const _podcastTransportFailureCode = 'PODCAST_NETWORK_ERROR';

/// Short, telemetry-safe label for [error]: its type, refined with the Dio
/// failure type and HTTP status. Never includes the message, which can
/// carry URLs with credentials or tokens.
String errorCategory(Object error) => switch (error) {
  DioException(:final type, :final response) => [
    'DioException',
    type.name,
    if (response?.statusCode case final status?) '$status',
  ].join('.'),
  _ => error.runtimeType.toString(),
};

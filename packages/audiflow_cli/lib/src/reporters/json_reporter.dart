import 'dart:convert';

import '../models/extraction_result.dart';

/// Formats extraction results as JSON.
class JsonReporter {
  JsonReporter([StringSink? sink]) : _sink = sink ?? StringBuffer();

  final StringSink _sink;
  final List<Map<String, dynamic>> _results = [];
  String? _feedUrl;
  String? _patternId;

  /// Starts the report with metadata.
  void start({required String feedUrl, required String? patternId}) {
    _feedUrl = feedUrl;
    _patternId = patternId;
    _results.clear();
  }

  /// Adds a result to the report.
  void addResult(ExtractionResult result) {
    _results.add(result.toJson());
  }

  /// Finishes the report and writes to sink.
  void finish({required int total, required int passed, required int failed}) {
    final output = {
      'feed_url': _feedUrl,
      'pattern_id': _patternId,
      'results': _results,
      'summary': {'total': total, 'pass': passed, 'fail': failed},
    };

    _sink.write(const JsonEncoder.withIndent('  ').convert(output));
  }
}

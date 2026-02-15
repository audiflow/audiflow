import 'package:freezed_annotation/freezed_annotation.dart';

import 'opml_entry.dart';

part 'opml_import_result.freezed.dart';

/// Tracks outcomes of an OPML import operation.
@freezed
class OpmlImportResult with _$OpmlImportResult {
  const factory OpmlImportResult({
    required List<OpmlEntry> succeeded,
    required List<OpmlEntry> alreadySubscribed,
    required List<OpmlEntry> failed,
  }) = _OpmlImportResult;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'opml_entry.freezed.dart';

/// A single podcast entry parsed from an OPML file.
@freezed
class OpmlEntry with _$OpmlEntry {
  const factory OpmlEntry({
    required String title,
    required String feedUrl,
    String? htmlUrl,
  }) = _OpmlEntry;
}

/// How a download was requested.
///
/// Retention rules (keep count, played cleanup) only ever remove [auto]
/// downloads; anything the listener asked for explicitly is left alone.
enum DownloadOrigin {
  /// Requested by the listener (single, batch, or season download).
  manual,

  /// Enqueued by the auto-download pipeline after a feed sync.
  auto;

  /// Value persisted in `DownloadTask.origin`.
  int get dbValue => index;

  /// Unknown values map to [manual] so retention never deletes a download
  /// whose origin it cannot vouch for.
  static DownloadOrigin fromDbValue(int value) =>
      value == auto.index ? auto : manual;
}

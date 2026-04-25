/// Gemma 4 edge variant supported for on-device voice command parsing.
///
/// Sizes are approximate Q4-quantized download sizes; minimum-RAM figures are
/// the device-total RAM thresholds the capability check uses to decide
/// whether a variant is offerable on a given device.
enum GemmaModelVariant {
  /// Gemma 4 E2B — 2B effective params, ~1.3 GB on disk, runs on mid-range
  /// phones.
  e2b(
    fileName: 'gemma-4-e2b-it.litertlm',
    approximateSizeMb: 1300,
    minimumDeviceRamMb: 3000,
  ),

  /// Gemma 4 E4B — 4B effective params, ~2.5 GB on disk, flagship-class
  /// devices only.
  e4b(
    fileName: 'gemma-4-e4b-it.litertlm',
    approximateSizeMb: 2500,
    minimumDeviceRamMb: 5000,
  )
  ;

  const GemmaModelVariant({
    required this.fileName,
    required this.approximateSizeMb,
    required this.minimumDeviceRamMb,
  });

  /// On-disk filename used by the underlying inference plugin to identify
  /// the cached model.
  final String fileName;

  /// Approximate download size in megabytes (4-bit quantized).
  final int approximateSizeMb;

  /// Minimum total device RAM, in megabytes, required to run this variant.
  final int minimumDeviceRamMb;
}

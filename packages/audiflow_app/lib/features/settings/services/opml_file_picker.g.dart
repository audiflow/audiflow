// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opml_file_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(opmlFilePicker)
final opmlFilePickerProvider = OpmlFilePickerProvider._();

final class OpmlFilePickerProvider
    extends $FunctionalProvider<OpmlFilePicker, OpmlFilePicker, OpmlFilePicker>
    with $Provider<OpmlFilePicker> {
  OpmlFilePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opmlFilePickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opmlFilePickerHash();

  @$internal
  @override
  $ProviderElement<OpmlFilePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OpmlFilePicker create(Ref ref) {
    return opmlFilePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpmlFilePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpmlFilePicker>(value),
    );
  }
}

String _$opmlFilePickerHash() => r'308f986da768605e91c34aaa7e41f5d840347010';

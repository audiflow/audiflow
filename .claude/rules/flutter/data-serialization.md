---
paths: **/*.dart
---
# Data Serialization

* JSON keys are camelCase. Match Dart field names directly.
* Do NOT use `fieldRename: FieldRename.snake` on `@JsonSerializable` classes. The smartplaylist config and force-update config both ship camelCase keys; staying uniform across the ecosystem reduces drift risk.
* If an upstream service forces a different key shape, isolate the difference inside a hand-written `fromJson` (see smartplaylist models for the pattern) rather than flipping the renamer globally.

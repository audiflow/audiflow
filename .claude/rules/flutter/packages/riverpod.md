---
paths: **/*.dart
---
# State Management

* Use Riverpod as the primary state management solution.
* Always use `@riverpod` annotation with code generation.
* Use `NotifierProvider` and `AsyncNotifierProvider` exclusively.
* Avoid: `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`.
* Use `ref.invalidate()` to manually trigger provider updates.
* Implement proper cancellation of async operations on disposal.
* Only use `ValueNotifier` for trivial ephemeral UI state.

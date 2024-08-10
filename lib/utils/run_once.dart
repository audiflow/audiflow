import 'dart:async';

FutureOr<T> runOnce<T>(FutureOr<T> Function() fn) {
  late FutureOr<T> result;
  var ran = false;
  return () {
    if (!ran) {
      result = fn();
      ran = true;
    }
    return result;
  }();
}

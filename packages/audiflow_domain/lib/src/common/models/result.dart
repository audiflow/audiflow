/// Result type for handling success and failure
sealed class Result<T> {
  const Result();
}

/// Success result containing data
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// Failure result containing error
class Failure<T> extends Result<T> {
  const Failure(this.error);

  final Object error;
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data or null
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Get error or null
  Object? get errorOrNull => isFailure ? (this as Failure<T>).error : null;

  /// Map result to another type
  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final error) => Failure(error),
    };
  }
}

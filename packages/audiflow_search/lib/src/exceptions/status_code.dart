/// gRPC canonical status codes.
///
/// These codes are based on the gRPC specification and provide
/// standardized error categorization across distributed systems.
///
/// See: https://grpc.io/docs/guides/error/
enum StatusCode {
  /// Not an error; returned on success.
  ok(0),

  /// The operation was cancelled (typically by the caller).
  cancelled(1),

  /// Unknown error. An example of where this error may be returned is
  /// if a Status value received from another address space belongs to
  /// an error-space that is not known in this address space.
  unknown(2),

  /// Client specified an invalid argument. Note that this differs
  /// from FAILED_PRECONDITION. INVALID_ARGUMENT indicates arguments
  /// that are problematic regardless of the state of the system
  /// (e.g., a malformed file name).
  invalidArgument(3),

  /// Deadline expired before operation could complete. For operations
  /// that change the state of the system, this error may be returned
  /// even if the operation has completed successfully.
  deadlineExceeded(4),

  /// Some requested entity (e.g., file or directory) was not found.
  notFound(5),

  /// Some entity that we attempted to create (e.g., file or directory)
  /// already exists.
  alreadyExists(6),

  /// The caller does not have permission to execute the specified
  /// operation. PERMISSION_DENIED must not be used for rejections
  /// caused by exhausting some resource (use RESOURCE_EXHAUSTED
  /// instead for those errors).
  permissionDenied(7),

  /// Some resource has been exhausted, perhaps a per-user quota, or
  /// perhaps the entire file system is out of space.
  resourceExhausted(8),

  /// Operation was rejected because the system is not in a state
  /// required for the operation's execution. For example, directory
  /// to be deleted may be non-empty, an rmdir operation is applied to
  /// a non-directory, etc.
  failedPrecondition(9),

  /// The operation was aborted, typically due to a concurrency issue
  /// like sequencer check failures, transaction aborts, etc.
  aborted(10),

  /// Operation was attempted past the valid range. E.g., seeking or
  /// reading past end of file.
  outOfRange(11),

  /// Operation is not implemented or not supported/enabled in this service.
  unimplemented(12),

  /// Internal errors. Means some invariants expected by underlying
  /// system has been broken. If you see one of these errors,
  /// something is very broken.
  internal(13),

  /// The service is currently unavailable. This is a most likely a
  /// transient condition and may be corrected by retrying with
  /// a backoff.
  unavailable(14),

  /// Unrecoverable data loss or corruption.
  dataLoss(15),

  /// The request does not have valid authentication credentials for the
  /// operation.
  unauthenticated(16)
  ;

  /// The numeric value of the status code.
  final int value;

  const StatusCode(this.value);

  /// Creates a StatusCode from its numeric value.
  ///
  /// Returns [StatusCode.unknown] if the value doesn't match any known code.
  static StatusCode fromValue(int value) {
    return StatusCode.values.firstWhere(
      (code) => code.value == value,
      orElse: () => StatusCode.unknown,
    );
  }
}

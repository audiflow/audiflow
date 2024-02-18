class NotFoundError extends Error {
  NotFoundError() : message = 'Not found';

  final String message;
}

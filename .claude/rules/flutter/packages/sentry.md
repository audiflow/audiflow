---
paths: **/*.dart
---
# Sentry

## When to Use

* Production crashes and unhandled exceptions
* Critical operations: payment, auth, data sync
* Async failures in Riverpod providers, HTTP requests, DB operations

## When NOT to Use

* Development-only errors (use debuggers)
* Expected user errors (validation, form errors)
* Verbose logging (use logging framework)
* Non-actionable noise (e.g., network timeouts on poor connections)

## Project Configuration

* Production: `tracesSampleRate: 0.1`, `profilesSampleRate: 0.1`
* Development: `tracesSampleRate: 1.0`, `profilesSampleRate: 1.0`
* Use `beforeSend` to filter PII, tokens, passwords
* In Riverpod: capture, rethrow, let UI handle gracefully

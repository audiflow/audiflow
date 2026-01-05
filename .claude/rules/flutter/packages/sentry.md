# Sentry

## When to Use

### Error Tracking
* **Production crashes:** Capture unhandled exceptions in released apps
* **Critical operations:** Manually capture errors in payment, auth, data sync
* **Async failures:** Track errors in Riverpod providers, HTTP requests, DB operations
* **Debug information:** Add breadcrumbs for user flows leading to errors

### Performance Monitoring
* **App startup:** Track cold/warm start times
* **API calls:** Monitor network request duration and failures
* **Heavy operations:** Profile image processing, large data parsing
* **Screen navigation:** Track routing performance with `SentryNavigatorObserver`
* **Asset loading:** Monitor critical asset bundle loads

### User Context
* **After authentication:** Set user ID/email for error attribution
* **Feature flags:** Track which features are active when errors occur
* **App state:** Capture theme, locale, connection state as context

## When NOT to Use

* Development-only errors (use debuggers instead)
* Expected user errors (validation failures, form errors)
* Verbose logging (use proper logging framework)
* Non-actionable noise (e.g., network timeouts on poor connections)

## Best Practices

### Configuration
* Set `environment` and `release` for proper versioning
* Production: `tracesSampleRate: 0.1` (10%), `profilesSampleRate: 0.1`
* Development: `tracesSampleRate: 1.0`, `profilesSampleRate: 1.0`
* Use `beforeSend` to filter sensitive data (PII, tokens, passwords)

### Error Handling
* Capture only actionable errors (can be fixed or mitigated)
* Add hints with operation context for debugging
* Always include stack traces when manually capturing
* In Riverpod: capture, rethrow, let UI handle gracefully
* Clear user context on logout

### Performance
* Use transactions for feature-level operations (login, checkout)
* Use spans for sub-operations (HTTP, parsing, rendering)
* Tag transactions by feature/screen name
* Don't track every widget rebuild (too noisy)

### Context
* Add breadcrumbs for critical user flows only
* Set custom context for app-specific state
* Update user context on auth changes
* Include relevant feature flags in context

### Platform-Specific
* **Web:** Enable and upload source maps for readable stack traces
* **Android:** Configure ProGuard/R8 mapping files for deobfuscation
* **iOS:** Upload dSYM files for symbolication

## Integration Points

* `main()`: Initialize with `SentryFlutter.init`
* `MaterialApp`: Add `SentryNavigatorObserver` for route tracking
* Riverpod providers: Wrap critical async operations
* Auth layer: Set/clear user context
* Network layer: Track API transaction spans
* Heavy operations: Profile with custom transactions/spans

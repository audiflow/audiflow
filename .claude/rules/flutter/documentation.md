# Documentation

## Philosophy

* Document **why**, not **what** - code should be self-explanatory
* No useless documentation - avoid restating obvious information
* User-focused - answer real-world questions
* Consistent terminology throughout

## Style Rules

* Use `///` for doc comments (enables dartdoc generation)
* First sentence: concise summary ending with period
* Blank line after summary separates it from details
* Avoid redundancy - don't repeat obvious context
* **Getter/Setter:** Document only one, not both (treated as single field)
* Write concisely
* No jargon or unexplained acronyms
* Minimal markdown, no HTML
* Use backticks for code, specify language in fenced blocks

## What to Document

* **Required:** All public APIs
* **Recommended:** Private APIs, library-level overview
* **Include:** Code samples, parameters, return values, exceptions
* **Placement:** Doc comments before annotations

## Example

```dart
/// Fetches user data from the remote API.
///
/// Throws [NetworkException] if connection fails.
/// Returns cached data if [useCache] is true.
Future<User> fetchUser({bool useCache = false}) async {
  // Implementation
}
```

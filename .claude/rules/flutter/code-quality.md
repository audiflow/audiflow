# Code Quality

* **Code structure:** Adhere to maintainable code structure and separation of
  concerns (e.g., UI logic separate from business logic).
* **Naming conventions:** Avoid abbreviations and use meaningful, consistent,
  descriptive names for variables, functions, and classes.
* **Conciseness:** Write code that is as short as it can be while remaining
  clear.
* **Simplicity:** Write straightforward code. Code that is clever or
  obscure is difficult to maintain.
* **Error Handling:** Anticipate and handle potential errors. Don't let your
  code fail silently.
* **Styling:**
    * Line length: Lines should be 80 characters or fewer.
    * Use `PascalCase` for classes, `camelCase` for
      members/variables/functions/enums, and `snake_case` for files.
* **Functions:**
    * Functions short and with a single purpose (strive for less than 20 lines).
* **Testing:** Write code with testing in mind. Use the `file`, `process`, and
  `platform` packages, if appropriate, so you can inject in-memory and fake
  versions of the objects.
* **Logging:** Use the `logging` package instead of `print`.

## Flutter Style Guide

* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Concise and Declarative:** Write concise, modern, technical Dart code.
  Prefer functional and declarative patterns.
* **Composition over Inheritance:** Favor composition for building complex
  widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially
  `StatelessWidget`) should be immutable.
* **State Management:** Separate ephemeral state and app state. Use a state
  management solution for app state to handle the separation of concerns.
* **Widgets are for UI:** Everything in Flutter's UI is a widget. Compose
  complex UIs from smaller, reusable widgets.
* **Navigation:** Use a modern routing package like `auto_route` or `go_router`.
  See the [navigation guide](./navigation.md) for a detailed example using
  `go_router`.

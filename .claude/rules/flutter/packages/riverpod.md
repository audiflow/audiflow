---
paths: **/*.dart
---
# State Management

## Core Principles

* **Use Riverpod:** Primary state management solution for compile-time safety and testability.
* **Code Generation:** Always use `@riverpod` annotation with code generation.
* **Prefer Notifier:** Use `NotifierProvider` and `AsyncNotifierProvider` exclusively.
* **Avoid:** `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`.
* **Manual Updates:** Use `ref.invalidate()` to manually trigger provider updates.
* **Cancellation:** Implement proper cancellation of async operations on disposal.
* **Built-in Fallback:** Only use `ValueNotifier` for trivial ephemeral UI state.

## Setup

```bash
flutter pub add flutter_riverpod riverpod_annotation
flutter pub add dev:riverpod_generator dev:build_runner dev:riverpod_lint dev:custom_lint
```

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

## Code Generation

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
dart run build_runner watch --delete-conflicting-outputs
```

## Provider Patterns

### Notifier (Synchronous State)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

// Usage
class CounterWidget extends ConsumerWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).increment(),
      child: Text('Count: $count'),
    );
  }
}
```

### AsyncNotifier (Asynchronous State)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

@riverpod
class User extends _$User {
  @override
  Future<UserModel> build() async {
    // Implement cancellation on disposal
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());

    final repository = ref.watch(userRepositoryProvider);
    return repository.fetchUser(cancelToken: cancelToken);
  }

  Future<void> updateName(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userRepositoryProvider);
      return repository.updateUserName(name);
    });
  }

  // Manual refresh
  void refresh() {
    ref.invalidate(userProvider);
  }
}

// Usage
class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => Text('Hello ${user.name}'),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Simple Providers (Dependency Injection)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
HttpClient httpClient(HttpClientRef ref) => HttpClient();

@riverpod
ApiService apiService(ApiServiceRef ref) {
  final client = ref.watch(httpClientProvider);
  return ApiService(client);
}
```

### Future Provider (One-time Async)

```dart
@riverpod
Future<Config> config(ConfigRef ref) async {
  final json = await rootBundle.loadString('assets/config.json');
  return Config.fromJson(jsonDecode(json));
}
```

### Stream Provider

```dart
@riverpod
Stream<List<Message>> messages(MessagesRef ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.watchMessages();
}
```

## Best Practices

### Ref Methods

* `ref.watch()`: In build methods to rebuild on state changes
* `ref.read()`: In event handlers for one-time reads
* `ref.listen()`: For side effects (navigation, snackbars)
* `ref.invalidate()`: To manually refresh providers

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    ref.listen(counterProvider, (previous, next) {
      if (10 <= next) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reached 10!')),
        );
      }
    });

    return ElevatedButton(
      onPressed: () {
        ref.read(counterProvider.notifier).increment();
        // Or manually refresh
        ref.invalidate(counterProvider);
      },
      child: Text('Count: $count'),
    );
  }
}
```

### Parameters (Family)

```dart
@riverpod
Todo todo(TodoRef ref, String id) {
  final todos = ref.watch(todosProvider);
  return todos.todos.firstWhere((todo) => todo.id == id);
}

// Usage
final todo = ref.watch(todoProvider('id-123'));
```

### KeepAlive

```dart
// Auto-disposed by default
@riverpod
Future<Data> data(DataRef ref) async => fetchData();

// Keep alive
@Riverpod(keepAlive: true)
Future<Config> config(ConfigRef ref) async => loadConfig();
```

### Combining Providers

```dart
@riverpod
List<Todo> filteredTodos(FilteredTodosRef ref) {
  final todos = ref.watch(todosProvider).todos;
  final filter = ref.watch(todoFilterProvider);
  return todos.where((t) => t.matches(filter)).toList();
}
```

### ConsumerWidget vs Consumer

* Use `ConsumerWidget` when entire widget rebuilds on state changes
* Use `Consumer` to limit rebuilds to a specific subtree

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Static'),
        Consumer(
          builder: (context, ref, child) {
            final count = ref.watch(counterProvider);
            return Text('Count: $count');
          },
        ),
      ],
    );
  }
}
```

## Testing

```dart
testWidgets('counter increments', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        counterProvider.overrideWith(() => Counter()..state = 5),
      ],
      child: const MyApp(),
    ),
  );

  expect(find.text('Count: 5'), findsOneWidget);
});
```

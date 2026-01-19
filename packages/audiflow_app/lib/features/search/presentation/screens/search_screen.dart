import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/search_controller.dart';

/// Search screen for discovering podcasts by keyword.
///
/// This screen provides a search input field with a submit button,
/// allowing users to search for podcasts. The screen watches the
/// [PodcastSearchController] state and will display appropriate UI states
/// (initial, loading, results, empty, error) in future implementations.
///
/// Requirements covered:
/// - 1.1: Search text input field
/// - 1.2: Submit button with search icon
/// - 1.3: Submit button initiates search
/// - 1.4: Enter key initiates search
/// - 1.5: Dismiss keyboard on search
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _textController.text;
    if (query.trim().isEmpty) return;

    // Dismiss keyboard (Requirement 1.5)
    _focusNode.unfocus();

    // Call controller search method (Requirements 1.3, 1.4)
    ref.read(podcastSearchControllerProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller state for future UI updates
    final _ = ref.watch(podcastSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Podcasts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search podcasts...',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

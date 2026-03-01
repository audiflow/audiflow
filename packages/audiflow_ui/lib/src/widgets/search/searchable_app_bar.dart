import 'dart:async';

import 'package:flutter/material.dart';

/// An [AppBar] that toggles between a title view and
/// a debounced search text field.
class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates a searchable app bar.
  const SearchableAppBar({
    required this.title,
    required this.onSearchChanged,
    this.actions,
    this.debounceDuration = const Duration(milliseconds: 300),
    super.key,
  });

  /// The title widget shown in the default state.
  final Widget title;

  /// Called with the debounced search query.
  /// Called with empty string when search is closed.
  final ValueChanged<String> onSearchChanged;

  /// Additional actions shown alongside the search icon
  /// in the default (non-searching) state.
  final List<Widget>? actions;

  /// Debounce duration for search input.
  final Duration debounceDuration;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    _focusNode.requestFocus();
  }

  void _closeSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() => _isSearching = false);
    widget.onSearchChanged('');
  }

  void _clearText() {
    _searchController.clear();
    _debounceTimer?.cancel();
    widget.onSearchChanged('');
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      widget.debounceDuration,
      () => widget.onSearchChanged(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching ? _buildSearchField() : widget.title,
      actions: _isSearching
          ? [IconButton(icon: const Icon(Icons.close), onPressed: _closeSearch)]
          : [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _openSearch,
              ),
              ...?widget.actions,
            ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      onChanged: _onTextChanged,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearText,
            );
          },
        ),
      ),
    );
  }
}

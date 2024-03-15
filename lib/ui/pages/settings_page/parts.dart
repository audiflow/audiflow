// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../settings_page.dart';

class _AppBar extends HookConsumerWidget {
  const _AppBar(this.title);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      title: Text(title),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Divider(
        height: 20,
        thickness: 0.3,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    this.description,
    this.routeName,
  });

  final String title;
  final String? description;
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionText(title),
                if (description != null)
                  Padding(
                    padding: EdgeInsets.only(
                      right: routeName == null ? 60 : 16,
                    ),
                    child: _HintText(description!),
                  ),
              ],
            ),
          ),
          if (routeName != null)
            IconButton(
              onPressed: () {},
              icon: const Icon(Symbols.chevron_right),
            ),
        ],
      ),
    );
  }
}

class _Router extends StatelessWidget {
  const _Router({
    required this.text,
    required this.routeName,
  });

  final String text;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _EntryText(text),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _BinarySwitch extends StatelessWidget {
  const _BinarySwitch(
    this.text, {
    this.hint,
    required this.value,
    required this.onToggle,
  });

  final String text;
  final String? hint;
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EntryText(text),
              if (hint != null) _HintText(hint!),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          activeTrackColor: theme.colorScheme.tertiary,
          onChanged: (_) => onToggle(),
        ),
      ],
    );
  }
}

// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../settings_page.dart';

class _SectionText extends StatelessWidget {
  const _SectionText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium!
          .copyWith(color: theme.colorScheme.primary),
    );
  }
}

class _HintText extends StatelessWidget {
  const _HintText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall!.copyWith(
        color: theme.hintColor,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _EntryText extends StatelessWidget {
  const _EntryText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium!
          .copyWith(color: theme.colorScheme.onSurface),
    );
  }
}

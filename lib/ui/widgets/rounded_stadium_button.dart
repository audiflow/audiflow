// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoundedStadiumButton extends ConsumerWidget {
  const RoundedStadiumButton({
    required this.caption,
    required this.onPressed,
    required this.size,
    super.key,
  });

  const RoundedStadiumButton.md({
    required this.caption,
    required this.onPressed,
    super.key,
  }) : size = const Size(220, 48);

  final Widget caption;
  final Size size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      backgroundColor: theme.primaryColor,
      fixedSize: size,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (constraints.maxWidth - size.width) / 2,
          ),
          child: OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: DefaultTextStyle(
              style: theme.textTheme.titleMedium!
                  .copyWith(color: theme.colorScheme.onPrimary),
              child: caption,
            ),
          ),
        );
      },
    );
  }
}

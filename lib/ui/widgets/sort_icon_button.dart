// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SortIconButton extends StatelessWidget {
  const SortIconButton({
    required this.ascend,
    required this.onTap,
    super.key,
  });

  final bool ascend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: ascend
          ? const Icon(Symbols.keyboard_double_arrow_down_rounded)
          : const Icon(Symbols.keyboard_double_arrow_up_rounded),
    );
  }
}

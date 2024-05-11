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

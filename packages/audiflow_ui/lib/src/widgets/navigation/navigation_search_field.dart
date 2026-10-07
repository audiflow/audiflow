import 'package:flutter/material.dart';

import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';

/// In-navigation search row (redesign 3.4): a focused search field and
/// an accent "cancel" text button that clears the query.
///
/// The screen owns filtering, the result count line, and hiding the
/// hero while searching; this widget is only the input row.
class NavigationSearchField extends StatelessWidget {
  const NavigationSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.cancelLabel,
    required this.onCancel,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final String cancelLabel;
  final VoidCallback onCancel;
  final ValueChanged<String>? onChanged;

  void _cancel() {
    controller.clear();
    onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: AppTextStyles.body.copyWith(color: colors.ink),
            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: Spacing.xs),
        TextButton(
          onPressed: _cancel,
          style: TextButton.styleFrom(
            foregroundColor: colors.accent,
            minimumSize: const Size(Spacing.minTouchTarget, 44),
          ),
          child: Text(cancelLabel),
        ),
      ],
    );
  }
}

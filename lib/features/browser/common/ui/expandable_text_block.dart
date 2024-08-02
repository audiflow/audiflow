import 'package:audiflow/features/browser/common/ui/podcast_html.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/utils/html.dart';
import 'package:conditional_wrap/conditional_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';

/// This class wraps the description in an expandable box.
///
/// This handles the common case whereby the description is very long and,
/// without this constraint, would require the use to always scroll before
/// reaching the podcast episodes.
///
class ExpandableTextBlock extends HookWidget {
  const ExpandableTextBlock({required this.text, super.key});

  final String text;
  static const maxHeight = 60.0;
  static const padding = 4.0;

  @override
  Widget build(BuildContext context) {
    final expandedState = useState(false);
    final formatted = formatDescriptionHtml(text)!;
    return WidgetWrapper(
      wrapper: (child) => expandedState.value
          ? child
          : GestureDetector(
              onTap: () => expandedState.value = !expandedState.value,
              child: child,
            ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: padding),
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: Container(
                constraints: expandedState.value
                    ? null
                    : BoxConstraints.loose(
                        const Size(double.infinity, maxHeight - padding),
                      ),
                child: ShaderMask(
                  shaderCallback: LinearGradient(
                    colors: [Colors.white, Colors.white.withAlpha(0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: expandedState.value ? const [1, 1] : const [0.7, 1],
                  ).createShader,
                  child: PodcastHtml(
                    content: formatted,
                    fontSize: FontSize.medium,
                    textSelectable: expandedState.value,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => expandedState.value = !expandedState.value,
                  child: Text(
                    expandedState.value
                        ? L10n.of(context).showLess
                        : L10n.of(context).showMore,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

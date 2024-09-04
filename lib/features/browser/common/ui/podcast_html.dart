import 'package:conditional_wrap/conditional_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:url_launcher/url_launcher.dart';

/// This class is a simple, common wrapper around the flutter_html Html widget.
///
/// This wrapper allows us to remove some of the HTML tags which can cause
/// rendering issues when viewing podcast descriptions on a mobile device.
class PodcastHtml extends StatelessWidget {
  const PodcastHtml({
    super.key,
    required this.content,
    this.fontSize,
    this.textSelectable = false,
  });

  final String content;
  final FontSize? fontSize;
  final bool textSelectable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return WidgetWrapper(
      wrapper: (child) => textSelectable ? SelectionArea(child: child) : child,
      child: Html(
        data: content,
        extensions: const [
          SvgHtmlExtension(),
          TableHtmlExtension(),
        ],
        style: {
          'html': Style(
            fontWeight: textTheme.bodyLarge!.fontWeight,
            fontSize: fontSize ?? FontSize.large,
          ),
        },
        onLinkTap: (url, _, __) => canLaunchUrl(Uri.parse(url!)).then(
          (value) => launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ),
    );
  }
}

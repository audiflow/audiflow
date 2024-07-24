import 'package:audiflow/common/data/device_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleListenerWidget extends ConsumerStatefulWidget {
  const LocaleListenerWidget({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  ConsumerState createState() => _LocaleListenerWidgetState();
}

class _LocaleListenerWidgetState extends ConsumerState<LocaleListenerWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    final currentLocale = locales?.first;
    if (currentLocale != null) {
      ref.read(deviceLocaleProvider.notifier).setLocale(currentLocale);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}

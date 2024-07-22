import 'dart:async';

import 'package:audiflow/entities/funding.dart';
import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/widgets/action_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:url_launcher/url_launcher.dart';

/// This class is responsible for rendering the funding menu on the podcast
/// details page.
///
/// The target platform is based on the current [Theme]: [ThemeData.platform].
class FundingMenu extends StatelessWidget {
  const FundingMenu(
    this.funding, {
    super.key,
  });

  final IsarLinks<Funding>? funding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return _MaterialFundingMenu(funding);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _CupertinoFundingMenu(funding);
    }
  }
}

/// This is the material design version of the context menu. This will be
/// rendered for all platforms that are not iOS.
class _MaterialFundingMenu extends ConsumerWidget {
  const _MaterialFundingMenu(this.funding);

  final IsarLinks<Funding>? funding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);

    return funding == null || funding!.isEmpty
        ? const SizedBox.shrink()
        : Semantics(
            label: L10n.of(context).podcast_funding_dialog_header,
            child: PopupMenuButton<String>(
              onSelected: (url) {
                FundingLink.fundingLink(
                  url,
                  context,
                  consent: settings.externalLinkConsent,
                ).then((value) {
                  ref
                      .read(settingsServiceProvider.notifier)
                      .externalLinkConsent = value;
                });
              },
              icon: const Icon(
                Icons.payment,
              ),
              itemBuilder: (BuildContext context) {
                return List<PopupMenuEntry<String>>.generate(funding!.length,
                    (index) {
                  final item = funding!.elementAt(index);
                  return PopupMenuItem<String>(
                    value: item.url,
                    child: Text(item.value),
                  );
                });
              },
            ),
          );
  }
}

/// This is the Cupertino context menu and is rendered only when running on
/// an iOS device.
class _CupertinoFundingMenu extends ConsumerWidget {
  const _CupertinoFundingMenu(this.funding);

  final IsarLinks<Funding>? funding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);

    return funding == null || funding!.isEmpty
        ? const SizedBox.shrink()
        : IconButton(
            tooltip: L10n.of(context).podcast_funding_dialog_header,
            icon: const Icon(Icons.payment),
            onPressed: () => showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoActionSheet(
                  actions: <Widget>[
                    ...List<CupertinoActionSheetAction>.generate(
                        funding!.length, (index) {
                      final item = funding!.elementAt(index);
                      return CupertinoActionSheetAction(
                        onPressed: () {
                          FundingLink.fundingLink(
                            item.url,
                            context,
                            consent: settings.externalLinkConsent,
                          ).then((value) {
                            ref
                                .read(settingsServiceProvider.notifier)
                                .externalLinkConsent = value;
                            Navigator.pop(context, 'Cancel');
                          });
                        },
                        child: Text(item.value),
                      );
                    }),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                    },
                    child: Text(L10n.of(context).cancel),
                  ),
                );
              },
            ),
          );
  }
}

class FundingLink {
  FundingLink._();

  /// Check the consent status. If this is the first time we have been
  /// requested to open a funding link, present the user with and
  /// information dialog first to make clear that the link is provided
  /// by the podcast owner and not AnyTime.
  static Future<bool> fundingLink(
    String url,
    BuildContext context, {
    required bool consent,
  }) async {
    bool? result = false;

    if (consent) {
      result = true;
      final uri = Uri.parse(url);

      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $uri');
      }
    } else {
      result = await showPlatformDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (_) => BasicDialogAlert(
          title: Text(L10n.of(context).podcast_funding_dialog_header),
          content: Text(L10n.of(context).podcast_funding_consent_message),
          actions: <Widget>[
            BasicDialogAction(
              title: ActionText(
                L10n.of(context).goBack,
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            BasicDialogAction(
              title: ActionText(
                L10n.of(context).continues,
              ),
              iosIsDefaultAction: true,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      );

      if (result!) {
        final uri = Uri.parse(url);

        unawaited(
          canLaunchUrl(uri).then((value) => launchUrl(uri)),
        );
      }
    }

    return Future.value(result);
  }
}

// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/funding.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/services/settings/settings_service.dart';
import 'package:seasoning/ui/widgets/action_text.dart';
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

  final List<Funding>? funding;

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

  final List<Funding>? funding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);

    return funding == null || funding!.isEmpty
        ? const SizedBox.shrink()
        : Semantics(
            label: L.of(context)!.podcast_funding_dialog_header,
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
                  return PopupMenuItem<String>(
                    value: funding![index].url,
                    child: Text(funding![index].value),
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

  final List<Funding>? funding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);

    return funding == null || funding!.isEmpty
        ? const SizedBox.shrink()
        : IconButton(
            tooltip: L.of(context)!.podcast_funding_dialog_header,
            icon: const Icon(Icons.payment),
            onPressed: () => showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoActionSheet(
                  actions: <Widget>[
                    ...List<CupertinoActionSheetAction>.generate(
                        funding!.length, (index) {
                      return CupertinoActionSheetAction(
                        onPressed: () {
                          FundingLink.fundingLink(
                            funding![index].url,
                            context,
                            consent: settings.externalLinkConsent,
                          ).then((value) {
                            ref
                                .read(settingsServiceProvider.notifier)
                                .externalLinkConsent = value;
                            Navigator.pop(context, 'Cancel');
                          });
                        },
                        child: Text(funding![index].value),
                      );
                    }),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                    },
                    child: Text(L.of(context)!.cancel_option_label),
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
          title: Text(L.of(context)!.podcast_funding_dialog_header),
          content: Text(L.of(context)!.consent_message),
          actions: <Widget>[
            BasicDialogAction(
              title: ActionText(
                L.of(context)!.go_back_button_label,
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            BasicDialogAction(
              title: ActionText(
                L.of(context)!.continue_button_label,
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

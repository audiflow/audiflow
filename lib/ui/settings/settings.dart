// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:seasoning/bloc/podcast/opml_bloc.dart';
import 'package:seasoning/bloc/podcast/podcast_bloc.dart';
import 'package:seasoning/bloc/settings/settings_bloc.dart';
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/app_settings.dart';
import 'package:seasoning/events/opml_event.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/ui/library/opml_export.dart';
import 'package:seasoning/ui/library/opml_import.dart';
import 'package:seasoning/ui/settings/episode_refresh.dart';
import 'package:seasoning/ui/settings/search_provider.dart';
import 'package:seasoning/ui/settings/settings_section_label.dart';
import 'package:seasoning/ui/widgets/action_text.dart';

/// This is the settings page and allows the user to select various
/// options for the app.
///
/// This is a self contained page and so, unlike the other forms, talks directly
/// to a settings service rather than a BLoC. Whilst this deviates slightly from
/// the overall architecture, adding a BLoC to simply be consistent with the rest
/// of the application would add unnecessary complexity.
///
/// This page is built with both Android & iOS in mind. However, the
/// rest of the application is not prepared for iOS design; this
/// is in preparation for the iOS version.
class Settings extends StatefulWidget {
  const Settings({
    super.key,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool sdcard = false;

  Widget _buildList(BuildContext context) {
    final settingsBloc = Provider.of<SettingsBloc>(context);
    final podcastBloc = Provider.of<PodcastBloc>(context);
    final opmlBloc = Provider.of<OPMLBloc>(context);

    return StreamBuilder<AppSettings>(
      stream: settingsBloc.settings,
      initialData: settingsBloc.currentSettings,
      builder: (context, snapshot) {
        return ListView(
          children: [
            SettingsDividerLabel(
              label: L.of(context)!.settings_personalisation_divider_label,
            ),
            ListTile(
              shape: const RoundedRectangleBorder(),
              title: Text(L.of(context)!.settings_theme_switch_label),
              trailing: Switch.adaptive(
                value: snapshot.data!.theme == 'dark',
                onChanged: (value) {
                  settingsBloc.darkMode(value);
                },
              ),
            ),
            SettingsDividerLabel(
              label: L.of(context)!.settings_episodes_divider_label,
            ),
            ListTile(
              title: Text(L.of(context)!.settings_mark_deleted_played_label),
              trailing: Switch.adaptive(
                value: snapshot.data!.markDeletedEpisodesAsPlayed,
                onChanged: (value) =>
                    setState(() => settingsBloc.markDeletedAsPlayed(value)),
              ),
            ),
            sdcard
                ? ListTile(
                    title: Text(L.of(context)!.settings_download_sd_card_label),
                    trailing: Switch.adaptive(
                      value: snapshot.data!.storeDownloadsSDCard,
                      onChanged: (value) => sdcard
                          ? setState(() {
                              if (value) {
                                _showStorageDialog(
                                  enableExternalStorage: true,
                                );
                              } else {
                                _showStorageDialog(
                                  enableExternalStorage: false,
                                );
                              }

                              settingsBloc.storeDownloadonSDCard(value);
                            })
                          : null,
                    ),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            SettingsDividerLabel(
              label: L.of(context)!.settings_playback_divider_label,
            ),
            ListTile(
              title: Text(L.of(context)!.settings_auto_open_now_playing),
              trailing: Switch.adaptive(
                value: snapshot.data!.autoOpenNowPlaying,
                onChanged: (value) =>
                    setState(() => settingsBloc.setAutoOpenNowPlaying(value)),
              ),
            ),
            const EpisodeRefreshWidget(),
            SettingsDividerLabel(
              label: L.of(context)!.settings_data_divider_label,
            ),
            ListTile(
              title: Text(L.of(context)!.settings_import_opml),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  // `podcast.opml` is a UTTypeDeclaration made in iOS setup.
                  allowedExtensions: ['opml', 'podcast.opml', 'xml'],
                );

                if (result != null && result.count > 0) {
                  final file = result.files.first;

                  if (context.mounted) {
                    final e = await showPlatformDialog<bool>(
                      useRootNavigator: false,
                      context: context,
                      builder: (_) => PopScope(
                        onPopInvoked: (didPop) async => false,
                        child: BasicDialogAlert(
                          title: Text(L.of(context)!.settings_import_opml),
                          content: OPMLImport(file: file.path!),
                          actions: <Widget>[
                            BasicDialogAction(
                              title: ActionText(
                                L.of(context)!.cancel_button_label,
                              ),
                              onPressed: () {
                                return Navigator.pop(context, true);
                              },
                            ),
                          ],
                        ),
                      ),
                    );

                    if (e != null && e) {
                      opmlBloc.opmlEvent(OPMLCancelEvent());
                    }
                  }
                  podcastBloc.podcastEvent(PodcastEvent.reloadSubscriptions);
                }
              },
            ),
            ListTile(
              title: Text(L.of(context)!.settings_export_opml),
              onTap: () async {
                await showPlatformDialog<void>(
                  context: context,
                  useRootNavigator: false,
                  builder: (_) => BasicDialogAlert(
                    content: const OPMLExport(),
                  ),
                );
              },
            ),
            const SearchProviderWidget(),
          ],
        );
      },
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            L.of(context)!.settings_label,
          ),
        ),
        body: _buildList(context),
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      child: Material(child: _buildList(context)),
    );
  }

  void _showStorageDialog({required bool enableExternalStorage}) {
    showPlatformDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (_) => BasicDialogAlert(
        title: Text(L.of(context)!.settings_download_switch_label),
        content: Text(
          enableExternalStorage
              ? L.of(context)!.settings_download_switch_card
              : L.of(context)!.settings_download_switch_internal,
        ),
        actions: <Widget>[
          BasicDialogAction(
            title: Text(
              L.of(context)!.ok_button_label,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _buildAndroid(context);
      case TargetPlatform.iOS:
        return _buildIos(context);
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
        return _buildAndroid(context);
    }
  }

  @override
  void initState() {
    super.initState();

    hasExternalStorage().then((value) {
      setState(() {
        sdcard = value;
      });
    });
  }
}

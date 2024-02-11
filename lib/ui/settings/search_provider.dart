// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:seasoning/bloc/settings/settings_bloc.dart';
import 'package:seasoning/entities/app_settings.dart';
import 'package:seasoning/l10n/L.dart';

class SearchProviderWidget extends StatefulWidget {

  const SearchProviderWidget({
    super.key,
    this.onChanged,
  });
  final ValueChanged<String?>? onChanged;

  @override
  State<SearchProviderWidget> createState() => _SearchProviderWidgetState();
}

class _SearchProviderWidgetState extends State<SearchProviderWidget> {
  @override
  Widget build(BuildContext context) {
    final settingsBloc = Provider.of<SettingsBloc>(context);

    return StreamBuilder<AppSettings>(
        stream: settingsBloc.settings,
        initialData: AppSettings.sensibleDefaults(),
        builder: (context, snapshot) {
          return snapshot.data!.searchProviders.length > 1
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(L.of(context)!.search_provider_label),
                      subtitle: Text(snapshot.data!.searchProvider == 'itunes'
                          ? 'iTunes'
                          : 'PodcastIndex',),
                      onTap: () {
                        showPlatformDialog<void>(
                          context: context,
                          useRootNavigator: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: Text(
                                    L.of(context)!.search_provider_label,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,),
                                content: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState,) {
                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          RadioListTile<String>(
                                            title: const Text('iTunes'),
                                            value: 'itunes',
                                            dense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    ,),
                                            groupValue:
                                                snapshot.data!.searchProvider,
                                            onChanged: (String? value) {
                                              setState(() {
                                                settingsBloc.setSearchProvider(
                                                    value ?? 'itunes',);

                                                if (widget.onChanged != null) {
                                                  widget.onChanged!(value);
                                                }

                                                Navigator.pop(context);
                                              });
                                            },
                                          ),
                                          RadioListTile<String>(
                                            title: const Text('PodcastIndex'),
                                            value: 'podcastindex',
                                            dense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    ,),
                                            groupValue:
                                                snapshot.data!.searchProvider,
                                            onChanged: (String? value) {
                                              setState(() {
                                                settingsBloc.setSearchProvider(
                                                    value ?? 'podcastindex',);

                                                if (widget.onChanged != null) {
                                                  widget.onChanged!(value);
                                                }

                                                Navigator.pop(context);
                                              });
                                            },
                                          ),
                                        ],);
                                  },
                                ),);
                          },
                        );
                      },
                    ),
                  ],
                )
              : Container();
        },);
  }
}

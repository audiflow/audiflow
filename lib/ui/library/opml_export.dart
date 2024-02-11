// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seasoning/bloc/podcast/opml_bloc.dart';
import 'package:seasoning/events/opml_event.dart';
import 'package:seasoning/l10n/L.dart';

class OPMLExport extends StatefulWidget {
  const OPMLExport({
    super.key,
  });

  @override
  State<OPMLExport> createState() => _OPMLExportState();
}

class _OPMLExportState extends State<OPMLExport> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<OPMLBloc>(context, listen: false);
    final width = MediaQuery.of(context).size.width - 60.0;

    return SizedBox(
      height: 80,
      width: width,
      child: StreamBuilder<OPMLActionEvent>(
          initialData: OPMLNoneEvent(),
          stream: bloc.opmlState,
          builder: (context, snapshot) {
            if (snapshot.data is OPMLCompletedState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
              });
            }

            return Row(
              children: [
                const Flexible(
                  child: CircularProgressIndicator.adaptive(),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      L.of(context)!.settings_export_opml,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            );
          },),
    );
  }

  @override
  void initState() {
    super.initState();

    final bloc = Provider.of<OPMLBloc>(context, listen: false);

    bloc.opmlEvent(OPMLExportEvent());
  }
}

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

class OPMLImport extends StatefulWidget {

  const OPMLImport({
    super.key,
    required this.file,
  });
  final String file;

  @override
  State<OPMLImport> createState() => _OPMLImportState();
}

class _OPMLImportState extends State<OPMLImport> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<OPMLBloc>(context, listen: false);
    final width = MediaQuery.of(context).size.width - 60.0;

    return IntrinsicHeight(
      child: SizedBox(
        width: width,
        child: StreamBuilder<OPMLActionEvent>(
            initialData: OPMLNoneEvent(),
            stream: bloc.opmlState,
            builder: (context, snapshot) {
              String? t = '';
              final d = snapshot.data;

              if (d is OPMLCompletedState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context);
                });
              } else if (d is OPMLLoadingEvent) {
                t = d.podcast;
              }

              return Row(
                children: [
                  const Flexible(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            L.of(context)!.label_opml_importing,
                            maxLines: 1,
                          ),
                          const SizedBox(
                            width: 0,
                            height: 2,
                          ),
                          Text(
                            t!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final bloc = Provider.of<OPMLBloc>(context, listen: false);

    bloc.opmlEvent(
      OPMLImportEvent(file: widget.file),
    );
  }
}

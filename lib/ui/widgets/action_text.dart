// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/widgets.dart';

/// This is a simple wrapper for the [Text] widget that is intended to
/// be used with action dialogs.
///
/// It should be supplied with a text value in sentence case. If running on
/// Android this will be shifted to all upper case to meet the Material Design
/// guidelines; otherwise it will be displayed as is to fit in the with iOS
/// developer guidelines.
class ActionText extends StatelessWidget {
  const ActionText(this.text, {super.key});

  /// The text to display which will be shifted to all upper-case on Android.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? Text(text.toUpperCase()) : Text(text);
  }
}

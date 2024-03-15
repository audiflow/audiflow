// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeString {
  DateTimeString._();

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy.MM.dd HH:mm:ss').format(dateTime);
  }

  static String relativeDateTime(BuildContext context, Duration elapsed) {
    final l10n = L10n.of(context)!;

    if (1 <= elapsed.inDays) {
      return l10n.nDaysAgo(elapsed.inDays);
    } else if (1 <= elapsed.inHours) {
      return l10n.nHoursAgo(elapsed.inHours);
    } else if (1 <= elapsed.inMinutes) {
      return l10n.nDaysAgo(elapsed.inMinutes);
    } else {
      return l10n.justNow;
    }
  }
}

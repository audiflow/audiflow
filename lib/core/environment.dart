// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// The key required when searching via PodcastIndex.org.
const podcastIndexKey = String.fromEnvironment('PINDEX_KEY');

/// The secret required when searching via PodcastIndex.org.
const podcastIndexSecret = String.fromEnvironment('PINDEX_SECRET');

/// Allows a user to override the default user agent string.
const userAgentAppString = String.fromEnvironment('USER_AGENT');

/// Link to a feedback form. This will be shown in the main overflow menu if set
const feedbackUrl = String.fromEnvironment('FEEDBACK_URL');

class Environment {
  Environment._();

  static const _applicationName = 'Anytime';
  static const _applicationUrl =
      'https://github.com/amugofjava/anytime_podcast_player';
  static const _projectVersion = '1.3.7';
  static const _build = '107';

  static var _agentString = userAgentAppString;

  static Future<void> loadEnvironment() async {}

  static String userAgent() {
    if (_agentString.isEmpty) {
      final platform =
          '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'
              .trim();

      _agentString =
          '$_applicationName/$_projectVersion b$_build (phone;$platform) $_applicationUrl';
    }

    return _agentString;
  }

  static String get projectVersion => '$_projectVersion b$_build';
}

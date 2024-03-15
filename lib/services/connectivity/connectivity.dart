// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<bool> isWifiEnabled() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.wifi;
}

Future<bool> usesCellularConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.mobile;
}

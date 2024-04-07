// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:isar/isar.dart';

part 'value.g.dart';

/// This class represents a PC2.0 [value](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#value)
/// tag and is used for value-for-value payments via cryptocurrency or another
/// payment layer.
@collection
class Value {
  Value({
    required this.type,
    required this.method,
    this.suggested,
  });

  Id? id;

  /// The service layer to use. For example, 'lightning' for payments over the
  /// Lightning network.
  final String type;

  /// The transport mechanism used. For example 'keysend'.
  final String method;

  /// The suggested payment amount.
  final double? suggested;

  /// Each value can have zero or more recipients who will receive a split of
  /// the value sent.
  final recipients = IsarLinks<ValueRecipient>();
}

/// This class represents a PC2.0 [valueRecipient](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#value-recipient) tag
/// and is used in conjunction with a [Value] instance.
@collection
class ValueRecipient {
  ValueRecipient({
    this.name,
    this.customKey,
    this.customValue,
    required this.type,
    required this.address,
    required this.split,
    required this.fee,
  });

  Id? id;

  /// The name of the recipient.
  final String? name;

  /// The name of a custom record key to send along with the payment.
  final String? customKey;

  /// A custom value to pass along with the payment. This is considered the
  /// value that belongs to the [customKey].
  final String? customValue;

  /// The type of receiving address that will receive the payment.
  final String type;

  /// The payee address.
  final String address;

  /// The number of shares this recipient/share will receive.
  final int split;

  /// Whether this split should be treated as a fee, or a normal split.
  final bool fee;
}

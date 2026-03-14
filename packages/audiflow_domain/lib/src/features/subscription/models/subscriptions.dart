import 'package:isar_community/isar.dart';

part 'subscriptions.g.dart';

@collection
class Subscription {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String itunesId;

  late String feedUrl;
  late String title;
  late String artistName;
  String? artworkUrl;
  String? description;
  String genres = '';
  bool explicit = false;
  late DateTime subscribedAt;
  DateTime? lastRefreshedAt;
}

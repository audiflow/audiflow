import 'package:audiflow/services/podcast/mobile_opml_service.dart';
import 'package:audiflow/services/podcast/opml_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/services/podcast/opml_service.dart';

part 'opml_service_provider.g.dart';

@riverpod
OPMLService opmlService(OpmlServiceRef ref) {
  return MobileOPMLService(ref);
}

import '../models/deep_link_target.dart';

/// Resolves incoming universal link URIs to typed navigation targets.
abstract class DeepLinkResolver {
  Future<DeepLinkTarget?> resolve(Uri uri);
}

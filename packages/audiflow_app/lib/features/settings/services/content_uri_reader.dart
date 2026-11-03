import 'package:flutter/services.dart';

/// Native channel that reads a `content://` URI off the main thread.
const contentResolverChannelName = 'com.reedom.audiflow_app/content_resolver';

/// Reads a `content://` URI through the native content resolver.
///
/// Throws [FormatException] when the provider cannot serve the document, so
/// callers report it the same way as a file that fails to parse.
Future<String> readContentUri(String uri) async {
  const channel = MethodChannel(contentResolverChannelName);
  try {
    final content = await channel.invokeMethod<String>('readContentUri', uri);
    if (content == null) {
      throw const FormatException('Failed to read content from URI');
    }
    return content;
  } on PlatformException catch (e) {
    throw FormatException(e.message ?? 'Failed to read content from URI');
  }
}

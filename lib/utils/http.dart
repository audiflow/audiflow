import 'dart:io';

Future<String> resolveUrl(String url, {bool forceHttps = false}) async {
  final client = HttpClient();
  var uri = Uri.parse(url);
  var request = await client.getUrl(uri);

  request.followRedirects = false;

  var response = await request.close();

  while (response.isRedirect) {
    await response.drain(0);
    final location = response.headers.value(HttpHeaders.locationHeader);
    if (location != null) {
      uri = uri.resolve(location);
      request = await client.getUrl(uri)
        // Set the body or headers as desired.
        ..followRedirects = false;
      response = await request.close();
    }
  }

  if (uri.scheme == 'http') {
    uri = uri.replace(scheme: 'https');
  }

  return uri.toString();
}

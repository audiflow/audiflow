import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/services/download/download_service.dart';
import 'package:seasoning/services/download/mobile_download_service.dart';

export 'package:seasoning/services/download/download_service.dart';

part 'download_service_provider.g.dart';

@Riverpod(keepAlive: true)
DownloadService downloadService(DownloadServiceRef ref) =>
    MobileDownloadService(ref);

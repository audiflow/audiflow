import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/settings/settings_service.dart';

class EmptySettingsService extends SettingsService {
  @override
  bool autoOpenNowPlaying = false;

  @override
  int autoUpdateEpisodePeriod = 0;

  @override
  bool externalLinkConsent = false;

  @override
  int layoutMode = 0;

  @override
  bool markDeletedEpisodesAsPlayed = false;

  @override
  double playbackSpeed = 1.0;

  @override
  String searchProvider = 'itunes';

  @override
  AppSettings? settings;

  @override
  bool showFunding = false;

  @override
  bool storeDownloadsSDCard = false;

  @override
  bool themeDarkMode = false;

  @override
  bool trimSilence = false;

  @override
  bool volumeBoost = false;

  @override
  // TODO: implement settingsListener
  Stream<String> get settingsListener => throw UnimplementedError();
}

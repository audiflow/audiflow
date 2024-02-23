import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/audio/mobile_audio_player_service.dart';

final audioPlayerServiceProvider =
    NotifierProvider<AudioPlayerService, AudioPlayerState?>(
  MobileAudioPlayerService.new,
);

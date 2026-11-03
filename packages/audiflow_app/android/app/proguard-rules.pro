# SessionQueueChannel.kt reaches these audio_service members by name.
-keepclassmembernames class com.ryanheise.audioservice.AudioService {
    static com.ryanheise.audioservice.AudioService instance;
    android.support.v4.media.session.MediaSessionCompat mediaSession;
}

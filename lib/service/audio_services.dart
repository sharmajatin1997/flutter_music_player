import 'package:audioplayers/audioplayers.dart';

/// A service class that wraps the [AudioPlayer] from the `audioplayers` package
/// and provides common audio playback functionalities.
///
/// This class exposes reactive streams for tracking playback position,
/// duration, and player state. It also provides methods for playing,
/// pausing, resuming, seeking, and stopping audio playback.
class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Emits updates when the audio playback position changes.
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  /// Emits updates when the total duration of the audio changes.
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  /// Emits the current state of the audio player (playing, paused, stopped, etc.).
  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  /// Emits an event when audio playback completes.
  ///
  /// This stream filters the [onPlayerStateChanged] stream for the
  /// [PlayerState.completed] event.
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerStateChanged
      .where((state) => state == PlayerState.completed)
      .map((_) {});

  /// Plays the audio from the provided [url].
  ///
  /// The URL must point to a valid audio source.
  Future<void> play(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  /// Pauses the currently playing audio.
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resumes audio playback if it was paused.
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  /// Seeks the audio to a specific [position].
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Stops the audio playback completely.
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Sets the audio volume.
  ///
  /// The [volume] should be between 0.0 (mute) and 1.0 (full volume).
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  /// Releases resources used by the audio player.
  ///
  /// This should be called when the player is no longer needed.
  void dispose() {
    _audioPlayer.dispose();
  }
}

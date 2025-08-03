import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Singleton service class for managing audio playback with metadata.
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _currentUrl;
  String? _currentTitle;

  final StreamController<String?> _titleController =
  StreamController<String?>.broadcast();

  /// Stream of current title changes (for reactive UI).
  Stream<String?> get currentTitleStream => _titleController.stream;

  /// Current audio URL being played.
  String? get currentUrl => _currentUrl;

  /// Current title of the song.
  String? get currentTitle => _currentTitle;

  /// Emits updates when the audio playback position changes.
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  /// Emits updates when the total duration of the audio changes.
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  /// Emits the current state of the audio player (playing, paused, stopped, etc.).
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  /// Emits an event when audio playback completes.
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerStateChanged
      .where((state) => state == PlayerState.completed)
      .map((_) {});

  /// Plays the audio from the provided [url] with an optional [title].
  Future<void> play(String url, {String? title}) async {
    _currentUrl = url;
    _currentTitle = title;
    _titleController.add(title);
    await _audioPlayer.play(UrlSource(url));
  }

  /// Pauses the currently playing audio.
  Future<void> pause() async => _audioPlayer.pause();

  /// Resumes audio playback if it was paused.
  Future<void> resume() async => _audioPlayer.resume();

  /// Seeks the audio to a specific [position].
  Future<void> seek(Duration position) async => _audioPlayer.seek(position);

  /// Stops the audio playback and clears metadata.
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentUrl = null;
    _currentTitle = null;
    _titleController.add(null);
  }

  /// Sets the audio volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async =>
      _audioPlayer.setVolume(volume);

  /// Releases resources used by the audio player.
  void dispose() {
    _titleController.close();
    _audioPlayer.dispose();
  }
}

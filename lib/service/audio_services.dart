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

  final StreamController<String?> _titleController = StreamController<String?>.broadcast();

  /// Stream of current title changes (for reactive UI).
  Stream<String?> get currentTitleStream => _titleController.stream;

  /// Current audio URL being played.
  String? get currentUrl => _currentUrl;

  /// Current title of the song.
  String? get currentTitle => _currentTitle;

  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerStateChanged.where((state) => state == PlayerState.completed).map((_) {});

  /// Plays the audio from the provided [url] with an optional [title].
  Future<void> play(String url, {String? title}) async {
    _currentUrl = url;
    _currentTitle = title;
    _titleController.add(title);
    await _audioPlayer.play(UrlSource(url));
  }

  /// Manually update current title
  void updateTitle(String? title) {
    _currentTitle = title;
    if (!_titleController.isClosed) {
      _titleController.add(title);
    }
  }

  Future<void> pause() async => _audioPlayer.pause();
  Future<void> resume() async => _audioPlayer.resume();
  Future<void> seek(Duration position) async => _audioPlayer.seek(position);

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentUrl = null;
    _currentTitle = null;
    _titleController.add(null);
  }

  Future<void> setVolume(double volume) async => _audioPlayer.setVolume(volume);

  void dispose() {
    _titleController.close();
    _audioPlayer.dispose();
  }
}

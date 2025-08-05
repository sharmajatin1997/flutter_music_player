import 'dart:async';
import 'package:flutter_music_player_ui/model/music_model.dart' show MusicModel;
import 'package:flutter_music_player_ui/service/global_model_notifier.dart';
import 'package:flutter_music_player_ui/service/mini_player_controller.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal() {
    _setupListeners();
  }

  final AudioPlayer _player = AudioPlayer();
  final List<MusicModel> _playlist = [];
  int _currentIndex = 0;

  bool isRepeating = false;
  bool isAutoPlayEnabled = true;

  final _isPlayingController = StreamController<bool>.broadcast();
  final _currentIndexController = StreamController<int>.broadcast();
  final _isRepeatingController = StreamController<bool>.broadcast();

  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<int> get currentIndexStream => _currentIndexController.stream;
  Stream<bool> get isRepeatingStream => _isRepeatingController.stream;
  double? get currentVolume => _player.volume;

  // Inside AudioPlayerService
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  int get currentIndex => _currentIndex;
  int get playlistLength => _playlist.length;

  MusicModel? get currentSong =>
      _playlist.isNotEmpty ? _playlist[_currentIndex] : null;

  AudioPlayer get player => _player;

  void _setupListeners() {
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        if (isRepeating) {
          await _player.seek(Duration.zero);
          await _player.play();
        } else if (isAutoPlayEnabled) {
          await playNext();

        }
      }
      _isPlayingController.add(state.playing);
    });
  }


  Future<void> setPlaylist(List<MusicModel> songs, bool isStart, {int startAt = 0}) async {
    _playlist.clear();
    _playlist.addAll(songs);
    setCurrentIndex(startAt);
    if (isStart) {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    _currentIndexController.add(index);
  }

  Future<void> play() async {
    final song = currentSong;
    if (song == null) return;

    try {
      await _player.setUrl(song.url);
      await _player.play();

      /// ✅ Notify UI about the current song
      GlobalModelNotifier.currentSongNotifier.value = song;

      _isPlayingController.add(true);
      _currentIndexController.add(_currentIndex);
    } catch (e) {
      print('Error playing song: $e');
    }
  }


  Future<void> pause() async {
    await _player.pause();
    _isPlayingController.add(false);
  }

  Future<void> resume() async {
    await _player.play();
    _isPlayingController.add(true);
  }

  Future<void> playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      setCurrentIndex(_currentIndex + 1);
      await play();
    } else if (isRepeating) {
      setCurrentIndex(0);
      await play();
    } else {
      await _player.stop();
      GlobalModelNotifier.currentSongNotifier.value = null;
      miniPlayerController.hideMiniPlayer();
    }
  }


  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      setCurrentIndex(_currentIndex - 1);
      await play();
    }
  }

  void toggleRepeat() {
    isRepeating = !isRepeating;
    _isRepeatingController.add(isRepeating);
  }

  void toggleAutoPlay() {
    isAutoPlayEnabled = !isAutoPlayEnabled;
  }

  Stream<double> get volumeStream => _player.volumeStream;

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  List<MusicModel> get playlistSongs => _playlist;

  void setRepeatAll(bool enable) {
    player.setLoopMode(enable ? LoopMode.all : LoopMode.off);
  }

  void dispose() {
    _player.dispose();
    _isPlayingController.close();
    _currentIndexController.close();
    _isRepeatingController.close();
  }
}

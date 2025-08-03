import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';
import 'package:flutter_music_player_ui/screen/gradient_progress_bar.dart';
import 'package:flutter_music_player_ui/screen/song_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_music_player_ui/service/audio_services.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../service/global_model_notifier.dart';

/// A full-featured, customizable music player UI screen for Flutter.
///
/// Supports audio playback, seek bar, volume control, repeat mode,
/// shimmer loading, Lottie animations, song queue, and download with progress.
///
/// Part of the `flutter_music_player_ui` package.
class MusicPlayerScreen extends StatefulWidget {
  /// List of music tracks to be played.
  final List<MusicModel> songs;

  /// The index of the initially selected track.
  final int initialIndex;

  /// Whether to display the song queue at the bottom.
  final bool showQueue;

  /// Whether repeat mode is enabled by default.
  final bool repeat;

  /// Whether to show the download icon.
  final bool showDownloadIcon;

  /// Gradient color 1 for background and progress bar.
  final Color gradiant1;

  /// Gradient color 2 for background and progress bar.
  final Color gradiant2;

  /// Color for inactive dots in the page indicator.
  final Color indicatorDotColor;

  /// Color for the active dot in the page indicator.
  final Color indicatorActiveDotColor;

  /// Color for all icons.
  final Color iconColor;

  /// Color for the song title.
  final Color titleColor;

  /// Color for the song description text.
  final Color descriptionColor;

  /// Gradient start color for the song card widget.
  final Color songGradiantColor1;

  /// Gradient end color for the song card widget.
  final Color songGradiantColor2;

  final bool isBackMusic;

  /// Creates a [MusicPlayerScreen] with all UI and playback options.
  const MusicPlayerScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
    this.showQueue = false,
    this.repeat = false,
    this.showDownloadIcon = false,
    this.gradiant1 = const Color(0xFF8E2DE2),
    this.gradiant2 = const Color(0xFF4A00E0),
    this.indicatorDotColor = Colors.white30,
    this.indicatorActiveDotColor = Colors.white,
    this.iconColor = Colors.white,
    this.titleColor = Colors.white,
    this.descriptionColor = const Color(0xffCECECE),
    this.songGradiantColor1 = const Color(0xFF8E2DE2),
    this.songGradiantColor2 = const Color(0xFFC18FF3),
    this.isBackMusic = false,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();
  double _volume = 0.6;
  bool _isPaused = false;
  bool _isLoading = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late List<int> _playOrder;

  bool _isRepeat = false;

  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  MusicModel get currentSongModel => widget.songs[_playOrder[_currentIndex]];

  String get currentSong => widget.songs[_playOrder[_currentIndex]].url;

  @override
  void initState() {
    super.initState();
    _isRepeat = widget.repeat;
    _playOrder = List.generate(widget.songs.length, (i) => i);
    _currentIndex = widget.initialIndex;

    VolumeController.instance.showSystemUI = false;
    VolumeController.instance.addListener((v) => setState(() => _volume = v));
    VolumeController.instance.getVolume().then(
      (v) => setState(() => _volume = v),
    );

    _setupAudio();
    if (!mounted) return;
    _audioService.onPositionChanged.listen((pos) {
      setState(() => _position = pos);
      // call here
      updateCurrentSong();
    });
    if (!mounted) return;
    _audioService.onDurationChanged.listen((dur) {
      setState(() => _duration = dur);
      // call here
      updateCurrentSong();
    });
    if (!mounted) return;
    _audioService.onPlayerComplete.listen((_) {
      if (_currentIndex < _playOrder.length - 1 || _isRepeat) {
        _playNext();
      } else {
        _audioService.stop();
      }
      // call here
      updateCurrentSong();
    });
  }

  void updateCurrentSong() {
    GlobalModelNotifier.currentSongNotifier.value = currentSongModel;
  }

  /// Sets up the audio player and begins playing the selected song.
  Future<void> _setupAudio() async {
    setState(() {
      _isLoading = true;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _audioService.play(currentSong);
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    if (!widget.isBackMusic) {
      stopMusic();
    }
    super.dispose();
  }

  /// Plays the next song in the list. Respects repeat mode.
  void _playNext() {
    if (_currentIndex < _playOrder.length - 1) {
      _currentIndex++;
    } else if (_isRepeat) {
      _currentIndex = 0;
    } else {
      return;
    }

    _isPaused = false;
    _setupAudio();
  }

  /// Plays the previous song if available.
  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _isPaused = false;
      _setupAudio();
    }
  }

  /// Formats a [Duration] into mm:ss format.
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  final List<String> lottieFiles = [
    'assets/disk.json',
    'assets/headphone.json',
  ];

  @override
  Widget build(BuildContext context) {
    double progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: widget.gradiant1),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.gradiant1, widget.gradiant2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x4affffff),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: widget.iconColor,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.showDownloadIcon,
                    child: IconButton(
                      icon: Icon(
                        Icons.download_rounded,
                        color: widget.iconColor,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                              _downloadCurrentSong(context);
                            },
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: widget.showQueue ? 20 : 25),
                      _buildHeaderArtwork(),
                      SizedBox(height: widget.showQueue ? 15 : 20),
                      _isLoading
                          ? _shimmerLine(width: 220, height: 16)
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.songs[_playOrder[_currentIndex]].title ??
                                    currentSong.split("/").last,
                                style: TextStyle(
                                  color: widget.titleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                      SizedBox(height: widget.showQueue ? 4 : 8),
                      _isLoading
                          ? _shimmerLine(width: 120, height: 12)
                          : Visibility(
                              visible:
                                  widget
                                      .songs[_playOrder[_currentIndex]]
                                      .description
                                      ?.isNotEmpty ==
                                  true,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.songs[_playOrder[_currentIndex]].description ??
                                      '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: widget.descriptionColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: widget.showQueue ? 24 : 30),
                      _isLoading
                          ? _shimmerLine(height: 10)
                          : GradientProgressBar(
                              value: progress.clamp(0.0, 1.0),
                              totalDuration: _duration,
                              gradiant1: widget.gradiant1,
                              gradiant2: widget.gradiant2,
                              onSeek: (position) {
                                _audioService.seek(position);
                              },
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _isLoading
                              ? _shimmerLine(width: 40, height: 10)
                              : Text(
                                  formatDuration(_position),
                                  style: TextStyle(
                                    color: widget.titleColor,
                                    fontSize: 10,
                                  ),
                                ),
                          _isLoading
                              ? _shimmerLine(width: 40, height: 10)
                              : Text(
                                  formatDuration(_duration),
                                  style: TextStyle(
                                    color: widget.titleColor,
                                    fontSize: 10,
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(height: widget.showQueue ? 15 : 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: _isLoading
                                ? _shimmerIcon(Icons.repeat)
                                : Icon(
                                    Icons.repeat,
                                    color: _isRepeat
                                        ? Colors.pinkAccent
                                        : widget.iconColor,
                                    size: 24,
                                  ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() => _isRepeat = !_isRepeat);
                                  },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _isLoading || _currentIndex == 0
                                ? null
                                : _playPrevious,
                            icon: _isLoading
                                ? _shimmerIcon(Icons.skip_previous)
                                : Icon(
                                    Icons.skip_previous,
                                    color: _currentIndex == 0
                                        ? Colors.white38
                                        : widget.iconColor,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          StreamBuilder<PlayerState>(
                            stream: _audioService.onPlayerStateChanged,
                            builder: (context, snapshot) {
                              final isPlaying =
                                  snapshot.data == PlayerState.playing;
                              final icon = Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: widget.iconColor,
                                size: 30,
                              );
                              return IconButton(
                                icon: _isLoading
                                    ? _shimmerIcon(
                                        isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      )
                                    : icon,
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (isPlaying) {
                                          _isPaused = true;
                                          _audioService.pause();
                                        } else {
                                          _isPaused
                                              ? _audioService.resume()
                                              : _setupAudio();
                                          _isPaused = false;
                                        }
                                      },
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed:
                                _isLoading ||
                                    (!_isRepeat &&
                                        _currentIndex == _playOrder.length - 1)
                                ? null
                                : _playNext,
                            icon: _isLoading
                                ? _shimmerIcon(Icons.skip_next)
                                : Icon(
                                    Icons.skip_next,
                                    color:
                                        (!_isRepeat &&
                                            _currentIndex ==
                                                _playOrder.length - 1)
                                        ? Colors.white38
                                        : widget.iconColor,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      SizedBox(height: widget.showQueue ? 15 : 20),
                      Row(
                        children: [
                          Icon(
                            Icons.volume_down,
                            color: widget.iconColor,
                            size: 30,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              min: 0,
                              max: 1,
                              activeColor: widget.gradiant1,
                              onChanged: _isLoading
                                  ? null
                                  : (value) async {
                                      _volume = value;
                                      await VolumeController.instance.setVolume(
                                        value,
                                      );
                                      _audioService.setVolume(value);
                                      setState(() {});
                                    },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.volume_up,
                            color: widget.iconColor,
                            size: 30,
                          ),
                        ],
                      ),
                      // 🔽 Queue
                      Visibility(
                        visible: widget.showQueue,
                        child: SongStackWidget(
                          songGradiantColor1: widget.songGradiantColor1,
                          songGradiantColor2: widget.songGradiantColor2,
                          textColor: widget.titleColor,
                          songs: _playOrder
                              .sublist(_currentIndex)
                              .map((i) => widget.songs[i])
                              .toList(),
                          onNext: _playNext,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the animated Lottie artwork and page indicator.
  Widget _buildHeaderArtwork() {
    return _isLoading
        ? Shimmer.fromColors(
            baseColor: widget.gradiant2.withAlpha(100),
            highlightColor: Colors.white.withAlpha(150),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        : Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [widget.gradiant2, widget.gradiant1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: lottieFiles.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Lottie.asset(
                        lottieFiles[index],
                        package: 'flutter_music_player_ui',
                        repeat: _isPaused ? false : true,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SmoothPageIndicator(
                controller: _pageController,
                count: lottieFiles.length,
                effect: WormEffect(
                  dotColor: widget.indicatorDotColor,
                  activeDotColor: widget.indicatorActiveDotColor,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ],
          );
  }

  /// Returns a shimmer line placeholder used during loading.
  Widget _shimmerLine({double width = double.infinity, double height = 14}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: widget.gradiant2.withAlpha(77),
        highlightColor: Colors.white.withAlpha(153),
        child: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Returns a shimmer icon placeholder used during loading.
  Widget _shimmerIcon(IconData? icon) {
    return Shimmer.fromColors(
      baseColor: widget.gradiant2.withAlpha(77),
      highlightColor: Colors.white.withAlpha(153),
      child: Icon(icon, color: widget.iconColor, size: 30),
    );
  }

  /// Downloads the currently playing song and shows a progress dialog.
  Future<void> _downloadCurrentSong(BuildContext context) async {
    final url = currentSong;
    final title =
        widget.songs[_playOrder[_currentIndex]].title?.replaceAll(' ', '_') ??
        'audio_${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      final dir = await getDownloadDirectory();
      if (dir == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access storage')),
        );
        return;
      }

      final filePath = '${dir.path}/$title.mp3';
      final dio = Dio();

      _downloadProgress = 0.0;
      _isDownloading = true;

      StateSetter? setDialogState;

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) {
            setDialogState = setState;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [widget.gradiant1, widget.gradiant2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isDownloading
                      ? Column(
                          key: const ValueKey('progress'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.download_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Downloading...",
                              style: TextStyle(
                                color: widget.titleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GradientProgressDownloadBar(
                              value: _downloadProgress.clamp(0.0, 1.0),
                              gradiant1: widget.gradiant1,
                              gradiant2: widget.gradiant2,
                              height: 8,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${(_downloadProgress * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                color: widget.descriptionColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('success'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/success_check.json',
                              package: 'flutter_music_player_ui',
                              width: 100,
                              height: 100,
                              repeat: false,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Download Complete!",
                              style: TextStyle(
                                color: widget.titleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      );

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress = received / total;
            if (setDialogState != null) {
              setDialogState!(() {}); // updates the dialog's UI
            }
          }
        },
      );

      _isDownloading = false;
      if (setDialogState != null) {
        setDialogState!(() {}); // Trigger AnimatedSwitcher to show success
      }

      await Future.delayed(const Duration(seconds: 2)); // Allow Lottie to play

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Downloaded to: ${dir.path}')));
    } catch (e) {
      _isDownloading = false;
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Download failed')));
      debugPrint("Download error: $e");
    }
  }

  /// Returns the appropriate download directory for the platform.
  Future<Directory?> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // This points to the public Downloads folder on Android
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return null;
    }
  }

  void stopMusic() async{
    await _audioService.stop();
  }
}

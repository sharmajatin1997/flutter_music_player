import 'package:flutter/material.dart';
import 'package:flutter_music_player_ui/service/mini_player_controller.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';
import 'package:flutter_music_player_ui/screen/gradient_progress_bar.dart';
import 'package:flutter_music_player_ui/screen/song_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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


  /// Creates a [MusicPlayerScreen] with all UI and playback options.
  const MusicPlayerScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
    this.showQueue = false,
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
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool _isLoading = false;
  final audioService = AudioPlayerService();
  bool isPlaying = true;
  bool _isMuted = false;
  double _lastVolume = 1.0;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await audioService.setPlaylist(widget.songs, false, startAt: widget.initialIndex);
      // set current song
      GlobalModelNotifier.currentSongNotifier.value = widget.songs[widget.initialIndex];
      // start playback
      await audioService.play();
      // show mini player
      miniPlayerController.showMiniPlayer();
    });
    // 🔹 Listen for song loading states
    audioService.player.processingStateStream.listen((state) {
      if (state == ProcessingState.loading || state == ProcessingState.buffering) {
        setState(() => _isLoading = true);
      } else if (state == ProcessingState.ready) {
        setState(() => _isLoading = false);
      }
    });
    // 🔹 Listen for track changes
    audioService.player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < widget.songs.length) {
        GlobalModelNotifier.currentSongNotifier.value = widget.songs[index];
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        miniPlayerController.showMiniPlayer();
      }
    });
    super.dispose();
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
                    onTap: () {
                      Navigator.pop(context);
                      miniPlayerController.showMiniPlayer(); // Show mini player on back
                    },
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

                            },
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: ValueListenableBuilder<MusicModel?>(
                      valueListenable: GlobalModelNotifier.currentSongNotifier,
                      builder: (context, currentSong, _) {
                        if (currentSong == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height:25),
                            _buildHeaderArtwork(),
                            SizedBox(height: 20),
                            _isLoading
                                ? _shimmerLine(width: 220, height: 16)
                                : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currentSong.title ?? currentSong.url.split("/").last,
                                style: TextStyle(
                                  color: widget.titleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            _isLoading
                                ? _shimmerLine(width: 120, height: 12)
                                : Visibility(
                              visible:
                              currentSong.description?.isNotEmpty == true,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currentSong.description ?? '',
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
                            SizedBox(height:20),
                            _isLoading
                                ? _shimmerLine(height: 10)
                                : _buildDraggableProgressBar(),
                            SizedBox(height: 10),
                            StreamBuilder<int>(
                              stream: audioService.currentIndexStream,
                              initialData: audioService.currentIndex,
                              builder: (context, indexSnapshot) {
                                final index = indexSnapshot.data ?? 0;
                                return StreamBuilder<bool>(
                                  stream: audioService.isRepeatingStream,
                                  initialData: audioService.isRepeating,
                                  builder: (context, repeatSnapshot) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // 🔹 NEW: Mute / Unmute button
                                        IconButton(
                                          icon: Icon(
                                            _isMuted ? Icons.volume_off : Icons.volume_up,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_isMuted) {
                                                audioService.setVolume(_lastVolume);
                                                _isMuted = false;
                                              } else {
                                                _lastVolume = audioService.currentVolume ?? 1.0;
                                                audioService.setVolume(0);
                                                _isMuted = true;
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.skip_previous,
                                            color: index > 0 ? Colors.white : Colors.white.withOpacity(0.4),
                                          ),
                                          onPressed: index > 0
                                              ? () => audioService.playPrevious()
                                              : null,
                                        ),
                                        StreamBuilder<bool>(
                                          stream: audioService.isPlayingStream,
                                          initialData: true,
                                          builder: (context, playingSnapshot) {
                                            final playing = playingSnapshot.data ?? false;
                                            return IconButton(
                                              icon: Icon(
                                                playing
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_fill,
                                                size: 55,
                                                color: Colors.white,
                                              ),
                                              onPressed: () async {
                                                if (playing) {
                                                  setState(() {
                                                    isPlaying=false;
                                                  });
                                                  await audioService.pause();
                                                } else {
                                                  setState(() {
                                                    isPlaying=true;
                                                  });
                                                  await audioService.resume();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.skip_next,
                                            color: (index < audioService.playlistLength - 1 || audioService.isRepeating)
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.4),
                                          ),
                                          onPressed: (index < audioService.playlistLength - 1 || audioService.isRepeating)
                                              ? () => audioService.playNext()
                                              : null,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            audioService.isRepeating ? Icons.repeat_on : Icons.repeat,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() => audioService.toggleRepeat());
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 15),
                            _volumeSlider(),
                          ],
                        );
                      })
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
                        repeat: isPlaying?true:false,
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

  Widget _buildDraggableProgressBar() {
    return StreamBuilder<Duration?>(
      stream: audioService.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: audioService.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localOffset = box.globalToLocal(details.globalPosition);
                final relative = localOffset.dx / box.size.width;
                final newPosition = duration * relative.clamp(0.0, 1.0);
                audioService.seek(newPosition);
              },
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final relative = details.localPosition.dx / box.size.width;
                final newPosition = duration * relative.clamp(0.0, 1.0);
                audioService.seek(newPosition);
              },
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(position),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        formatDuration(duration),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _volumeSlider() {
    return StreamBuilder<double>(
      stream: audioService.volumeStream,
      initialData: 1.0,
      builder: (context, snapshot) {
        final volume = snapshot.data ?? 1.0;
        return Row(
          children: [
            const Icon(Icons.volume_down, color: Colors.white),
            Expanded(
              child: Slider(
                value: volume,
                min: 0.0,
                max: 1.0,
                activeColor: Color(0xFF8E2DE2),
                inactiveColor: Colors.grey.withAlpha(200),
                onChanged: (value) {
                  audioService.setVolume(value);
                },
              ),
            ),
            const Icon(Icons.volume_up, color: Colors.white),
          ],
        );
      },
    );
  }
}



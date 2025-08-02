import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:music_player/model/music_model.dart';
import 'package:music_player/screen/gradient_progress_bar.dart';
import 'package:music_player/screen/song_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_player/service/audio_services.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<MusicModel> songs;
  final int initialIndex;
  final bool showQueue;

  const MusicPlayerScreen({super.key, required this.songs, required this.initialIndex,this.showQueue=false});

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
  Duration _bufferedPosition = Duration.zero;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  String get currentSong => widget.songs[_currentIndex].url;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    VolumeController.instance.showSystemUI = false;
    VolumeController.instance.addListener((v) => setState(() => _volume = v));
    VolumeController.instance.getVolume().then((v) => setState(() => _volume = v));

    _setupAudio();

    _audioService.onPositionChanged.listen((pos) {
      setState(() => _position = pos);
    });

    _audioService.onDurationChanged.listen((dur) {
      setState(() => _duration = dur);
    });

    // 👉 Auto play next track on completion
    _audioService.onPlayerComplete.listen((_) {
      if (_currentIndex < widget.songs.length - 1) {
        _playNext();
      } else {
        // Optionally reset or stop on last track
        _audioService.stop();
      }
    });
  }

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
    _audioService.stop();
    _audioService.dispose();
    super.dispose();
  }

  void _playNext() {
    if (_currentIndex < widget.songs.length - 1) {
      _currentIndex++;
      _isPaused = false;
      _setupAudio();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _isPaused = false;
      _setupAudio();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    double progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

    double buffered = _duration.inMilliseconds == 0
        ? 0.0
        : _bufferedPosition.inMilliseconds / _duration.inMilliseconds;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: const Color(0xFF8E2DE2)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x4affffff),
                  ),
                  child: Icon(Icons.arrow_back_ios_new, size: 20,color: Colors.white,),
                ),
              ),
               SizedBox(height: widget.showQueue?10:25),
              _buildHeaderArtwork(),
              SizedBox(height: widget.showQueue?15:20),
              _isLoading
                  ? _shimmerLine(width: 220, height: 16)
                  : Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    widget.songs[_currentIndex].title??currentSong.split("/").last,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: widget.showQueue?4:8),
              _isLoading
                  ? _shimmerLine(width: 120, height: 12)
                  : Visibility(
                    visible: widget.songs[_currentIndex].description?.isNotEmpty==true,
                    child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                    'Relaxing music',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xffCECECE), fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                  ),
              SizedBox(height: widget.showQueue?24:30),
              _isLoading
                  ? _shimmerLine(height: 10)
                  : GradientProgressBar(
                value: progress.clamp(0.0, 1.0),
                bufferedValue: buffered.clamp(0.0, 1.0),
                totalDuration: _duration,
                onSeek: (position) => _audioService.seek(position),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _isLoading
                      ? _shimmerLine(width: 40, height: 10)
                      : Text(formatDuration(_position), style: const TextStyle(color: Color(0xffCECECE), fontSize: 10)),
                  _isLoading
                      ? _shimmerLine(width: 40, height: 10)
                      : Text(formatDuration(_duration), style: const TextStyle(color: Color(0xffCECECE), fontSize: 10)),
                ],
              ),
              SizedBox(height: widget.showQueue?15:20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _isLoading || _currentIndex == 0 ? null : _playPrevious,
                    icon: _isLoading
                        ? _shimmerIcon()
                        : Icon(Icons.skip_previous, color: _currentIndex == 0 ? Colors.white38 :Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  StreamBuilder<PlayerState>(
                    stream: _audioService.onPlayerStateChanged,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data == PlayerState.playing;
                      final icon = Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      );

                      return IconButton(
                        icon: _isLoading ? _shimmerIcon() : icon,
                        onPressed: _isLoading
                            ? null
                            : () {
                          if (isPlaying) {
                            _isPaused = true;
                            _audioService.pause();
                          } else {
                            _isPaused ? _audioService.resume() : _setupAudio();
                            _isPaused = false;
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _isLoading || _currentIndex == widget.songs.length - 1 ? null : _playNext,
                    icon: _isLoading
                        ? _shimmerIcon()
                        : Icon(Icons.skip_next, color: _currentIndex == widget.songs.length - 1 ? Colors.white38 : Colors.white, size: 30),
                  ),
                ],
              ),
              SizedBox(height: widget.showQueue?10:20),
              Row(
                children: [
                  const Icon(Icons.volume_down, color: Colors.white, size: 30),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Slider(
                      value: _volume,
                      min: 0,
                      max: 1,
                      activeColor: Colors.pinkAccent,
                      onChanged: _isLoading
                          ? null
                          : (value) async {
                        _volume = value;
                        await VolumeController.instance.setVolume(value);
                        _audioService.setVolume(value);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.volume_up, color: Colors.white, size: 30),
                ],
              ),
              Visibility(
                visible: widget.showQueue,
                child: SongStackWidget(
                  songs: widget.songs.sublist(_currentIndex), // e.g. widget.songs.sublist(currentIndex),
                  onNext: _playNext, // your existing next handler
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> lottieFiles = [
    'assets/disk.json',
    'assets/headphone.json',
  ];

  Widget _buildHeaderArtwork() {
    return _isLoading
        ? Shimmer.fromColors(
      baseColor: const Color(0xFF4A00E0).withAlpha(100),
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
            gradient: const LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
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
                  package: 'music_player',
                  repeat: true,
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
            dotColor: Colors.white30,
            activeDotColor: Colors.white,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }

  Widget _shimmerLine({double width = double.infinity, double height = 14}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF4A00E0).withAlpha(77),
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

  Widget _shimmerIcon() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF4A00E0).withAlpha(77),
      highlightColor: Colors.white.withAlpha(153),
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
    );
  }
}




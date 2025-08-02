// All your imports remain unchanged
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
  final bool repeat;
  final Color gradiant1,gradiant2, indicatorDotColor, indicatorActiveDotColor,titleColor,descriptionColor,iconColor,songGradiantColor1,songGradiantColor2;

  const MusicPlayerScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
    this.showQueue = false,
    this.repeat = false,
    this.gradiant1=const Color(0xFF8E2DE2),
    this.gradiant2=const Color(0xFF4A00E0),
    this.indicatorDotColor=Colors.white30,
    this.indicatorActiveDotColor=Colors.white,
    this.iconColor=Colors.white,
    this.titleColor=Colors.white,
    this.descriptionColor=const Color(0xffCECECE),
    this.songGradiantColor1= const Color(0xFF8E2DE2),
    this.songGradiantColor2=const  Color(0xFFC18FF3),
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

  String get currentSong => widget.songs[_playOrder[_currentIndex]].url;

  @override
  void initState() {
    super.initState();
    _isRepeat = widget.repeat;
    _playOrder = List.generate(widget.songs.length, (i) => i);
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

    _audioService.onPlayerComplete.listen((_) {
      if (_currentIndex < _playOrder.length - 1 || _isRepeat) {
        _playNext();
      } else {
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
        decoration:  BoxDecoration(
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
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x4affffff),
                  ),
                  child:  Icon(Icons.arrow_back_ios_new, size: 20, color: widget.iconColor),
                ),
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
                          style:  TextStyle(color: widget.titleColor, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: widget.showQueue ? 4 : 8),
                      _isLoading
                          ? _shimmerLine(width: 120, height: 12)
                          : Visibility(
                        visible: widget.songs[_playOrder[_currentIndex]].description?.isNotEmpty == true,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.songs[_playOrder[_currentIndex]].description??'',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: widget.descriptionColor, fontSize: 10, fontWeight: FontWeight.w600),
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
                        onSeek: (position) => _audioService.seek(position),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _isLoading
                              ? _shimmerLine(width: 40, height: 10)
                              : Text(formatDuration(_position), style:  TextStyle(color: widget.titleColor, fontSize: 10)),
                          _isLoading
                              ? _shimmerLine(width: 40, height: 10)
                              : Text(formatDuration(_duration), style:  TextStyle(color: widget.titleColor, fontSize: 10)),
                        ],
                      ),
                      SizedBox(height: widget.showQueue ? 15 : 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: _isLoading
                                ? _shimmerIcon(Icons.repeat):Icon(
                              Icons.repeat,
                              color: _isRepeat ? Colors.pinkAccent : widget.iconColor,
                              size: 24,
                            ),
                            onPressed: _isLoading? null :() {
                              setState(() => _isRepeat = !_isRepeat);
                            },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _isLoading || _currentIndex == 0 ? null : _playPrevious,
                            icon: _isLoading
                                ? _shimmerIcon(Icons.skip_previous)
                                : Icon(Icons.skip_previous, color: _currentIndex == 0 ? Colors.white38 :widget.iconColor, size: 30),
                          ),
                          const SizedBox(width: 16),
                          StreamBuilder<PlayerState>(
                            stream: _audioService.onPlayerStateChanged,
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data == PlayerState.playing;
                              final icon = Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: widget.iconColor,
                                size: 30,
                              );
                              return IconButton(
                                icon: _isLoading ? _shimmerIcon(isPlaying ? Icons.pause : Icons.play_arrow,) : icon,
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
                            onPressed: _isLoading || (!_isRepeat && _currentIndex == _playOrder.length - 1)
                                ? null
                                : _playNext,
                            icon: _isLoading
                                ? _shimmerIcon(Icons.skip_next)
                                : Icon(
                              Icons.skip_next,
                              color: (!_isRepeat && _currentIndex == _playOrder.length - 1)
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
                           Icon(Icons.volume_down, color: widget.iconColor, size: 30),
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
                                await VolumeController.instance.setVolume(value);
                                _audioService.setVolume(value);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                           Icon(Icons.volume_up, color: widget.iconColor, size: 30),
                        ],
                      ),
                      // 🔽 Queue
                      Visibility(
                        visible: widget.showQueue,
                        child: SongStackWidget(
                          songGradiantColor1:widget.songGradiantColor1,
                          songGradiantColor2:widget.songGradiantColor2,
                          textColor: widget.titleColor,
                          songs: _playOrder.sublist(_currentIndex).map((i) => widget.songs[i]).toList(),
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
            gradient:  LinearGradient(
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
                  package: 'music_player',
                  repeat: _isPaused?false:true,
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
            activeDotColor:widget.indicatorActiveDotColor,
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

  Widget _shimmerIcon(IconData? icon) {
    return Shimmer.fromColors(
      baseColor: widget.gradiant2.withAlpha(77),
      highlightColor: Colors.white.withAlpha(153),
      child:  Icon(icon, color: widget.iconColor, size: 30),
    );
  }
}

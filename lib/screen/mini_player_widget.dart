import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';
import 'package:flutter_music_player_ui/screen/gradient_progress_bar.dart';
import 'package:flutter_music_player_ui/service/audio_services.dart';
import 'package:flutter_music_player_ui/service/global_model_notifier.dart';

class MiniPlayerWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const MiniPlayerWidget({super.key, this.onTap});

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  final AudioPlayerService audioService = AudioPlayerService();
  Offset position = const Offset(20, 100); // Initial position
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    double progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;
    return StreamBuilder<PlayerState>(
      stream: audioService.onPlayerStateChanged,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data == PlayerState.playing;
        if (!isPlaying) return const SizedBox(); // Hide when not playing

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                position += details.delta;
              });
            },
            onTap: widget.onTap,
            child: _buildDraggableBubble(progress),
          ),
        );
      },
    );
  }

  Widget _buildDraggableBubble(double progress) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(50),
      color: Colors.purple.shade600.withAlpha(242),
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E2DE2),
              Color(0xFF4A00E0)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.music_note, color: Colors.white),
                const SizedBox(width: 10),
                ValueListenableBuilder<MusicModel?>(
                  valueListenable: GlobalModelNotifier.currentSongNotifier,
                  builder: (context, song, _) {
                    debugPrint("current playing song $song ${song?.title}");
                    if (song == null) return SizedBox.shrink();
                    return Text(song.title ?? song.url.split("/").last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.white),
                  tooltip: 'Stop Music',
                  onPressed: () async {
                    await audioService.stop();
                  },
                ),
              ],
            ),
            GradientProgressBar(
              value: progress.clamp(0.0, 1.0),
              totalDuration: _duration,
              gradiant1: Color(0xFF8E2DE2),
              gradiant2: Color(0xFF4A00E0),
              onSeek: (position) {
                audioService.seek(position);
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    audioService.onPositionChanged.listen((pos) {
      setState(() => _position = pos);
    });

    audioService.onDurationChanged.listen((dur) {
      setState(() => _duration = dur);
    });
  }
}

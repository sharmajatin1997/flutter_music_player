import 'package:flutter/material.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';
import 'package:flutter_music_player_ui/service/audio_services.dart';
import 'package:flutter_music_player_ui/service/mini_player_controller.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayerWidget extends StatefulWidget {
  final MusicModel currentSong;
  final Offset initialPosition;

  const MiniPlayerWidget({
    super.key,
    required this.currentSong,
    this.initialPosition = const Offset(20, 100),
  });

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  late Offset position;
  double? dragValue; // For progress bar dragging

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(50),
          color: Colors.purple.shade600.withAlpha(242),
          child: Container(
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.currentSong.title ?? "Playing...",
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Play/Pause toggle
                    StreamBuilder<PlayerState>(
                      stream: audioService.player.playerStateStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data?.playing ?? false;
                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              audioService.pause();
                            } else {
                              audioService.resume();
                            }
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        audioService.pause();
                        miniPlayerController.hideMiniPlayer();
                      },
                    ),
                  ],
                ),
                _buildDraggableProgressBar(audioService),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableProgressBar(AudioPlayerService audioService) {
    return StreamBuilder<Duration?>(
      stream: audioService.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: audioService.positionStream,
          builder: (context, positionSnapshot) {
            final position = dragValue != null
                ? Duration(milliseconds: (duration.inMilliseconds * dragValue!).toInt())
                : positionSnapshot.data ?? Duration.zero;

            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localOffset = box.globalToLocal(details.globalPosition);
                setState(() {
                  dragValue = (localOffset.dx / box.size.width).clamp(0.0, 1.0);
                });
              },
              onHorizontalDragEnd: (_) {
                if (dragValue != null) {
                  audioService.seek(duration * dragValue!.clamp(0.0, 1.0));
                  setState(() {
                    dragValue = null;
                  });
                }
              },
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final relative = details.localPosition.dx / box.size.width;
                audioService.seek(duration * relative.clamp(0.0, 1.0));
              },
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  height: 6,
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
            );
          },
        );
      },
    );
  }
}



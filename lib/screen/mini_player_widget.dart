import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_music_player_ui/service/audio_services.dart';

class MiniPlayerWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const MiniPlayerWidget({super.key, this.onTap});

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  final AudioPlayerService audioService = AudioPlayerService();
  Offset position = const Offset(20, 100); // Initial position

  @override
  Widget build(BuildContext context) {
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
            child: _buildDraggableBubble(),
          ),
        );
      },
    );
  }

  Widget _buildDraggableBubble() {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(50),
      color: Colors.purple.shade600.withOpacity(0.95),
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<String?>(
                stream: audioService.currentTitleStream,
                builder: (context, snapshot) {
                  final title = snapshot.data ?? "Now Playing";
                  return Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              tooltip: 'Stop Music',
              onPressed: () async {
                await audioService.stop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

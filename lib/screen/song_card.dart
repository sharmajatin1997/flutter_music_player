// ✅ FIXED VERSION

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_player/model/music_model.dart';

class SongStackWidget extends StatelessWidget {
  final List<MusicModel> songs;
  final VoidCallback onNext;

  const SongStackWidget({super.key, required this.songs, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final visibleStack = songs.length > 1
        ? songs.sublist(1, min(4, songs.length))
        : [];

    if (visibleStack.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Up Next",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90 + (visibleStack.length - 1) * 14.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: visibleStack.asMap().entries.map((entry) {
              final reversedIndex = visibleStack.length - 1 - entry.key;
              final MusicModel song = visibleStack[reversedIndex];
              final isTopCard = reversedIndex == 0;
              return Positioned(
                top: reversedIndex * 14.0,
                left: 0,
                right: 0,
                child: SongCard(
                  song: song,
                  onNext: isTopCard ? onNext : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SongCard extends StatelessWidget {
  final MusicModel song;
  final VoidCallback? onNext;

  const SongCard({super.key, required this.song, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8E2DE2),
            Color(0xFFC18FF3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              song.title?? song.url.split("/").last,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A00E0),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
            child: const Icon(Icons.skip_next),
          )
        ],
      ),
    );
  }
}

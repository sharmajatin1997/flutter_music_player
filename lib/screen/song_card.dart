import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';

/// A widget that displays a stacked list of upcoming songs below the current one.
///
/// It shows a maximum of 3 queued songs (excluding the currently playing one),
/// with a stacked card appearance. The topmost card has a "Next" button.
///
/// Typically used within the [MusicPlayerScreen] to show "Up Next" queue.
class SongStackWidget extends StatelessWidget {
  /// The list of songs in the queue.
  ///
  /// The first song is assumed to be currently playing and will not be shown in the stack.
  final List<MusicModel> songs;

  /// Callback triggered when the topmost card's "Next" button is pressed.
  final VoidCallback onNext;

  /// Text color used in each stacked card.
  final Color textColor;

  /// Gradient start color for song cards.
  final Color songGradiantColor1;

  /// Gradient end color for song cards.
  final Color songGradiantColor2;

  /// Creates a widget that displays the upcoming songs in a stacked format.
  const SongStackWidget({
    super.key,
    required this.songs,
    required this.onNext,
    required this.textColor,
    required this.songGradiantColor1,
    required this.songGradiantColor2,
  });

  @override
  Widget build(BuildContext context) {
    final visibleStack = songs.length > 1
        ? songs.sublist(1, min(4, songs.length))
        : [];

    if (visibleStack.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Up Next",
          style: TextStyle(
            color: textColor,
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
                  textColor: textColor,
                  songGradiantColor1: songGradiantColor1,
                  songGradiantColor2: songGradiantColor2,
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

/// A single card representing a song in the "Up Next" queue.
///
/// Displays the song title and an optional "Next" button when [onNext] is provided.
class SongCard extends StatelessWidget {
  /// The music track displayed in the card.
  final MusicModel song;

  /// Optional callback triggered when the "Next" button is pressed.
  final VoidCallback? onNext;

  /// Color used for the text (title).
  final Color textColor;

  /// Gradient start color of the card background.
  final Color songGradiantColor1;

  /// Gradient end color of the card background.
  final Color songGradiantColor2;

  /// Creates a [SongCard] with title and optional skip button.
  const SongCard({
    super.key,
    required this.song,
    required this.textColor,
    required this.songGradiantColor1,
    required this.songGradiantColor2,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [songGradiantColor1, songGradiantColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              song.title ?? song.url.split("/").last,
              style: TextStyle(
                color: textColor,
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
              backgroundColor: const Color(0xFF4A00E0),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
            child: const Icon(Icons.skip_next),
          ),
        ],
      ),
    );
  }
}

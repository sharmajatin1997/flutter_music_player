import 'package:flutter/material.dart';

/// A custom gradient progress bar with seek functionality.
///
/// Used to display the current progress of media playback and allows
/// the user to seek to a different position by tapping or dragging.
///
/// [value] should be between 0.0 and 1.0 to represent progress.
/// [totalDuration] is the full duration of the media.
/// [onSeek] is a callback triggered when the user taps or drags to seek.
/// [gradiant1] and [gradiant2] define the gradient colors.
class GradientProgressBar extends StatelessWidget {
  /// Current progress value (0.0 to 1.0).
  final double value;

  /// Total duration of the media being played.
  final Duration totalDuration;

  /// Callback invoked when the user seeks to a new position.
  final Function(Duration position) onSeek;

  /// Starting color of the gradient.
  final Color gradiant1;

  /// Ending color of the gradient.
  final Color gradiant2;

  /// Creates a [GradientProgressBar] widget.
  const GradientProgressBar({
    super.key,
    required this.value,
    required this.totalDuration,
    required this.onSeek,
    required this.gradiant1,
    required this.gradiant2,
  });

  /// Handles seeking logic based on user's interaction on the bar.
  void _handleSeek(BuildContext context, double dx) {
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final percent = (dx / width).clamp(0.0, 1.0);
    final position = totalDuration * percent;
    onSeek(position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _handleSeek(context, details.localPosition.dx),
      onHorizontalDragUpdate: (details) =>
          _handleSeek(context, details.localPosition.dx),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 8,
          width: double.infinity,
          color: gradiant2,
          child: Stack(
            children: [
              // Background fill to show inactive area
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                color: Colors.white.withAlpha(51),
              ),
              // Foreground fill representing progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [gradiant2, gradiant1]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A read-only horizontal gradient progress bar (no seek).
///
/// Useful for showing buffering, downloads, or background progress.
/// The gradient fills based on the [value] from left to right.
///
/// [value] should be between 0.0 and 1.0.
/// [gradiant1] and [gradiant2] define the gradient colors.
/// [height] and [borderRadius] are customizable for styling.
class GradientProgressDownloadBar extends StatelessWidget {
  /// Current progress value (0.0 to 1.0).
  final double value;

  /// Starting color of the gradient.
  final Color gradiant1;

  /// Ending color of the gradient.
  final Color gradiant2;

  /// Height of the progress bar.
  final double height;

  /// Border radius for rounding the corners.
  final BorderRadius borderRadius;

  /// Creates a [GradientProgressDownloadBar] widget.
  const GradientProgressDownloadBar({
    super.key,
    required this.value,
    required this.gradiant1,
    required this.gradiant2,
    this.height = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey.shade300.withAlpha(128)),
        child: Stack(
          children: [
            // Foreground gradient fill
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradiant1, gradiant2],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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

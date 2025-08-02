// Reuse your existing GradientProgressBar code from earlier
import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final double value;
  final Duration totalDuration;
  final Function(Duration position) onSeek;
  final Color gradiant1,gradiant2;

  const GradientProgressBar({
    super.key,
    required this.value,
    required this.totalDuration,
    required this.onSeek,
    required this.gradiant1,
    required this.gradiant2,
  });

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
      onHorizontalDragUpdate: (details) => _handleSeek(context, details.localPosition.dx),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 8,
          width: double.infinity,
          color: gradiant2,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width ,
                color: Colors.white.withAlpha(51),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * value,
                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradiant2,
                      gradiant1
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
}

class GradientProgressDownloadBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color gradiant1;
  final Color gradiant2;
  final double height;
  final BorderRadius borderRadius;

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
        decoration: BoxDecoration(
          color: Colors.grey.shade300.withOpacity(0.5),
        ),
        child: Stack(
          children: [
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
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
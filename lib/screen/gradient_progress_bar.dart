// Reuse your existing GradientProgressBar code from earlier
import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final double value;
  final double bufferedValue;
  final Duration totalDuration;
  final Function(Duration position) onSeek;

  const GradientProgressBar({
    super.key,
    required this.value,
    required this.bufferedValue,
    required this.totalDuration,
    required this.onSeek,
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
          color: const Color(0xff191558),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * bufferedValue,
                color: Colors.white.withOpacity(0.2),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * value,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff191558), Color(0xff771DF8)],
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
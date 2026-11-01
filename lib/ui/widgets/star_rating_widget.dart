import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StarRatingWidget extends StatelessWidget {
  final int stars; // 0, 1, 2, 3
  final double starSize;
  final bool animate;

  const StarRatingWidget({
    super.key,
    required this.stars,
    this.starSize = 36.0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isFilled = index < stars;

        Widget star = Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isFilled ? const Color(0xFFFFD700) : const Color(0x66FFFFFF),
          size: index == 1 ? starSize * 1.25 : starSize,
          shadows: isFilled
              ? [
                  const Shadow(
                    color: Color(0xFFFF9100),
                    blurRadius: 12,
                  ),
                ]
              : null,
        );

        if (animate && isFilled) {
          star = star
              .animate(delay: Duration(milliseconds: 200 * index + 100))
              .scale(
                begin: const Offset(0.2, 0.2),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .rotate(
                begin: -0.3,
                end: 0.0,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: star,
        );
      }),
    );
  }
}

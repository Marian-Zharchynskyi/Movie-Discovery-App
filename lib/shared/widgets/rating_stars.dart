import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating10; // 0-10 scale
  final double size;
  final Color color;

  const RatingStars({
    super.key,
    required this.rating10,
    this.size = 16,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    // Convert 0-10 to 0-5 scale
    final rating5 = (rating10 / 2).clamp(0, 5);
    final fullStars = rating5.floor();
    final hasHalf = (rating5 - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++) Icon(Icons.star, size: size, color: color),
        if (hasHalf) Icon(Icons.star_half, size: size, color: color),
        for (int i = 0; i < emptyStars; i++) Icon(Icons.star_border, size: size, color: color),
      ],
    );
  }
}

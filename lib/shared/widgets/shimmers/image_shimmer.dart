import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ImageShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius,
      ),
    );

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: borderRadius != null ? ClipRRect(borderRadius: borderRadius!, child: box) : box,
    );
  }
}

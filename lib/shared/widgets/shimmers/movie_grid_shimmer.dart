import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MovieGridShimmer extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final int itemCount;

  const MovieGridShimmer({
    super.key,
    required this.crossAxisCount,
    this.childAspectRatio = 0.6,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 12, color: base),
            const SizedBox(height: 6),
            Container(height: 10, width: 60, color: base),
          ],
        ),
      ),
    );
  }
}

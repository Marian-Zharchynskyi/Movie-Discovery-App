import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MovieDetailsShimmer extends StatelessWidget {
  const MovieDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final base = Colors.grey.shade300;
        final highlight = Colors.grey.shade100;

        Widget posterBox({double width = 180, double height = 270, BorderRadius? radius}) =>
            Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: radius ?? BorderRadius.circular(10),
                ),
              ),
            );

        Widget line(double width, double height, {double radius = 8}) => Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            );

        final infoColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            line(240, 22),
            const SizedBox(height: 12),
            Row(
              children: [
                line(100, 16, radius: 6),
                const SizedBox(width: 12),
                line(60, 14, radius: 6),
              ],
            ),
            const SizedBox(height: 12),
            line(120, 14, radius: 6),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                3,
                (_) => line(70, 28, radius: 20),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    posterBox(),
                    const SizedBox(width: 24),
                    Expanded(child: infoColumn),
                  ],
                )
              else ...[
                Center(child: posterBox()),
                const SizedBox(height: 16),
                infoColumn,
              ],
              const SizedBox(height: 24),
              // Overview title and lines
              line(120, 18),
              const SizedBox(height: 12),
              line(double.infinity, 12),
              const SizedBox(height: 8),
              line(double.infinity, 12),
              const SizedBox(height: 8),
              line(constraints.maxWidth * 0.6, 12),
              const SizedBox(height: 24),
              // Backdrop placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Shimmer.fromColors(
                  baseColor: base,
                  highlightColor: highlight,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: base,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

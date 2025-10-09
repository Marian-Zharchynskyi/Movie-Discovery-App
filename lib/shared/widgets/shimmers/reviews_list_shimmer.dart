import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReviewsListShimmer extends StatelessWidget {
  final int itemCount;
  const ReviewsListShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        ...List.generate(
          itemCount,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          line(120, 16, radius: 6),
                          const SizedBox(width: 8),
                          line(40, 14, radius: 6),
                        ],
                      ),
                      const SizedBox(height: 10),
                      line(double.infinity, 10),
                      const SizedBox(height: 6),
                      line(double.infinity, 10),
                      const SizedBox(height: 6),
                      line(MediaQuery.of(context).size.width * 0.6, 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

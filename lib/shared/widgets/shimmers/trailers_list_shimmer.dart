import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrailersListShimmer extends StatelessWidget {
  final int itemCount;
  const TrailersListShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trailers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) => Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

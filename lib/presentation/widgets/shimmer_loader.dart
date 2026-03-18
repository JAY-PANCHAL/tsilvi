import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/app_colors.dart';

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.height,
    required this.width,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardFill.withOpacity(0.35),
      highlightColor: Colors.white.withOpacity(0.18),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final double height;

  const ShimmerListTile({super.key, this.height = 84});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardFill.withOpacity(0.35),
      highlightColor: Colors.white.withOpacity(0.18),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Used anywhere data is loading from Firestore or the AI is generating
/// content, instead of a blank screen or spinner-in-a-void.
class SkeletonBlock extends StatelessWidget {
  final double height;
  final double? width;

  const SkeletonBlock({super.key, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.paper,
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}

class ResumeCardSkeleton extends StatelessWidget {
  const ResumeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(height: 16, width: 160),
              SizedBox(height: AppSpacing.sm),
              SkeletonBlock(height: 12, width: 100),
              SizedBox(height: AppSpacing.md),
              SkeletonBlock(height: 6, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}

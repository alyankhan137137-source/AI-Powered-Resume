import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';

/// Fixed placement (top of every builder step) per DESIGN_SYSTEM.md —
/// component placement stays identical across the whole flow.
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepLabel;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(stepLabel, style: AppTypography.title.copyWith(color: Colors.white, fontSize: 18)),
            Text('$currentStep of $totalSteps', style: AppTypography.caption.copyWith(color: Colors.white60)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            minHeight: 4,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryPurple),
          ),
        ),
      ],
    );
  }
}

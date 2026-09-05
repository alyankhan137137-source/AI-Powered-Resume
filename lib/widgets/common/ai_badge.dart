import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';

/// Marks content the AI generated so the user always knows what it wrote
/// vs. what they wrote themselves — this is a functional signal, not decoration.
class AiBadge extends StatelessWidget {
  const AiBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.signal500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.signal500.withValues(alpha: 0.2)),
      ),
      child: Text(
        'AI suggested',
        style: AppTypography.caption.copyWith(
          color: AppColors.signal500,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

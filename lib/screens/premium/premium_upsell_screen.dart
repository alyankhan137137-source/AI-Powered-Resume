import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/primary_button.dart';
import '../../core/theme/app_colors.dart';

class PremiumUpsellScreen extends StatelessWidget {
  const PremiumUpsellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(decoration: AppTheme.mainBackground),
          Container(decoration: AppTheme.auraGradient),
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.auto_awesome, size: 80, color: AppTheme.primaryPurple),
                const SizedBox(height: 40),
                Text('Unlock Your Career Potential', 
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(color: Colors.white, fontSize: 32)),
                const SizedBox(height: 16),
                Text('Get access to exclusive features and templates.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: Colors.white70)),
                const SizedBox(height: 60),
                const _FeatureRow(icon: Icons.all_inclusive_rounded, label: 'Unlimited AI Generations'),
                const _FeatureRow(icon: Icons.star_border_rounded, label: 'Exclusive Premium Templates'),
                const _FeatureRow(icon: Icons.history, label: 'Unlimited Resume Versions'),
                const _FeatureRow(icon: Icons.support_agent, label: 'Priority Human Support'),
                const _FeatureRow(icon: Icons.remove_circle_outline, label: 'Ad-Free Experience'),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Not now, maybe later', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: PrimaryButton(
            label: 'Subscribe for \$9.99/mo',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment flow simulated in Mock Mode.')),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryPurple, size: 24),
          const SizedBox(width: 20),
          Expanded(child: Text(label, style: AppTypography.body.copyWith(color: Colors.white))),
          const Icon(Icons.check_circle, color: AppColors.growth600, size: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import 'legal_content_screen.dart';
import 'feedback_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action is permanent and all your resumes will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deletion simulated in Mock Mode.')));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: isDark ? Colors.white : AppColors.ink900, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.ink900),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: isDark ? AppTheme.glassCard : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
                  child: Text(
                    (user?.displayName?.isNotEmpty ?? false) ? user!.displayName![0].toUpperCase() : '?',
                    style: AppTypography.title.copyWith(color: AppTheme.primaryPurple),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? '', 
                        style: AppTypography.bodyStrong.copyWith(color: isDark ? Colors.white : AppColors.ink900),
                        overflow: TextOverflow.ellipsis),
                      Text(user?.email ?? '', 
                        style: AppTypography.caption.copyWith(color: isDark ? Colors.white60 : AppColors.ink600),
                        overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SettingsTile(icon: Icons.work_outline, label: 'Target job title', value: user?.targetJobTitle ?? 'Not set', onTap: () {}),
          _SettingsTile(icon: Icons.palette_outlined, label: 'Appearance', value: isDark ? 'Dark' : 'Light', onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme switching is set to "System" in AppConfig.')));
          }),
          _SettingsTile(icon: Icons.help_outline_rounded, label: 'Help & Support', value: '', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()));
          }),
          _SettingsTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', value: '', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(
              title: 'Privacy Policy',
              content: 'We take your privacy seriously. This policy explains how we collect and use your data...',
            )));
          }),
          _SettingsTile(icon: Icons.description_outlined, label: 'Terms of Service', value: '', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(
              title: 'Terms of Service',
              content: 'By using this app, you agree to the following terms and conditions...',
            )));
          }),
          _SettingsTile(icon: Icons.delete_outline, label: 'Delete Account', value: '', color: Colors.redAccent, onTap: () => _showDeleteAccountDialog(context)),
          const SizedBox(height: AppSpacing.xxxl),
          Center(child: Text('Version 1.0.0+1', style: AppTypography.caption.copyWith(color: isDark ? Colors.white24 : AppColors.ink300))),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: PrimaryButton(
            label: 'Sign out',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({required this.icon, required this.label, required this.value, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: Icon(icon, size: 20, color: color ?? (isDark ? Colors.white70 : AppColors.ink600)),
      title: Text(label, style: AppTypography.body.copyWith(color: color ?? (isDark ? Colors.white : AppColors.ink900))),
      trailing: value.isEmpty
          ? Icon(Icons.chevron_right, color: isDark ? Colors.white24 : AppColors.ink300)
          : Text(value, style: AppTypography.caption.copyWith(color: isDark ? Colors.white60 : AppColors.ink600)),
    );
  }
}

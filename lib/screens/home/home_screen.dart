import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';
import '../../widgets/skeletons/skeleton_loader.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../builder/builder_flow_screen.dart';
import '../linkedin/linkedin_import_screen.dart';
import '../templates/resume_preview_screen.dart';
import '../profile/profile_screen.dart';
import '../premium/premium_upsell_screen.dart';
import 'ai_assistant_screen.dart';
import 'package:intl/intl.dart';

/// Lands right after your existing login/signup flow. Shows the user's
/// saved resumes and the two ways to start a new one.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) context.read<ResumeProvider>().listenToResumes(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.displayName?.split(' ').first ?? 'there'}', 
          style: TextStyle(color: isDark ? Colors.white : AppColors.ink900, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: isDark ? Colors.white : AppColors.ink900),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final uid = context.read<AuthProvider>().user?.uid;
          if (uid != null) context.read<ResumeProvider>().listenToResumes(uid);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: 60), // Account for transparent app bar
            _PremiumBanner(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumUpsellScreen()))),
            const SizedBox(height: AppSpacing.lg),
            _StartCard(
              icon: Icons.add_circle_outline,
              title: 'Start from scratch',
              subtitle: 'Answer a few questions, let AI help you write it.',
              onTap: () {
                context.read<ResumeProvider>().startNewDraft();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BuilderFlowScreen()));
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _StartCard(
              icon: Icons.link,
              title: 'Import from LinkedIn',
              subtitle: 'Pull your experience and skills automatically.',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkedInImportScreen())),
            ),
            const SizedBox(height: AppSpacing.md),
            _StartCard(
              icon: Icons.auto_awesome,
              title: 'AI Career Assistant',
              subtitle: 'Ask Gemini for career advice or resume tips.',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Your resumes', style: AppTypography.title.copyWith(color: isDark ? Colors.white : AppColors.ink900)),
            const SizedBox(height: AppSpacing.md),
            if (resumeProvider.resumes.isEmpty) ...[
              const ResumeCardSkeleton(),
            ] else
              for (final resume in resumeProvider.resumes) _ResumeListItem(resume: resume),
            if (resumeProvider.resumes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Text(
                  'No resumes yet — tap "Start from scratch" above to build your first one.',
                  style: AppTypography.bodyMuted.copyWith(color: isDark ? Colors.white70 : AppColors.ink600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Go Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Unlock exclusive templates and unlimited AI generations.', 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StartCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: isDark ? AppTheme.glassCard : BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(AppRadius.sm)
                  ),
                  child: Icon(icon, color: AppTheme.primaryPurple, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyStrong.copyWith(color: isDark ? Colors.white : AppColors.ink900)),
                      Text(subtitle, style: AppTypography.caption.copyWith(color: isDark ? Colors.white70 : AppColors.ink600)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: isDark ? Colors.white24 : AppColors.ink300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumeListItem extends StatelessWidget {
  final Resume resume;
  const _ResumeListItem({required this.resume});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: isDark ? AppTheme.glassCard : BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              context.read<ResumeProvider>().loadDraft(resume);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumePreviewScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(resume.title, 
                          style: AppTypography.bodyStrong.copyWith(color: isDark ? Colors.white : AppColors.ink900), 
                          overflow: TextOverflow.ellipsis),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white70 : AppColors.ink600),
                        onSelected: (value) async {
                          final uid = context.read<AuthProvider>().user?.uid;
                          if (uid == null) return;
                          if (value == 'duplicate') {
                            await context.read<ResumeProvider>().duplicateResume(uid, resume);
                          } else if (value == 'delete') {
                            await context.read<ResumeProvider>().deleteResume(uid, resume.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'Updated ${DateFormat.yMMMd().format(resume.updatedAt)}',
                    style: AppTypography.caption.copyWith(color: isDark ? Colors.white60 : AppColors.ink600),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: resume.completeness,
                      minHeight: 5,
                      backgroundColor: isDark ? Colors.white10 : AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPurple),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

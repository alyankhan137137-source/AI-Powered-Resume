import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';
import '../../models/template_model.dart';
import '../../widgets/skeletons/skeleton_loader.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../builder/builder_flow_screen.dart';
import '../linkedin/linkedin_import_screen.dart';
import '../templates/resume_preview_screen.dart';
import '../templates/template_gallery_screen.dart';
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
      body: RefreshIndicator(
        onRefresh: () async {
          final uid = context.read<AuthProvider>().user?.uid;
          if (uid != null) context.read<ResumeProvider>().listenToResumes(uid);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.blurBackground, StretchMode.fadeTitle],
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.lg),
                title: Text(
                  'Hi, ${user?.displayName?.split(' ').first ?? 'there'}',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.ink900,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.person_outline, color: isDark ? Colors.white : AppColors.ink900),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsRow(count: resumeProvider.resumes.length),
                    const SizedBox(height: AppSpacing.xl),
                    _FakeSearchBar(),
                    const SizedBox(height: AppSpacing.xl),
                    _PremiumBanner(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumUpsellScreen()))),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Create New', style: AppTypography.label.copyWith(color: isDark ? Colors.white60 : AppColors.ink600)),
                    const SizedBox(height: AppSpacing.md),
                    _QuickActionsGrid(),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Resumes', style: AppTypography.title.copyWith(color: isDark ? Colors.white : AppColors.ink900, fontSize: 20)),
                        if (resumeProvider.resumes.isNotEmpty)
                          TextButton(
                            onPressed: () {},
                            child: const Text('See all'),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            if (resumeProvider.resumes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: ResumeCardSkeleton()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ResumeListItem(resume: resumeProvider.resumes[index]),
                    childCount: resumeProvider.resumes.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int count;
  const _StatsRow({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(label: 'Total Resumes', value: count.toString()),
        const SizedBox(width: AppSpacing.xl),
        const _StatItem(label: 'Job Matches', value: '12'),
        const SizedBox(width: AppSpacing.xl),
        const _StatItem(label: 'Profile Views', value: '48'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.title.copyWith(color: isDark ? Colors.white : AppColors.ink900, fontSize: 18)),
        Text(label, style: AppTypography.caption.copyWith(color: isDark ? Colors.white38 : AppColors.ink600)),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.4,
      children: [
        _QuickActionCard(
          icon: Icons.add_circle_outline,
          title: 'Start Fresh',
          color: AppTheme.primaryPurple,
          onTap: () {
            context.read<ResumeProvider>().startNewDraft();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BuilderFlowScreen()));
          },
        ),
        _QuickActionCard(
          icon: Icons.link,
          title: 'LinkedIn Sync',
          color: Colors.blueAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkedInImportScreen())),
        ),
        _QuickActionCard(
          icon: Icons.auto_awesome,
          title: 'AI Assistant',
          color: Colors.amber,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
        ),
        _QuickActionCard(
          icon: Icons.description_outlined,
          title: 'Templates',
          color: AppColors.growth600,
          onTap: () {
            // Future: Directly to gallery with a new draft
            context.read<ResumeProvider>().startNewDraft();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateGalleryScreen()));
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.title, required this.color, required this.onTap});

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
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(title, style: AppTypography.bodyStrong.copyWith(color: isDark ? Colors.white : AppColors.ink900, fontSize: 14)),
              ],
            ),
          ),
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

class _FakeSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.white38 : AppColors.ink300, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text('Search resumes...', style: TextStyle(color: isDark ? Colors.white24 : AppColors.ink300)),
        ],
      ),
    );
  }
}

class _ResumeListItem extends StatelessWidget {
  final Resume resume;
  const _ResumeListItem({required this.resume});

  IconData _getTemplateIcon() {
    switch (resume.templateId) {
      case ResumeTemplateId.classic: return Icons.article_outlined;
      case ResumeTemplateId.modern: return Icons.dashboard_customize_outlined;
      case ResumeTemplateId.minimal: return Icons.notes_outlined;
    }
  }

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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: (resume.customAccentColorHex != null 
                        ? Color(int.parse(resume.customAccentColorHex!.replaceAll('#', '0xFF'))) 
                        : AppTheme.primaryPurple).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getTemplateIcon(), 
                      color: resume.customAccentColorHex != null 
                        ? Color(int.parse(resume.customAccentColorHex!.replaceAll('#', '0xFF'))) 
                        : AppTheme.primaryPurple, 
                      size: 24),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(resume.title, 
                          style: AppTypography.bodyStrong.copyWith(
                            color: isDark ? Colors.white : AppColors.ink900,
                            fontSize: 16,
                          ), 
                          overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${resume.templateId.name.toUpperCase()} · Updated ${DateFormat.yMMMd().format(resume.updatedAt)}',
                          style: AppTypography.caption.copyWith(color: isDark ? Colors.white38 : AppColors.ink600),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: resume.completeness,
                            minHeight: 4,
                            backgroundColor: isDark ? Colors.white10 : AppColors.border,
                            valueColor: AlwaysStoppedAnimation(resume.customAccentColorHex != null 
                              ? Color(int.parse(resume.customAccentColorHex!.replaceAll('#', '0xFF'))) 
                              : AppTheme.primaryPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white30 : AppColors.ink300),
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
            ),
          ),
        ),
      ),
    );
  }
}

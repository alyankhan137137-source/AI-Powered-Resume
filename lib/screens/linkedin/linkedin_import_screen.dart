import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';
import '../../models/experience_model.dart';
import '../../models/skill_model.dart';
import '../../services/linkedin_import_service.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/config/app_config.dart';
import '../builder/builder_flow_screen.dart';
import 'advanced_import_screen.dart';

/// Two import paths: OAuth (requires your own backend + approved LinkedIn
/// app, see LinkedInImportService docs) or pasting exported profile text,
/// which works today with no extra setup.
class LinkedInImportScreen extends StatefulWidget {
  const LinkedInImportScreen({super.key});

  @override
  State<LinkedInImportScreen> createState() => _LinkedInImportScreenState();
}

class _LinkedInImportScreenState extends State<LinkedInImportScreen> {
  final _service = LinkedInImportService();
  final _pastedText = TextEditingController();
  bool _connecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import from LinkedIn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link, size: 20, color: AppColors.growth600),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Connect your LinkedIn account', style: AppTypography.bodyStrong),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'We\'ll pull your headline, positions, education, and skills directly '
                    'and pre-fill a new resume. You can edit anything after import.',
                    style: AppTypography.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Connect LinkedIn',
                    isLoading: _connecting,
                    onPressed: () async {
                      if (AppConfig.useMockMode) {
                        setState(() => _connecting = true);
                        await Future.delayed(const Duration(seconds: 1));
                        if (!context.mounted) return;
                        
                        // Load a pre-filled mock resume to simulate a real import
                        final mockImport = Resume(
                          title: 'Imported from LinkedIn',
                          fullName: 'Alyan Khan',
                          email: AppConfig.mockEmail,
                          targetJobTitle: 'Senior Flutter Developer',
                          summary: 'Experienced mobile developer with a passion for building high-quality apps.',
                          experience: [
                            ExperienceEntry(
                              jobTitle: 'Mobile Lead',
                              company: 'Tech Corp',
                              bullets: ['Led a team of 5 developers', 'Built 3 major apps'],
                              startDate: DateTime(2020, 1, 1),
                            )
                          ],
                          skills: [SkillEntry(name: 'Flutter'), SkillEntry(name: 'Dart')],
                        );
                        
                        context.read<ResumeProvider>().loadDraft(mockImport);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const BuilderFlowScreen()),
                        );
                        return;
                      }
                      setState(() => _connecting = true);
                      await _service.launchOAuthFlow();
                      if (context.mounted) setState(() => _connecting = false);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('or', style: AppTypography.caption),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: AppSpacing.xl),
            Text('Paste your profile text', style: AppTypography.bodyStrong),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'On LinkedIn: Profile → More → Save to PDF, open it, then copy and paste '
              'the text below. Works without connecting an account.',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Profile text',
              controller: _pastedText,
              maxLines: 8,
              hint: 'Paste your LinkedIn profile export here…',
            ),
            const SizedBox(height: AppSpacing.lg),
            Consumer<ResumeProvider>(
              builder: (context, provider, _) {
                final isLoading = provider.aiStatus == AiTaskStatus.loading;
                return PrimaryButton(
                  label: 'Continue with pasted text',
                  isLoading: isLoading,
                  onPressed: _pastedText.text.trim().isEmpty || isLoading
                      ? null
                      : () async {
                          await provider.importFromLinkedInText(_pastedText.text);
                          if (!context.mounted) return;
                          if (provider.aiStatus == AiTaskStatus.success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const BuilderFlowScreen()),
                            );
                          } else if (provider.aiError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.aiError!)),
                            );
                          }
                        },
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Advanced Job Tailor', style: AppTypography.bodyStrong),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Upload your official LinkedIn "Profile PDF" and a job description. AI will synthesis a tailored resume for you.',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Use Profile PDF & Job Post',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdvancedImportScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

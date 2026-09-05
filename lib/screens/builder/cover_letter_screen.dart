import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _jobDescController = TextEditingController();
  String? _generatedLetter;
  bool _loading = false;

  Future<void> _generate() async {
    if (_jobDescController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final letter = await context.read<ResumeProvider>().generateCoverLetter(_jobDescController.text);
    setState(() {
      _generatedLetter = letter;
      _loading = false;
    });
  }

  void _copy() {
    if (_generatedLetter != null) {
      Clipboard.setData(ClipboardData(text: _generatedLetter!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cover letter copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Cover Letter Generator', style: TextStyle(color: isDark ? Colors.white : AppColors.ink900, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.ink900),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              'Paste the job description below and AI will draft a tailored cover letter using your resume data.',
              style: AppTypography.bodyMuted.copyWith(color: isDark ? Colors.white70 : AppColors.ink600),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Job Description',
              controller: _jobDescController,
              maxLines: 8,
              hint: 'Paste the requirements and description here…',
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Generate Cover Letter',
              isLoading: _loading,
              onPressed: _generate,
            ),
            if (_generatedLetter != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Generated Letter', style: AppTypography.bodyStrong.copyWith(color: isDark ? Colors.white : AppColors.ink900)),
                  IconButton(
                    icon: Icon(Icons.copy, color: isDark ? Colors.white70 : AppColors.ink600, size: 20),
                    onPressed: _copy,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: isDark ? AppTheme.glassCard : BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  _generatedLetter!,
                  style: AppTypography.body.copyWith(color: isDark ? Colors.white70 : AppColors.ink800, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

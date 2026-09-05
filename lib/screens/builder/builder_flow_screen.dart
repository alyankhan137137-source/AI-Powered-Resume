import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/step_progress_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../templates/template_gallery_screen.dart';
import 'steps/personal_info_step.dart';
import 'steps/experience_step.dart';
import 'steps/education_step.dart';
import 'steps/skills_step.dart';
import 'steps/summary_step.dart';

/// Controls the 5-step resume builder flow. Component placement (progress
/// bar top, primary action bottom) stays identical across every step —
/// see DESIGN_SYSTEM.md section 3.
class BuilderFlowScreen extends StatefulWidget {
  const BuilderFlowScreen({super.key});

  @override
  State<BuilderFlowScreen> createState() => _BuilderFlowScreenState();
}

class _BuilderFlowScreenState extends State<BuilderFlowScreen> {
  int _step = 0;
  static const _labels = ['Personal info', 'Experience', 'Education', 'Skills', 'Summary'];
  static const _steps = [
    PersonalInfoStep(),
    ExperienceStep(),
    EducationStep(),
    SkillsStep(),
    SummaryStep(),
  ];

  Future<void> _saveAndExit() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      await context.read<ResumeProvider>().saveDraft(uid);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _next() async {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      return;
    }
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      await context.read<ResumeProvider>().saveDraft(uid);
    }
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateGalleryScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : AppColors.ink900), 
          onPressed: _saveAndExit
        ),
        title: Text(
          _labels[_step], 
          style: TextStyle(color: isDark ? Colors.white : AppColors.ink900, fontWeight: FontWeight.bold)
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: StepProgressBar(
              currentStep: _step + 1, 
              totalSteps: _steps.length, 
              stepLabel: _labels[_step],
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _steps[_step],
          )),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white24 : AppColors.border),
                      foregroundColor: isDark ? Colors.white : AppColors.ink900,
                    ),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: AppTheme.glassButton,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _step == _steps.length - 1 ? 'Choose a template' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/resume_provider.dart';
import '../../../models/education_model.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

class EducationStep extends StatelessWidget {
  const EducationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final education = provider.draft!.education;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (education.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No education added yet', style: AppTypography.bodyStrong),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Add your most recent degree or program first.', style: AppTypography.bodyMuted),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: 'Add education', icon: Icons.add, onPressed: () => _openEditor(context)),
                ],
              ),
            ),
          for (final entry in education)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  title: Text('${entry.degree} in ${entry.fieldOfStudy}', style: AppTypography.bodyStrong),
                  subtitle: Text(
                    '${entry.institution} · ${DateFormat('yyyy').format(entry.startDate)}',
                    style: AppTypography.caption,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => provider.removeEducation(entry.id),
                  ),
                ),
              ),
            ),
          if (education.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add another'),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EducationEditorSheet(),
    );
  }
}

class _EducationEditorSheet extends StatefulWidget {
  const _EducationEditorSheet();

  @override
  State<_EducationEditorSheet> createState() => _EducationEditorSheetState();
}

class _EducationEditorSheetState extends State<_EducationEditorSheet> {
  final _institution = TextEditingController();
  final _degree = TextEditingController();
  final _field = TextEditingController();
  final _gpa = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add education', style: AppTypography.title),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(label: 'Institution', controller: _institution),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Degree', hint: 'e.g. Bachelor of Science', controller: _degree),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Field of study', controller: _field),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'GPA (optional)', controller: _gpa),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Save',
              onPressed: () {
                context.read<ResumeProvider>().addEducation(EducationEntry(
                      institution: _institution.text,
                      degree: _degree.text,
                      fieldOfStudy: _field.text,
                      gpa: _gpa.text.isEmpty ? null : _gpa.text,
                    ));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

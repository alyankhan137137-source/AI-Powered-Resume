import 'package:flutter/material.dart';
import '../../models/resume_model.dart';
import '../../models/template_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import 'package:intl/intl.dart';

/// Live, on-device preview of the resume in its selected template.
/// This mirrors PdfExportService layouts so what's on screen is what exports.
class ResumePreview extends StatelessWidget {
  final Resume resume;

  const ResumePreview({super.key, required this.resume});

  Color get _accent {
    final hex = resume.customAccentColorHex ??
        ResumeTemplate.all.firstWhere((t) => t.id == resume.templateId).accentColorHex;
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SingleChildScrollView(
        child: resume.templateId == ResumeTemplateId.modern
            ? _modernLayout()
            : _standardLayout(),
      ),
    );
  }

  Widget _standardLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(resume.fullName.isEmpty ? 'Your name' : resume.fullName, style: AppTypography.serifName),
        const SizedBox(height: 4),
        Text(
          [resume.email, resume.phone, resume.location].where((s) => s.isNotEmpty).join('  ·  '),
          style: AppTypography.caption.copyWith(color: AppColors.ink600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (resume.summary.isNotEmpty) _section('Summary', [Text(resume.summary, style: AppTypography.serifBody)]),
        if (resume.experience.isNotEmpty)
          _section('Experience', resume.experience.map(_experienceBlock).toList()),
        if (resume.education.isNotEmpty)
          _section('Education', resume.education.map(_educationBlock).toList()),
        if (resume.skills.isNotEmpty)
          _section('Skills', [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: resume.skills.map((s) => Text(s.name, style: AppTypography.serifBody)).toList(),
            ),
          ]),
      ],
    );
  }

  Widget _modernLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resume.fullName.isEmpty ? 'Your name' : resume.fullName,
                    style: AppTypography.serifName.copyWith(fontSize: 18, color: _accent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.sm),
                Text(resume.email, style: AppTypography.caption.copyWith(color: AppColors.ink600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(resume.phone, style: AppTypography.caption.copyWith(color: AppColors.ink600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(resume.location, style: AppTypography.caption.copyWith(color: AppColors.ink600), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (resume.skills.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('SKILLS', style: AppTypography.serifSectionHeading.copyWith(color: _accent, fontSize: 11)),
                  const SizedBox(height: AppSpacing.xs),
                  ...resume.skills.map((s) => Text(s.name, style: AppTypography.serifBody.copyWith(fontSize: 11))),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.summary.isNotEmpty)
                  _section('Summary', [Text(resume.summary, style: AppTypography.serifBody)]),
                if (resume.experience.isNotEmpty)
                  _section('Experience', resume.experience.map(_experienceBlock).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: AppTypography.serifSectionHeading.copyWith(color: _accent)),
          const SizedBox(height: 4),
          Divider(color: _accent, height: 1, thickness: 0.8),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _experienceBlock(dynamic e) {
    final fmt = DateFormat('MMM yyyy');
    final range = '${fmt.format(e.startDate)} – ${e.endDate == null ? 'Present' : fmt.format(e.endDate)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('${e.jobTitle} — ${e.company}', style: AppTypography.serifBody.copyWith(fontWeight: FontWeight.w700))),
              Text(range, style: AppTypography.caption.copyWith(color: AppColors.ink600)),
            ],
          ),
          const SizedBox(height: 3),
          for (final b in e.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 4),
              child: Text('•  $b', style: AppTypography.serifBody),
            ),
        ],
      ),
    );
  }

  Widget _educationBlock(dynamic e) {
    final fmt = DateFormat('MMM yyyy');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.degree} in ${e.fieldOfStudy}', style: AppTypography.serifBody.copyWith(fontWeight: FontWeight.w700)),
                Text(e.institution, style: AppTypography.serifBody),
              ],
            ),
          ),
          Text(fmt.format(e.startDate), style: AppTypography.caption.copyWith(color: AppColors.ink600)),
        ],
      ),
    );
  }
}

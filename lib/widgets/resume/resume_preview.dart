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
        child: _buildPreviewLayout(),
      ),
    );
  }

  Widget _buildPreviewLayout() {
    switch (resume.templateId) {
      case ResumeTemplateId.classic:
      case ResumeTemplateId.minimal:
      case ResumeTemplateId.academic:
        return _standardLayout();
      case ResumeTemplateId.modern:
      case ResumeTemplateId.creative:
        return _modernLayout();
      case ResumeTemplateId.executive:
      case ResumeTemplateId.professionalBold:
        return _boldLayout();
      case ResumeTemplateId.techClean:
        return _techLayout();
      case ResumeTemplateId.compact:
        return _compactLayout();
      case ResumeTemplateId.elegant:
        return _elegantLayout();
    }
  }

  Widget _standardLayout() {
    final isAcademic = resume.templateId == ResumeTemplateId.academic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(resume.fullName.isEmpty ? 'Your Name' : resume.fullName, 
          style: AppTypography.serifName.copyWith(color: isAcademic ? _accent : null)),
        const SizedBox(height: 4),
        Text(
          [resume.email, resume.phone, resume.location].where((s) => s.isNotEmpty).join('  ·  '),
          style: AppTypography.caption.copyWith(color: AppColors.ink600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (resume.summary.isNotEmpty) _section('Summary', [Text(resume.summary, style: AppTypography.serifBody)]),
        if (resume.experience.isNotEmpty) _section('Experience', resume.experience.map(_experienceBlock).toList()),
        if (resume.education.isNotEmpty) _section('Education', resume.education.map(_educationBlock).toList()),
      ],
    );
  }

  Widget _modernLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resume.fullName.isEmpty ? 'Your Name' : resume.fullName,
                  style: AppTypography.serifName.copyWith(fontSize: 18, color: _accent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.sm),
              Text(resume.email, style: AppTypography.caption.copyWith(color: AppColors.ink600, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(resume.phone, style: AppTypography.caption.copyWith(color: AppColors.ink600, fontSize: 10)),
              if (resume.skills.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('SKILLS', style: AppTypography.serifSectionHeading.copyWith(color: _accent, fontSize: 10)),
                const SizedBox(height: AppSpacing.xs),
                ...resume.skills.map((s) => Text(s.name, style: AppTypography.serifBody.copyWith(fontSize: 10))),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (resume.summary.isNotEmpty) _section('Summary', [Text(resume.summary, style: AppTypography.serifBody)]),
              if (resume.experience.isNotEmpty) _section('Experience', resume.experience.map(_experienceBlock).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _boldLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          width: double.infinity,
          decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resume.fullName.isEmpty ? 'YOUR NAME' : resume.fullName.toUpperCase(), 
                style: AppTypography.serifName.copyWith(color: Colors.white, fontSize: 22)),
              Text(resume.targetJobTitle.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (resume.summary.isNotEmpty) _section('Objective', [Text(resume.summary, style: AppTypography.serifBody)]),
        if (resume.experience.isNotEmpty) _section('Professional History', resume.experience.map(_experienceBlock).toList()),
      ],
    );
  }

  Widget _techLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resume.fullName, style: AppTypography.title.copyWith(color: _accent)),
                Text(resume.targetJobTitle, style: AppTypography.caption),
              ],
            ),
            Text(resume.email, style: AppTypography.caption),
          ],
        ),
        const Divider(thickness: 2),
        if (resume.experience.isNotEmpty) _section('Technical Experience', resume.experience.map(_experienceBlock).toList()),
        if (resume.skills.isNotEmpty)
          _section('Skills', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resume.skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: _accent), borderRadius: BorderRadius.circular(4)),
                child: Text(s.name, style: const TextStyle(fontSize: 10)),
              )).toList(),
            )
          ]),
      ],
    );
  }

  Widget _compactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(resume.fullName.toUpperCase(), style: AppTypography.bodyStrong.copyWith(fontSize: 16)),
        Text('${resume.email} | ${resume.phone}', style: AppTypography.caption.copyWith(fontSize: 10)),
        const Divider(),
        if (resume.experience.isNotEmpty) _section('Work', resume.experience.map((e) => _experienceBlock(e, isCompact: true)).toList()),
      ],
    );
  }

  Widget _elegantLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(resume.fullName, style: AppTypography.serifName.copyWith(fontSize: 24, color: _accent)),
        Text(resume.targetJobTitle.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('${resume.email}  •  ${resume.location}', style: AppTypography.caption),
        const SizedBox(height: 16),
        if (resume.summary.isNotEmpty) Text(resume.summary, textAlign: TextAlign.center, style: AppTypography.serifBody.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        if (resume.experience.isNotEmpty) _section('Career Path', resume.experience.map(_experienceBlock).toList()),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: AppTypography.serifSectionHeading.copyWith(color: _accent, fontSize: 12)),
          const SizedBox(height: 4),
          Divider(color: _accent, height: 1, thickness: 1),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _experienceBlock(dynamic e, {bool isCompact = false}) {
    final fmt = DateFormat('MMM yyyy');
    final range = '${fmt.format(e.startDate)} – ${e.endDate == null ? 'Present' : fmt.format(e.endDate)}';
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('${e.jobTitle} — ${e.company}', 
                style: AppTypography.serifBody.copyWith(fontWeight: FontWeight.bold, fontSize: isCompact ? 10 : 11))),
              Text(range, style: AppTypography.caption.copyWith(fontSize: 9)),
            ],
          ),
          for (final b in e.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 8),
              child: Text('•  $b', style: AppTypography.serifBody.copyWith(fontSize: isCompact ? 9 : 10)),
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
          Expanded(child: Text('${e.degree}, ${e.institution}', style: AppTypography.serifBody.copyWith(fontSize: 10))),
          Text(fmt.format(e.startDate), style: AppTypography.caption.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

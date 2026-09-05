import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/template_model.dart';
import '../../models/resume_model.dart';
import '../../widgets/resume/resume_preview.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import 'resume_preview_screen.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({super.key});

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen> {
  late ResumeTemplateId _selected;
  String? _customColorHex;

  final List<String> _presets = [
    '#2E6E58', // Forest Green
    '#1A438A', // Deep Blue
    '#7C3AED', // Royal Purple
    '#B91C1C', // Brick Red
    '#1F2937', // Slate
  ];

  @override
  void initState() {
    super.initState();
    final draft = context.read<ResumeProvider>().draft!;
    _selected = draft.templateId;
    _customColorHex = draft.customAccentColorHex;
  }

  @override
  Widget build(BuildContext context) {
    final resume = context.watch<ResumeProvider>().draft!;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Choose a template', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Expanded(
              flex: 3,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: ResumePreview(
                  key: ValueKey('$_selected-$_customColorHex'),
                  resume: Resume.fromJson({
                    ...resume.toJson(),
                    'templateId': _selected.name,
                    'customAccentColorHex': _customColorHex,
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Color Presets
            if (_selected != ResumeTemplateId.minimal)
              SizedBox(
                height: 40,
                child: Center(
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _presets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final colorHex = _presets[index];
                      final isSelected = _customColorHex == colorHex;
                      final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));

                      return GestureDetector(
                        onTap: () => setState(() => _customColorHex = colorHex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)]
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ResumeTemplate.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final t = ResumeTemplate.all[index];
                  final isSelected = t.id == _selected;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = t.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      width: 160,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryPurple.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryPurple : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: AppTypography.bodyStrong.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            t.description,
                            style: AppTypography.caption.copyWith(color: Colors.white60),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Preview & export',
              onPressed: () {
                resume.templateId = _selected;
                resume.customAccentColorHex = _customColorHex;
                context.read<ResumeProvider>().loadDraft(resume);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumePreviewScreen()));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

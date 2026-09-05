import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/resume_provider.dart';
import '../../../models/skill_model.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

class SkillsStep extends StatefulWidget {
  const SkillsStep({super.key});

  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  final _controller = TextEditingController();
  List<String> _suggestions = [];
  bool _loadingSuggestions = false;

  Future<void> _fetchSuggestions() async {
    setState(() => _loadingSuggestions = true);
    final result = await context.read<ResumeProvider>().suggestSkills();
    setState(() {
      _suggestions = result;
      _loadingSuggestions = false;
    });
  }

  void _addSkill(String name) {
    if (name.trim().isEmpty) return;
    context.read<ResumeProvider>().addSkill(SkillEntry(name: name.trim()));
    _controller.clear();
    setState(() => _suggestions.remove(name));
  }

  @override
  Widget build(BuildContext context) {
    final skills = context.watch<ResumeProvider>().draft!.skills;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Add a skill',
                  hint: 'e.g. Python, Figma, Project Management',
                  controller: _controller,
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 26),
                child: IconButton.filled(
                  onPressed: () => _addSkill(_controller.text),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (skills.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: skills
                  .map((s) => Chip(
                        label: Text(s.name),
                        onDeleted: () => context.read<ResumeProvider>().removeSkill(s.name),
                        deleteIconColor: AppColors.growth600,
                      ))
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: _loadingSuggestions ? null : _fetchSuggestions,
            icon: _loadingSuggestions
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome_outlined, size: 18),
            label: Text(_loadingSuggestions ? 'Thinking…' : 'Suggest skills for this role'),
          ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Suggested for you', style: AppTypography.label.copyWith(color: Colors.white70)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _suggestions
                  .map((s) => ActionChip(
                        avatar: const Icon(Icons.add, size: 16, color: AppColors.signal500),
                        label: Text(s),
                        backgroundColor: AppColors.signal100,
                        labelStyle: AppTypography.label.copyWith(color: AppColors.signal500),
                        onPressed: () => _addSkill(s),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

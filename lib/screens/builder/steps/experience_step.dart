import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/resume_provider.dart';
import '../../../models/experience_model.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/ai_badge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import 'package:intl/intl.dart';

class ExperienceStep extends StatelessWidget {
  const ExperienceStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final experience = provider.draft!.experience;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (experience.isEmpty)
            _EmptyState(onAdd: () => _openEditor(context)),
          for (final entry in experience)
            _ExperienceCard(
              entry: entry,
              onEdit: () => _openEditor(context, existing: entry),
              onDelete: () => provider.removeExperience(entry.id),
            ),
          if (experience.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add another role'),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, {ExperienceEntry? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ExperienceEditorSheet(existing: existing),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No experience added yet', style: AppTypography.bodyStrong.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add a role and describe it in your own words — the AI will turn it into '
            'polished, achievement-focused bullet points.',
            style: AppTypography.bodyMuted.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Add experience', icon: Icons.add, onPressed: onAdd, isLoading: false),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final ExperienceEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExperienceCard({required this.entry, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM yyyy');
    final range =
        '${fmt.format(entry.startDate)} – ${entry.endDate == null ? 'Present' : fmt.format(entry.endDate!)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.jobTitle.isEmpty ? 'Untitled role' : entry.jobTitle,
                            style: AppTypography.bodyStrong.copyWith(color: Colors.white),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${entry.company} · $range', 
                            style: AppTypography.caption.copyWith(color: Colors.white60),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white70), onPressed: onEdit),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white70), onPressed: onDelete),
                ],
              ),
              if (entry.bullets.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                if (entry.aiGenerated) const Padding(padding: EdgeInsets.only(bottom: AppSpacing.sm), child: AiBadge()),
                ...entry.bullets.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('•  $b', style: AppTypography.bodyMuted.copyWith(color: Colors.white70)),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExperienceEditorSheet extends StatefulWidget {
  final ExperienceEntry? existing;
  const _ExperienceEditorSheet({this.existing});

  @override
  State<_ExperienceEditorSheet> createState() => _ExperienceEditorSheetState();
}

class _ExperienceEditorSheetState extends State<_ExperienceEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _company;
  late final TextEditingController _location;
  late final TextEditingController _rawDescription;
  bool _isCurrent = false;
  List<String> _bullets = [];
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.jobTitle ?? '');
    _company = TextEditingController(text: widget.existing?.company ?? '');
    _location = TextEditingController(text: widget.existing?.location ?? '');
    _rawDescription = TextEditingController();
    _isCurrent = widget.existing?.isCurrent ?? false;
    _bullets = List.from(widget.existing?.bullets ?? []);
  }

  Future<void> _generateBullets() async {
    if (_rawDescription.text.trim().isEmpty) return;
    setState(() => _generating = true);
    final entry = ExperienceEntry(jobTitle: _title.text, company: _company.text);
    final bullets = await context.read<ResumeProvider>().generateBulletsFor(entry, _rawDescription.text);
    setState(() {
      _bullets = bullets;
      _generating = false;
    });
  }

  void _save() {
    final provider = context.read<ResumeProvider>();
    final entry = (widget.existing ?? ExperienceEntry()).copyWith(
      jobTitle: _title.text,
      company: _company.text,
      location: _location.text,
      clearEndDate: _isCurrent,
      bullets: _bullets,
      aiGenerated: _bullets.isNotEmpty,
    );
    if (widget.existing == null) {
      provider.addExperience(entry);
    } else {
      provider.updateExperience(entry);
    }
    Navigator.pop(context);
  }

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
            Text(widget.existing == null ? 'Add experience' : 'Edit experience', 
              style: AppTypography.title.copyWith(color: Colors.white, fontSize: 20)),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(label: 'Job title', controller: _title),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Company', controller: _company),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Location', controller: _location),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('I currently work here'),
              value: _isCurrent,
              onChanged: (v) => setState(() => _isCurrent = v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Describe what you did (plain language is fine)',
              hint: 'e.g. "managed social media, grew followers, ran ads"',
              controller: _rawDescription,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _generating ? null : _generateBullets,
              icon: _generating
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(_generating ? 'Generating…' : 'Generate bullet points with AI'),
            ),
            if (_bullets.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const AiBadge(),
              const SizedBox(height: AppSpacing.sm),
              ..._bullets.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(e.value, style: AppTypography.body)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => setState(() => _bullets.removeAt(e.key)),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

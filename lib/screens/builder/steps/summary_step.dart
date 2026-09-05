import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/resume_provider.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/ai_badge.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

class SummaryStep extends StatefulWidget {
  const SummaryStep({super.key});

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<ResumeProvider>().draft!.summary);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final isGenerating = provider.aiStatus == AiTaskStatus.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A short professional summary sits at the top of your resume. Write your own, '
            'or let the AI draft one from the experience and skills you already added.',
            style: AppTypography.bodyMuted.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: isGenerating
                ? null
                : () async {
                    await provider.generateSummary();
                    _controller.text = provider.draft!.summary;
                  },
            icon: isGenerating
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome_outlined, size: 18),
            label: Text(isGenerating ? 'Writing your summary…' : 'Generate with AI'),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (provider.draft!.summaryAiGenerated) ...[
            const AiBadge(),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppTextField(
            label: 'Summary',
            controller: _controller,
            maxLines: 5,
            onChanged: (val) {
              provider.draft!.summary = val;
              provider.draft!.summaryAiGenerated = false;
            },
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

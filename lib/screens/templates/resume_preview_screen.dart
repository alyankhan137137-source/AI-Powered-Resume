import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../services/pdf_export_service.dart';
import '../../widgets/resume/resume_preview.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../builder/cover_letter_screen.dart';

class ResumePreviewScreen extends StatefulWidget {
  const ResumePreviewScreen({super.key});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  final _pdfService = PdfExportService();
  bool _exporting = false;
  List<String>? _reviewNotes;
  bool _reviewLoading = false;
  bool _isLetter = true; // Default to US Letter
  bool _downloading = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final resume = context.read<ResumeProvider>().draft!;
      final file = await _pdfService.generatePdf(resume, isLetter: _isLetter);
      await _pdfService.shareOrPrint(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed. Check your connection and try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _download() async {
    final format = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Format', style: AppTypography.bodyStrong),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              title: const Text('Download PDF (Recommended)'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blueAccent),
              title: const Text('Download PNG (Image)'),
              onTap: () => Navigator.pop(context, 'png'),
            ),
          ],
        ),
      ),
    );

    if (format == null || !mounted) return;

    final resumeProvider = context.read<ResumeProvider>();
    setState(() => _downloading = true);
    try {
      final resume = resumeProvider.draft!;
      if (format == 'pdf') {
        await _pdfService.downloadPdf(resume, isLetter: _isLetter);
      } else {
        await _pdfService.downloadAsImage(resume, isLetter: _isLetter);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _runReview() async {
    setState(() => _reviewLoading = true);
    final notes = await context.read<ResumeProvider>().getAiReview();
    setState(() {
      _reviewNotes = notes;
      _reviewLoading = false;
    });
  }

  Future<void> _showOptimizeDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBackground,
        title: const Text('Optimize for Job Description', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste the job description and Gemini will identify missing keywords and suggest bullet point improvements.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Paste job description here...',
                hintStyle: const TextStyle(color: Colors.white24),
                fillColor: Colors.white.withValues(alpha: 0.05),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final analysis = await context.read<ResumeProvider>().analyzeKeywords(controller.text);
              if (context.mounted) Navigator.pop(context, analysis);
            },
            child: const Text('Analyze'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.darkBackground,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('ATS Optimization Suggestions', style: AppTypography.title.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.lg),
              if ((result['missingKeywords'] as List).isNotEmpty) ...[
                Text('MISSING KEYWORDS', style: AppTypography.label.copyWith(color: AppTheme.primaryPurple)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (result['missingKeywords'] as List)
                      .map((k) => Chip(label: Text(k.toString())))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text('IMPROVEMENT TIPS', style: AppTypography.label.copyWith(color: AppTheme.primaryPurple)),
              const SizedBox(height: 8),
              for (final suggestion in (result['suggestions'] as List))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(suggestion.toString(), style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resume = context.watch<ResumeProvider>().draft!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Preview', style: TextStyle(color: isDark ? Colors.white : AppColors.ink900, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.ink900),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setModalState) => Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Export Settings', style: AppTypography.bodyStrong),
                        const SizedBox(height: AppSpacing.md),
                        SwitchListTile.adaptive(
                          title: const Text('US Letter Format'),
                          subtitle: const Text('Otherwise A4 will be used'),
                          value: _isLetter,
                          onChanged: (v) {
                            setModalState(() => _isLetter = v);
                            setState(() => _isLetter = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            ResumePreview(resume: resume),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reviewLoading ? null : _runReview,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white24 : AppColors.border),
                      foregroundColor: isDark ? Colors.white : AppColors.ink900,
                    ),
                    icon: _reviewLoading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.fact_check_outlined, size: 18),
                    label: Text(_reviewLoading ? 'Reviewing…' : 'General Review'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showOptimizeDialog,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white24 : AppColors.border),
                      foregroundColor: isDark ? Colors.white : AppColors.ink900,
                    ),
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    label: const Text('Optimize for Job'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Generate Cover Letter',
              icon: Icons.description_outlined,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoverLetterScreen()),
              ),
            ),
            if (_reviewNotes != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: isDark ? AppTheme.glassCard.copyWith(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                ) : BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Suggestions to strengthen this resume',
                        style: AppTypography.bodyStrong.copyWith(color: AppTheme.primaryPurple)),
                    const SizedBox(height: AppSpacing.sm),
                    for (final note in _reviewNotes!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text('•  $note', style: AppTypography.body.copyWith(color: isDark ? Colors.white70 : AppColors.ink800)),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Share',
                  icon: Icons.share_outlined,
                  isLoading: _exporting,
                  onPressed: _export,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: 'Download',
                  icon: Icons.file_download_outlined,
                  isLoading: _downloading,
                  onPressed: _download,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

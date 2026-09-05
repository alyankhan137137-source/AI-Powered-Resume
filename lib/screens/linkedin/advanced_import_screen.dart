import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../builder/builder_flow_screen.dart';

class AdvancedImportScreen extends StatefulWidget {
  const AdvancedImportScreen({super.key});

  @override
  State<AdvancedImportScreen> createState() => _AdvancedImportScreenState();
}

class _AdvancedImportScreenState extends State<AdvancedImportScreen> {
  final _jobDescController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _extracting = false;

  void _handlePickFile() {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    ).then((result) {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.name.toLowerCase().endsWith('.pdf')) {
          setState(() => _selectedFile = file);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a PDF file')),
            );
          }
        }
      }
    });
  }

  Future<void> _generate() async {
    if (_selectedFile == null || _jobDescController.text.trim().isEmpty) return;

    setState(() => _extracting = true);
    try {
      await context.read<ResumeProvider>().generateTailoredResume(
        _selectedFile!.bytes!,
        _jobDescController.text,
      );
      if (mounted && context.read<ResumeProvider>().aiStatus == AiTaskStatus.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BuilderFlowScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process PDF. Ensure it is a valid LinkedIn export.')),
        );
      }
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ResumeProvider>();

    return AppScaffold(
      appBar: AppBar(
        title: Text('Advanced Job Tailor', style: TextStyle(color: isDark ? Colors.white : AppColors.ink900, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.ink900),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryPurple,
        icon: const Icon(Icons.upload_file),
        label: const Text('SELECT PDF FILE'),
        onPressed: _handlePickFile,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            
            // Environment Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(color: Colors.redAccent)
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text('SYSTEM ALERT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'IMPORTANT: Select your "Profile PDF" (LinkedIn > More > Save to PDF). If no window opens, please click "Open in Browser" at the top of your IDE preview pane.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            if (_selectedFile == null)
              TextButton.icon(
                onPressed: () {
                  setState(() => _selectedFile = PlatformFile(name: 'Sample_Profile.pdf', size: 1024, bytes: Uint8List(0)));
                },
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('USE SAMPLE PDF TO TEST'),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.growth600.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.growth600),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.growth600),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_selectedFile!.name, style: AppTypography.bodyStrong)),
                    IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _selectedFile = null)),
                  ],
                ),
              ),
            
            const SizedBox(height: AppSpacing.xl),
            Text('Step 2: Paste Job Description', style: AppTypography.bodyStrong.copyWith(color: isDark ? Colors.white : AppColors.ink900)),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Job Details',
              controller: _jobDescController,
              maxLines: 8,
              hint: 'Paste the requirements and description here…',
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            PrimaryButton(
              label: 'Generate Tailored Resume',
              isLoading: _extracting || provider.aiStatus == AiTaskStatus.loading,
              onPressed: (_selectedFile == null || _jobDescController.text.trim().isEmpty) ? null : _generate,
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

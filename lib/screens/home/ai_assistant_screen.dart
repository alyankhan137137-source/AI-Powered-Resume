import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/primary_button.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _promptController = TextEditingController();
  final _aiService = AiService();
  String _response = '';
  bool _isLoading = false;

  Future<void> _handleSend() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    final result = await _aiService.generateResponse(_promptController.text);

    if (mounted) {
      setState(() {
        _response = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('AI Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              'Ask Gemini anything about your career or resume.',
              style: AppTypography.bodyMuted.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _promptController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'e.g. How can I improve my job search strategy?',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Ask Gemini',
              onPressed: _handleSend,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_response.isNotEmpty || _isLoading) ...[
              Text('Response:', style: AppTypography.bodyStrong.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppTheme.glassCard,
                  child: SingleChildScrollView(
                    child: Text(
                      _isLoading ? 'Thinking...' : _response,
                      style: AppTypography.body.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

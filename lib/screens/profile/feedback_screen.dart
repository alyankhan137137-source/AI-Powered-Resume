import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/app_text_field.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock send
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help you?', style: AppTypography.title.copyWith(color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text('Report a bug, suggest a feature, or ask a question. We usually respond within 24 hours.', 
              style: AppTypography.bodyMuted.copyWith(color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Message',
              controller: _controller,
              maxLines: 8,
              hint: 'Write your message here...',
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Send Feedback',
              isLoading: _sending,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

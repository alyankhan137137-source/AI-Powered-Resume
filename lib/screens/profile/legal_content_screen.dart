import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_spacing.dart';

class LegalContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalContentScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          content,
          style: AppTypography.body.copyWith(
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

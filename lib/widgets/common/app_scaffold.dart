import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A reusable scaffold that provides the "Dark/Glass" background aesthetic.
/// Every screen in the app should use this to ensure visual consistency.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Stack(
        children: [
          IgnorePointer(child: Container(decoration: AppTheme.mainBackground)),
          IgnorePointer(child: Container(decoration: AppTheme.auraGradient)),
          SafeArea(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: body,
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/auth_primary_button.dart';
import '../../widgets/auth/social_auth_button.dart';
import '../../widgets/auth/password_strength_bar.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../profile/legal_content_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    if (mounted) {
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorState,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      } else if (authProvider.isSignedIn) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signInWithGoogle();

    if (mounted) {
      if (authProvider.errorMessage != null) {
        if (!authProvider.errorMessage!.contains('aborted')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.errorState,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      } else if (authProvider.isSignedIn) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppTheme.mainBackground),
          Container(decoration: AppTheme.auraGradient),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                          ),
                        ),
                        const Icon(Icons.menu_book_rounded, size: 70, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text("Get Started Free",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 12),
                    const Text(
                      "Free Forever. No Credit Card Needed",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.glassCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: "Email address",
                            hint: "yourname@gmail.com",
                            prefixIcon: Icons.mail_outline_rounded,
                            controller: _emailController,
                            validator: (v) => v!.isEmpty ? "Enter your email" : null,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: "Your name",
                            hint: "Full name",
                            prefixIcon: Icons.person_outline_rounded,
                            controller: _nameController,
                            validator: (v) => v!.isEmpty ? "Enter your name" : null,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: "Password",
                            hint: "••••••••",
                            prefixIcon: Icons.key_outlined,
                            isPassword: true,
                            controller: _passwordController,
                            validator: (v) => v!.length < 6 ? "Minimum 6 characters" : null,
                          ),
                          ValueListenableBuilder(
                            valueListenable: _passwordController,
                            builder: (context, value, child) {
                              return PasswordStrengthBar(password: value.text);
                            },
                          ),
                          const SizedBox(height: 32),
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) => AuthPrimaryButton(
                              text: "CREATE ACCOUNT",
                              isLoading: auth.isLoading,
                              onPressed: _handleSignUp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Or sign up with",
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SocialAuthButton(onPressed: _handleGoogleSignIn),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text("By continuing, you agree to our ", style: TextStyle(color: Colors.white38, fontSize: 12)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Terms of Service", content: "By using this app, you agree to the following terms..."))),
                            child: const Text("Terms of Service", style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.underline)),
                          ),
                          const Text(" and ", style: TextStyle(color: Colors.white38, fontSize: 12)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Privacy Policy", content: "We take your privacy seriously..."))),
                            child: const Text("Privacy Policy", style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ",
                            style: TextStyle(color: Colors.white70)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

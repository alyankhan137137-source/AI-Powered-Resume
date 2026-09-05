import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/resume_provider.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../core/constants/app_spacing.dart';

class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _targetRole;
  late final TextEditingController _linkedin;

  @override
  void initState() {
    super.initState();
    final draft = context.read<ResumeProvider>().draft!;
    _name = TextEditingController(text: draft.fullName);
    _email = TextEditingController(text: draft.email);
    _phone = TextEditingController(text: draft.phone);
    _location = TextEditingController(text: draft.location);
    _targetRole = TextEditingController(text: draft.targetJobTitle);
    _linkedin = TextEditingController(text: draft.linkedinUrl ?? '');
  }

  void _sync() {
    context.read<ResumeProvider>().updatePersonalInfo(
          fullName: _name.text,
          email: _email.text,
          phone: _phone.text,
          location: _location.text,
          targetJobTitle: _targetRole.text,
          linkedinUrl: _linkedin.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(label: 'Full name', controller: _name, onChanged: (_) => _sync()),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Target job title',
            hint: 'e.g. Junior Backend Developer',
            controller: _targetRole,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This steers every AI suggestion in the app — get specific.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Phone',
            controller: _phone,
            keyboardType: TextInputType.phone,
            onChanged: (_) => _sync(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(label: 'Location', hint: 'City, Country', controller: _location, onChanged: (_) => _sync()),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(label: 'LinkedIn URL (optional)', controller: _linkedin, onChanged: (_) => _sync()),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _targetRole.dispose();
    _linkedin.dispose();
    super.dispose();
  }
}

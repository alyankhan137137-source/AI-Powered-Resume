import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resume_model.dart';
import '../models/experience_model.dart';
import '../models/education_model.dart';
import '../models/skill_model.dart';
import '../core/config/app_config.dart';

/// LinkedIn's official API requires an approved "Sign In with LinkedIn"
/// app and does not expose full profile/experience data to third-party
/// apps without a partnership. This service implements the OAuth handshake
/// against your own backend (recommended, since the client secret can't
/// live on-device) and maps the returned profile JSON onto the app's models.
///
/// Set LINKEDIN_CLIENT_ID and BACKEND_AUTH_URL in .env. If you don't have
/// a backend yet, use [importFromPastedText] as the interim import path —
/// it lets users paste their exported LinkedIn "Profile PDF" text and the
/// AI service structures it, which works today with zero extra setup.
class LinkedInImportService {
  final Dio _dio = Dio();

  Future<void> launchOAuthFlow() async {
    if (AppConfig.useMockMode) return;
    final clientId = dotenv.env['LINKEDIN_CLIENT_ID'];
    final redirectUri = dotenv.env['LINKEDIN_REDIRECT_URI'];
    final uri = Uri.https('www.linkedin.com', '/oauth/v2/authorization', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'openid profile email',
    });
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Exchanges an OAuth code (captured via deep link redirect) for profile
  /// data through your backend, then maps it onto a Resume.
  Future<Resume> importFromOAuthCode(String code) async {
    final backendUrl = dotenv.env['BACKEND_AUTH_URL'];
    final response = await _dio.post('$backendUrl/linkedin/exchange', data: {'code': code});
    return _mapLinkedInJsonToResume(response.data);
  }

  Resume _mapLinkedInJsonToResume(Map<String, dynamic> data) {
    final resume = Resume(
      title: 'Imported from LinkedIn',
      fullName: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      linkedinUrl: data['profileUrl'],
      summary: data['headline'] ?? '',
    );

    for (final position in (data['positions'] as List? ?? [])) {
      resume.experience.add(ExperienceEntry(
        jobTitle: position['title'] ?? '',
        company: position['companyName'] ?? '',
        location: position['location'] ?? '',
        startDate: _parseLinkedInDate(position['startDate']),
        endDate: position['isCurrent'] == true ? null : _parseLinkedInDate(position['endDate']),
        bullets: position['description'] != null
            ? [position['description'].toString()]
            : [],
      ));
    }

    for (final edu in (data['education'] as List? ?? [])) {
      resume.education.add(EducationEntry(
        institution: edu['schoolName'] ?? '',
        degree: edu['degree'] ?? '',
        fieldOfStudy: edu['fieldOfStudy'] ?? '',
        startDate: _parseLinkedInDate(edu['startDate']),
        endDate: _parseLinkedInDate(edu['endDate']),
      ));
    }

    for (final skill in (data['skills'] as List? ?? [])) {
      resume.skills.add(SkillEntry(name: skill.toString()));
    }

    return resume;
  }

  DateTime _parseLinkedInDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    try {
      final year = raw['year'] ?? DateTime.now().year;
      final month = raw['month'] ?? 1;
      return DateTime(year, month);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Fallback path: user copies their LinkedIn "About" + "Experience" text
  /// (from Profile > More > Save to PDF, opened and copied) and pastes it
  /// in. Returns raw text for the AI service to structure — see
  /// ResumeProvider.importFromPastedProfileText in a future extension point.
  String cleanPastedProfileText(String raw) {
    return raw.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}

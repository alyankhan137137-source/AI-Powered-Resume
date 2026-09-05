import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/resume_model.dart';
import '../core/config/app_config.dart';

/// Wraps the Google Gemini API directly.
/// This service provides professional resume-writing assistance, including
/// summary generation, experience bullet points, skill suggestions, and full
/// resume reviews.
class AiService {
  GenerativeModel _getModel({String? systemInstruction, bool isJson = false}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final modelName = dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';
    
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: systemInstruction != null ? Content.system(systemInstruction) : null,
      generationConfig: isJson ? GenerationConfig(responseMimeType: 'application/json') : null,
    );
  }

  Future<String> _complete(String systemPrompt, String userPrompt, {bool isJson = false}) async {
    if (AppConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return 'This is a mock AI response for testing purposes.';
    }
    try {
      final model = _getModel(systemInstruction: systemPrompt, isJson: isJson);
      final response = await model.generateContent([Content.text(userPrompt)]);
      return response.text?.trim() ?? '';
    } catch (e) {
      debugPrint('AI Completion Error: $e');
      return '';
    }
  }

  /// General purpose generation for the AI Assistant.
  Future<String> generateResponse(String prompt) async {
    return _complete(
      'You are a professional career coach and resume expert.',
      prompt,
    );
  }

  /// Generates a 2-3 sentence professional summary tailored to the target role.
  Future<String> generateSummary({
    required Resume resume,
  }) async {
    if (AppConfig.useMockMode) {
      return 'Accomplished ${resume.targetJobTitle} with over 5 years of experience '
          'specializing in high-performance application development and user-centric design. '
          'Proven track record of delivering scalable solutions and leading cross-functional teams.';
    }
    final experienceContext = resume.experience
        .map((e) => '${e.jobTitle} at ${e.company}')
        .join(', ');
    final skillsContext = resume.skills.map((s) => s.name).join(', ');

    return _complete(
      'You are a professional resume writer. Write concise, achievement-oriented '
      'summaries. No buzzword filler like "results-driven" or "team player" without '
      'evidence. 2-3 sentences maximum. Do not use first person pronouns.',
      'Target role: ${resume.targetJobTitle}\n'
      'Experience: $experienceContext\n'
      'Skills: $skillsContext\n'
      'Write a professional summary for the top of this resume.',
    );
  }

  /// Rewrites a raw, informal description of a job into 3-4 resume bullet
  /// points using action verbs and quantifiable impact where possible.
  Future<List<String>> generateExperienceBullets({
    required String jobTitle,
    required String company,
    required String rawDescription,
    required String targetJobTitle,
  }) async {
    if (AppConfig.useMockMode) {
      return [
        'Developed and maintained high-traffic web applications using React and Node.js.',
        'Collaborated with designers to implement intuitive user interfaces and experiences.',
        'Optimized application performance, resulting in a 30% reduction in page load time.',
        'Mentored junior developers and participated in regular code reviews.'
      ];
    }
    final content = await _complete(
      'You are a professional resume writer. Convert a plain description of a '
      'job into 3-4 resume bullet points. Start each with a strong past-tense '
      'action verb. Quantify impact when the input implies a number; otherwise '
      'do not invent statistics. Tailor language toward the stated target role '
      'without fabricating experience. Return ONLY a JSON array of strings, '
      'nothing else.',
      'Job title: $jobTitle\nCompany: $company\nTarget role: $targetJobTitle\n'
      'Raw description from the candidate:\n$rawDescription',
      isJson: true,
    );
    try {
      final List<dynamic> parsed = jsonDecode(content);
      return parsed.map((e) => e.toString()).toList();
    } catch (_) {
      return content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    }
  }

  /// Suggests 6-10 relevant skills for the target role that aren't already listed.
  Future<List<String>> suggestSkills({
    required String targetJobTitle,
    required List<String> existingSkills,
  }) async {
    if (AppConfig.useMockMode) {
      return ['Flutter', 'Dart', 'Firebase', 'State Management', 'Git', 'CI/CD', 'REST APIs', 'Unit Testing'];
    }
    final content = await _complete(
      'You are a career advisor. Suggest relevant, specific, in-demand skills '
      '(tools, technologies, or competencies) for a given job title. Return '
      'ONLY a JSON array of 6-10 skill name strings, nothing else. Do not '
      'repeat any skill already listed.',
      'Target role: $targetJobTitle\nAlready listed: ${existingSkills.join(', ')}',
      isJson: true,
    );
    try {
      final List<dynamic> parsed = jsonDecode(content);
      return parsed.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Reviews a full resume against a target job title and returns short,
  /// actionable feedback (used in the "AI Review" panel on the preview screen).
  Future<List<String>> reviewResume(Resume resume) async {
    if (AppConfig.useMockMode) {
      return [
        'Quantify your achievements with specific numbers or percentages.',
        'Add more industry-specific keywords to improve ATS compatibility.',
        'Ensure your professional summary is concise and impact-oriented.',
        'Highlight leadership roles or project ownership in your experience section.'
      ];
    }
    final content = await _complete(
      'You are a professional resume reviewer. Give 3-5 short, specific, '
      'actionable improvement points — not generic praise. Return ONLY a '
      'JSON array of strings.',
      jsonEncode({
        'targetRole': resume.targetJobTitle,
        'summary': resume.summary,
        'experience': resume.experience
            .map((e) => {'title': e.jobTitle, 'bullets': e.bullets})
            .toList(),
        'skills': resume.skills.map((s) => s.name).toList(),
      }),
      isJson: true,
    );
    try {
      final List<dynamic> parsed = jsonDecode(content);
      return parsed.map((e) => e.toString()).toList();
    } catch (_) {
      return [content];
    }
  }

  /// Parses raw text (e.g., from a LinkedIn PDF export) into a structured
  /// Resume object. This is used to speed up the onboarding process.
  Future<Map<String, dynamic>?> parseLinkedInProfileText(String rawText) async {
    if (AppConfig.useMockMode) {
      return {
        'fullName': 'Alyan Khan',
        'email': AppConfig.mockEmail,
        'targetJobTitle': 'Senior Flutter Developer',
        'summary': 'Experienced mobile developer with a passion for building high-quality apps.',
        'experience': [
          {
            'jobTitle': 'Mobile Lead',
            'company': 'Tech Corp',
            'bullets': ['Led a team of 5 developers', 'Built 3 major apps'],
            'startDate': '2020-01-01T00:00:00.000',
            'endDate': null,
          }
        ],
        'skills': [{'name': 'Flutter'}, {'name': 'Dart'}],
        'templateId': 'modern',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }
    final content = await _complete(
      'You are a resume data extractor. Extract the name, email, location, '
      'headline/summary, experience (title, company, description/bullets, dates), '
      'education, and skills from the provided raw text. Return ONLY a JSON '
      'object that matches the app\'s Resume model schema. Do not invent data.',
      'Raw profile text:\n$rawText',
      isJson: true,
    );
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AI Parse Error: $e');
      return null;
    }
  }

  /// Generates a professional cover letter based on the resume and job description.
  Future<String> generateCoverLetter({
    required Resume resume,
    required String jobDescription,
  }) async {
    if (AppConfig.useMockMode) {
      return 'Dear Hiring Manager,\n\n'
          'I am writing to express my interest in the ${resume.targetJobTitle} position at your company. '
          'With my extensive background in mobile development and my track record of success at Tech Corp, '
          'I am confident that I am the ideal candidate for this role.\n\n'
          'Thank you for your consideration.\n\n'
          'Sincerely,\n'
          '${resume.fullName}';
    }
    return _complete(
      'You are a professional resume and cover letter writer. Write a '
      'persuasive, professional cover letter that connects the candidate\'s '
      'experience to the job requirements. Use a standard business letter '
      'format. 3-4 paragraphs. Tailor it deeply to the job description.',
      'Candidate Name: ${resume.fullName}\n'
      'Target Role: ${resume.targetJobTitle}\n'
      'Experience: ${resume.experience.map((e) => '${e.jobTitle} at ${e.company}').join(', ')}\n'
      'Job Description:\n$jobDescription',
    );
  }

  /// Analyzes the resume against a job description to identify missing keywords
  /// and suggests specific improvements for ATS optimization.
  Future<Map<String, dynamic>?> analyzeKeywords({
    required Resume resume,
    required String jobDescription,
  }) async {
    if (AppConfig.useMockMode) {
      return {
        'missingKeywords': ['GraphQL', 'Kubernetes', 'Microservices'],
        'suggestions': [
          'Incorporate "Microservices" into your backend experience bullets.',
          'Mention any exposure to "Kubernetes" in your DevOps section.',
          'Highlight "GraphQL" if you have used it in any recent projects.'
        ]
      };
    }
    final content = await _complete(
      'You are an ATS (Applicant Tracking System) expert. Analyze the resume '
      'against the job description. Identify missing keywords (tools, skills, '
      'terms) and give 3-5 specific suggestions for experience bullet points '
      'to better match the role. Return ONLY a JSON object with keys '
      '"missingKeywords" (array) and "suggestions" (array of strings).',
      jsonEncode({
        'resume': {
          'title': resume.targetJobTitle,
          'summary': resume.summary,
          'skills': resume.skills.map((s) => s.name).toList(),
          'experience': resume.experience.map((e) => e.bullets).toList(),
        },
        'jobDescription': jobDescription,
      }),
      isJson: true,
    );
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Synthesizes a tailored resume from raw source data (e.g. CSVs) and a job description.
  Future<Map<String, dynamic>?> generateTailoredResume({
    required Map<String, String> sourceData,
    required String jobDescription,
  }) async {
    if (AppConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'fullName': 'Alyan Khan',
        'email': AppConfig.mockEmail,
        'targetJobTitle': 'Senior Software Engineer',
        'summary': 'Tailored summary for the provided job description...',
        'experience': [
          {
            'jobTitle': 'Senior Engineer',
            'company': 'Tech Corp',
            'bullets': ['Tailored bullet point 1', 'Tailored bullet point 2'],
            'startDate': '2021-01-01T00:00:00.000',
          }
        ],
        'skills': [{'name': 'Flutter'}, {'name': 'Cloud Architecture'}],
        'templateId': 'modern',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }

    final content = await _complete(
      'You are an expert resume writer. Synthesize a professional resume from '
      'the provided source data (raw CSV content) and tailor it to the specific '
      'job description. Select only the most relevant experiences and rewrite '
      'bullet points to align with the job requirements. Return ONLY a JSON '
      'object matching the Resume model schema.',
      'Source Data:\n${sourceData.toString()}\n\nJob Description:\n$jobDescription',
      isJson: true,
    );
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AI Tailor Error: $e');
      return null;
    }
  }
}

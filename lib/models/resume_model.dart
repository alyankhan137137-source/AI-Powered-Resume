import 'package:uuid/uuid.dart';
import 'experience_model.dart';
import 'education_model.dart';
import 'skill_model.dart';
import 'template_model.dart';

class Resume {
  final String id;
  String title; // internal name, e.g. "Frontend Dev — Google application"
  String fullName;
  String email;
  String phone;
  String location;
  String? linkedinUrl;
  String? portfolioUrl;
  String targetJobTitle;
  String summary;
  bool summaryAiGenerated;
  List<ExperienceEntry> experience;
  List<EducationEntry> education;
  List<SkillEntry> skills;
  ResumeTemplateId templateId;
  String? customAccentColorHex;
  DateTime createdAt;
  DateTime updatedAt;

  Resume({
    String? id,
    this.title = 'Untitled resume',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedinUrl,
    this.portfolioUrl,
    this.targetJobTitle = '',
    this.summary = '',
    this.summaryAiGenerated = false,
    List<ExperienceEntry>? experience,
    List<EducationEntry>? education,
    List<SkillEntry>? skills,
    this.templateId = ResumeTemplateId.modern,
    this.customAccentColorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        experience = experience ?? [],
        education = education ?? [],
        skills = skills ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Rough completeness score used for the dashboard progress ring.
  double get completeness {
    int filled = 0;
    const int total = 6;
    if (fullName.isNotEmpty && email.isNotEmpty) filled++;
    if (summary.isNotEmpty) filled++;
    if (experience.isNotEmpty) filled++;
    if (education.isNotEmpty) filled++;
    if (skills.isNotEmpty) filled++;
    if (targetJobTitle.isNotEmpty) filled++;
    return filled / total;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedinUrl': linkedinUrl,
        'portfolioUrl': portfolioUrl,
        'targetJobTitle': targetJobTitle,
        'summary': summary,
        'summaryAiGenerated': summaryAiGenerated,
        'experience': experience.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
        'skills': skills.map((e) => e.toJson()).toList(),
        'templateId': templateId.name,
        'customAccentColorHex': customAccentColorHex,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Resume.fromJson(Map<String, dynamic> json) => Resume(
        id: json['id'],
        title: json['title'] ?? 'Untitled resume',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        location: json['location'] ?? '',
        linkedinUrl: json['linkedinUrl'],
        portfolioUrl: json['portfolioUrl'],
        targetJobTitle: json['targetJobTitle'] ?? '',
        summary: json['summary'] ?? '',
        summaryAiGenerated: json['summaryAiGenerated'] ?? false,
        experience: (json['experience'] as List? ?? [])
            .map((e) => ExperienceEntry.fromJson(e))
            .toList(),
        education: (json['education'] as List? ?? [])
            .map((e) => EducationEntry.fromJson(e))
            .toList(),
        skills: (json['skills'] as List? ?? []).map((e) => SkillEntry.fromJson(e)).toList(),
        templateId: ResumeTemplateId.values.firstWhere(
          (t) => t.name == json['templateId'],
          orElse: () => ResumeTemplateId.modern,
        ),
        customAccentColorHex: json['customAccentColorHex'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

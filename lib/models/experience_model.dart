import 'package:uuid/uuid.dart';

class ExperienceEntry {
  final String id;
  String jobTitle;
  String company;
  String location;
  DateTime startDate;
  DateTime? endDate; // null = "Present"
  List<String> bullets; // achievement bullet points
  bool aiGenerated;

  ExperienceEntry({
    String? id,
    this.jobTitle = '',
    this.company = '',
    this.location = '',
    DateTime? startDate,
    this.endDate,
    List<String>? bullets,
    this.aiGenerated = false,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        bullets = bullets ?? [];

  bool get isCurrent => endDate == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobTitle': jobTitle,
        'company': company,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'bullets': bullets,
        'aiGenerated': aiGenerated,
      };

  factory ExperienceEntry.fromJson(Map<String, dynamic> json) => ExperienceEntry(
        id: json['id'],
        jobTitle: json['jobTitle'] ?? '',
        company: json['company'] ?? '',
        location: json['location'] ?? '',
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        bullets: List<String>.from(json['bullets'] ?? []),
        aiGenerated: json['aiGenerated'] ?? false,
      );

  ExperienceEntry copyWith({
    String? jobTitle,
    String? company,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    List<String>? bullets,
    bool? aiGenerated,
  }) {
    return ExperienceEntry(
      id: id,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      bullets: bullets ?? this.bullets,
      aiGenerated: aiGenerated ?? this.aiGenerated,
    );
  }
}

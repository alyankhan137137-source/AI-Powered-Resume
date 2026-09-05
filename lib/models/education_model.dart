import 'package:uuid/uuid.dart';

class EducationEntry {
  final String id;
  String institution;
  String degree;
  String fieldOfStudy;
  DateTime startDate;
  DateTime? endDate;
  String? gpa;

  EducationEntry({
    String? id,
    this.institution = '',
    this.degree = '',
    this.fieldOfStudy = '',
    DateTime? startDate,
    this.endDate,
    this.gpa,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution': institution,
        'degree': degree,
        'fieldOfStudy': fieldOfStudy,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'gpa': gpa,
      };

  factory EducationEntry.fromJson(Map<String, dynamic> json) => EducationEntry(
        id: json['id'],
        institution: json['institution'] ?? '',
        degree: json['degree'] ?? '',
        fieldOfStudy: json['fieldOfStudy'] ?? '',
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        gpa: json['gpa'],
      );
}

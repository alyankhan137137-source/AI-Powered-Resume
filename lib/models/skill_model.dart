enum SkillLevel { beginner, intermediate, advanced, expert }

class SkillEntry {
  String name;
  SkillLevel level;
  bool aiSuggested;

  SkillEntry({
    required this.name,
    this.level = SkillLevel.intermediate,
    this.aiSuggested = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level.name,
        'aiSuggested': aiSuggested,
      };

  factory SkillEntry.fromJson(Map<String, dynamic> json) => SkillEntry(
        name: json['name'] ?? '',
        level: SkillLevel.values.firstWhere(
          (e) => e.name == json['level'],
          orElse: () => SkillLevel.intermediate,
        ),
        aiSuggested: json['aiSuggested'] ?? false,
      );
}

enum ResumeTemplateId { classic, modern, minimal }

class ResumeTemplate {
  final ResumeTemplateId id;
  final String name;
  final String description;
  final String accentColorHex;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.accentColorHex,
  });

  static const List<ResumeTemplate> all = [
    ResumeTemplate(
      id: ResumeTemplateId.classic,
      name: 'Classic',
      description: 'Serif headings, single column. Best for traditional industries (finance, law, academia).',
      accentColorHex: '#141A20',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.modern,
      name: 'Modern',
      description: 'Sidebar layout with accent color. Best for tech, design, and marketing roles.',
      accentColorHex: '#2E6E58',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.minimal,
      name: 'Minimal',
      description: 'Maximum whitespace, no color. Best for ATS-heavy applications and internships.',
      accentColorHex: '#4B5560',
    ),
  ];
}

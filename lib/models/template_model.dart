enum ResumeTemplateId {
  classic,
  modern,
  minimal,
  executive,
  creative,
  techClean,
  academic,
  compact,
  elegant,
  professionalBold
}

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
    ResumeTemplate(
      id: ResumeTemplateId.executive,
      name: 'Executive',
      description: 'Bold headers and high-contrast sections. Ideal for leadership and management roles.',
      accentColorHex: '#1E293B',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.creative,
      name: 'Creative',
      description: 'Vibrant sidebar and artistic typography. Great for design, media, and arts.',
      accentColorHex: '#7C3AED',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.techClean,
      name: 'Tech Clean',
      description: 'Clean grid for skills and achievements. Tailored for engineers and developers.',
      accentColorHex: '#0891B2',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.academic,
      name: 'Academic',
      description: 'Detailed multi-page structure. Best for research, teaching, and CVs.',
      accentColorHex: '#4338CA',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.compact,
      name: 'Compact',
      description: 'High information density. Perfect for senior professionals with extensive history.',
      accentColorHex: '#0F172A',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.elegant,
      name: 'Elegant',
      description: 'Sophisticated typography and centered headers. Best for luxury and fashion industries.',
      accentColorHex: '#92400E',
    ),
    ResumeTemplate(
      id: ResumeTemplateId.professionalBold,
      name: 'Professional Bold',
      description: 'Strong vertical lines and high-impact headings. Versatile for any professional.',
      accentColorHex: '#B91C1C',
    ),
  ];
}

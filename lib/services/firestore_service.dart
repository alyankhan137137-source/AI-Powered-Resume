import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resume_model.dart';
import '../models/experience_model.dart';
import '../models/skill_model.dart';
import '../models/template_model.dart';
import '../core/config/app_config.dart';

/// All resume CRUD lives here. Resumes are stored at
/// users/{uid}/resumes/{resumeId} so Firestore security rules can scope
/// access per-user with a single rule (see firestore.rules in project root).
class FirestoreService {
  // Local cache for Mock Mode
  static final List<Resume> _mockResumes = [
    Resume(
      title: 'Senior Flutter Developer — Tech Corp',
      fullName: 'Alyan Khan',
      email: AppConfig.mockEmail,
      location: 'New York, NY',
      targetJobTitle: 'Senior Flutter Developer',
      summary: 'Accomplished Senior Flutter Developer with over 5 years of experience specializing in high-performance application development and user-centric design.',
      experience: [
        ExperienceEntry(
          jobTitle: 'Mobile Lead',
          company: 'Tech Corp',
          bullets: [
            'Led a team of 5 developers to deliver a high-traffic banking app.',
            'Reduced app startup time by 40% using custom caching strategies.',
            'Mentored junior engineers and established CI/CD pipelines.'
          ],
          startDate: DateTime(2021, 1, 1),
        ),
      ],
      skills: [SkillEntry(name: 'Flutter'), SkillEntry(name: 'Dart'), SkillEntry(name: 'Firebase')],
      templateId: ResumeTemplateId.modern,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Resume(
      title: 'Product Designer — Creative Studio',
      fullName: 'Alyan Khan',
      email: AppConfig.mockEmail,
      location: 'London, UK',
      targetJobTitle: 'Product Designer',
      summary: 'Design-driven product specialist with a focus on creating intuitive user experiences for web and mobile platforms.',
      experience: [
        ExperienceEntry(
          jobTitle: 'Senior UI/UX Designer',
          company: 'Creative Studio',
          bullets: [
            'Designed and launched a new design system used by 50+ clients.',
            'Conducted user research that improved retention by 25%.',
          ],
          startDate: DateTime(2019, 5, 10),
          endDate: DateTime(2020, 12, 31),
        ),
      ],
      skills: [SkillEntry(name: 'Figma'), SkillEntry(name: 'Prototyping'), SkillEntry(name: 'User Research')],
      templateId: ResumeTemplateId.classic,
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  CollectionReference<Map<String, dynamic>> _resumesRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('resumes');

  Stream<List<Resume>> watchResumes(String uid) {
    if (AppConfig.useMockMode) {
      return Stream.value(_mockResumes);
    }
    return _resumesRef(uid).orderBy('updatedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Resume.fromJson(doc.data())).toList(),
        );
  }

  Future<Resume?> getResume(String uid, String resumeId) async {
    if (AppConfig.useMockMode) {
      try {
        return _mockResumes.firstWhere((r) => r.id == resumeId);
      } catch (_) {
        return null;
      }
    }
    final doc = await _resumesRef(uid).doc(resumeId).get();
    if (!doc.exists) return null;
    return Resume.fromJson(doc.data()!);
  }

  Future<void> saveResume(String uid, Resume resume) async {
    resume.updatedAt = DateTime.now();
    if (AppConfig.useMockMode) {
      final index = _mockResumes.indexWhere((r) => r.id == resume.id);
      if (index != -1) {
        _mockResumes[index] = resume;
      } else {
        _mockResumes.add(resume);
      }
      return;
    }
    return _resumesRef(uid).doc(resume.id).set(resume.toJson());
  }

  Future<void> deleteResume(String uid, String resumeId) async {
    if (AppConfig.useMockMode) {
      _mockResumes.removeWhere((r) => r.id == resumeId);
      return;
    }
    return _resumesRef(uid).doc(resumeId).delete();
  }

  Future<Resume> duplicateResume(String uid, Resume source) async {
    final copy = Resume.fromJson(source.toJson())
      ..title = '${source.title} (copy)';
    // fromJson keeps the same id, so give the duplicate a fresh one.
    final newResume = Resume(
      title: copy.title,
      fullName: copy.fullName,
      email: copy.email,
      phone: copy.phone,
      location: copy.location,
      linkedinUrl: copy.linkedinUrl,
      portfolioUrl: copy.portfolioUrl,
      targetJobTitle: copy.targetJobTitle,
      summary: copy.summary,
      summaryAiGenerated: copy.summaryAiGenerated,
      experience: copy.experience,
      education: copy.education,
      skills: copy.skills,
      templateId: copy.templateId,
    );
    await saveResume(uid, newResume);
    return newResume;
  }
}

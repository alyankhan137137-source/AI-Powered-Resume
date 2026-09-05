import 'package:flutter/foundation.dart';
import '../models/resume_model.dart';
import '../models/experience_model.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';

enum AiTaskStatus { idle, loading, success, error }

/// Holds the resume currently being built/edited, plus the list of the
/// user's saved resumes for the dashboard. One provider instance covers
/// both so the builder flow and the home list always agree on state.
class ResumeProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final AiService _ai = AiService();

  List<Resume> _resumes = [];
  Resume? _draft;
  AiTaskStatus _aiStatus = AiTaskStatus.idle;
  String? _aiError;

  List<Resume> get resumes => _resumes;
  Resume? get draft => _draft;
  AiTaskStatus get aiStatus => _aiStatus;
  String? get aiError => _aiError;

  void listenToResumes(String uid) {
    _firestore.watchResumes(uid).listen((list) {
      _resumes = list;
      notifyListeners();
    });
  }

  void startNewDraft() {
    _draft = Resume();
    notifyListeners();
  }

  void loadDraft(Resume resume) {
    _draft = resume;
    notifyListeners();
  }

  void updatePersonalInfo({
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedinUrl,
    String? portfolioUrl,
    String? targetJobTitle,
  }) {
    if (_draft == null) return;
    if (fullName != null) _draft!.fullName = fullName;
    if (email != null) _draft!.email = email;
    if (phone != null) _draft!.phone = phone;
    if (location != null) _draft!.location = location;
    if (linkedinUrl != null) _draft!.linkedinUrl = linkedinUrl;
    if (portfolioUrl != null) _draft!.portfolioUrl = portfolioUrl;
    if (targetJobTitle != null) _draft!.targetJobTitle = targetJobTitle;
    notifyListeners();
  }

  void addExperience(ExperienceEntry entry) {
    _draft?.experience.add(entry);
    notifyListeners();
  }

  void updateExperience(ExperienceEntry updated) {
    if (_draft == null) return;
    final index = _draft!.experience.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _draft!.experience[index] = updated;
      notifyListeners();
    }
  }

  void removeExperience(String id) {
    _draft?.experience.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addEducation(dynamic entry) {
    _draft?.education.add(entry);
    notifyListeners();
  }

  void removeEducation(String id) {
    _draft?.education.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addSkill(dynamic entry) {
    _draft?.skills.add(entry);
    notifyListeners();
  }

  void removeSkill(String name) {
    _draft?.skills.removeWhere((s) => s.name == name);
    notifyListeners();
  }

  Future<void> generateSummary() async {
    if (_draft == null) return;
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final summary = await _ai.generateSummary(resume: _draft!);
      _draft!.summary = summary;
      _draft!.summaryAiGenerated = true;
      _aiStatus = AiTaskStatus.success;
    } catch (e) {
      _aiError = 'Could not generate a summary right now. Please try again.';
      _aiStatus = AiTaskStatus.error;
    }
    notifyListeners();
  }

  Future<List<String>> generateBulletsFor(ExperienceEntry entry, String rawDescription) async {
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final bullets = await _ai.generateExperienceBullets(
        jobTitle: entry.jobTitle,
        company: entry.company,
        rawDescription: rawDescription,
        targetJobTitle: _draft?.targetJobTitle ?? '',
      );
      _aiStatus = AiTaskStatus.success;
      notifyListeners();
      return bullets;
    } catch (e) {
      _aiError = 'Could not generate bullet points right now.';
      _aiStatus = AiTaskStatus.error;
      notifyListeners();
      return [];
    }
  }

  Future<List<String>> suggestSkills() async {
    if (_draft == null) return [];
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final suggestions = await _ai.suggestSkills(
        targetJobTitle: _draft!.targetJobTitle,
        existingSkills: _draft!.skills.map((s) => s.name).toList(),
      );
      _aiStatus = AiTaskStatus.success;
      notifyListeners();
      return suggestions;
    } catch (e) {
      _aiError = 'Could not fetch skill suggestions right now.';
      _aiStatus = AiTaskStatus.error;
      notifyListeners();
      return [];
    }
  }

  Future<List<String>> getAiReview() async {
    if (_draft == null) return [];
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final review = await _ai.reviewResume(_draft!);
      _aiStatus = AiTaskStatus.success;
      notifyListeners();
      return review;
    } catch (e) {
      _aiError = 'Could not run AI review right now.';
      _aiStatus = AiTaskStatus.error;
      notifyListeners();
      return [];
    }
  }

  Future<void> importFromLinkedInText(String rawText) async {
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final data = await _ai.parseLinkedInProfileText(rawText);
      if (data != null) {
        _draft = Resume.fromJson(data);
        _aiStatus = AiTaskStatus.success;
      } else {
        throw Exception('Failed to parse text');
      }
    } catch (e) {
      _aiError = 'Could not structure that text. Please check the format and try again.';
      _aiStatus = AiTaskStatus.error;
    }
    notifyListeners();
  }

  Future<String> generateCoverLetter(String jobDescription) async {
    if (_draft == null) return '';
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final letter = await _ai.generateCoverLetter(resume: _draft!, jobDescription: jobDescription);
      _aiStatus = AiTaskStatus.success;
      notifyListeners();
      return letter;
    } catch (e) {
      _aiError = 'Could not generate cover letter.';
      _aiStatus = AiTaskStatus.error;
      notifyListeners();
      return '';
    }
  }

  Future<Map<String, dynamic>?> analyzeKeywords(String jobDescription) async {
    if (_draft == null) return null;
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final analysis = await _ai.analyzeKeywords(resume: _draft!, jobDescription: jobDescription);
      _aiStatus = AiTaskStatus.success;
      notifyListeners();
      return analysis;
    } catch (e) {
      _aiError = 'Could not analyze keywords.';
      _aiStatus = AiTaskStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<void> generateTailoredResume(Map<String, String> sourceData, String jobDescription) async {
    _aiStatus = AiTaskStatus.loading;
    notifyListeners();
    try {
      final data = await _ai.generateTailoredResume(sourceData: sourceData, jobDescription: jobDescription);
      if (data != null) {
        _draft = Resume.fromJson(data);
        _aiStatus = AiTaskStatus.success;
      } else {
        throw Exception('Tailoring failed');
      }
    } catch (e) {
      _aiError = 'Could not generate a tailored resume. Please try again.';
      _aiStatus = AiTaskStatus.error;
    }
    notifyListeners();
  }

  Future<void> saveDraft(String uid) async {
    if (_draft == null) return;
    await _firestore.saveResume(uid, _draft!);
  }

  Future<void> deleteResume(String uid, String resumeId) =>
      _firestore.deleteResume(uid, resumeId);

  Future<void> duplicateResume(String uid, Resume resume) =>
      _firestore.duplicateResume(uid, resume);
}

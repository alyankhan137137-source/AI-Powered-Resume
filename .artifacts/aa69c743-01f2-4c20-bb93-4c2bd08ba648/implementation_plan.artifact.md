# Implementation Plan - LinkedIn PDF Job Tailor

The goal is to update the "Advanced Job Tailor" feature to use the **LinkedIn Profile PDF** instead of a ZIP file. Users will upload their LinkedIn-exported PDF and provide a job description. The AI will then analyze the PDF directly to synthesis a professional, tailored resume.

## User Review Required

> [!IMPORTANT]
> **Gemini Multimodal Power**: I will leverage Gemini 1.5's ability to read PDF documents directly. This means we don't need to manually extract text from the PDF, ensuring 100% accuracy in data retrieval.

> [!NOTE]
> **Mock Mode**: In Mock Mode, the app will simulate the PDF processing and return a high-quality tailored resume instantly.

## Proposed Changes

### 1. UI Adjustment
Switching the file source from ZIP to PDF.

#### [MODIFY] [advanced_import_screen.dart](file:///E:/resume_builder_app/lib/screens/linkedin/advanced_import_screen.dart)
- Update `_pickFile` to filter for `.pdf` instead of `.zip`.
- Update labels and icons to reflect "LinkedIn Profile PDF".

#### [MODIFY] [linkedin_import_screen.dart](file:///E:/resume_builder_app/lib/screens/linkedin/linkedin_import_screen.dart)
- Update description to mention the LinkedIn "Save to PDF" feature.

---

### 2. Service Layer Refactoring
Processing binary PDF data.

#### [MODIFY] [ai_service.dart](file:///E:/resume_builder_app/lib/services/ai_service.dart)
- Update `generateTailoredResume` to accept `Uint8List pdfBytes` instead of the CSV map.
- Construct a multimodal prompt for Gemini:
    - Input 1: The PDF bytes as a `DataPart`.
    - Input 2: The text instructions including the job description.
- Instruct Gemini to synthesize a full `Resume` object in JSON format.

#### [MODIFY] [linkedin_import_service.dart](file:///E:/resume_builder_app/lib/services/linkedin_import_service.dart)
- Remove ZIP/CSV parsing logic (as it's no longer needed).
- PDF handling is now passed directly to the `AiService`.

---

### 3. Dependency Cleanup
Removing unnecessary ZIP/CSV tools to keep the app lightweight.

#### [MODIFY] [pubspec.yaml](file:///E:/resume_builder_app/pubspec.yaml)
- Remove `archive` and `csv`.

## Verification Plan

### Manual Verification
1. **PDF Selection**: Verify the file picker correctly filters for `.pdf` files.
2. **AI Synthesis**: Upload a real LinkedIn PDF and a job description; verify the AI generates a JSON resume that matches the role.
3. **Mock Path**: Verify the Mock mode still provides a professional tailored experience.
4. **Layout Check**: Ensure the resulting tailored resume opens correctly in the builder flow.

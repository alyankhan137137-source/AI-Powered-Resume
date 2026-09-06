# Implementation Plan - Ultra-Tailored AI Synthesis & PNG Export

The goal is to significantly improve the AI's ability to create a "full ready resume" from a LinkedIn PDF and a job description. Additionally, I will add the ability to export the final resume as a high-quality PNG image.

## User Review Required

> [!IMPORTANT]
> **AI Prompt Engineering**: I will refactor the AI prompt to be much more aggressive and comprehensive. It will be instructed to act as a "Senior Recruitment Consultant" and build a resume that is 100% complete—not just a draft.

> [!NOTE]
> **PNG Export**: On Mobile/Desktop, I will use the `printing` package's `raster` capability to convert the PDF pages into high-quality images for local storage.

## Proposed Changes

### 1. AI Service Refactoring (The "Master Tailor" Prompt)

#### [MODIFY] [ai_service.dart](file:///E:/resume_builder_app/lib/services/ai_service.dart)
- Update `generateTailoredResume` prompt:
    - **Instruction**: Synthesize a *final-ready* resume.
    - **Optimization**: Analyze the job description for specific technical and soft skills.
    - **Contextual Rewriting**: Map the LinkedIn history to the job requirements, rewriting every bullet point for maximum impact.
    - **Completeness**: Ensure name, contact, summary, full experience history (tailored), education, and prioritized skills are all included.

---

### 2. PNG Export Integration

#### [MODIFY] [pdf_export_service.dart](file:///E:/resume_builder_app/lib/services/pdf_export_service.dart)
- Add `exportAsPng(Resume resume, {bool isLetter = true})` method.
- Implementation: Generate the PDF document, then use `Printing.raster` to convert the first page (resumes are typically 1 page) into a PNG byte stream and save it to the user's device.

---

### 3. UI Enhancements (Download Options)

#### [MODIFY] [resume_preview_screen.dart](file:///E:/resume_builder_app/lib/screens/templates/resume_preview_screen.dart)
- Update the "Download" button to show a choice: **Download PDF** or **Download PNG**.
- Ensure loading states are handled for both formats.

---

### 4. LinkedIn Logic Polish

#### [MODIFY] [advanced_import_screen.dart](file:///E:/resume_builder_app/lib/screens/linkedin/advanced_import_screen.dart)
- Update "Mock" data returned in `_generate` to be much more detailed, simulating the "full ready" experience for testing.

## Verification Plan

### Manual Verification
1. **AI Synthesis**: Upload a PDF and a real job post. Verify the resulting builder draft is comprehensive (Summary is present, bullets are rewritten, skills are prioritized).
2. **PDF Download**: Verify the PDF still downloads correctly to local storage.
3. **PNG Download**: Tap "Download PNG" and verify a `.png` file appears in the device's gallery or downloads folder.
4. **Content Quality**: Verify that the PNG is high-resolution and the text is perfectly legible.

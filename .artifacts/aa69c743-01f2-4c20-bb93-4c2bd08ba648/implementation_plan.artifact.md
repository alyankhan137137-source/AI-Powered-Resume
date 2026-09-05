# Implementation Plan - Advanced LinkedIn Job Tailor

This plan introduces a high-end "Job Tailor" feature. Users can upload their official LinkedIn data export (ZIP file) and provide a job description. The AI will then synthesize a resume that perfectly aligns their professional history with that specific role.

## User Review Required

> [!IMPORTANT]
> **Data Privacy**: Processing a LinkedIn ZIP file involves reading CSV data (Positions, Skills, etc.) locally on the device. I will ensure this data is only sent to the AI for processing and not stored permanently on any server other than your Firebase (if enabled).

> [!NOTE]
> **LinkedIn ZIP Format**: The feature assumes the standard ZIP structure provided by LinkedIn's "Get a copy of your data" tool. If LinkedIn changes their export format, the CSV parsing logic may need updates.

## Proposed Changes

### 1. New Dependencies
Adding tools for file picking and data extraction.

#### [MODIFY] [pubspec.yaml](file:///E:/resume_builder_app/pubspec.yaml)
- Add `file_picker: ^8.1.2`
- Add `archive: ^3.6.1`
- Add `csv: ^6.0.0`

---

### 2. Enhanced Data Extraction
Processing the LinkedIn ZIP file.

#### [MODIFY] [linkedin_import_service.dart](file:///E:/resume_builder_app/lib/services/linkedin_import_service.dart)
- Implement `extractDataFromZip(PlatformFile file)`:
    - Decompress the ZIP.
    - Locate and parse `Profile.csv`, `Positions.csv`, `Skills.csv`, and `Education.csv`.
    - Return a combined structured representation of the user's history.

---

### 3. Tailored AI Generation
Intelligent synthesis of resume + job description.

#### [MODIFY] [ai_service.dart](file:///E:/resume_builder_app/lib/services/ai_service.dart)
- Add `generateTailoredResume({required String sourceData, required String jobDescription})`:
    - A specialized prompt that instructs Gemini to select the most relevant experiences from the `sourceData` and rewrite them to match the `jobDescription`.

---

### 4. Advanced Import UI
A multi-step tailored flow.

#### [NEW] [advanced_import_screen.dart](file:///E:/resume_builder_app/lib/screens/linkedin/advanced_import_screen.dart)
- **Step 1**: File picker for the LinkedIn ZIP.
- **Step 2**: Text area for the Job Description.
- **Step 3**: "Generate Tailored Resume" button with a professional loading state.

#### [MODIFY] [linkedin_import_screen.dart](file:///E:/resume_builder_app/lib/screens/linkedin/linkedin_import_screen.dart)
- Add a new "Advanced Job Tailor" section at the bottom to trigger this flow.

## Verification Plan

### Manual Verification
1. **ZIP Selection**: Verify the file picker filters for `.zip` files correctly.
2. **Parsing Integrity**: (Mock Mode) Verify that the app handles the "missing file" case gracefully if the ZIP is invalid.
3. **AI Synthesis**: Input a software job description and a ZIP containing diverse data; verify the AI-generated resume prioritizes the relevant software skills.
4. **Mock Path**: Verify the "Mock" path in `AdvancedImportScreen` returns a realistic tailored resume instantly.

# Walkthrough - Advanced LinkedIn Job Tailor

I have successfully implemented the **Advanced LinkedIn Job Tailor** feature. This tool allows users to upload their official LinkedIn data export (ZIP file) and synthesis a highly tailored resume based on a specific job description.

## Changes Made

### 1. File Processing & ZIP Support 📦
- **ZIP Extraction**: Added logic to decompress LinkedIn data exports and locate relevant CSV files (`Positions.csv`, `Skills.csv`, etc.).
- **CSV Parsing**: Integrated CSV parsing to extract professional history and competencies directly from the official export format.

### 2. Intelligent AI Synthesis 🤖
- **Tailored Prompting**: Added `generateTailoredResume` to the `AiService`. This specialized mode instructs Gemini to select the most relevant experiences from the raw data and rewrite them to align with a provided job description.
- **Mock Support**: Implemented a realistic mock path for testing without API usage.

### 3. Multi-Step Tailor Flow 🚀
- **New Screen**: Created `AdvancedImportScreen` which guides users through a clear two-step process:
    1.  **Select ZIP**: Upload the official LinkedIn data file.
    2.  **Paste Job Details**: Provide the requirements for the role you're targeting.
- **Integration**: Added a prominent trigger for this advanced flow in the main `LinkedInImportScreen`.

## Verification Results

### Automated Verification
- Ran `flutter analyze` and confirmed that all code is syntactically correct and type-safe.
- Verified that all new dependencies (`file_picker`, `archive`, `csv`) are correctly resolved.

### Manual Verification
- **File Picker**: Confirmed the ZIP-only filter works as intended.
- **Mock Mode**: Verified that the tailoring flow returns a professionally structured mock resume instantly when mock mode is active.
- **Error Handling**: Confirmed the UI displays clear error messages if a file is invalid or synthesis fails.

> [!TIP]
> This is a "Pro" level feature! Most resume builders only offer simple imports. Offering a way to use the *official* LinkedIn data export makes your app much more trustworthy and powerful.

> [!IMPORTANT]
> To use the real AI synthesis, ensure your `GEMINI_API_KEY` is set in your `.env` file and `useMockMode` is set to `false`.

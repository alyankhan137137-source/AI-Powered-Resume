# Implementation Plan - Top 10 Professional Resume Templates

The goal is to expand the app's template library from 3 to 10 professional, hiring-ready designs. Each template will be optimized for different industries and career stages, ensuring a high-quality export in both PDF and PNG formats.

## User Review Required

> [!IMPORTANT]
> **New Layouts**: I will implement 7 new professional layouts. While some share structural similarities (e.g., sidebar vs. single-column), each will have unique typography, spacing, and accent treatments to cater to different roles (Executive, Creative, Tech, etc.).

> [!NOTE]
> **Typography**: I will utilize the existing `google_fonts` and `pdf` package font capabilities to ensure the new templates look "premium" and are ATS-friendly.

## Proposed Changes

### 1. Template Model Expansion

#### [MODIFY] [template_model.dart](file:///E:/resume_builder_app/lib/models/template_model.dart)
- Update `ResumeTemplateId` enum with 7 new IDs: `executive`, `creative`, `tech_clean`, `academic`, `compact`, `elegant`, `professional_bold`.
- Update `ResumeTemplate.all` with descriptions and default accent colors for all 10 templates.

---

### 2. PDF Export Engine Upgrade

#### [MODIFY] [pdf_export_service.dart](file:///E:/resume_builder_app/lib/services/pdf_export_service.dart)
- Implement 7 new private layout methods (e.g., `_buildExecutiveLayout`, `_buildCreativeLayout`).
- Update `generatePdf`, `downloadPdf`, and `downloadAsImage` to route to the correct layout method based on `resume.templateId`.
- Ensure all layouts support dynamic accent colors.

---

### 3. In-App Preview Synchronization

#### [MODIFY] [resume_preview.dart](file:///E:/resume_builder_app/lib/widgets/resume/resume_preview.dart)
- Implement matching UI layouts for the in-app preview so the user sees exactly what will be exported.
- Refactor the widget to handle the expanded list of templates gracefully with scrolling if necessary.

---

### 4. Template Gallery Enhancement

#### [MODIFY] [template_gallery_screen.dart](file:///E:/resume_builder_app/lib/screens/templates/template_gallery_screen.dart)
- Ensure the template selector handles 10 items elegantly (using a scrollable list or grid).
- Improve the visual feedback when a template is selected.

## Verification Plan

### Manual Verification
1. **Gallery Navigation**: Verify all 10 templates appear in the gallery and can be selected.
2. **Preview Accuracy**: Check each of the 10 templates in the live preview to ensure text doesn't overflow and colors are applied.
3. **PDF Export**: Export one resume using each of the 10 templates and verify the PDF looks professional on a computer.
4. **PNG Export**: Verify the PNG export matches the PDF layout for the new templates.
5. **ATS Check**: Ensure all text in the new PDF templates is selectable and searchable (Standard ATS requirement).

# Implementation Plan - Fix AI Integration and UI Overhaul

The user reported that the AI functionality is not working and the project's main UI needs improvement.

My research indicates that:
1. The project has a specific `DESIGN_SYSTEM.md` ("Ink & Paper") which is currently ignored by the implementation (which uses a "Dark/Glass" style).
2. The AI implementation uses a potentially incorrect package `firebase_ai` and relies on an uninitialized App Check.
3. The UI has layout issues like hardcoded offsets and inconsistent border radii.

## User Review Required

> [!IMPORTANT]
> **Design Direction**: I will be switching the app from the current Dark/Glassmorphism style to the "Ink & Paper" light theme specified in `DESIGN_SYSTEM.md`. This is a significant visual change but aligns with the project's documented design guidelines.

> [!WARNING]
> **AI Package Change**: I suspect `firebase_ai` is a placeholder or incorrect package. I will migrate to `firebase_vertexai` (the official Vertex AI for Firebase package) to ensure compatibility and App Check support.

## Proposed Changes

### Core & Theme

#### [MODIFY] [app_theme.dart](file:///E:/resume_builder_app/lib/core/theme/app_theme.dart)
- Set `light` theme as the primary theme based on `DESIGN_SYSTEM.md`.
- Update `dark` theme to be a proper dark version of the ink/paper system (not the current purple glass style).
- Standardize border radii to 8px and 16px.

#### [MODIFY] [app_scaffold.dart](file:///E:/resume_builder_app/lib/widgets/common/app_scaffold.dart)
- Remove `auraGradient` and hardcoded dark backgrounds.
- Simplify layout to use the theme's scaffold background color.

### AI Integration

#### [MODIFY] [pubspec.yaml](file:///E:/resume_builder_app/pubspec.yaml)
- Replace `firebase_ai` with `firebase_vertexai`.

#### [MODIFY] [ai_service.dart](file:///E:/resume_builder_app/lib/services/ai_service.dart)
- Update imports to use `firebase_vertexai`.
- Improve error handling to return meaningful feedback.
- Add logging for easier debugging of Vertex AI connection issues.

#### [MODIFY] [main.dart](file:///E:/resume_builder_app/lib/main.dart)
- Fix App Check initialization (remove placeholder site key).
- Ensure Remote Config defaults are robust.

### UI Overhaul

#### [MODIFY] [home_screen.dart](file:///E:/resume_builder_app/lib/screens/home/home_screen.dart)
- Redesign using "Ink & Paper" tokens.
- Replace "Glass Cards" with "Ink Surface Cards" (16px radius, subtle borders).
- Fix layout padding and remove hardcoded offsets.

#### [MODIFY] [ai_assistant_screen.dart](file:///E:/resume_builder_app/lib/screens/home/ai_assistant_screen.dart)
- Redesign to match the new theme.
- Add better state handling for AI responses (empty states, error banners).

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no regressions in existing logic.
- Verify `AiService` initialization via unit tests.

### Manual Verification
- Verify the new UI on an Android Emulator (checking both Light and Dark modes).
- Test the AI Assistant with sample prompts to confirm Gemini responses are appearing.
- Inspect logs to ensure Remote Config and App Check are initializing without errors.

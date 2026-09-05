# AI-Powered Resume Builder

A Flutter mobile app that helps users build a professional resume with AI-generated
content, pre-designed templates, LinkedIn import, and PDF export.

This package picks up **after** your existing splash screen, welcome screen, login, and
signup screens — it does not touch or replace them.

## What's included

| Feature (from the brief)                          | Where it lives                                          |
|-----------------------------------------------------|-----------------------------------------------------------|
| AI-generated resume content                          | `lib/services/ai_service.dart`, used in the Summary & Experience builder steps |
| Tailored suggestions per job role                    | `AiService.suggestSkills`, `AiService.reviewResume`      |
| Customizable pre-designed templates                  | `lib/models/template_model.dart`, `lib/widgets/resume/resume_preview.dart`, `lib/screens/templates/` |
| LinkedIn import                                      | `lib/services/linkedin_import_service.dart`, `lib/screens/linkedin/` |
| PDF export                                           | `lib/services/pdf_export_service.dart`                    |
| Firebase auth + storage                              | `lib/services/auth_service.dart`, `lib/services/firestore_service.dart` |
| Multi-step resume builder                            | `lib/screens/builder/`                                    |
| Home dashboard / resume list                         | `lib/screens/home/home_screen.dart`                        |
| Design system (see `DESIGN_SYSTEM.md`)               | `lib/core/theme/`                                          |

## Setup

1. **Install dependencies**
   ```
   flutter pub get
   ```

2. **Connect Firebase**
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This overwrites `lib/firebase_options.dart` with your real project config.
   Then deploy `firestore.rules` (already scoped so each user can only read/write
   their own resumes):
   ```
   firebase deploy --only firestore:rules
   ```

3. **Add your API key**
   Copy `.env.example` to `.env` and add your OpenAI key:
   ```
   OPENAI_API_KEY=sk-...
   ```
   `.env` is gitignored — never commit it.

   > **Production note:** shipping an OpenAI key inside a public app bundle means
   > it can be extracted. For a real launch, proxy `AiService`'s calls through a
   > small backend (Cloud Function is enough) that holds the key server-side.
   > For an internship build/demo, calling OpenAI directly from the client is fine.

4. **Wire in your existing screens**
   Open `lib/app.dart`. Your login/signup screen's "success" callback should call:
   ```dart
   await context.read<AuthProvider>().signIn(email, password);
   // or signUp(email, password, displayName)
   ```
   and then navigate to `HomeScreen()`. Point your splash screen's initial route
   at `ResumeBuilderApp` (or embed `_AuthGate`'s logic into your existing navigation).

5. **Run it**
   ```
   flutter run
   ```

## Project structure

```
lib/
  core/            design tokens: colors, typography, spacing (see DESIGN_SYSTEM.md)
  models/          Resume, Experience, Education, Skill, Template, User
  services/        Firebase auth/Firestore, OpenAI, LinkedIn import, PDF export
  providers/       AuthProvider, ResumeProvider (Provider/ChangeNotifier state)
  screens/
    home/          dashboard — list of saved resumes, entry points
    builder/       5-step resume builder (personal info → experience → education → skills → summary)
    templates/     template gallery + live preview + export
    linkedin/      LinkedIn OAuth + paste-to-import fallback
    profile/       account settings, sign out
  widgets/         shared buttons, inputs, AI badge, skeleton loaders, resume preview renderer
```

## Design approach

`DESIGN_SYSTEM.md` documents the color palette, type scale, spacing, and motion rules used
throughout — written specifically for a resume/career product (ink-on-paper palette, serif
document typography vs. sans UI typography) rather than a generic template look. Every screen
pulls from `lib/core/theme/` instead of hardcoding values, so changing the palette or type
scale is a one-file change.

## Known limitations / next steps

- `firebase_options.dart` contains placeholder values — must run `flutterfire configure`
  before the app will actually connect to Firebase.
- LinkedIn's official API doesn't grant third-party apps full profile access without a
  partnership; the OAuth path here expects your own backend to broker that. The "paste your
  exported profile text" flow works today with no extra setup and is the practical path for
  a student/intern project.
- Offline font loading: `google_fonts` fetches Inter and Source Serif 4 at runtime. For a
  fully offline build, download the `.ttf` files and register them under `flutter.fonts:` in
  `pubspec.yaml`, then swap `GoogleFonts.inter(...)` calls in `app_typography.dart` for
  `TextStyle(fontFamily: 'Inter', ...)`.
- No automated tests included — recommend adding widget tests for the builder steps and a
  unit test for `PdfExportService` before submitting as a finished deliverable.

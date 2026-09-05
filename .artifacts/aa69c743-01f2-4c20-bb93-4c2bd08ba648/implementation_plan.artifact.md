# Implementation Plan - Ultra-Professional App Suite

This plan expands the previous goal of making the app "more professional" by adding a high-end onboarding experience, advanced settings, and deeper monetization/legal components.

## User Review Required

> [!IMPORTANT]
> **Onboarding Flow**: This will be shown on the first launch (mocked using `SharedPreferences`). It will use professional illustrations (placeholders) and copy to set a high-quality tone.

> [!NOTE]
> **Advanced Export**: I will add a "Settings" gear to the Preview screen allowing users to toggle between **A4** and **US Letter** formats, a must-have for international professional use.

## Proposed Changes

### 1. High-End Onboarding
Creating a "wow" factor for new users.

#### [NEW] [onboarding_screen.dart](file:///E:/resume_builder_app/lib/screens/onboarding/onboarding_screen.dart)
- A 3-page carousel explaining: 1. AI-Powered Resume Builder, 2. LinkedIn Sync, 3. Premium Templates & Export.
- Seamless transition to the Signup/Login flow.

---

### 2. Monetization & Premium Strategy
Showing "scale" and business readiness.

#### [NEW] [premium_upsell_screen.dart](file:///E:/resume_builder_app/lib/screens/premium/premium_upsell_screen.dart)
- A sleek, dark-themed comparison table: "Free" vs "Pro".
- Highlights: Unlimited AI generations, All Premium Templates, Priority Support.

#### [MODIFY] [home_screen.dart](file:///E:/resume_builder_app/lib/screens/home/home_screen.dart)
- Add a "Upgrade to Pro" badge/banner in the user profile area.

---

### 3. Support, Legal & Feedback
Standard "Store-Ready" requirements.

#### [NEW] [legal_content_screen.dart](file:///E:/resume_builder_app/lib/screens/profile/legal_content_screen.dart)
#### [NEW] [feedback_screen.dart](file:///E:/resume_builder_app/lib/screens/profile/feedback_screen.dart)
- Functional UI for Privacy Policy, Terms of Service, and a Support/Feedback form.

#### [MODIFY] [profile_screen.dart](file:///E:/resume_builder_app/lib/screens/profile/profile_screen.dart)
- Add "Delete Account" flow (with confirmation dialog).
- Add "Manual Theme Toggle" (Light/Dark/System).
- Add "App Version" and "Share App" features.

---

### 4. Advanced Resume Controls
Small details that signal a "Serious" app.

#### [MODIFY] [resume_preview_screen.dart](file:///E:/resume_builder_app/lib/screens/templates/resume_preview_screen.dart)
- Add an "Export Options" modal to select PDF Paper Size (A4/Letter).

#### [MODIFY] [resume_model.dart](file:///E:/resume_builder_app/lib/models/resume_model.dart)
- Ensure `portfolioUrl` is fully integrated into the data flow.

## Verification Plan

### Manual Verification
1. **Onboarding**: Restart app (or clear storage) and verify the onboarding carousel appears first.
2. **Theme Toggle**: Manually switch between Light/Dark in Settings and verify immediate UI update.
3. **Legal/Feedback**: Navigate through all Profile tiles to ensure no broken screens.
4. **Premium UI**: Verify the "Pro" plan landing page looks modern and professional.
5. **Account Deletion**: Verify the warning dialog appears before the "Mock Delete" happens.

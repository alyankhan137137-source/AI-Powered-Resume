# Task List - LinkedIn PDF Job Tailor

- `[x]` Cleanup Dependencies
    - `[x]` Remove `archive` and `csv` from `pubspec.yaml`
    - `[x]` Run `flutter pub get`
- `[x]` Update AI Service
    - `[x]` Modify `generateTailoredResume` to support multimodal PDF input
- `[x]` Refactor LinkedIn Import Service
    - `[x]` Remove ZIP/CSV parsing logic
- `[x]` Update Advanced Import UI
    - `[x]` Change file picker filter to `.pdf`
    - `[x]` Update labels and icons (ZIP -> PDF)
    - `[x]` Pass PDF bytes to the tailored generation flow
- `[x]` Verification
    - `[x]` Verify PDF selection
    - `[x]` Verify AI synthesis with mock/real data

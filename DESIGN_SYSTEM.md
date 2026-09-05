# Design System — AI Resume Builder

This app helps someone turn a messy work history into a polished, hireable document.
The visual language should feel like **a well-organized paper resume, not a generic SaaS dashboard** —
calm, structured, confidence-inspiring. No purple gradients, no glow effects, no sparkle emojis.

Read this before touching any screen. Every screen must follow these tokens — see `lib/core/theme/`.

---

## 1. Color — "Ink & Paper"

Grounded in the subject matter: ink on paper, a highlighter for AI suggestions, a growth-green for progress.

| Token              | Hex       | Usage                                              |
|--------------------|-----------|-----------------------------------------------------|
| `ink900`           | `#141A20` | Primary text, headings, icons on light surfaces    |
| `ink600`           | `#4B5560` | Secondary/body text                                |
| `ink300`           | `#9AA3AC` | Placeholder text, disabled states                  |
| `paper`            | `#F7F6F3` | App background (warm neutral, not stark white)     |
| `surface`          | `#FFFFFF` | Cards, sheets, input fields                        |
| `border`           | `#E2E0DA` | Hairline borders, dividers                         |
| `growth600`        | `#2E6E58` | Primary brand accent — CTAs, progress, links        |
| `growth100`        | `#DCEBE4` | Growth accent tint (chips, selected states)        |
| `signal500`        | `#B8622E` | AI-generated content marker (warm copper, not glow)|
| `signal100`        | `#F3E3D6` | AI content background tint                          |
| `error500`         | `#B3403A` | Errors, destructive actions                         |

No purple. No default Material `#6750A4`. `growth600` is the one accent that carries brand weight —
`signal500` is reserved *only* for marking AI-generated content, so users always know what the AI touched
vs. what they wrote themselves. That distinction is a functional UX signal, not decoration.

## 2. Typography — "Interface vs. Document"

Two families, each with one clear job:

- **Inter** — all app UI: navigation, buttons, forms, labels. Neutral, legible, doesn't compete with resume content.
- **Source Serif 4** — used *inside resume templates only* (the actual resume preview/export), because
  real resumes read as more credible in serif. This also visually separates "the app" from "the document,"
  which helps users trust that what they see in preview is what gets exported.

### Type scale (Inter, app UI)
| Style       | Size | Weight | Line height | Usage                    |
|-------------|------|--------|-------------|---------------------------|
| Display     | 28   | 600    | 1.2         | Screen titles              |
| Title       | 20   | 600    | 1.3         | Section headers            |
| Body        | 15   | 400    | 1.5         | Paragraph/body text        |
| BodyStrong  | 15   | 600    | 1.5         | Emphasized body            |
| Label       | 13   | 500    | 1.4         | Form labels, tabs          |
| Caption     | 12   | 400    | 1.4         | Helper text, timestamps    |

Rules: no ALL-CAPS labels, no single-word bold/italic accenting inside headings, sentence case everywhere
(including buttons: "Save changes," not "Submit" or "SAVE CHANGES").

## 3. Layout & components

- **Two border radii only:** `8px` (inputs, buttons, chips) and `16px` (cards, bottom sheets, modals). Never mix a third.
- **Spacing scale:** 4 / 8 / 12 / 16 / 24 / 32 / 48 — no arbitrary values.
- Component placement is identical across builder steps: title top-left, progress indicator top-right,
  primary action always bottom-right/full-width-bottom, back action always top-left. Users should never
  have to relearn the screen.
- Hover/press states: max 2px elevation lift, 120ms ease-out. No glow, no scale-bounce.
- Icons sized proportionally to adjacent text (18px icon next to 15px body text, 20px next to titles) — never
  oversized decorative icons.
- No placeholder social icons anywhere (no unlinked Twitter/Facebook icons in footers etc.)

## 4. Motion

- Easing: `Curves.easeOutCubic` for entrances, `Curves.easeInOutCubic` for state changes.
- One orchestrated moment per screen at most (e.g., resume preview builds itself in on first load).
- No stagger-fade on every list item by default — only when it communicates something (e.g., AI generating
  bullet points one at a time, because that mirrors the actual work happening).
- Every async action (AI generation, PDF export, Firebase save) has a visible loading/progress state —
  never a frozen button.

## 5. Copy voice

- Plain, active, specific. "Generate summary" not "Unleash your potential." No em dashes stacked for effect.
- Buttons name the action, not a generic verb: "Add experience," "Import from LinkedIn," "Export PDF."
- Empty states explain what to do next: "No resumes yet — tap Create to build your first one," not "Nothing here!"
- AI output is always labeled: a small `signal500` tag reading "AI suggested" — never presented as if the user wrote it.

# Refined Academic Website Modernization

## Summary

Modernize the existing academic website without replacing its Jekyll/Academic Pages foundation, changing its information architecture, or adding a front-end framework. The selected direction is **Refined Academic**: a restrained visual system built from the existing blue-green accent, system fonts, subtle surfaces, consistent spacing, and clear interaction states.

The work covers the shared site shell and all public page types, but it does not rewrite academic content, migrate publication data, add new imagery, or publish the result. English and Chinese home pages must remain structurally equivalent and use the same style rules. All review is performed through a local Jekyll preview in both light and dark modes.

Reference principles:

- [al-folio](https://alshedivat.github.io/al-folio/) for compact academic information hierarchy and publication affordances.
- [Carbon 2x Grid](https://carbondesignsystem.com/elements/2x-grid/overview/) for a consistent spacing rhythm.
- [USWDS card guidance](https://designsystem.digital.gov/components/card/) for limiting cards to genuinely grouped, self-contained information.
- [WCAG text contrast guidance](https://www.w3.org/WAI/WCAG22/Techniques/general/G18) and [`prefers-reduced-motion`](https://web.dev/learn/accessibility/motion/) for accessible visual polish.

## Design System

### Theme tokens

Keep the existing default theme identity but replace layout-level Sass color literals with semantic CSS custom properties defined separately for light and dark modes:

- Page and component surfaces: page background, raised surface, accent-tinted surface, and overlay surface.
- Text: primary, secondary, and link colors.
- Borders: subtle and strong borders.
- Interaction: hover tint, focus ring, and active navigation background.
- Depth: one soft surface shadow and one stronger overlay shadow.

All custom properties must compile to valid CSS colors. Layout components must consume theme tokens rather than the `$primary-color` value left by Sass import order. Light-mode body text, secondary text, and links must meet WCAG AA contrast for their rendered sizes; dark mode must retain visible secondary hierarchy instead of rendering all text near-white.

### Spacing, shape, and typography

- Use a compact 4/8 px-derived rhythm expressed in `rem`: 0.25, 0.5, 0.75, 1, 1.5, and 2 rem.
- Use `0.625rem` rounding for elevated panels and image frames, `0.5rem` for controls, and full rounding for chips.
- Keep the system font stack and existing icon fonts; do not add a web font.
- Increase metadata and sidebar text from the current very small scale to a readable minimum of `0.8125rem` at the base viewport, while preserving compact density.
- Keep content measures between 44 and 52 rem depending on page type. Publications receive an explicit readable measure instead of spanning the full desktop archive width.

### Motion and states

- Replace blanket `transition: all` rules with targeted 150–180 ms transitions for color, background, border, opacity, box-shadow, and small transforms only where needed.
- Interactive surfaces may move upward by at most 1 px on hover; continuous content must not animate into view.
- Every hover treatment must have a keyboard `:focus-visible` equivalent.
- Add a global `prefers-reduced-motion: reduce` branch that disables nonessential animation, smooth scrolling, and transforms.
- Do not add scroll-reveal libraries, View Transitions, animated backgrounds, or `backdrop-filter` effects.

## Component and Page Behavior

### Site shell

- **Masthead:** retain the fixed greedy-navigation structure. Use the raised surface and subtle border/shadow tokens. Replace the heavy active underline with the soft accent pill shown in the approved mockup, while preserving a visible focus ring and the current collapsed navigation behavior.
- **Theme control:** retain the sun/moon control and stored user preference. Apply the chosen theme before the main stylesheet paints, expose `color-scheme: light dark`, and keep the browser theme color synchronized to the active mode.
- **Author profile:** preserve the current desktop sidebar and compact mobile profile. Make the portrait fluid within its column, allow long contact text to wrap safely at intermediate widths, and use the shared hover/focus surface for profile links and the WeChat trigger.
- **Footer:** apply the same text, border, and spacing tokens. Retain the existing counter and attribution, but keep them visually subordinate to page content.

### English and Chinese home pages

- `_pages/about.md` and `_pages/zh_cn.md` continue to use the same `.academic-home`, intro, section, chips, and timeline structure.
- Any markup adjustment made to one page must be mirrored in the other during the same change. Language-specific copy remains independent.
- The introduction remains the primary elevated panel with a blue-green left accent, soft theme-aware tint, 10 px radius, and minimal shadow.
- Research interests remain chips, but adopt the unified chip token and interaction-independent styling.
- Education remains a timeline, with theme-aware rail and markers and no new JavaScript.
- Section headings receive consistent spacing and rule treatment across both languages.

### Publications and blog

- Add a dedicated publication index wrapper with a 52 rem maximum measure.
- Preserve category ordering and the current publication front matter model.
- Differentiate category heading, entry title, metadata, excerpt/citation, and resource links as five clear levels. Remove redundant heading rules and use spacing plus a subtle separator between entries rather than turning every publication into a card.
- Keep Paper/Slides/BibTeX links as compact outlined actions and fix archive selector precedence so they are not underlined.
- Keep the blog as a chronological editorial list. Reuse the same metadata, separator, chip, and focus tokens without adding cards around every post.

### CV, Hobbies, and utility pages

- Keep CV education and awards on the shared timeline. Use raised surfaces for the four skill groups and lock the desktop arrangement to a balanced two-column layout before collapsing to one column on small screens.
- Keep the existing Hobbies media, aspect ratios, lazy loading, and page structure. Apply shared image radius, border, and a reduced-motion-safe 1 px hover treatment only on devices that support hover.
- Bring the 404 page, buttons, pagination, dropdowns, and table of contents onto the shared surface, border, focus, and shadow tokens without changing their content or navigation behavior.

## Theme Initialization and JavaScript

Add a very small inline theme initializer before the main stylesheet in the document head. It must:

1. Safely read `localStorage.theme` when available.
2. Fall back to `prefers-color-scheme` when no explicit preference exists.
3. Set or remove `data-theme="dark"` before first paint.
4. Set the matching browser `theme-color`.
5. If storage access is blocked, continue with the system preference; fall back to light only when no preference can be resolved.

The existing theme toggle remains in `assets/js/_main.js`; it updates the HTML attribute, icon, stored preference, and browser theme color. Any source change must be followed by regeneration of `assets/js/main.min.js`. No new JavaScript dependency is allowed.

## Validation and Acceptance Criteria

### Automated checks

- Extend the local regression coverage to assert that compiled CSS contains the new semantic tokens, contains no unresolved `mix(...)` color values, and includes a reduced-motion branch.
- Assert that both `/` and `/zh_cn/` render the shared intro, chips, timeline, and section structures.
- Preserve and run the existing base-path, Hobbies media, sidebar alignment, and site hygiene checks.
- Run a local production-mode Jekyll build to a temporary destination; this is a build verification only and must not deploy or push anything.

### Local visual review

Run the Jekyll preview locally and inspect at minimum:

- Pages: English home, Chinese home, Publications, Blog Posts, CV, Hobbies, and 404.
- Modes: explicit light and explicit dark selection, plus system-preference fallback with no saved theme.
- Viewports: approximately 1440×900 desktop, 1024×768 intermediate/tablet, and 390×844 mobile.
- States: navigation active/hover/focus, theme toggle, collapsed navigation, author Follow menu, WeChat focus/hover popover, publication resource links, and image hover behavior.

Acceptance requires no horizontal overflow, no theme flash during normal local navigation, readable secondary text, visible keyboard focus, matching English/Chinese component structure, and no broken assets or console errors.

### Resource budget and release boundary

- Add no external fonts, images, animation libraries, CSS frameworks, or client-side component libraries.
- Keep new behavior to CSS and a small inline theme initializer; the existing compressed JavaScript bundle remains the only site script bundle.
- Do not deploy, push, or publish during this task. The deliverable is a locally verified working tree and local preview for user review.

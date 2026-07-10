# Refined Academic Website Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the approved “Refined Academic” visual system across the Jekyll site while preserving its content model, keeping English and Chinese home pages synchronized, and validating every page locally in light and dark modes.

**Architecture:** Introduce semantic light/dark CSS tokens at the theme layer, then consume them from existing focused Sass modules. Add a pre-paint theme initializer in the document head, retain the current theme toggle and compressed bundle, and refine each existing page family without adding a framework or new runtime dependency.

**Tech Stack:** Jekyll 3.10, Liquid, Sass, shell regression tests, existing jQuery bundle, UglifyJS build, Codex in-app browser for local visual QA.

## Global Constraints

- Do not deploy, push, publish, or invoke a GitHub Pages release workflow.
- Preview only through a local `bundle exec jekyll serve` process.
- Keep `_pages/about.md` and `_pages/zh_cn.md` on the same structural classes and shared Sass selectors.
- Test explicit light mode, explicit dark mode, and system-preference fallback.
- Test 1440×900, 1024×768, and 390×844 viewports.
- Add no external font, image, animation library, CSS framework, or client-side component library.
- Preserve publication front matter, Hobbies images and lazy-loading rules, MathJax/Mermaid opt-in loading, and the greedy-navigation behavior.
- When `assets/js/_main.js` changes, regenerate `assets/js/main.min.js`.
- Do not commit `AGENTS.md`, `_site/`, `vendor/`, `.bundle/`, `.sass-cache/`, `node_modules/`, or local preview artifacts.

## File Map

- `_sass/theme/_default_light.scss`, `_sass/theme/_default_dark.scss`: authoritative theme values and semantic token definitions.
- `_sass/layout/_base.scss`: typography baseline, targeted transitions, and reduced-motion fallback.
- `_includes/head.html`, `_includes/head/custom.html`, `assets/js/_main.js`, `assets/js/main.min.js`: pre-paint theme resolution and subsequent theme changes.
- `_sass/layout/_masthead.scss`, `_sass/layout/_navigation.scss`, `_sass/layout/_sidebar.scss`, `_sass/layout/_buttons.scss`, `_sass/layout/_footer.scss`, `_sass/layout/_not-found.scss`: global shell and reusable interaction states.
- `_sass/layout/_academic-home.scss`, `_sass/layout/_academic-content.scss`: English/Chinese home, CV, Hobbies, and blog-specific presentation.
- `_pages/publications.html`, `_sass/layout/_archive.scss`: publication width and information hierarchy.
- `_tests/visual_refresh.sh`: focused regression contract for this modernization.

---

### Task 1: Semantic theme foundation

**Files:**
- Create: `_tests/visual_refresh.sh`
- Modify: `_sass/theme/_default_light.scss`
- Modify: `_sass/theme/_default_dark.scss`
- Modify: `_sass/layout/_base.scss`

**Interfaces:**
- Consumes: Existing `data-theme="dark"` convention and legacy `--global-*` variables.
- Produces: `--global-surface-raised-color`, `--global-surface-accent-color`, `--global-surface-overlay-color`, `--global-text-color-light`, `--global-hover-color`, `--global-focus-color`, `--global-shadow-soft`, `--global-shadow-overlay`, `--global-radius-panel`, `--global-radius-control`, and `--global-transition-fast` for later tasks.

- [ ] **Step 1: Add the failing theme regression test**

Create `_tests/visual_refresh.sh` with this complete initial content:

```sh
#!/bin/sh

set -eu

fail() {
  echo "visual_refresh.sh: $1" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "missing expected file: $1"
}

assert_contains() {
  file=$1
  pattern=$2
  grep -Fq -- "$pattern" "$file" || fail "expected '$pattern' in $file"
}

assert_not_contains() {
  file=$1
  pattern=$2
  if grep -Fq -- "$pattern" "$file"; then
    fail "did not expect '$pattern' in $file"
  fi
}

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/qianyi-visual-refresh.XXXXXX")

cd "$repo_root"

JEKYLL_ENV=development bundle exec jekyll build --destination "$build_dir" --quiet

css="$build_dir/assets/css/main.css"

assert_file "$css"
assert_contains "_sass/theme/_default_light.scss" "--global-surface-raised-color"
assert_contains "_sass/theme/_default_dark.scss" "--global-surface-raised-color"
assert_contains "_sass/theme/_default_light.scss" "--global-focus-color"
assert_contains "_sass/theme/_default_dark.scss" "--global-focus-color"
assert_contains "_sass/layout/_base.scss" "@media (prefers-reduced-motion: reduce)"
assert_contains "$css" "--global-surface-accent-color"
assert_contains "$css" "prefers-reduced-motion: reduce"
assert_not_contains "$css" "mix(#"

echo "visual_refresh.sh: ok"
```

- [ ] **Step 2: Run the test and verify the missing-token failure**

Run: `sh _tests/visual_refresh.sh`

Expected: FAIL with `expected '--global-surface-raised-color' in _sass/theme/_default_light.scss`.

- [ ] **Step 3: Define exact light-mode tokens**

In `_sass/theme/_default_light.scss`, set `$border-radius: 0.5rem`, set `$box-shadow: var(--global-shadow-soft)`, set `$global-transition` to `color 160ms ease, background-color 160ms ease, border-color 160ms ease, box-shadow 160ms ease, opacity 160ms ease, transform 160ms ease`, and replace the `:root` block with:

```scss
:root {
  color-scheme: light;
  --global-base-color: #2f7f93;
  --global-bg-color: #f7f9fa;
  --global-surface-raised-color: #ffffff;
  --global-surface-accent-color: #eaf5f7;
  --global-surface-overlay-color: #ffffff;
  --global-footer-bg-color: #eef3f4;
  --global-border-color: #dbe4e7;
  --global-dark-border-color: #aebdc2;
  --global-code-background-color: #f0f4f5;
  --global-code-text-color: #26343a;
  --global-fig-caption-color: #5f6f76;
  --global-link-color: #176b80;
  --global-link-color-hover: #0f5263;
  --global-link-color-visited: #536f7a;
  --global-masthead-link-color: #35464d;
  --global-masthead-link-color-hover: #176b80;
  --global-text-color: #26343a;
  --global-text-color-light: #5f6f76;
  --global-thead-color: #eaf0f2;
  --global-toc-bg-color: #ffffff;
  --global-hover-color: #e4f1f4;
  --global-focus-color: #176b80;
  --global-shadow-soft: 0 8px 24px rgba(38, 52, 58, 0.07);
  --global-shadow-overlay: 0 14px 36px rgba(38, 52, 58, 0.14);
  --global-radius-panel: 0.625rem;
  --global-radius-control: 0.5rem;
  --global-transition-fast: 160ms ease;
}
```

- [ ] **Step 4: Define exact dark-mode tokens**

In `_sass/theme/_default_dark.scss`, make the same three Sass variable changes and replace the `html[data-theme="dark"]` block with:

```scss
html[data-theme="dark"] {
  color-scheme: dark;
  --global-base-color: #48b7cf;
  --global-bg-color: #202a30;
  --global-surface-raised-color: #29363d;
  --global-surface-accent-color: #173d47;
  --global-surface-overlay-color: #303f47;
  --global-footer-bg-color: #1c252a;
  --global-border-color: #42535b;
  --global-dark-border-color: #63747c;
  --global-code-background-color: #182126;
  --global-code-text-color: #e8f0f2;
  --global-fig-caption-color: #aebcc1;
  --global-link-color: #72c9dc;
  --global-link-color-hover: #a2e2ef;
  --global-link-color-visited: #9ec1cb;
  --global-masthead-link-color: #eaf2f4;
  --global-masthead-link-color-hover: #8bd8e7;
  --global-text-color: #f3f7f8;
  --global-text-color-light: #b8c5ca;
  --global-thead-color: #34444c;
  --global-toc-bg-color: #29363d;
  --global-hover-color: #31464f;
  --global-focus-color: #72c9dc;
  --global-shadow-soft: 0 8px 24px rgba(0, 0, 0, 0.22);
  --global-shadow-overlay: 0 16px 40px rgba(0, 0, 0, 0.34);
  --global-radius-panel: 0.625rem;
  --global-radius-control: 0.5rem;
  --global-transition-fast: 160ms ease;
}
```

- [ ] **Step 5: Replace blanket motion with an accessible fallback**

In `_sass/layout/_base.scss`, remove the broad selector that assigns `$global-transition` to nearly every text element. Keep the existing `intro` keyframes, and add:

```scss
a,
button,
.btn,
figure img,
.archive__item-teaser {
  transition: $global-transition;
}

@media (prefers-reduced-motion: reduce) {
  html:focus-within {
    scroll-behavior: auto;
  }

  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: 0.01ms !important;
  }
}
```

- [ ] **Step 6: Run the focused test**

Run: `sh _tests/visual_refresh.sh`

Expected: `visual_refresh.sh: ok` and no unresolved `mix(#` values in compiled CSS.

- [ ] **Step 7: Commit the foundation**

```bash
git add -f _tests/visual_refresh.sh
git add _sass/theme/_default_light.scss _sass/theme/_default_dark.scss _sass/layout/_base.scss
git commit -m "style: add semantic theme foundation"
```

---

### Task 2: Pre-paint theme initialization

**Files:**
- Modify: `_tests/visual_refresh.sh`
- Modify: `_includes/head.html`
- Modify: `_includes/head/custom.html`
- Modify: `assets/js/_main.js`
- Modify: `assets/js/main.min.js`

**Interfaces:**
- Consumes: `data-theme="dark"`, `localStorage.theme`, `#theme-toggle`, and the Task 1 background colors `#f7f9fa` and `#202a30`.
- Produces: `<meta id="theme-color" data-light="…" data-dark="…">`, a pre-stylesheet theme resolver, and `updateThemeColor(theme)` in the main script.

- [ ] **Step 1: Extend the regression test for head order and bundle synchronization**

Add this function after `assert_not_contains` in `_tests/visual_refresh.sh`:

```sh
assert_before() {
  file=$1
  first=$2
  second=$3
  first_line=$(grep -nF "$first" "$file" | head -n 1 | cut -d: -f1)
  second_line=$(grep -nF "$second" "$file" | head -n 1 | cut -d: -f1)
  [ -n "$first_line" ] || fail "missing '$first' in $file"
  [ -n "$second_line" ] || fail "missing '$second' in $file"
  [ "$first_line" -lt "$second_line" ] || fail "expected '$first' before '$second' in $file"
}
```

Add these assertions immediately before the final `echo`:

```sh
assert_contains "_includes/head.html" 'id="theme-color"'
assert_contains "_includes/head.html" 'name="color-scheme"'
assert_contains "_includes/head.html" 'data-light="#f7f9fa"'
assert_contains "_includes/head.html" 'data-dark="#202a30"'
assert_before "_includes/head.html" 'id="theme-color"' '<link rel="stylesheet"'
assert_before "_includes/head.html" 'localStorage.getItem("theme")' '<link rel="stylesheet"'
assert_not_contains "_includes/head/custom.html" '<meta name="theme-color"'
assert_contains "assets/js/_main.js" "updateThemeColor"
assert_contains "assets/js/main.min.js" "theme-color"
```

- [ ] **Step 2: Run the test and verify it fails on the missing head marker**

Run: `sh _tests/visual_refresh.sh`

Expected: FAIL with `expected 'id="theme-color"' in _includes/head.html`.

- [ ] **Step 3: Add the pre-paint resolver before the stylesheet**

In `_includes/head.html`, place the following block after the existing `no-js` class script and before the stylesheet link:

```html
<meta name="color-scheme" content="light dark">
<meta
  id="theme-color"
  name="theme-color"
  content="#f7f9fa"
  data-light="#f7f9fa"
  data-dark="#202a30">
<script>
  (function () {
    var root = document.documentElement;
    var storedTheme = null;
    var resolvedTheme;

    try {
      storedTheme = localStorage.getItem("theme");
    } catch (error) {
      storedTheme = null;
    }

    if (storedTheme === "light" || storedTheme === "dark") {
      resolvedTheme = storedTheme;
    } else if (root.getAttribute("data-theme") === "dark") {
      resolvedTheme = "dark";
    } else if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
      resolvedTheme = "dark";
    } else {
      resolvedTheme = "light";
    }

    if (resolvedTheme === "dark") {
      root.setAttribute("data-theme", "dark");
    } else {
      root.removeAttribute("data-theme");
    }

    var themeColor = document.getElementById("theme-color");
    themeColor.setAttribute(
      "content",
      themeColor.getAttribute(resolvedTheme === "dark" ? "data-dark" : "data-light")
    );
  }());
</script>
```

Remove the existing static `<meta name="theme-color" content="#ffffff"/>` from `_includes/head/custom.html`.

- [ ] **Step 4: Make the existing toggle share the same theme-color contract**

At the top of `assets/js/_main.js`, replace the existing theme helpers with:

```js
const browserPref = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';

const getStoredTheme = () => {
  try {
    return localStorage.getItem('theme');
  } catch (error) {
    return null;
  }
};

const storeTheme = (theme) => {
  try {
    localStorage.setItem('theme', theme);
  } catch (error) {
    // The visual theme still changes when storage is unavailable.
  }
};

const updateThemeColor = (theme) => {
  const themeColor = document.getElementById('theme-color');
  if (!themeColor) return;

  const attribute = theme === 'dark' ? 'data-dark' : 'data-light';
  themeColor.setAttribute('content', themeColor.getAttribute(attribute));
};

const setTheme = (theme) => {
  const useTheme = theme || getStoredTheme() || $('html').attr('data-theme') || browserPref;

  if (useTheme === 'dark') {
    $('html').attr('data-theme', 'dark');
    $('#theme-icon').removeClass('fa-sun').addClass('fa-moon');
    updateThemeColor('dark');
  } else {
    $('html').removeAttr('data-theme');
    $('#theme-icon').removeClass('fa-moon').addClass('fa-sun');
    updateThemeColor('light');
  }
};

const toggleTheme = () => {
  const currentTheme = $('html').attr('data-theme');
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  storeTheme(newTheme);
  setTheme(newTheme);
};
```

Inside the existing media-query change listener, replace `localStorage.getItem("theme")` with `getStoredTheme()`; leave the remaining document-ready behavior unchanged.

- [ ] **Step 5: Rebuild the compressed bundle**

If `node_modules/` is absent, run `npm install`. Then run:

```bash
npm run build:js
```

Expected: `assets/js/main.min.js` is regenerated and contains the `theme-color` string.

- [ ] **Step 6: Run the theme tests**

Run: `sh _tests/visual_refresh.sh`

Expected: `visual_refresh.sh: ok`.

- [ ] **Step 7: Commit the theme lifecycle**

```bash
git add _tests/visual_refresh.sh _includes/head.html _includes/head/custom.html assets/js/_main.js assets/js/main.min.js
git commit -m "feat: apply theme before first paint"
```

---

### Task 3: Refine the site shell and reusable controls

**Files:**
- Modify: `_tests/visual_refresh.sh`
- Modify: `_sass/layout/_masthead.scss`
- Modify: `_sass/layout/_navigation.scss`
- Modify: `_sass/layout/_sidebar.scss`
- Modify: `_sass/layout/_buttons.scss`
- Modify: `_sass/layout/_footer.scss`
- Modify: `_sass/layout/_not-found.scss`

**Interfaces:**
- Consumes: Task 1 semantic tokens and the current masthead/sidebar HTML.
- Produces: Soft active-navigation pill, shared hover/focus surface, fluid author portrait, safe contact wrapping, and tokenized reusable surfaces.

- [ ] **Step 1: Add failing source-contract assertions**

Append these assertions before the final `echo` in `_tests/visual_refresh.sh`:

```sh
assert_contains "_sass/layout/_masthead.scss" "background: var(--global-surface-raised-color)"
assert_contains "_sass/layout/_masthead.scss" "background: var(--global-surface-accent-color)"
assert_contains "_sass/layout/_navigation.scss" "background: var(--global-hover-color)"
assert_contains "_sass/layout/_sidebar.scss" "overflow-wrap: anywhere"
assert_contains "_sass/layout/_sidebar.scss" "box-shadow: var(--global-shadow-overlay)"
assert_contains "_sass/layout/_buttons.scss" "outline: 2px solid var(--global-focus-color)"
assert_contains "_sass/layout/_footer.scss" "color: var(--global-text-color-light)"
assert_contains "_sass/layout/_not-found.scss" "background-color: var(--global-surface-raised-color)"
```

- [ ] **Step 2: Run the test and confirm the first shell assertion fails**

Run: `sh _tests/visual_refresh.sh`

Expected: FAIL on the masthead raised-surface assertion.

- [ ] **Step 3: Apply the approved masthead and navigation state**

In `_sass/layout/_masthead.scss`:

- Set `.masthead` background to `var(--global-surface-raised-color)` and box-shadow to `var(--global-shadow-soft)`.
- Set `.masthead__menu-item` background to `transparent`.
- Set menu links to `border-radius: var(--global-radius-control)` and targeted transition properties.
- Replace the selected-link styling with this exact state:

```scss
.masthead__menu-item.selected a {
  color: var(--global-text-color);
  font-weight: 700;
  background: var(--global-surface-accent-color);
  border-bottom-color: transparent;
  pointer-events: none;
  cursor: default;
}
```

In `_sass/layout/_navigation.scss`, set `.greedy-nav` to the raised surface, change its top-level link spacing to `margin: 0 0.2rem; padding: 0.5rem 0.7rem`, remove the animated underline pseudo-element, and use:

```scss
.greedy-nav .visible-links a:hover,
.greedy-nav .visible-links a:focus-visible {
  color: var(--global-masthead-link-color-hover);
  background: var(--global-hover-color);
}

.greedy-nav .hidden-links {
  background: var(--global-surface-overlay-color);
  border-color: var(--global-border-color);
  border-radius: var(--global-radius-panel);
  box-shadow: var(--global-shadow-overlay);
}
```

Keep the existing greedy-navigation button, visible/hidden list behavior, and persistence classes unchanged.

- [ ] **Step 4: Make the profile resilient and theme-aware**

In `_sass/layout/_sidebar.scss`:

- Use `border-radius: var(--global-radius-panel)` and `background: var(--global-surface-raised-color)` on the portrait.
- At desktop breakpoints, use `width: 100%; max-width: 175px; height: auto` instead of a fixed 175 px width.
- Change `.author__urls li` from `white-space: nowrap` to:

```scss
.author__urls li {
  min-width: 0;
  white-space: normal;
  overflow-wrap: anywhere;
}
```

- Use `var(--global-hover-color)` for author-link hover/focus backgrounds.
- Use the overlay surface, panel radius, and overlay shadow for the mobile Follow menu and WeChat popover.
- Preserve the shared grid selectors required by `_tests/sidebar_alignment.sh`.

- [ ] **Step 5: Tokenize reusable controls and utility surfaces**

In `_sass/layout/_buttons.scss`, add targeted transitions and this focus rule to `.btn`:

```scss
&:focus-visible {
  outline: 2px solid var(--global-focus-color);
  outline-offset: 2px;
}
```

Use `var(--global-surface-raised-color)` and `var(--global-hover-color)` for `.btn--inverse`, without changing semantic warning/success/danger variants.

In `_sass/layout/_footer.scss`, keep the existing layout but use the subtle border token, add a nested `@media (prefers-reduced-motion: reduce)` rule that sets both standard and WebKit `animation-delay` to `0s`, and add:

```scss
.page__footer-hit-counter {
  margin-bottom: 0.5rem;
  opacity: 0.72;
}
```

In `_sass/layout/_not-found.scss`, set the main panel to the raised surface, panel radius, and soft shadow; set link tiles to the accent surface and add `:focus-visible` alongside `:hover`.

- [ ] **Step 6: Run focused and existing shell tests**

Run:

```bash
sh _tests/visual_refresh.sh
sh _tests/sidebar_alignment.sh
sh _tests/local_base_path.sh
```

Expected: each script ends in `: ok`.

- [ ] **Step 7: Commit the shell refinement**

```bash
git add _tests/visual_refresh.sh _sass/layout/_masthead.scss _sass/layout/_navigation.scss _sass/layout/_sidebar.scss _sass/layout/_buttons.scss _sass/layout/_footer.scss _sass/layout/_not-found.scss
git commit -m "style: refine site shell and controls"
```

---

### Task 4: Synchronize and polish academic content pages

**Files:**
- Modify: `_tests/visual_refresh.sh`
- Modify: `_sass/layout/_academic-home.scss`
- Modify: `_sass/layout/_academic-content.scss`
- Verify unchanged structure: `_pages/about.md`
- Verify unchanged structure: `_pages/zh_cn.md`

**Interfaces:**
- Consumes: Shared `.academic-home*`, `.academic-page*`, `.academic-skill*`, `.hobby-*`, and Task 1 tokens.
- Produces: One visual implementation shared by English home, Chinese home, CV, and Hobbies without language-specific CSS.

- [ ] **Step 1: Add a failing English/Chinese parity check**

Add this function after `assert_before` in `_tests/visual_refresh.sh`:

```sh
assert_same_count() {
  first_file=$1
  second_file=$2
  pattern=$3
  first_count=$(grep -Fc "$pattern" "$first_file")
  second_count=$(grep -Fc "$pattern" "$second_file")
  [ "$first_count" -eq "$second_count" ] \
    || fail "expected matching '$pattern' counts in $first_file and $second_file"
}
```

Append these assertions before the final `echo`:

```sh
for pattern in \
  'class="academic-home"' \
  'class="academic-home__intro"' \
  'class="academic-home__section"' \
  'class="academic-home__chips"' \
  'class="academic-home__timeline"'
do
  assert_same_count "_pages/about.md" "_pages/zh_cn.md" "$pattern"
done

assert_contains "_sass/layout/_academic-home.scss" "background: var(--global-surface-accent-color)"
assert_contains "_sass/layout/_academic-home.scss" "box-shadow: var(--global-shadow-soft)"
assert_contains "_sass/layout/_academic-content.scss" "grid-template-columns: repeat(2, minmax(0, 1fr))"
assert_contains "_sass/layout/_academic-content.scss" "@media (hover: hover) and (pointer: fine)"
```

- [ ] **Step 2: Run the test and verify the surface assertion fails**

Run: `sh _tests/visual_refresh.sh`

Expected: FAIL on the missing academic-home accent-surface declaration.

- [ ] **Step 3: Apply the shared home-page presentation**

In `_sass/layout/_academic-home.scss`:

- Keep `.academic-home` shared and set its measure to `46rem`.
- Set `.academic-home__intro` to `padding: 1.15rem 1.2rem`, panel radius, a 1 px subtle border, 4 px base-color left border, accent surface, and soft shadow.
- Set `.academic-home__section` top margin to `2rem` and style its direct `h2` with `margin-bottom: 0.75rem`, `padding-bottom: 0.5rem`, and a subtle border.
- Replace all chip Sass `rgba($primary-color, …)` backgrounds with `var(--global-surface-accent-color)`, use the strong border token, and retain full rounding.
- Set the timeline rail to the strong border token and markers to a raised-surface fill with a base-color border.
- Keep the existing mobile list simplification and use the same values for both languages; do not introduce `:lang()` or page-specific selectors.

- [ ] **Step 4: Apply CV and Hobbies polish**

In `_sass/layout/_academic-content.scss`:

- Set `.academic-skill-grid` to `grid-template-columns: repeat(2, minmax(0, 1fr))` and keep the existing one-column mobile override.
- Set skill groups to the raised surface, panel radius, subtle border, 3 px accent border, and soft shadow.
- Replace skill-chip and post-tag Sass `rgba($primary-color, …)` backgrounds with the accent surface.
- Apply panel radius, subtle border, and raised surface to Hobbies images.
- Add the following pointer-specific treatment, relying on Task 1 to suppress it for reduced motion:

```scss
@media (hover: hover) and (pointer: fine) {
  .hobby-gallery img:hover,
  .hobby-gallery img:focus-visible,
  .hobby-feature__media img:hover,
  .hobby-feature__media img:focus-visible {
    border-color: var(--global-dark-border-color);
    box-shadow: var(--global-shadow-soft);
    transform: translateY(-1px);
  }
}
```

Do not modify image files, aspect ratios, `loading="lazy"`, or content copy.

- [ ] **Step 5: Run content and media regressions**

Run:

```bash
sh _tests/visual_refresh.sh
sh _tests/hobbies_media.sh
sh _tests/local_base_path.sh
```

Expected: each script ends in `: ok`.

- [ ] **Step 6: Commit the synchronized content styling**

```bash
git add _tests/visual_refresh.sh _sass/layout/_academic-home.scss _sass/layout/_academic-content.scss
git commit -m "style: polish shared academic pages"
```

---

### Task 5: Improve Publications and Blog hierarchy

**Files:**
- Modify: `_tests/visual_refresh.sh`
- Modify: `_pages/publications.html`
- Modify: `_sass/layout/_archive.scss`
- Modify: `_sass/layout/_academic-content.scss`

**Interfaces:**
- Consumes: Existing `archive-single.html`, publication front matter, `.publication-*` classes, `.blog-index`, and Task 1 tokens.
- Produces: `.publication-index`, `.publication-category`, readable 52 rem measure, separated editorial rows, and non-underlined resource actions.

- [ ] **Step 1: Add failing publication/blog assertions**

Append these assertions before the final `echo` in `_tests/visual_refresh.sh`:

```sh
assert_contains "_pages/publications.html" 'class="publication-index"'
assert_contains "_pages/publications.html" 'class="publication-category"'
assert_not_contains "_pages/publications.html" '<h2>{{ category[1].title }}</h2><hr />'
assert_contains "_sass/layout/_archive.scss" ".publication-index"
assert_contains "_sass/layout/_archive.scss" "max-width: 52rem"
assert_contains "_sass/layout/_archive.scss" ".archive a.publication-link"
assert_contains "_sass/layout/_academic-content.scss" ".blog-index .list__item"
```

- [ ] **Step 2: Run the test and confirm the missing wrapper failure**

Run: `sh _tests/visual_refresh.sh`

Expected: FAIL with `expected 'class="publication-index"' in _pages/publications.html`.

- [ ] **Step 3: Add semantic publication wrappers without changing data flow**

In `_pages/publications.html`, keep the front matter and `base_path` include, wrap the rendering loops in `<div class="publication-index">`, and change the category output to:

```liquid
{% unless title_shown %}
  <h2 class="publication-category">{{ category[1].title }}</h2>
  {% assign title_shown = true %}
{% endunless %}
```

Close `.publication-index` after both branches of the existing category conditional. Do not alter loop order, `archive-single.html`, publication fields, or status behavior.

- [ ] **Step 4: Implement the editorial publication hierarchy**

Add these blocks to `_sass/layout/_archive.scss` and remove the invalid `padding-right: auto` declarations from `.list__item`:

```scss
.publication-index {
  max-width: 52rem;
}

.publication-category {
  margin: 2rem 0 0.75rem;
  padding-bottom: 0.55rem;
  color: var(--global-text-color);
  font-size: $type-size-4;
  border-bottom: 1px solid var(--global-border-color);
}

.publication-index .list__item {
  margin: 0;
  padding: 0.25rem 0 1.15rem;
  border-bottom: 1px solid var(--global-border-color);
}

.publication-index .list__item:last-child {
  border-bottom: 0;
}

.publication-index .archive__item-title {
  margin-top: 0.85rem;
  font-size: 1.05rem;
  line-height: 1.35;
}

.archive a.publication-link {
  text-decoration: none;
}
```

Use `var(--global-text-color-light)` for metadata/citation labels, `0.8125rem` as their minimum size, the accent surface for resource-link hover/focus, and the control radius for resource links. Preserve the Submitted/Published semantic classes.

- [ ] **Step 5: Give blog posts the same editorial rhythm**

In `_sass/layout/_academic-content.scss`, add:

```scss
.blog-index .list__item {
  padding: 0.4rem 0 1rem;
  border-bottom: 1px solid var(--global-border-color);
}

.blog-index .list__item:last-child {
  border-bottom: 0;
}

.blog-index .archive__item-title {
  line-height: 1.35;
}
```

Keep tag chips, year ordering, excerpts, and links unchanged.

- [ ] **Step 6: Run focused and archive regressions**

Run:

```bash
sh _tests/visual_refresh.sh
sh _tests/local_base_path.sh
sh _tests/site_hygiene.sh
```

Expected: each script ends in `: ok`.

- [ ] **Step 7: Commit the archive hierarchy**

```bash
git add _tests/visual_refresh.sh _pages/publications.html _sass/layout/_archive.scss _sass/layout/_academic-content.scss
git commit -m "style: improve publication and blog hierarchy"
```

---

### Task 6: Full local verification and preview handoff

**Files:**
- Verify: all files changed in Tasks 1–5
- Generated outside repository: temporary Jekyll production build

**Interfaces:**
- Consumes: Complete local implementation and all regression scripts.
- Produces: A locally running preview URL and recorded evidence for light/dark, desktop/intermediate/mobile acceptance.

- [ ] **Step 1: Run every repository regression**

Run:

```bash
sh _tests/visual_refresh.sh
sh _tests/local_base_path.sh
sh _tests/hobbies_media.sh
sh _tests/sidebar_alignment.sh
sh _tests/site_hygiene.sh
```

Expected: five `: ok` results and exit code 0.

- [ ] **Step 2: Run a local production-mode build**

Run:

```bash
JEKYLL_ENV=production bundle exec jekyll build --destination /tmp/qianyi-site-build --quiet
```

Expected: exit code 0 with no Liquid or Sass error. This command builds locally and does not deploy.

- [ ] **Step 3: Check the working tree and generated bundle**

Run:

```bash
git diff --check
git status --short
```

Expected: no whitespace errors; only intentional tracked changes, the saved implementation plan if still uncommitted, and no `_site`, cache, dependency, or private maintenance files.

- [ ] **Step 4: Start the local preview**

Run `bundle exec jekyll serve --port 4001` in a persistent terminal session.

Expected: `Server address: http://127.0.0.1:4001/`. If port 4001 is already occupied, do not stop the existing process; use port 4002 and report that exact URL.

- [ ] **Step 5: Verify the fresh system-preference load**

Open the fresh localhost origin before changing the theme. At 1440×900, verify that the initial `data-theme`, theme icon, `#theme-color`, and computed body background all agree with `prefers-color-scheme`, and that the first captured frame does not flash the opposite surface.

- [ ] **Step 6: Verify the required page and viewport matrix**

For each of `/`, `/zh_cn/`, `/publications/`, `/year-archive/`, `/cv/`, `/hobbies/`, and `/404.html`:

1. Inspect at 1440×900 in light mode.
2. Inspect at 1440×900 in dark mode.
3. Inspect at 1024×768 in both modes.
4. Inspect at 390×844 in both modes.

At every combination, verify no horizontal overflow, readable secondary text, stable content measure, matching English/Chinese component geometry, intact images, and visible active navigation.

- [ ] **Step 7: Verify interaction and accessibility states**

Check keyboard focus and pointer states for the theme toggle, greedy-navigation menu, author Follow menu, WeChat trigger/popover, author links, publication resource links, CV skill surfaces, Hobbies images, pagination, and 404 actions. Enable reduced-motion preference and verify that intro animation, hover translation, and smooth scrolling are suppressed while all content remains visible.

- [ ] **Step 8: Inspect browser errors and retain the local server**

Confirm the browser console contains no errors from CSS, theme initialization, assets, or greedy navigation. Leave the Jekyll server running for the user’s local review, report its localhost URL, and do not push or deploy.

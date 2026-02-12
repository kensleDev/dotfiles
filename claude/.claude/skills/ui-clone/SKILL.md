---
name: ui-cloner
description: Clone and replicate live website UI into the current project stack. Uses agent-browser to capture screenshots of target and dev sites, zai-vision MCP for visual diffing, and codebase analysis to produce a pixel-perfect implementation plan. Outputs structured plans to .agent/plans/ ready for execution via PRD loops. Trigger when asked to replicate, clone, copy, match, or rebuild the look/feel/UI of an external website or specific page/section.
---

# UI Cloner Agent

Replicate live website UI into the current project's tech stack with pixel-perfect accuracy.

Think of this as a reverse-engineering assembly line: **photograph the target → photograph your current state → diff them → extract a precise spec → plan the build**.

## Required MCP Servers

Verify both are connected before starting (`/mcp` in Claude Code, or check OpenCode MCP panel):

- **agent-browser** — Navigate sites, capture screenshots, extract DOM structure
- **zai-vision** (`@z_ai/mcp-server`) — Visual analysis and diff comparison via GLM-4.6V

If either is missing, stop and tell the user which MCP server needs configuring.

## Inputs

The user provides one or more of:

| Input        | Required | Example                                        |
| ------------ | -------- | ---------------------------------------------- |
| `target_url` | ✅       | `https://example.com/pricing`                  |
| `dev_url`    | Optional | `http://localhost:5173/pricing`                |
| `focus`      | Optional | "hero section", "the nav bar", "/pricing page" |

Auto-detected from codebase: framework (SvelteKit / Next.js), styling (Tailwind / CSS modules), component library (shadcn, etc.)

## Mode Selection

```
Has the user provided a dev_url to compare against?
├─ YES → COMPARISON MODE
│   Capture both sites → visual diff → gap analysis → plan
│
└─ NO → GREENFIELD MODE
    Capture target only → extract full spec → plan from scratch
```

---

## Phase 1: Reconnaissance

### Step 1 — Explore the codebase

Before touching any URLs, understand what you're working with:

```
1. Read package.json to identify framework and dependencies
2. Identify the styling approach (Tailwind config, CSS modules, styled-components)
3. Find the relevant route/page files for the focus area
4. Note existing component patterns, design tokens, and shared utilities
5. Check for an existing Tailwind config — note any custom theme values
   (colors, spacing, fonts, breakpoints)
```

This gives you the "vocabulary" the implementation plan must use. Like reading the building codes before drafting blueprints.

### Step 2 — Capture the target site

Navigate to the target URL and capture at three breakpoints:

```
Breakpoints:
  Mobile:  390px width  (iPhone 14 / standard mobile)
  Tablet:  768px width  (iPad)
  Desktop: 1440px width (standard desktop)
```

For each breakpoint:

```typescript
// 1. Navigate and wait for load
mcp__agent_browser__browser_navigate({ url: targetUrl });

// 2. Get the accessibility/DOM tree for structure
mcp__agent_browser__browser_snapshot();

// 3. Capture full-page screenshot
mcp__agent_browser__browser_screenshot({
  path: ".agent/cloner/{slug}/target/target-{breakpoint}.png",
  fullPage: true,
});
```

If the user specified a **focus area**, also scroll to that section and capture a cropped viewport screenshot of just that region.

Save all screenshots to: `.agent/cloner/{slug}/target/`

### Step 3 — Analyze the target screenshots with vision

Use zai-vision to extract a structured UI spec from the target screenshots:

```typescript
// Get a detailed UI breakdown
mcp__zai -
  mcp -
  server__ui_to_artifact({
    image_path: ".agent/cloner/{slug}/target/target-desktop.png",
    artifact_type: "description", // Returns structured UI description
  });

// Extract any visible text content
mcp__zai -
  mcp -
  server__extract_text_from_screenshot({
    image_path: ".agent/cloner/{slug}/target/target-desktop.png",
  });
```

From the vision analysis, extract and document:

- **Layout structure**: Grid/flex patterns, column counts, section ordering
- **Spacing system**: Map observed spacing to nearest Tailwind values (p-4, gap-6, etc.)
- **Typography**: Font sizes, weights, line heights → map to Tailwind (text-lg, font-semibold, etc.)
- **Colors**: Extract hex/rgb → map to Tailwind palette or note custom values needed
- **Interactive elements**: Buttons, links, forms, dropdowns, hover states visible
- **Responsive behavior**: How layout changes across the three breakpoints
- **Images/media**: Aspect ratios, placeholder patterns, decorative vs content images

### Step 4 — Capture the dev site (COMPARISON MODE only)

If `dev_url` was provided, repeat the same screenshot process:

```typescript
mcp__agent_browser__browser_navigate({ url: devUrl });
mcp__agent_browser__browser_snapshot();
mcp__agent_browser__browser_screenshot({
  path: ".agent/cloner/{slug}/dev/dev-{breakpoint}.png",
  fullPage: true,
});
```

Save to: `.agent/cloner/{slug}/dev/`

### Step 5 — Visual diff (COMPARISON MODE only)

Use zai-vision's diff tool to identify exactly what's different:

```typescript
mcp__zai -
  mcp -
  server__ui_diff_check({
    image_path_1: ".agent/cloner/{slug}/target/target-desktop.png",
    image_path_2: ".agent/cloner/{slug}/dev/dev-desktop.png",
  });
```

Run the diff for each breakpoint (mobile, tablet, desktop).

Categorize every difference found:

| Category       | Example                                                 | Priority  |
| -------------- | ------------------------------------------------------- | --------- |
| **Layout**     | Missing section, wrong column count, incorrect ordering | 🔴 High   |
| **Spacing**    | Padding/margin mismatches, gap differences              | 🟡 Medium |
| **Typography** | Wrong font size, weight, or line height                 | 🟡 Medium |
| **Color**      | Background, text, or border color mismatches            | 🟡 Medium |
| **Component**  | Missing element, wrong variant, missing state           | 🔴 High   |
| **Responsive** | Breakpoint behavior differs                             | 🟡 Medium |
| **Polish**     | Border radius, shadows, transitions, hover effects      | 🟢 Low    |

---

## Phase 2: Spec Extraction

Compile everything from Phase 1 into a structured spec document.

### Tailwind Mapping Rules

Always prefer Tailwind's preset scale over arbitrary values. Think of Tailwind's spacing scale like Lego — you snap to the nearest compatible piece rather than cutting custom bricks:

```
Observed pixels → Nearest Tailwind class

4px   → p-1, gap-1, m-1
8px   → p-2, gap-2, m-2
12px  → p-3, gap-3, m-3
16px  → p-4, gap-4, m-4
20px  → p-5, gap-5, m-5
24px  → p-6, gap-6, m-6
32px  → p-8, gap-8, m-8
40px  → p-10
48px  → p-12
64px  → p-16
80px  → p-20
96px  → p-24

Font sizes:
12px → text-xs
14px → text-sm
16px → text-base
18px → text-lg
20px → text-xl
24px → text-2xl
30px → text-3xl
36px → text-4xl

Border radius:
2px → rounded-sm
4px → rounded
6px → rounded-md
8px → rounded-lg
12px → rounded-xl
16px → rounded-2xl
```

If an observed value falls between two Tailwind steps, pick the **nearest** step. Only use arbitrary values `[Xpx]` when the design clearly requires an exact non-standard value and rounding would be visibly wrong.

### Spec Document Structure

Write the spec to `.agent/cloner/{slug}/spec.md`:

```markdown
# UI Spec: {page/section name}

Source: {target_url}
Date: {today}
Framework: {SvelteKit|Next.js}
Styling: {Tailwind + any component library}

## Design Tokens

### Colors

- Primary: #XXXX → closest Tailwind or custom theme value
- Background: ...
- Text: ...

### Typography

- Heading 1: text-4xl font-bold leading-tight
- Body: text-base leading-relaxed
- ...

### Spacing Pattern

- Section padding: py-16 px-4 md:px-8 lg:px-16
- Card gap: gap-6
- ...

## Sections (top to bottom)

### 1. {Section Name}

- **Layout**: flex flex-col md:flex-row gap-8
- **Content**: [describe what's in this section]
- **Components needed**: [list]
- **Responsive**: [how it changes across breakpoints]
- **Notes**: [any interactive behavior observed]

### 2. {Section Name}

...

## Component Inventory

| Component        | Exists? | Needs Changes?        | New?   |
| ---------------- | ------- | --------------------- | ------ |
| Button (primary) | ✅      | border-radius differs |        |
| PricingCard      |         |                       | ✅ New |
| ...              |         |                       |        |

## Differences from Dev (if comparison mode)

[Paste categorized diff results from Phase 1 Step 5]
```

---

## Phase 3: Implementation Plan

Working backwards from the finished UI to the code changes needed.

### Plan Structure

Write the plan to `.agent/plans/{slug}-ui-clone.md`:

```markdown
# Implementation Plan: {page/section name}

Source: {target_url}
Spec: .agent/cloner/{slug}/spec.md
Screenshots: .agent/cloner/{slug}/

## Goal

Pixel-perfect recreation of {target} in {framework} using {styling approach}.

## Prerequisites

- [ ] Any new dependencies to install
- [ ] Any Tailwind config changes needed (custom colors, fonts, etc.)
- [ ] Any shared components or utilities to create first

## Tasks (ordered by dependency, highest priority first)

### Task 1: {Component/Section Name}

**Priority**: 🔴 High
**Files**:

- Create: `src/lib/components/PricingCard.svelte`
- Modify: `src/routes/pricing/+page.svelte`

**Spec**:

- Layout: grid grid-cols-1 md:grid-cols-3 gap-8
- Card: rounded-xl border border-gray-200 p-8 shadow-sm
- Heading: text-2xl font-bold text-gray-900
- Price: text-4xl font-bold + text-base text-gray-500 for period
- Features: space-y-3, each with a check icon + text-sm
- CTA button: w-full py-3 rounded-lg bg-blue-600 text-white font-medium

**Responsive**:

- Mobile: single column, full width cards
- Tablet: 2 columns (third card spans or stacks)
- Desktop: 3 columns equal width

**Interactive states**:

- Hover on card: shadow-md transition-shadow
- Hover on CTA: bg-blue-700
- Popular card: ring-2 ring-blue-600 relative with badge

### Task 2: ...

### Task 3: ...

## Verification Strategy

After implementation, capture screenshots at all three breakpoints and run
ui_diff_check against the target screenshots to verify accuracy.

## Estimated Scope

- New components: X
- Modified files: Y
- Complexity: Low / Medium / High
```

### Plan Quality Checklist

Before saving the plan, verify:

- [ ] Every task lists exact files to create or modify
- [ ] Tailwind classes are specified (not vague descriptions like "big text")
- [ ] Responsive behavior is defined per breakpoint per task
- [ ] Interactive states are noted even though screenshots can't capture them
- [ ] Tasks are ordered so dependencies come first
- [ ] Each task is small enough for a single commit (Ralph loop compatible)
- [ ] Prerequisites (config changes, shared components) are listed as early tasks

---

## Phase 4: Verification Loop

After implementation (either manual or via Ralph loop), verify the result:

```typescript
// 1. Capture the new dev state
mcp__agent_browser__browser_navigate({ url: devUrl });
mcp__agent_browser__browser_screenshot({
  path: ".agent/cloner/{slug}/verify/verify-{breakpoint}.png",
  fullPage: true,
});

// 2. Diff against target
mcp__zai -
  mcp -
  server__ui_diff_check({
    image_path_1: ".agent/cloner/{slug}/target/target-desktop.png",
    image_path_2: ".agent/cloner/{slug}/verify/verify-desktop.png",
  });

// 3. If differences remain, append fix tasks to the plan
```

Repeat until the diff reports no significant visual differences.

---

## File Structure

```
project-root/
├── .agent/
│   ├── cloner/
│   │   └── {slug}/
│   │       ├── target/
│   │       │   ├── target-mobile.png
│   │       │   ├── target-tablet.png
│   │       │   └── target-desktop.png
│   │       ├── dev/              (comparison mode only)
│   │       │   ├── dev-mobile.png
│   │       │   ├── dev-tablet.png
│   │       │   └── dev-desktop.png
│   │       ├── verify/           (post-implementation)
│   │       │   ├── verify-mobile.png
│   │       │   ├── verify-tablet.png
│   │       │   └── verify-desktop.png
│   │       └── spec.md
│   └── plans/
│       └── {slug}-ui-clone.md
```

## Quick Reference: Tool Cheat Sheet

| Task                    | Tool          | MCP Call                                        |
| ----------------------- | ------------- | ----------------------------------------------- |
| Open a URL              | agent-browser | `browser_navigate({ url })`                     |
| Get DOM tree            | agent-browser | `browser_snapshot()`                            |
| Take screenshot         | agent-browser | `browser_screenshot({ path, fullPage })`        |
| Get page text           | agent-browser | `browser_get_text()`                            |
| Resize viewport         | agent-browser | `browser_resize({ width, height })`             |
| Scroll to element       | agent-browser | `browser_scroll({ direction, amount })`         |
| Analyze UI screenshot   | zai-vision    | `ui_to_artifact({ image_path, artifact_type })` |
| Extract text from image | zai-vision    | `extract_text_from_screenshot({ image_path })`  |
| Compare two screenshots | zai-vision    | `ui_diff_check({ image_path_1, image_path_2 })` |
| General image analysis  | zai-vision    | `image_analysis({ image_path, prompt })`        |
| Analyze diagram/chart   | zai-vision    | `understand_technical_diagram({ image_path })`  |

## Common Pitfalls

- **Don't skip codebase exploration** — you need to know the existing patterns before planning. Building a house extension without checking the existing foundations is asking for trouble.
- **Don't use arbitrary Tailwind values by default** — always map to the nearest preset value first. Only use `[Xpx]` when rounding would be visibly wrong.
- **Don't capture only desktop** — responsive behavior is where most drift happens. Always capture all three breakpoints.
- **Don't forget interactive states** — screenshots only show one state. Note buttons, links, dropdowns, and forms that will need hover/focus/active/disabled styles.
- **Don't create a monolithic plan** — break into task-per-component chunks so a Ralph loop can work through them one at a time, each with a clean commit.
- **Don't hallucinate colors or spacing** — use zai-vision to extract actual values. If you can't determine an exact value, note it as "needs manual verification" rather than guessing

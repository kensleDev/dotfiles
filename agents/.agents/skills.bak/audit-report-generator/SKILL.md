---
name: audit-report-generator
description: Generate polished, self-contained HTML audit reports from business-info and google-business-profile-audit output. Produces a single HTML file with client-facing and internal views, visual score cards, and print-to-PDF support. Use after running both prior skills when you want a professional deliverable. Triggers include "generate a report", "create an audit report", "make a smart report", "turn this into HTML", or any request for a polished report from audit data.
---

# Audit Report Generator

## Purpose

Takes the two output documents produced by the `business-info` and `google-business-profile-audit` skills and generates a polished, self-contained HTML report. Produces one file with two views: a **client-facing report** (beautiful, visual, actionable) and **internal notes** (scores, risk matrix, evidence quality — hidden behind a toggle).

## When to use

- After running `business-info` and `google-business-profile-audit` on a business
- When both output files exist in the working directory
- When you want a professional deliverable to send to a client or review internally
- The user asks for "a report", "smart report", "polished report", or "HTML report"

## Required inputs

- `business-research-{slug}.md` — raw evidence from the business-info skill
- `audit-output-{slug}.md` — scored audit from the google-business-profile-audit skill

Both files must be present in the current working directory (or supplied paths).

## Workflow

### 1. Locate input files

```bash
ls business-research-*.md audit-output-*.md
```

If multiple matches exist, ask the user which business. If only one pair, use them automatically.

### 2. Read the mapping guide

Load `references/data-mapping.md` — it maps every `{{PLACEHOLDER}}` in the template to where the data lives in the input files.

### 3. Parse both input files

Read both files in full. Extract all structured data following the mapping guide. Key data to extract:

| From research doc | From audit doc |
|-------------------|----------------|
| Business name, type, town, website, GBP link | Executive summary |
| Review count, rating, distribution | Directional scores (5 categories, /10) |
| NAP consistency, hours, photos | Risk level (Low/Medium/High) |
| Review themes, sample reviews | Top 3 opportunities |
| Website/mobile checks | What's working well |
| Directory listings, social media | Priority action plan |
| Risk flags, Companies House, FSA | Quick wins |
| Limitations, sources, metadata | Service offers |

### 4. Load the HTML template

Read `references/report-template.html`. It contains the complete HTML structure, embedded CSS, and `{{PLACEHOLDER}}` markers throughout both the client and internal sections.

### 5. Populate the template

Replace every `{{PLACEHOLDER}}` with the corresponding value extracted from the input files. Follow these rules:

- **Never invent data.** If a value is missing, write "Not checked" or "Unable to confirm" — never guess.
- **Scores** must come from the audit doc (scoring-rubric output). If not present, write "—" and set the corresponding `{{SCORE_BAND_N}}` to `none`.
- **Score bands** — for each of the 5 scores, derive `{{SCORE_BAND_N}}` from `{{SCORE_VALUE_N}}`: `good` (7-10), `mid` (4-6), `low` (0-3), `none` (when value is "—"). The band drives the gauge ring colour via a CSS class (`score-band-good` etc.); the ring fill amount is computed in CSS automatically from the score value — you do not set any width or offset.
- **Table rows** should be formatted as complete `<tr>...</tr>` HTML blocks. Every `<td>` must carry a `data-label` attribute matching its column heading (e.g. `data-label="Element"`, `data-label="Why it matters"`). On mobile, rows stack into labelled cards using these labels; on tablet/desktop and in print, real table layout is restored. Follow the example rows in the data-mapping guide.
- **Multi-platform review rows** — one `<tr>` per platform checked (Facebook, Tripadvisor, Yelp, Yell, Trustpilot, Just Eat, Deliveroo, Uber Eats), with `data-label` attributes matching the column headings (Platform / Reviews / Rating / Last active / Reply activity / Notes). Use `status-good`/`status-warn`/`status-bad` on the reply activity cell (Yes / Partial / No). If a platform had no listing, put "Not found" in Reviews and "—" in the other numeric cells. If blocked, put "Blocked" in Reviews.
- **Review disparity note** — compare each platform's rating to Google's. If any gap exceeds 1.0 star, describe it in plain English with the themes driving the gap. If ratings are consistent (within 0.5 stars), say so. If no other platforms had reviews, say "No other platforms with reviews found."
- **Competitor cards** — fill the 5 fields per competitor (name, rating, reviews, distance, note) from the research doc. The rating uses the ★ symbol in the template (no "/5" suffix — just the number). The note is one line, observational, not analytical. If fewer than 3 competitors were found, fill the available cards and put "No other competitors found in the area" in the remaining card's name field with empty stats.
- **Competitor benchmark** — compute the average of the competitors' review counts and ratings, compare to the subject's, and write 1-2 sentences in plain English stating whether the subject is ahead, behind, or level on both metrics. Cite both numbers (e.g. "Your 147 reviews sit above the local average of 95..."). If fewer than 3 competitors were found, average whatever was found and note the small sample.
- **Risk level badge** uses CSS class `badge-low`, `badge-medium`, or `badge-high`. The badge now also appears on the cover alongside the risk label.
- **Multi-line text** (executive summary, main issue paragraphs, etc.) can contain basic HTML tags (`<p>`, `<strong>`, `<em>`) but keep it simple.
- **List items** should be `<li>...</li>` elements.
- **The internal notes section** is hidden by default via CSS class `hidden`. The toggle button shows/hides it.

### 6. Write the output file

```bash
# Output: audit-report-{slug}.html in the working directory
```

The output file is completely self-contained — all CSS and JS are inline. It opens in any browser and prints cleanly to PDF (Chrome > Print > Save as PDF, or Cmd+P).

### 7. Verify (optional)

Open the file in a browser to check layout. Use print preview to verify the PDF output looks clean. The print stylesheet hides buttons, removes shadows, and optimizes page breaks.

## Output

A single file: `audit-report-{business-name-slug}.html`

The slug is derived from the business name (lowercase, hyphens).

## Tone and style rules (same as parent skills)

- UK English
- Plain English — no jargon, no marketing waffle
- Practical and calm
- No "AI bro" language, no hype
- Assume the reader is a non-technical small business owner
- Never guarantee rankings, leads, or outcomes
- Never recommend keyword-stuffing, fake reviews, or duplicate profiles

## Report sections

### Client-facing (visible by default)

1. **Cover** — business name, type, location, date, report title
2. **Executive summary** — 2-3 sentence plain-English summary
3. **Score snapshot** — 5 visual score bars + risk level badge
4. **What's working well** — green callout, 3-5 bullets
5. **Local competitive context** — 3 competitor cards + "how you compare" benchmark callout
6. **3 biggest opportunities** — numbered cards, issue → fix
7. **Findings** — 4 collapsible accordion sections:
   - Google Business Profile (status table + narrative)
   - Reviews & Trust (status table + narrative + review quotes)
   - Website & Mobile Journey (status table + narrative)
   - Contact & Ordering Flow (status table + narrative)
8. **Priority action plan** — ranked table (Priority | Fix | Why it matters | Effort | Who)
9. **Quick wins** — checkbox list
10. **Optional service offer** — 4 option cards
11. **Notes & limitations** — standard caveats

### Internal (hidden behind toggle)

11. **Evidence quality** — data completeness %, sources count
12. **Risk matrix** — table of all risk flags with severity
13. **Multi-platform review snapshot** — comparison table across Facebook, Tripadvisor, Yelp, Yell, Trustpilot, and food-delivery sites + rating disparity callout
14. **Missing evidence** — what could not be checked
15. **Manual checks needed** — what requires physical verification
16. **Research metadata** — sources table, tools used, limitations

## Connection to pipeline

This is the final step in the three-skill audit pipeline:

```
business-info → business-research-{slug}.md
       ↓
google-business-profile-audit → audit-output-{slug}.md
       ↓
audit-report-generator → audit-report-{slug}.html  ← YOU ARE HERE
```

## Reference files

- `references/report-template.html` — Self-contained HTML template with embedded CSS, JS, and all `{{PLACEHOLDER}}` markers for both client and internal views.
- `references/data-mapping.md` — Complete mapping of every template placeholder to its source field in the input documents, with extraction instructions.

# Data Mapping Guide

Maps every `{{PLACEHOLDER}}` in `report-template.html` to the source field in the input documents.

## Source file legend

- **R** = `business-research-{slug}.md` (from business-info skill)
- **A** = `audit-output-{slug}.md` (from google-business-profile-audit skill)
- **SYNTH** = Synthesize from both — use best available data

---

## Business info placeholders

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{BUSINESS_NAME}}` | R: Research Summary > Business name | Use the primary/Maps-listed name. If inconsistent, use the FSA or most common variant. |
| `{{BUSINESS_TYPE}}` | R: Research Summary > Business type | Clean up: "Takeaway — Pizza, Kebabs, Burgers" or similar |
| `{{TOWN}}` | R: Research Summary > Town/city | Include county if relevant |
| `{{WEBSITE_URL}}` | R: Research Summary > Website | Full URL |
| `{{DATE}}` | A: Business reviewed > Date of audit | Fallback: today's date |
| `{{GBP_LINK}}` | R: Research Summary > Google Maps link | Full URL |
| `{{REVIEW_COUNT}}` | R: Reviews > Review count | Primary Google review count |
| `{{AVERAGE_RATING}}` | R: Reviews > Average rating | Format as "X.X/5" |

---

## Executive summary

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{EXECUTIVE_SUMMARY}}` | A: Executive summary | Use the paragraph from the client-facing report. May contain `<strong>` tags. |

---

## Score snapshot

Each score produces **two** placeholders: a value and a band. The band drives the gauge ring colour via a CSS class.

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{SCORE_LABEL_1}}` | SYNTH | "Profile Accuracy" |
| `{{SCORE_VALUE_1}}` | A: Scorecard section (Internal) or synthesised from findings | Number 0-10, or "—" if insufficient evidence |
| `{{SCORE_BAND_1}}` | SYNTH from `{{SCORE_VALUE_1}}` | `good` (7-10), `mid` (4-6), `low` (0-3), or `none` (when value is "—") |
| `{{SCORE_LABEL_2}}` | SYNTH | "Profile Completeness" |
| `{{SCORE_VALUE_2}}` | A: Scorecard section | Number 0-10, or "—" |
| `{{SCORE_BAND_2}}` | SYNTH | `good` / `mid` / `low` / `none` |
| `{{SCORE_LABEL_3}}` | SYNTH | "Review System" |
| `{{SCORE_VALUE_3}}` | A: Scorecard section | Number 0-10, or "—" |
| `{{SCORE_BAND_3}}` | SYNTH | `good` / `mid` / `low` / `none` |
| `{{SCORE_LABEL_4}}` | SYNTH | "Mobile Journey" |
| `{{SCORE_VALUE_4}}` | A: Scorecard section | Number 0-10, or "—" |
| `{{SCORE_BAND_4}}` | SYNTH | `good` / `mid` / `low` / `none` |
| `{{SCORE_LABEL_5}}` | SYNTH | "Contact Flow" |
| `{{SCORE_VALUE_5}}` | A: Scorecard section | Number 0-10, or "—" |
| `{{SCORE_BAND_5}}` | SYNTH | `good` / `mid` / `low` / `none` |
| `{{RISK_LEVEL}}` | A: Internal > Risk flags > Overall risk level | "Low", "Medium", or "High" |
| `{{RISK_CLASS}}` | SYNTH from {{RISK_LEVEL}} | "low", "medium", or "high" (lowercase, for CSS class) |

### Score band rules

Derive `{{SCORE_BAND_N}}` from `{{SCORE_VALUE_N}}`:

| Score value | Band | Gauge colour |
|-------------|------|--------------|
| 7-10 | `good` | green |
| 4-6 | `mid` | amber |
| 0-3 | `low` | red |
| "—" (no evidence) | `none` | grey (ring hidden) |

The gauge ring fill is computed in CSS from the score value (`stroke-dashoffset: calc(circumference * (1 - value/10))`). You do **not** set any width or offset yourself — just put the raw number in `{{SCORE_VALUE_N}}` and the band class in `{{SCORE_BAND_N}}`.

If scores are not present in the audit doc, derive them from the scoring-rubric descriptions using available evidence. Never invent a score — use "—" with band `none` if insufficient evidence.

---

## What's working well

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{WORKING_WELL_ITEMS}}` | A: What is working well | Format as `<li>...</li>` items. 3-5 bullets. |

---

## 3 biggest opportunities

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{OPPORTUNITY_1_TITLE}}` | A: The 3 biggest opportunities > #1 | Issue title |
| `{{OPPORTUNITY_1_FIX}}` | A: The 3 biggest opportunities > #1 | Fix description |
| `{{OPPORTUNITY_2_TITLE}}` | A: The 3 biggest opportunities > #2 | Issue title |
| `{{OPPORTUNITY_2_FIX}}` | A: The 3 biggest opportunities > #2 | Fix description |
| `{{OPPORTUNITY_3_TITLE}}` | A: The 3 biggest opportunities > #3 | Issue title |
| `{{OPPORTUNITY_3_FIX}}` | A: The 3 biggest opportunities > #3 | Fix description |

---

## Local competitive context

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{COMPETITOR_1_NAME}}` | R: Local competitors > Competitor 1 > Name | Business name |
| `{{COMPETITOR_1_RATING}}` | R: Local competitors > Competitor 1 > Google rating | Format as "X.X" (no /5 — the ★ symbol implies /5) |
| `{{COMPETITOR_1_REVIEWS}}` | R: Local competitors > Competitor 1 > Review count | Number only |
| `{{COMPETITOR_1_DISTANCE}}` | R: Local competitors > Competitor 1 > Distance from subject | e.g. "0.3 miles away" |
| `{{COMPETITOR_1_NOTE}}` | R: Local competitors > Competitor 1 > What they do differently | One line, plain English, observational |
| `{{COMPETITOR_2_NAME}}` | R: Local competitors > Competitor 2 > Name | Business name |
| `{{COMPETITOR_2_RATING}}` | R: Local competitors > Competitor 2 > Google rating | Format as "X.X" |
| `{{COMPETITOR_2_REVIEWS}}` | R: Local competitors > Competitor 2 > Review count | Number only |
| `{{COMPETITOR_2_DISTANCE}}` | R: Local competitors > Competitor 2 > Distance from subject | e.g. "0.5 miles away" |
| `{{COMPETITOR_2_NOTE}}` | R: Local competitors > Competitor 2 > What they do differently | One line, observational |
| `{{COMPETITOR_3_NAME}}` | R: Local competitors > Competitor 3 > Name | Business name |
| `{{COMPETITOR_3_RATING}}` | R: Local competitors > Competitor 3 > Google rating | Format as "X.X" |
| `{{COMPETITOR_3_REVIEWS}}` | R: Local competitors > Competitor 3 > Review count | Number only |
| `{{COMPETITOR_3_DISTANCE}}` | R: Local competitors > Competitor 3 > Distance from subject | e.g. "1.2 miles away" |
| `{{COMPETITOR_3_NOTE}}` | R: Local competitors > Competitor 3 > What they do differently | One line, observational |
| `{{COMPETITOR_BENCHMARK}}` | SYNTH from R: Local competitors > Benchmark calculation + A: Internal > Local competitors | 1-2 sentences comparing the subject's review count and rating to the local average of the 3 competitors. State whether the subject is ahead, behind, or level on both metrics. Cite both numbers. e.g. "Your 147 reviews sit above the local average of 95, and your 4.6 rating edges out the 4.4 local average. You're the most-reviewed bakery in your immediate area." If behind: "Your 32 reviews are below the local average of 95 — competitors are accumulating reviews faster." If fewer than 3 competitors were found, average whatever was found and note the small sample. |

---

## Findings section: Google Business Profile

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{GBP_TABLE_ROWS}}` | A: Findings > GBP table + R: GBP checks | Format as `<tr><td data-label="Element">Element</td><td data-label="Status" class="status-{good|warn|bad}">Status</td><td data-label="Notes">Notes</td></tr>`. The `data-label` values must match the column headings (Element / Status / Notes). Use status-good for Yes/Positive, status-warn for Partial/Unable to confirm, status-bad for No/Negative. |
| `{{GBP_MAIN_ISSUE}}` | A: Findings > GBP > "The main GBP issue" | Paragraph text |

## Findings section: Reviews & Trust

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{REVIEWS_TABLE_ROWS}}` | A: Findings > Reviews table + R: Reviews | Same row format as GBP table (with `data-label="Element"` / `"Status"` / `"Notes"`) |
| `{{REVIEWS_MAIN_ISSUE}}` | A: Findings > Reviews > "The main review issue" | Paragraph text. May include `<blockquote>` for sample reviews. |

## Findings section: Website & Mobile Journey

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{WEBSITE_TABLE_ROWS}}` | A: Findings > Website table + R: Website checks | Same row format (with `data-label` attributes) |
| `{{WEBSITE_MAIN_ISSUE}}` | A: Findings > Website > "The main website issue" | Paragraph text |

## Findings section: Contact & Ordering Flow

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{CONTACT_TABLE_ROWS}}` | A: Findings > Contact table + R: Website checks | Same row format (with `data-label` attributes) |
| `{{CONTACT_MAIN_ISSUE}}` | A: Findings > Contact > "The main flow issue" | Paragraph text |

---

## Priority action plan

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{ACTION_PLAN_ROWS}}` | A: Priority action plan table | Format as `<tr><td data-label="#">1</td><td data-label="Fix">Fix</td><td data-label="Why it matters">Why</td><td data-label="Effort"><span class="effort effort-{low|medium|high}">Effort</span></td><td data-label="Who">Who</td></tr>`. The `data-label` values must match the column headings (# / Fix / Why it matters / Effort / Who). |

---

## Quick wins

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{QUICK_WIN_ITEMS}}` | A: Quick wins | Format as `<li>...</li>` items |

---

## Service offer

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{OFFER_1_TITLE}}` | A: Service offer > Option A-D titles | Short title |
| `{{OFFER_1_DESC}}` | A: Service offer > Option A-D descriptions | Bullet list, format with `<br>` line breaks or `<ul>` |
| `{{OFFER_2_TITLE}}` | Same pattern | |
| `{{OFFER_2_DESC}}` | Same pattern | |
| `{{OFFER_3_TITLE}}` | Same pattern | |
| `{{OFFER_3_DESC}}` | Same pattern | |
| `{{OFFER_4_TITLE}}` | Same pattern | |
| `{{OFFER_4_DESC}}` | Same pattern | |

---

## Notes & limitations

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{NOTES}}` | A: Notes and limitations | Paragraphs. Format with `<p>` tags. |

---

## Internal notes (hidden section)

| Placeholder | Source | Extraction notes |
|-------------|--------|-----------------|
| `{{EVIDENCE_QUALITY}}` | R: Research Summary > Data completeness | e.g. "High — 45/52 fields found across 17 sources" |
| `{{SOURCES_COUNT}}` | R: Research metadata table | Count of unique source URLs accessed |
| `{{EVIDENCE_SUPPLIED_ITEMS}}` | A: Internal > Evidence supplied | Format as `<li>...</li>` |
| `{{MISSING_EVIDENCE_ITEMS}}` | A: Internal > Missing evidence | Format as `<li>...</li>` |
| `{{MAIN_ISSUES_LIST}}` | A: Internal > Main issues | Format as numbered `<li>...</li>` |
| `{{RISK_MATRIX_ROWS}}` | A: Internal > Risk flags table | Format as `<tr><td data-label="Flag">Flag</td><td data-label="Severity"><span class="badge-{low|medium|high}">Severity</span></td><td data-label="Detail">Detail</td></tr>`. The `data-label` values must match the column headings (Flag / Severity / Detail). |
| `{{MULTI_PLATFORM_REVIEW_ROWS}}` | R: Multi-platform reviews | Format as `<tr><td data-label="Platform">Name</td><td data-label="Reviews">count or "Not found"</td><td data-label="Rating">X.X/5 or "—"</td><td data-label="Last active">date or "—"</td><td data-label="Reply activity" class="status-{good|warn|bad}">Yes/No/Partial/N/A</td><td data-label="Notes">themes, disparity flags, blocked status</td></tr>`. One row per platform checked (Facebook, Tripadvisor, Yelp, Yell, Trustpilot, Just Eat, Deliveroo, Uber Eats). The `data-label` values must match the column headings (Platform / Reviews / Rating / Last active / Reply activity / Notes). Use `status-good` for Yes, `status-warn` for Partial, `status-bad` for No. If a platform had no listing, put "Not found" in Reviews and "—" in Rating/Last active. If blocked, put "Blocked" in Reviews. |
| `{{REVIEW_DISPARITY_NOTE}}` | SYNTH from comparing all platform ratings to Google's | Compare each platform's rating to Google's. If any gap exceeds 1.0 star, describe it in plain English with the themes driving the gap (e.g. "Tripadvisor sits at 3.1 vs Google's 4.6 — the Tripadvisor reviews cite slow service and cold food, themes absent from Google reviews."). If no meaningful disparity, write "Ratings are consistent across platforms (within 0.5 stars)." If no other platforms had reviews, write "No other platforms with reviews found." |
| `{{SOURCES_TABLE_ROWS}}` | R: Research metadata table | Format as `<tr><td data-label="Source">URL</td><td data-label="Data Gathered">Data</td><td data-label="Status">Status</td><td data-label="Timestamp">Timestamp</td></tr>`. The `data-label` values must match the column headings (Source / Data Gathered / Status / Timestamp). Only include the most important 10-15 rows. |
| `{{LIMITATIONS}}` | R + A: Limitations sections | Combined limitations paragraphs. Format with `<p>` tags. |

---

## Risk badge CSS classes

Use these CSS classes for risk level badges:

| Level | Class |
|-------|-------|
| Low | `badge-low` |
| Medium | `badge-medium` |
| High | `badge-high` |

## Score band CSS classes (for gauge rings)

Use these classes on the gauge `<div>` alongside `score-band-` prefix. The class sets the ring and number colour.

| Band | Class | Score range |
|------|-------|-------------|
| Good | `score-band-good` | 7-10 |
| Mid | `score-band-mid` | 4-6 |
| Low | `score-band-low` | 0-3 |
| No data | `score-band-none` | "—" (ring hidden, number grey) |

## Responsive table rows (`data-label`)

Every `<td>` in a `table.responsive` **must** carry a `data-label` attribute matching its column heading. On mobile, rows stack into labelled cards and each cell shows its `data-label` as a small uppercase caption above the value. On tablet/desktop and in print, real table layout is restored and the `data-label` is hidden.

The `data-label` value must match the corresponding `<th>` text exactly (e.g. `data-label="Why it matters"`, not `data-label="Why"`).

## Status CSS classes (for table cells)

Use these classes on `<td>` elements:

| Status | Class | Example values |
|--------|-------|---------------|
| Good/Yes | `status-good` | "Yes", "Good", "Present" |
| Warning/Partial | `status-warn` | "Partially", "Unable to confirm", "Not checked" |
| Bad/No | `status-bad` | "No", "Not found", "Missing" |

## Effort CSS classes (for action plan)

Use these classes on `<span>` elements:

| Level | Class |
|-------|-------|
| Low | `effort-low` |
| Medium | `effort-medium` |
| High | `effort-high` |

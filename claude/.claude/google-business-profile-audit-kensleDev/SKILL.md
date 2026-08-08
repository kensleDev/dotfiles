---
name: google-business-profile-audit
description: Generate editable, evidence-led local business audit reports for Google Business Profile, website, reviews, and customer journey. For UK local businesses (takeaways, pubs, barbers, tradespeople, gyms, cafes, small shops). Automatically looks up GBP details via webfetch — no manual evidence collection needed. Produces internal analysis, client-facing report, follow-up message, and optional service offer, written to ./audits/{business-name}/. Evidence-led: never invents facts. Avoids risky GBP/review advice.
---

# Google Business Profile Audit

## Purpose

Generate a practical, client-friendly audit report for a local UK business. The report covers their Google Business Profile (GBP), website, reviews, contact flow and customer journey.

**This skill does not invent facts.** Every finding must be backed by evidence gathered from the web. Where evidence is missing, say so — never guess.

## When to use this skill

- A user asks for a "GBP audit", "local business audit", "Local Biz Fix report", or similar
- A user provides a business name and town/city (e.g. "audit Green Lane Barbers in Leeds")
- A user wants to generate a client-facing report from live web data

## Required inputs

- **Business name**
- **Town/city**
- Website URL (strongly recommended — the skill will try to find it if not provided)
- Google Business Profile link (optional — the skill will attempt to find it via search if not provided)

## Optional inputs

- Business type (takeaway, pub, barber, tradesperson, gym, cafe, small shop, other)
- Owner's stated goal (more calls, bookings, reviews, etc.)
- Budget or price point for done-for-you work (the skill will not assume a price)

## Workflow

1. **Extract business info.** Take the business name and town/city from the user prompt. Do not ask the user to confirm — instead, search online to verify and find missing details. If website or GBP link not provided, you will search for them in step 2.

2. **Fetch live data.** Immediately use webfetch to gather evidence. Run these search strategies. Start with the first batch in parallel, then fall back to later batches only if earlier searches return nothing useful:

   **Batch 1 — run in parallel first:**
   - `"[business name]" "[town/city]"` — exact phrase search for GBP panel data
   - `[business name] [town/city]` — same without quotes (broader match for partial names, postcodes like "LS9")
   - `"[business name]" [business type] [town/city]` — add the business type if known

   **Batch 2 — run if batch 1 fails (business names often differ from what people type):**
   - Try adding "The" prefix (e.g. "Famous" → "The Famous"). Many UK businesses use "The" in their official name but drop it from signage — this is a common mismatch.
   - Try removing "The" prefix (e.g. "The Crown" → "Crown")
   - Try the business name with just the postcode area (e.g. "Famous LS9" or "The Famous LS9")
   - Try common spelling variations or name-splitting (e.g. "Greenlane" vs "Green Lane")

   **Batch 3 — broad search if nothing found yet:**
   - `[town/city] [business type]` — search the area and type alone
   - Search just the postcode area with the business type (e.g. "LS9 takeaway")

   Also fetch:
   - Google Maps place page for the business, if findable from search results
   - The business website — extract contact info, services, about page, mobile usability signals

   Record what was found and what could not be confirmed from the web.

3. **Run the checklist.** Use `references/audit-checklist.md` to assess completeness against the evidence gathered.

4. **Score directionally.** Use `references/scoring-rubric.md` for a rough score — these are directional, not definitive.

5. **Check for risk flags.** Use `references/policy-and-risk-notes.md`. Flag anything risky. Do not recommend risky fixes.

6. **Identify the 3 biggest opportunities.** Focus on practical impact for the business owner.

7. **Generate outputs** (see Output format below).

8. **Review against risk rules** before finalising.

9. **Write output files.** Write all sections to `./audits/{business-name-kebab-case}/`. Create the `./audits/` directory if it does not exist. Use the business name slugified to kebab-case for the subdirectory (e.g. "Green Lane Barbers" → `./audits/green-lane-barbers/`).

**Important — no questions after the initial prompt:** Do not ask the user to confirm the business name, spelling, location, website, or any other detail. Search online to verify everything yourself. Use the batched search strategy above — the most common reason a search fails is that the user omitted or included "The" when the real name has/drops it (e.g. someone searches "Famous takeaway LS9" but the real listing is "The Famous"). Also try by postcode area, by business type, and with spelling variants. Only ask the user if every batch returns zero results (i.e. the business genuinely cannot be found online at all). Mark anything else unfindable or blocked as "Unable to confirm from web" and move on. Complete the full audit using whatever webfetch returns.

## Evidence rules

If evidence is missing or unclear for any finding, write one of:

- `Unable to confirm from web`
- `Needs manual verification`

Never invent scores, review counts, website performance data, or customer behaviour.

Never assume the business owner's intent unless they have stated it.

If webfetch returns data (review count, rating, hours, address, etc.), use it as evidence. If blocked, incomplete, or unavailable, mark as "Unable to confirm from web" and continue. Do not ask the user for additional information.

## Tone and style rules

- UK English
- Plain English — no jargon, no marketing waffle
- Practical and calm — like a helpful consultant, not a sales pitch
- No "AI bro" language, no hype, no corporate-speak
- Assume the reader is a non-technical small business owner
- Example tone: "The main issue is not that the website looks bad. The issue is that a mobile customer has to work too hard to call, order or book."

## What the report must never claim

- Guaranteed Google ranking improvements
- "Number 1 on Google"
- Guaranteed leads, bookings or sales
- Guaranteed review increases
- Guaranteed AI automation outcomes

## Risk rules: never recommend

See `references/policy-and-risk-notes.md` for full details. Key prohibitions:

- Keyword-stuffing the business name
- Creating duplicate profiles
- Fake reviews
- Incentivised reviews
- Only asking happy customers for reviews
- Pressuring customers to leave specific wording
- Misleading categories
- Fake addresses
- Scraping private/admin data
- Pretending to be the business owner without permission

## Safe recommendations

- Use the real-world business name
- Check opening hours and special hours
- Ensure phone, website and address are correct
- Choose accurate primary and secondary categories
- Add useful, recent photos
- Keep services/menu/product info clear and up to date
- Reply politely to all reviews (positive and negative)
- Ask genuine customers for reviews using a direct link or QR code, without incentives
- Improve the website/customer journey
- Make call/book/order/contact actions easier on mobile

## Output format

Generate these sections and write each as a separate file in `./audits/{business-name-kebab-case}/`. Create the `./audits/` directory if it does not exist. Use the business name slugified to kebab-case for the subdirectory (e.g. "Green Lane Barbers" → `./audits/green-lane-barbers/`).

```
./audits/{business-name}/
  ├── internal-audit-notes.md
  ├── client-facing-report.md
  ├── follow-up-message.md
  ├── optional-service-offer.md
  └── content-idea.md              (optional)
```

### 1. File: `internal-audit-notes.md`

```
# Internal Audit Notes

## Evidence gathered from web

## Unable to confirm from web

## Manual checks needed

## Main issues

## Risk flags

## Suggested priorities
```

### 2. File: `client-facing-report.md`

Use `references/report-template.md` as the base. Polish it for the specific business.

### 3. File: `follow-up-message.md`

A short, friendly message the business owner can copy and send.

### 4. File: `optional-service-offer.md`

A small, fixed-scope offer based on the findings. Do not include a price unless the user supplies one.

### 5. File: `content-idea.md` (optional)

An anonymised YouTube or short-form content idea inspired by the audit pattern (not naming the actual business).

## Service positioning

### Free lead magnet

**Free 3-Point Local Business Visibility Audit**
- 3 issues
- 3 quick fixes
- 1 suggested next step

### Paid audit

**Google Business Profile + Enquiry Flow Audit**
- Detailed report
- Screenshot/evidence references
- Priority fixes
- Review request system suggestion
- Website/contact flow notes

### Done-for-you fix pack

**Local Business Fix Pack** — possible inclusions:
- Profile cleanup guidance
- Review link/QR setup
- Review reply templates
- Website CTA/contact form improvements
- Simple follow-up email/message flow
- Basic landing page/customer journey recommendations

## Reference files

- `references/audit-input-schema.md` — What evidence the skill gathers via webfetch (also usable as a manual checklist)
- `references/audit-checklist.md` — Practical checklist organised by section
- `references/report-template.md` — Reusable client-facing report template
- `references/scoring-rubric.md` — Simple directional scoring system
- `references/policy-and-risk-notes.md` — Safe vs. risky recommendations
- `references/example-report.md` — Fictional example report (Green Lane Barbers, Leeds)

<!--
PROGRESSIVE DISCLOSURE GUIDELINES:
- Keep this file ~50-150 lines
- This is Level 2 — quick reference and workflow
- Detailed docs live in references/ (Level 3)
- Level 1 is the description in YAML frontmatter
-->

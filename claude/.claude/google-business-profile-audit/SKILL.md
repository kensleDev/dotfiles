---
name: google-business-profile-audit
description: Generate editable, evidence-led local business audit reports for Google Business Profile, website, reviews, and customer journey. For UK local businesses (takeaways, pubs, barbers, tradespeople, gyms, cafes, small shops). Produces internal analysis, client-facing report, follow-up message, and optional service offer. Evidence-led: never invents facts. Avoids risky GBP/review advice.
---

# Google Business Profile Audit

## Purpose

Generate a practical, client-friendly audit report for a local UK business. The report covers their Google Business Profile (GBP), website, reviews, contact flow and customer journey.

**This skill does not invent facts.** Every finding must be backed by supplied evidence. Where evidence is missing, say so — never guess.

## When to use this skill

- A user supplies structured audit input for a local business
- A user asks for a "GBP audit", "local business audit", "Local Biz Fix report", or similar
- A user wants to generate a client-facing report from manually collected evidence

## Required inputs

- Completed `audit-input-schema.md` data (structured evidence)
- At minimum: business name, business type, town/city, and one area of concern

## Optional inputs

- Screenshot descriptions or file references
- Owner's stated goal (more calls, bookings, reviews, etc.)
- Budget or price point for done-for-you work (the skill will not assume a price)

## Workflow

1. **Read the evidence.** Load the structured input. Identify what is present and what is missing.
2. **Run the checklist.** Use `references/audit-checklist.md` to assess completeness.
3. **Score directionally.** Use `references/scoring-rubric.md` for a rough score — these are directional, not definitive.
4. **Check for risk flags.** Use `references/policy-and-risk-notes.md`. Flag anything risky. Do not recommend risky fixes.
5. **Identify the 3 biggest opportunities.** Focus on practical impact for the business owner.
6. **Generate outputs** (see Output format below).
7. **Review against risk rules** before finalising.

## Evidence rules

If evidence is missing or unclear for any finding, write one of:

- `Not checked`
- `Unable to confirm from supplied evidence`
- `Needs manual verification`

Never invent scores, review counts, website performance data, or customer behaviour.

Never assume the business owner's intent unless they have stated it.

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

When the skill is used, generate these five sections as editable Markdown:

### 1. Internal Audit Notes

```
# Internal Audit Notes

## Evidence supplied

## Missing evidence

## Manual checks needed

## Main issues

## Risk flags

## Suggested priorities
```

### 2. Client-Facing Report

Use `references/report-template.md` as the base. Polish it for the specific business.

### 3. Follow-Up Message

A short, friendly message the business owner can copy and send.

### 4. Optional Service Offer

A small, fixed-scope offer based on the findings. Do not include a price unless the user supplies one.

### 5. Content Idea (optional)

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

- `references/audit-input-schema.md` — Structured input format for manual evidence collection
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

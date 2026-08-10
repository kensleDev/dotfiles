---
name: business-info
description: Research and gather business information from a Google Maps link. Use when the user provides a Google Maps URL and wants structured business data (name, address, phone, website, categories, hours, reviews, photos, risk flags) to populate the google-business-profile-audit skill. Triggers include "research this business", "gather info from this Maps link", "scrape Google Maps listing", "get business details for audit", or any task involving a maps.google.com / goo.gl/maps URL.
---

# Business Info Research

## Overview

Takes a Google Maps link and gathers as much publicly available structured business data as possible, outputting it in a format that feeds directly into the `google-business-profile-audit` skill.

**This skill does not invent facts.** Every finding must be backed by a live source. Where data cannot be found, mark it `[NOT FOUND]`. Where human verification is required, mark it `[MANUAL]`. Never guess.

## Quick start

Load the `agent-browser` skill, then follow the 4-phase workflow below. Use `references/output-schema.md` as the output template — fill it in as you go.

## Workflow

### Phase 1: Parse the Google Maps URL

Extract from the URL:
- **Place ID** (e.g. `ChIJ...` from `!1s` parameter or `place/` path)
- **Business name** (from the URL path slug or `q=` parameter)
- **Query string** if present

If the URL is a short link (`goo.gl/maps/...`), resolve it first with WebFetch to get the canonical URL.

### Phase 2: Scrape the Google Maps listing

Load the `agent-browser` skill, then navigate to the Maps URL. Extract every visible field:

**Identity and contact:**
- Business name as displayed on the listing
- Address (full, as shown)
- Phone number
- Website link (the URL behind the "Website" button)
- Primary category
- Secondary categories (if shown)
- Whether the address is a full address or "service area only"
- Service area description (if applicable)

**Hours:**
- Opening hours for each day
- Special/holiday hours (if shown)
- "Open now" status

**Content:**
- Business description text
- Services / products / menu listed
- Attributes (wheelchair access, Wi-Fi, etc.)
- Q&A section content
- Recent posts or updates (with dates)

**Reviews:**
- Total review count
- Average star rating
- Recent reviews (scroll to load ~10-20, note the text and rating)
- Common themes appearing across reviews
- Review reply presence (does the owner reply?)
- Any suspicious review patterns (sudden spikes, copy-paste language)

**Photos:**
- Approximate photo count
- Photo recency (look for upload dates)
- Photo variety (interior, exterior, team, work examples)
- Whether cover photo and logo are set

**Risk flags:**
- Does the business name contain keywords beyond the real trading name?
- Any sign of duplicate profiles?
- Category looks appropriate for the business type?
- Any mention of "get a discount for a review" in posts or description?

**Navigation tip:** Google Maps loads content dynamically on scroll. Scroll through each section (Info, Reviews, Photos) methodically. If content is behind a click (e.g. "Show more"), click to expand before extracting.

**Local competitors (after scraping the subject listing):**

Search Google Maps for `"[business type] in [town]"` and note the top 3 businesses in the local pack (excluding the subject business itself). For each competitor, click through to their GBP listing briefly and note:

- Business name
- Distance from the subject (e.g. "0.3 miles" or "Same street")
- Google rating and review count
- One observational line on what they do differently (e.g. "replies to every review", "no website listed", "open later", "has online ordering", "more photos than the subject"). Keep it factual — do not analyse.

If the local pack doesn't surface 3 competitors, try the wider map search results. If fewer than 3 competitors exist in the area, note how many were found.

### Phase 3: Visit the website

If a website URL was found in Phase 2, navigate to it with `agent-browser`. Set a mobile viewport (e.g. 375x812) to check mobile rendering.

**Check:**
- Does the site load? Is it reachable?
- Is the phone number visible on the mobile homepage without scrolling?
- Is the phone number a clickable `tel:` link?
- Is there a clear CTA (Call Now, Book Online, Order Here) above the fold?
- Is the contact form present? (Cannot test submission — mark `[MANUAL]`)
- Is a menu, services list, or pricing visible?
- How fast does the page load?
- Are there trust signals (review carousel, trade body logos, certifications, about page)?
- Any obvious broken links or missing pages?
- Does the contact info on the site match what was found on the GBP listing?
- Any accessibility issues (tiny text, low contrast)?

**Fallback:** If `agent-browser` cannot load the site (bot blocking, redirect loops), use `WebFetch` to get the raw HTML and extract what you can from the text content.

### Phase 4: Web search for additional data

Beyond Google Maps and the business website, search for:

**Directory listings:**
- Search for `"[business name]" "[town]"` on Yell, Yelp, Facebook, Tripadvisor
- Check for duplicate GBP profiles by searching the business name and address
- Note any inconsistent NAP (name, address, phone) across directories

**Social media:**
- Search for the business on Instagram, Facebook, Twitter/X, LinkedIn, TikTok
- Look for the business name + town on each platform

**Multi-platform reviews (internal notes only):**

Gather review snapshots from every platform where the business has a listing. This data feeds the internal notes section of the audit report — it does not appear in the client-facing report.

Always check these platforms:
- Facebook
- Tripadvisor
- Yelp
- Yell
- Trustpilot

Also check these if the business type is takeaway, restaurant, cafe, bakery, or food-related:
- Just Eat
- Deliveroo
- Uber Eats

For each platform:
1. Search for the business listing (`"[business name]" "[town]" site:platform.com` or via the platform's own search)
2. If a listing is found, navigate to it with `agent-browser` and extract:
   - Review count
   - Average rating
   - Last activity date (most recent review date, or "stale" if older than 6 months)
   - 3-5 recent review snippets (short quotes, with star rating)
   - 1-2 themes (common praise or complaints)
   - Reply activity (Yes / No / Partial — does the owner respond to reviews?)
3. If no listing is found, mark `[NOT FOUND]`
4. If the platform blocks scraping (anti-bot wall, login required), mark `[NOT FOUND — blocked]` or `[NOT FOUND — login required]` and note it in Limitations

**Navigation tip:** Some platforms show reviews behind a "Read more" link or in a separate `/reviews` tab. Click through to the reviews page before extracting. If reviews are paginated, the first page is sufficient for the snapshot — do not exhaustively scrape every page.

**Additional context:**
- Search for news mentions, blog posts, or articles about the business
- Check if there is a Companies House record (UK businesses)
- Look for any trade body memberships or certifications mentioned online

**Competitor fallback:** If Phase 2 did not surface 3 competitors from the Google Maps local pack, search `"[business type] [town]"` on Google and check the map results for additional local competitors.

## Output

**IMPORTANT: Write the completed research to a file when finished.** Copy the `references/output-schema.md` template, fill it in as you work through each phase, and save it as `business-research-{business-name-slug}.md` in the current working directory. Use the Write tool to persist the file.

Fill in fields as you discover them — do not wait until the end. Every field must carry a provenance marker:

- `[FOUND]` — gathered from a live source (name the source in Research Metadata)
- `[NOT FOUND]` — searched for but no source returned the data
- `[MANUAL]` — requires human verification; cannot determine programmatically

After completing all phases, fill in the **Research Summary** table at the top of the output, and complete the **Research Metadata** section at the bottom listing every source visited.

If any phase could not be completed, note it in **Limitations and caveats** rather than omitting the section.

## Connection to google-business-profile-audit

This skill produces the structured evidence that the `google-business-profile-audit` skill requires. Once the output is complete, run:

```
/skill google-business-profile-audit
```

and supply the filled-in output as the evidence input.

## Evidence rules

- Every claim must trace back to a live source listed in Research Metadata.
- If a field requires physical-world verification (e.g. "does the business name match signage?"), mark it `[MANUAL]`.
- If Google Maps blocks the scrape or returns incomplete data, note it in Limitations and move on to other sources.
- If the website is unreachable, mark website checks as `[NOT FOUND] — site unreachable` and note the reason.
- Never invent review counts, ratings, customer behaviour, or business intent.
- Never assume the business owner's goals unless they have stated them.

## Limitations

- Google Maps may show different content based on the requesting IP/location. Data may reflect a consumer view, not the business owner's GBP dashboard.
- Reviews are limited to what is publicly displayed. You cannot see private reviews or review analytics.
- Website checks are observational only. You cannot submit forms, book appointments, or test checkout flows.
- Some businesses may have minimal or no web presence beyond their GBP listing.
- Third-party review platforms (Facebook, Tripadvisor, Yelp, etc.) may block automated browsing with anti-bot walls or require login to view full review content. Where this happens, mark the platform `[NOT FOUND — blocked]` and continue with the platforms that are accessible.
- Multi-platform review data is a snapshot in time. Review counts and ratings shift daily.
- Local pack results vary by searcher location and IP. The competitors identified are those visible from the audit location, not an exhaustive list of every nearby business.
- Competitor data is a snapshot from the search at the time of research. Ratings and review counts shift daily.
- The output is as good as what is publicly available at the time of research.

## References

- [references/output-schema.md](references/output-schema.md) — Structured output template matching `audit-input-schema.md` with provenance markers
- The `google-business-profile-audit` skill (loaded separately) provides the `audit-input-schema.md` and full audit workflow that consumes this skill's output

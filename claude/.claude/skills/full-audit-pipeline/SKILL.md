--- name: full-audit-pipeline
description: End-to-end local business audit pipeline. Use TypeScript scrapers and report generators to turn a Google Maps URL into a polished HTML audit report.
---

# Full Audit Pipeline

## Purpose
Run the entire local-business audit as a script-driven workflow. The skill now delegates fetch, scraping, scoring, and rendering to TypeScript CLIs in `scripts/` so the model only coordinates and verifies.

## Required Input
- A Google Maps URL for the business.

## Runtime
1. Install dependencies once in this skill directory:
   - `npm install`
2. Run scripts with `tsx`:
   - `npx tsx scripts/run-pipeline.ts --url "<google-maps-url>"`

## Available Scripts
- `scripts/parse-maps-url.ts` - Canonicalize a Maps URL and derive the slug.
- `scripts/scrape-google-maps.ts` - Pull the public Maps listing surface into structured JSON.
- `scripts/scrape-website.ts` - Crawl the business website and capture page summaries.
- `scripts/scrape-competitors.ts` - Seed local competitor discovery from search results.
- `scripts/scrape-directories.ts` - Check public directory/review platforms.
- `scripts/collect-business-research.ts` - Build `business-research-{slug}.md` plus hidden JSON intermediates.
- `scripts/analyze-audit.ts` - Turn research JSON into `audit-output-{slug}.md` plus hidden audit JSON.
- `scripts/render-report.ts` - Render `audit-report-{slug}.html`.
- `scripts/run-pipeline.ts` - End-to-end orchestration.

## Workflow
1. Parse and validate the Google Maps URL.
2. Collect evidence with the scrapers:
   - Maps listing
   - Website crawl
   - Competitor discovery
   - Directory/review checks
3. Write `business-research-{slug}.md`.
4. Score and synthesize the audit into `audit-output-{slug}.md`.
5. Render `audit-report-{slug}.html`.

## Output Files
- `business-research-{slug}.md` - Raw evidence and provenance.
- `audit-output-{slug}.md` - Scored audit and action plan.
- `audit-report-{slug}.html` - Self-contained client report.
- Hidden intermediates live under `.audit-pipeline/{slug}/`.

## Rules
- Never invent missing evidence.
- Mark unavailable or blocked data explicitly with `[NOT FOUND]`, `blocked`, or `manual`.
- Keep the pipeline moving when one source fails; one blocked scrape should not stop the rest.
- Prefer the scripts for repeated fetch/scrape work instead of re-implementing the same logic in the agent.

## Fallbacks
- If the Maps URL is missing, ask for it.
- If a scrape is blocked, preserve the blocked status and continue.
- If `audit-report-{slug}.html` already exists, do not overwrite it without checking first.

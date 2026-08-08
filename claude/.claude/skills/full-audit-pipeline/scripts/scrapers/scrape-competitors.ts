import { fetchPage, looksBlocked } from '../lib/web.js';
import { collapseWhitespace } from '../lib/text.js';
import type { CompetitorEntry, SourceEvidence } from '../lib/types.js';
import * as cheerio from 'cheerio';

interface CompetitorRequest {
  businessName: string;
  category?: string;
  query?: string;
  slug: string;
}

function googleSearchUrl(query: string): string {
  return `https://www.google.com/maps/search/${encodeURIComponent(query)}?hl=en&gl=us`;
}

function pickCompetitorLinks(html: string, businessName: string): CompetitorEntry[] {
  const $ = cheerio.load(html);
  const candidates = $('a[href*="/maps/place/"]')
    .toArray()
    .map((node) => ({
      url: $(node).attr('href') ?? '',
      name: collapseWhitespace($(node).attr('aria-label') ?? $(node).text())
    }))
    .filter((candidate) => Boolean(candidate.url) && Boolean(candidate.name));
  return candidates
    .filter((candidate) => candidate.name && !candidate.name.toLowerCase().includes(businessName.toLowerCase()))
    .filter((candidate, index, all) => all.findIndex((item) => item.name === candidate.name) === index)
    .slice(0, 3)
    .map((candidate) => ({ name: candidate.name, url: candidate.url, note: 'Potential local competitor discovered from search results.' }));
}

export async function scrapeCompetitors(request: CompetitorRequest): Promise<{ entries: CompetitorEntry[]; sources: SourceEvidence[] }> {
  const query = request.query ?? request.category ?? request.businessName;
  const searchUrl = googleSearchUrl(`${query} near me`);
  try {
    const snapshot = await fetchPage(searchUrl, { useBrowser: true });
    const blocked = looksBlocked(`${snapshot.title ?? ''}\n${snapshot.text}`);
    const entries = blocked ? [] : pickCompetitorLinks(snapshot.html, request.businessName);
    return {
      entries,
      sources: [
        {
          source: 'competitor-search',
          status: blocked ? 'blocked' : entries.length ? 'ok' : 'not_found',
          sourceUrl: searchUrl,
          capturedAt: new Date().toISOString(),
          title: snapshot.title,
          rawText: snapshot.text,
          html: snapshot.html,
          links: snapshot.links,
          notes: blocked ? 'Google search appeared blocked or consent-gated.' : 'Used Google search results to seed local competitor discovery.'
        }
      ]
    };
  } catch (error) {
    return {
      entries: [],
      sources: [
        {
          source: 'competitor-search',
          status: 'error',
          sourceUrl: searchUrl,
          capturedAt: new Date().toISOString(),
          notes: error instanceof Error ? error.message : String(error)
        }
      ]
    };
  }
}

import { fetchPage, looksBlocked } from '../lib/web.js';
import type { DirectoryPlatformSummary, SourceEvidence } from '../lib/types.js';

interface DirectoryRequest {
  businessName: string;
  location?: string;
  slug: string;
}

interface DirectoryPlatform {
  name: string;
  domainHint: string;
  query: (request: DirectoryRequest) => string;
}

const PLATFORMS = [
  { name: 'Facebook', domainHint: 'facebook.com', query: (request: DirectoryRequest) => `site:facebook.com "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Tripadvisor', domainHint: 'tripadvisor.com', query: (request: DirectoryRequest) => `site:tripadvisor.com "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Yelp', domainHint: 'yelp.com', query: (request: DirectoryRequest) => `site:yelp.com "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Yell', domainHint: 'yell.com', query: (request: DirectoryRequest) => `site:yell.com "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Trustpilot', domainHint: 'trustpilot.com', query: (request: DirectoryRequest) => `site:trustpilot.com "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Just Eat', domainHint: 'just-eat.co.uk', query: (request: DirectoryRequest) => `site:just-eat.co.uk "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Deliveroo', domainHint: 'deliveroo.co.uk', query: (request: DirectoryRequest) => `site:deliveroo.co.uk "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Uber Eats', domainHint: 'ubereats.com', query: (request: DirectoryRequest) => `site:ubereats.com "${request.businessName}" ${request.location ?? ''}`.trim() },
  { name: 'Apple Maps', domainHint: 'maps.apple.com', query: (request: DirectoryRequest) => `site:maps.apple.com "${request.businessName}" ${request.location ?? ''}`.trim() },
  {
    name: 'Companies House',
    domainHint: 'find-and-update.company-information.service.gov.uk',
    query: (request: DirectoryRequest) => `site:find-and-update.company-information.service.gov.uk "${request.businessName}" ${request.location ?? ''}`.trim()
  }
];

function extractFirstResultUrl(html: string, domainHint: string): string | undefined {
  const anchors = Array.from(html.matchAll(/<a[^>]+href="([^"]+)"[^>]*>(.*?)<\/a>/gi));
  for (const [, href, inner] of anchors) {
    const text = inner.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
    if (!text) continue;
    if (domainHint && href.includes(domainHint)) return href;
  }
  return undefined;
}

async function probePlatform(request: DirectoryRequest, platform: DirectoryPlatform): Promise<DirectoryPlatformSummary> {
  const searchUrl = `https://www.google.com/search?hl=en&q=${encodeURIComponent(platform.query(request))}`;
  try {
    const snapshot = await fetchPage(searchUrl, { useBrowser: true });
    const blocked = looksBlocked(`${snapshot.title ?? ''}\n${snapshot.text}`);
    const foundUrl = blocked ? undefined : extractFirstResultUrl(snapshot.html, platform.domainHint);
    return {
      source: 'directories',
      platform: platform.name,
      status: blocked ? 'blocked' : foundUrl ? 'ok' : 'not_found',
      sourceUrl: searchUrl,
      capturedAt: new Date().toISOString(),
      foundUrl,
      notes: blocked ? 'Search results appeared blocked or consent-gated.' : foundUrl ? 'A matching public page was detected.' : 'No confident public profile was found.'
    };
  } catch (error) {
    return {
      source: 'directories',
      platform: platform.name,
      status: 'error',
      sourceUrl: searchUrl,
      capturedAt: new Date().toISOString(),
      notes: error instanceof Error ? error.message : String(error)
    };
  }
}

export async function scrapeDirectories(request: DirectoryRequest): Promise<DirectoryPlatformSummary[]> {
  return Promise.all(PLATFORMS.map((platform) => probePlatform(request, platform)));
}

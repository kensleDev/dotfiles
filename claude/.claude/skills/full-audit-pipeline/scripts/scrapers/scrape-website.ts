import { fetchPage, looksBlocked } from '../lib/web.js';
import { collapseWhitespace } from '../lib/text.js';
import type { SourceStatus, WebsitePageSummary, WebsiteSummary } from '../lib/types.js';

const PATH_HINTS = ['/', '/contact', '/about', '/menu', '/order', '/booking', '/book', '/services', '/visit', '/locations'];

function sameOrigin(urlA: string, urlB: string): boolean {
  try {
    return new URL(urlA).origin === new URL(urlB).origin;
  } catch {
    return false;
  }
}

export async function scrapeWebsite(siteUrl: string, options: { businessName?: string; slug: string }): Promise<WebsiteSummary> {
  if (!siteUrl) {
    return {
      source: 'website',
      status: 'not_found',
      sourceUrl: '',
      capturedAt: new Date().toISOString(),
      pages: [],
      notes: 'No website URL was available from the listing.'
    };
  }

  const visited = new Map<string, WebsitePageSummary>();
  const queue = [siteUrl];
  const discoveredLinks = new Set<string>();
  let contactEmail: string | undefined;
  let contactPhone: string | undefined;
  let orderLinks: string[] = [];
  let menuLinks: string[] = [];
  let blockedCount = 0;

  while (queue.length && visited.size < 5) {
    const current = queue.shift()!;
    if (visited.has(current)) continue;
    try {
      const snapshot = await fetchPage(current, { useBrowser: true });
      const text = collapseWhitespace(snapshot.text ?? '');
      const blocked = looksBlocked(`${snapshot.title ?? ''}\n${text}`);
      if (blocked) blockedCount += 1;
      if (!contactEmail) {
        contactEmail = text.match(/[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}/)?.[0];
      }
      if (!contactPhone) {
        contactPhone = text.match(/(\+?\d[\d\s().-]{7,}\d)/)?.[1];
      }
      const pageLinks = snapshot.links ?? [];
      const absoluteLinks = pageLinks.map((link) => {
        try {
          return new URL(link, current).toString();
        } catch {
          return link;
        }
      });
      discoveredLinks.forEach(() => void 0);
      for (const link of absoluteLinks) {
        discoveredLinks.add(link);
        if (/order|checkout|book|reserve/i.test(link)) {
          orderLinks.push(link);
        }
        if (/menu/i.test(link) || /\.pdf(\?|$)/i.test(link)) {
          menuLinks.push(link);
        }
        if (sameOrigin(current, link) && PATH_HINTS.some((hint) => new URL(link).pathname.startsWith(hint))) {
          queue.push(link);
        }
      }
      visited.set(current, {
        url: current,
        title: snapshot.title,
        status: blocked ? 'blocked' : 'ok',
        text,
        links: absoluteLinks,
        notes: blocked ? 'Browser content was blocked or gate-screened.' : undefined
      });
    } catch (error) {
      visited.set(current, {
        url: current,
        status: 'error',
        notes: error instanceof Error ? error.message : String(error)
      });
    }
  }

  const pages = Array.from(visited.values());
  const status: SourceStatus = pages.some((page) => page.status === 'ok') ? 'ok' : blockedCount > 0 ? 'blocked' : 'not_found';
  return {
    source: 'website',
    status,
    sourceUrl: siteUrl,
    capturedAt: new Date().toISOString(),
    pages,
    primaryDomain: (() => {
      try {
        return new URL(siteUrl).hostname;
      } catch {
        return undefined;
      }
    })(),
    contactEmail,
    contactPhone,
    orderLinks: Array.from(new Set(orderLinks)),
    menuLinks: Array.from(new Set(menuLinks)),
    notes: pages.length ? `Crawled ${pages.length} pages${blockedCount ? `, ${blockedCount} blocked` : ''}.` : 'No pages could be crawled.'
  };
}

import { fetchPage, looksBlocked } from '../lib/web.js';
import { collapseWhitespace, textLines } from '../lib/text.js';
import type { GoogleMapsListing } from '../lib/types.js';
import * as cheerio from 'cheerio';

function extractLinks(html: string, baseUrl: string): string[] {
  const hrefs = Array.from(html.matchAll(/href="([^"]+)"/gi)).map((match) => match[1]).filter(Boolean);
  return Array.from(
    new Set(
      hrefs.map((href) => {
        try {
          return new URL(href, baseUrl).toString();
        } catch {
          return href;
        }
      })
    )
  );
}

export async function scrapeGoogleMapsListing(sourceUrl: string): Promise<GoogleMapsListing> {
  const snapshot = await fetchPage(sourceUrl, { useBrowser: true });
  const text = snapshot.text || '';
  const $ = cheerio.load(snapshot.html);
  const lines = textLines(text);
  const title = snapshot.title;
  const blocked = looksBlocked(`${title ?? ''}\n${text}`);
  const ratingMatch = text.match(/([0-5](?:\.\d)?)\s*(?:\/5)?/i);
  const name = collapseWhitespace($('h1').first().text() || title?.replace(/\s*-\s*Google Maps.*$/i, '') || lines[0] || '');
  const category = collapseWhitespace($('button[jsaction*="category"]').first().text() || lines.find((line) => /restaurant|cafe|bakery|barber|salon|shop|store|clinic|hotel|gym|pub|takeaway/i.test(line)) || '');
  const phoneMatch = $('a[href^="tel:"]').first().attr('href')?.replace(/^tel:/i, '') ?? text.match(/(\+?\d[\d\s().-]{7,}\d)/)?.[1] ?? '';
  const phone = collapseWhitespace(phoneMatch);
  const website = $('a[aria-label*="Website"], a[aria-label*="website"], a[href^="http"]')
    .toArray()
    .map((node) => $(node).attr('href'))
    .find((href) => (href ? !/google\./i.test(href) : false));
  const address =
    snapshot.html.match(/\b\d{1,5}\s+[A-Za-z0-9'’.-]+(?:\s+[A-Za-z0-9'’.-]+)*,\s*[A-Za-z .'-]+,\s*[A-Z]{2}\s*\d{5}(?:-\d{4})?/i)?.[0] ??
    lines.find((line) => /\d{1,5}\s+[A-Za-z0-9'’.-]+(?:\s+[A-Za-z0-9'’.-]+)*,\s*[A-Za-z .'-]+,\s*[A-Z]{2}\s*\d{5}(?:-\d{4})?/i.test(line));
  const reviewCountMatch = text.match(/([\d,]+)\s+reviews?/i);

  return {
    source: 'google-maps',
    status: blocked ? 'blocked' : text ? 'ok' : 'manual',
    sourceUrl,
    capturedAt: new Date().toISOString(),
    title,
    name: name || undefined,
    category: category ? collapseWhitespace(category) : undefined,
    rating: ratingMatch ? Number(ratingMatch[1]) : undefined,
    reviewCount: reviewCountMatch ? Number(reviewCountMatch[1].replace(/,/g, '')) : undefined,
    address: address ? collapseWhitespace(address) : undefined,
    phone: phone ? collapseWhitespace(phone) : undefined,
    website,
    hours: lines.filter((line) => /\b(am|pm)\b/i.test(line)).slice(0, 7),
    rawText: text,
    links: extractLinks(snapshot.html, sourceUrl),
    notes: blocked ? 'Google Maps appeared blocked or consent-gated.' : 'Extracted from the public Maps page.'
  };
}

import { slugify } from './paths.js';
import { collapseWhitespace, textLines } from './text.js';
import type { CompetitorEntry, GoogleMapsListing, ParsedMapsUrl } from './types.js';

export function parseGoogleMapsUrl(inputUrl: string): ParsedMapsUrl {
  const url = new URL(inputUrl);
  const canonicalUrl = url.toString();
  const pathBits = url.pathname.split('/').filter(Boolean);
  const placeId = pathBits.includes('place') ? pathBits.slice(pathBits.indexOf('place') + 1).join('/') : undefined;
  const query = url.searchParams.get('q') ?? url.searchParams.get('query') ?? undefined;
  const slugSeed = query ?? placeId ?? pathBits[pathBits.length - 1] ?? url.hostname;
  return {
    inputUrl,
    canonicalUrl,
    placeId,
    query,
    slug: slugify(slugSeed || 'business')
  };
}

export function parseListingFromText(sourceUrl: string, rawText: string, links: string[] = [], title?: string): GoogleMapsListing {
  const lines = textLines(rawText);
  const firstLine = lines[0] ?? title?.replace(/\s*-\s*Google Maps.*$/i, '') ?? '';
  const reviewCountMatch = rawText.match(/([\d,]+)\s+reviews?/i) ?? rawText.match(/review count[:\s]+([\d,]+)/i);
  const ratingMatch = rawText.match(/([0-5](?:\.\d)?)\s*(?:\/5)?\s*(?:stars?)?/i);
  const phoneMatch = rawText.match(/(\+?\d[\d\s().-]{7,}\d)/);
  const website = links.find((link) => /^https?:\/\//i.test(link) && !/google\./i.test(link));
  const addressLine = lines.find((line) => /[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}/i.test(line) || /, [A-Z]{2,}$/.test(line));
  const categoryLine = lines.find((line, index) => index > 0 && index < 8 && /restaurant|cafe|bakery|shop|salon|barber|store|dentist|clinic|gym|hotel|pub/i.test(line));

  return {
    source: 'google-maps',
    status: rawText ? 'ok' : 'manual',
    sourceUrl,
    capturedAt: new Date().toISOString(),
    title,
    name: collapseWhitespace(firstLine) || undefined,
    category: categoryLine ? collapseWhitespace(categoryLine) : undefined,
    rating: ratingMatch ? Number(ratingMatch[1]) : undefined,
    reviewCount: reviewCountMatch ? Number(reviewCountMatch[1].replace(/,/g, '')) : undefined,
    address: addressLine ? collapseWhitespace(addressLine) : undefined,
    phone: phoneMatch ? collapseWhitespace(phoneMatch[1]) : undefined,
    website,
    hours: lines.filter((line) => /\b(am|pm)\b/i.test(line)).slice(0, 7),
    rawText,
    links,
    notes: 'Best-effort extraction from the public Maps surface.'
  };
}

export function rankCompetitors(candidates: Array<{ name?: string; rating?: number; reviewCount?: number; url?: string }>, businessName?: string): CompetitorEntry[] {
  const normalizedBusiness = (businessName ?? '').toLowerCase();
  return candidates
    .map((candidate) => ({
      name: candidate.name?.trim() || 'Unknown competitor',
      url: candidate.url,
      rating: candidate.rating,
      reviewCount: candidate.reviewCount,
      note: candidate.name?.toLowerCase().includes(normalizedBusiness) ? 'Possible same business listing' : undefined
    }))
    .filter((candidate) => candidate.name.toLowerCase() !== normalizedBusiness)
    .slice(0, 3);
}

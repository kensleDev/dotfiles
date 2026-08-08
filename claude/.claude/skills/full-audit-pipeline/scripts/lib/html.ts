import * as cheerio from 'cheerio';
import { collapseWhitespace, textLines } from './text.js';

export interface HtmlPageSnapshot {
  url: string;
  status: number;
  title?: string;
  text: string;
  html: string;
  links: string[];
  meta: Record<string, string>;
}

export function extractHtmlSnapshot(url: string, html: string, status = 200): HtmlPageSnapshot {
  const $ = cheerio.load(html);
  const title = collapseWhitespace($('title').first().text());
  $('script, style, noscript').remove();
  const bodyText = $('body').text();
  const text = collapseWhitespace(bodyText || $.root().text());
  const links = Array.from(new Set($('a[href]').toArray().map((node) => $(node).attr('href')).filter((href): href is string => Boolean(href))));
  const meta: Record<string, string> = {};
  $('meta').each((_, el) => {
    const name = $(el).attr('name') ?? $(el).attr('property');
    const content = $(el).attr('content');
    if (name && content && !meta[name]) meta[name] = content;
  });
  return { url, status, title, text, html, links, meta };
}

export function extractBodyText(html: string): string {
  const $ = cheerio.load(html);
  $('script, style, noscript').remove();
  return textLines($('body').text() || $.root().text()).join('\n');
}

export function normalizeLinks(links: string[], baseUrl: string): string[] {
  const resolved = links.map((link) => {
    try {
      return new URL(link, baseUrl).toString();
    } catch {
      return link;
    }
  });
  return Array.from(new Set(resolved));
}

import { extractHtmlSnapshot, type HtmlPageSnapshot } from './html.js';

const USER_AGENTS = [
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'
];

function pickUserAgent(): string {
  return USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)] ?? USER_AGENTS[0];
}

function shouldPreferBrowser(url: string): boolean {
  return /google\.(com|co\.uk|co\.jp|ca|de|fr|it|es|nl|com\.au)/i.test(url);
}

async function dismissGoogleConsent(page: import('playwright').Page): Promise<void> {
  try {
    const consentUrl = page.url().includes('consent.google.com');
    const bodyText = consentUrl ? await page.locator('body').innerText({ timeout: 5000 }).catch(() => '') : '';
    if (!consentUrl && !/before you continue|we use cookies/i.test(bodyText)) return;

    const reject = page.getByRole('button', { name: /reject all/i });
    const accept = page.getByRole('button', { name: /accept all/i });
    const moreOptions = page.getByRole('button', { name: /more options/i });

    if (await reject.count().catch(() => 0)) {
      await reject.first().click({ timeout: 5000 }).catch(() => {});
    } else if (await accept.count().catch(() => 0)) {
      await accept.first().click({ timeout: 5000 }).catch(() => {});
    } else if (await moreOptions.count().catch(() => 0)) {
      await moreOptions.first().click({ timeout: 5000 }).catch(() => {});
      await page.getByRole('button', { name: /reject all/i }).click({ timeout: 5000 }).catch(() => {
        void page.getByRole('button', { name: /accept all/i }).click({ timeout: 5000 }).catch(() => {});
      });
    }

    await page.waitForLoadState('domcontentloaded').catch(() => {});
    await page.waitForTimeout(2500);
  } catch {
    // Leave the page as-is if consent handling fails.
  }
}

async function openBrowserPage(url: string, timeoutMs: number): Promise<HtmlPageSnapshot> {
  const { chromium } = await import('playwright');
  const browser = await chromium.launch({ headless: true });
  try {
    const context = await browser.newContext({
      viewport: { width: 1440, height: 1600 },
      locale: 'en-GB',
      userAgent: pickUserAgent()
    });
    const page = await context.newPage();
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: timeoutMs });
    await dismissGoogleConsent(page);
    if (page.url().includes('consent.google.com')) {
      await page.goto(url, { waitUntil: 'domcontentloaded', timeout: timeoutMs }).catch(() => {});
      await dismissGoogleConsent(page);
    }
    await page.waitForTimeout(3000);
    const html = await page.content();
    const snapshot = extractHtmlSnapshot(page.url(), html, 200);
    await context.close();
    return snapshot;
  } finally {
    await browser.close();
  }
}

export async function fetchPage(url: string, options: { timeoutMs?: number; useBrowser?: boolean } = {}): Promise<HtmlPageSnapshot> {
  const timeoutMs = options.timeoutMs ?? 45000;
  const preferBrowser = options.useBrowser || shouldPreferBrowser(url);

  if (!preferBrowser) {
    const response = await fetch(url, {
      headers: {
        'user-agent': pickUserAgent()
      },
      redirect: 'follow'
    }).catch(async () => null);

    if (response) {
      const html = await response.text();
      if (html && !/consent\.google\.com|before you continue|window\.APP_OPTIONS/i.test(html)) {
        return extractHtmlSnapshot(url, html, response.status);
      }
    }
  }

  if (options.useBrowser === false && !preferBrowser) {
    throw new Error(`Unable to fetch ${url}`);
  }

  return openBrowserPage(url, timeoutMs);
}

export function looksBlocked(text: string): boolean {
  const lower = text.toLowerCase();
  return (
    lower.includes('unusual traffic') ||
    lower.includes('captcha') ||
    lower.includes('access denied') ||
    lower.includes('before you continue google') ||
    lower.includes('verify you are human')
  );
}

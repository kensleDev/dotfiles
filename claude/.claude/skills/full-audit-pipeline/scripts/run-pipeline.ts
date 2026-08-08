import { scrapeGoogleMapsListing } from './scrapers/scrape-google-maps.js';
import { scrapeWebsite } from './scrapers/scrape-website.js';
import { scrapeCompetitors } from './scrapers/scrape-competitors.js';
import { scrapeDirectories } from './scrapers/scrape-directories.js';
import { parseGoogleMapsUrl } from './lib/google-maps.js';
import { businessResearchToMarkdown, buildAuditOutput, auditOutputToMarkdown, renderAuditReportHtml } from './lib/research.js';
import { writeJson, writeText } from './lib/io.js';
import {
  auditOutputJsonPath,
  auditOutputMdPath,
  auditReportHtmlPath,
  businessResearchJsonPath,
  businessResearchMdPath,
  intermediarySnapshotPath
} from './lib/paths.js';
import type { BusinessResearch } from './lib/types.js';

function getArg(name: string): string | undefined {
  const prefix = `--${name}=`;
  const match = process.argv.find((arg) => arg.startsWith(prefix));
  if (match) return match.slice(prefix.length);
  const index = process.argv.indexOf(`--${name}`);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

async function main(): Promise<void> {
  const url = getArg('url');
  if (!url) throw new Error('Missing required --url');

  const parsed = parseGoogleMapsUrl(url);
  const listing = await scrapeGoogleMapsListing(parsed.canonicalUrl);
  const website = await scrapeWebsite(listing.website ?? '', {
    businessName: listing.name,
    slug: parsed.slug
  });
  const [competitors, directories] = await Promise.all([
    scrapeCompetitors({
      businessName: listing.name ?? parsed.slug,
      category: listing.category,
      query: parsed.query ?? listing.category,
      slug: parsed.slug
    }),
    scrapeDirectories({
      businessName: listing.name ?? parsed.slug,
      location: listing.address,
      slug: parsed.slug
    })
  ]);

  const research: BusinessResearch = {
    slug: parsed.slug,
    businessName: listing.name ?? parsed.slug,
    canonicalUrl: parsed.canonicalUrl,
    capturedAt: new Date().toISOString(),
    parsedUrl: parsed,
    listing,
    competitors: competitors.entries,
    website,
    directories,
    sources: [listing, website, ...directories, ...competitors.sources]
  };

  const audit = buildAuditOutput(research);
  const html = renderAuditReportHtml(audit, research);

  await writeJson(businessResearchJsonPath(parsed.slug), research);
  await writeJson(auditOutputJsonPath(parsed.slug), audit);
  await writeJson(intermediarySnapshotPath(parsed.slug, 'business-research.snapshot.json'), research);
  await writeJson(intermediarySnapshotPath(parsed.slug, 'audit-output.snapshot.json'), audit);
  await writeText(businessResearchMdPath(parsed.slug), businessResearchToMarkdown(research));
  await writeText(auditOutputMdPath(parsed.slug), auditOutputToMarkdown(audit));
  await writeText(auditReportHtmlPath(parsed.slug), html);

  console.log(JSON.stringify({
    slug: parsed.slug,
    businessName: research.businessName,
    outputs: {
      research: businessResearchMdPath(parsed.slug),
      audit: auditOutputMdPath(parsed.slug),
      html: auditReportHtmlPath(parsed.slug)
    }
  }, null, 2));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});

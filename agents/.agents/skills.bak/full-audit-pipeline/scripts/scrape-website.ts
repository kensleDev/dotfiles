import { scrapeWebsite } from './scrapers/scrape-website.js';
import { writeJson } from './lib/io.js';
import { intermediarySnapshotPath } from './lib/paths.js';

function getArg(name: string): string | undefined {
  const prefix = `--${name}=`;
  const match = process.argv.find((arg) => arg.startsWith(prefix));
  if (match) return match.slice(prefix.length);
  const index = process.argv.indexOf(`--${name}`);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

async function main(): Promise<void> {
  const url = getArg('url');
  const slug = getArg('slug');
  if (!url) throw new Error('Missing required --url');
  if (!slug) throw new Error('Missing required --slug');
  const website = await scrapeWebsite(url, { businessName: getArg('businessName') ?? undefined, slug });
  const out = getArg('out') ?? intermediarySnapshotPath(slug, 'website.snapshot.json');
  await writeJson(out, website);
  console.log(JSON.stringify(website, null, 2));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});

import { scrapeDirectories } from './scrapers/scrape-directories.js';
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
  const slug = getArg('slug');
  const businessName = getArg('businessName');
  if (!slug) throw new Error('Missing required --slug');
  if (!businessName) throw new Error('Missing required --businessName');
  const result = await scrapeDirectories({
    businessName,
    location: getArg('location'),
    slug
  });
  const out = getArg('out') ?? intermediarySnapshotPath(slug, 'directories.snapshot.json');
  await writeJson(out, result);
  console.log(JSON.stringify(result, null, 2));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});

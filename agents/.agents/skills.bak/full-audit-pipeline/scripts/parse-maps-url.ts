import { parseGoogleMapsUrl } from './lib/google-maps.js';
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
  if (!url) {
    throw new Error('Missing required --url');
  }

  const parsed = parseGoogleMapsUrl(url);
  const out = getArg('out') ?? intermediarySnapshotPath(parsed.slug, 'parsed-url.json');
  await writeJson(out, parsed);
  console.log(JSON.stringify(parsed, null, 2));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});

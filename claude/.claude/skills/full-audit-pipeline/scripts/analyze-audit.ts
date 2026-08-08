import { businessResearchToMarkdown, buildAuditOutput, auditOutputToMarkdown } from './lib/research.js';
import { readJson, writeJson, writeText } from './lib/io.js';
import { auditOutputJsonPath, auditOutputMdPath, businessResearchJsonPath } from './lib/paths.js';
import type { BusinessResearch } from './lib/types.js';

function getArg(name: string): string | undefined {
  const prefix = `--${name}=`;
  const match = process.argv.find((arg) => arg.startsWith(prefix));
  if (match) return match.slice(prefix.length);
  const index = process.argv.indexOf(`--${name}`);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

async function main(): Promise<void> {
  const slug = getArg('slug');
  if (!slug) throw new Error('Missing required --slug');

  const inputPath = getArg('input') ?? businessResearchJsonPath(slug);
  const research = await readJson<BusinessResearch>(inputPath);
  const audit = buildAuditOutput(research);

  await writeJson(auditOutputJsonPath(slug), audit);
  await writeText(auditOutputMdPath(slug), auditOutputToMarkdown(audit));
  console.log(JSON.stringify({ slug, output: auditOutputMdPath(slug) }, null, 2));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});

import { readJson, writeText } from './lib/io.js';
import { auditOutputJsonPath, auditReportHtmlPath, businessResearchJsonPath } from './lib/paths.js';
import { renderAuditReportHtml } from './lib/research.js';
import type { AuditOutput, BusinessResearch } from './lib/types.js';

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

  const research = await readJson<BusinessResearch>(getArg('research') ?? businessResearchJsonPath(slug));
  const audit = await readJson<AuditOutput>(getArg('audit') ?? auditOutputJsonPath(slug));
  const html = renderAuditReportHtml(audit, research);
  const out = getArg('out') ?? auditReportHtmlPath(slug);
  await writeText(out, html);
  console.log(JSON.stringify({ slug, output: out }, null, 2));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});

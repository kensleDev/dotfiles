import path from 'node:path';

export function slugify(value: string): string {
  return value
    .normalize('NFKD')
    .replace(/[^\w\s-]/g, '')
    .trim()
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase();
}

export function skillRoot(): string {
  return process.cwd();
}

export function artifactRoot(slug: string): string {
  return path.join(skillRoot(), '.audit-pipeline', slug);
}

export function businessResearchJsonPath(slug: string): string {
  return path.join(artifactRoot(slug), 'business-research.json');
}

export function auditOutputJsonPath(slug: string): string {
  return path.join(artifactRoot(slug), 'audit-output.json');
}

export function businessResearchMdPath(slug: string): string {
  return path.join(skillRoot(), `business-research-${slug}.md`);
}

export function auditOutputMdPath(slug: string): string {
  return path.join(skillRoot(), `audit-output-${slug}.md`);
}

export function auditReportHtmlPath(slug: string): string {
  return path.join(skillRoot(), `audit-report-${slug}.html`);
}

export function intermediarySnapshotPath(slug: string, name: string): string {
  return path.join(artifactRoot(slug), name);
}

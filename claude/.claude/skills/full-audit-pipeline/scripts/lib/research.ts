import { collapseWhitespace, textLines, toSentence, truncate } from './text.js';
import type { AuditOutput, BusinessResearch, FindingItem, OpportunityItem, RiskFlag, ScoreCard } from './types.js';

function hasUsefulWebsite(research: BusinessResearch): boolean {
  return Boolean(research.website?.pages?.some((page) => page.status === 'ok' && (page.text ?? '').length > 100));
}

function hasOnlineOrder(research: BusinessResearch): boolean {
  const pages = research.website?.pages ?? [];
  const links = pages.flatMap((page) => page.links ?? []);
  return links.some((link) => /order|book|reserve|checkout|cart/i.test(link));
}

function hasMenuPdf(research: BusinessResearch): boolean {
  const pages = research.website?.pages ?? [];
  const links = pages.flatMap((page) => page.links ?? []);
  return links.some((link) => /\.pdf(\?|$)/i.test(link) || /menu/i.test(link));
}

function reviewCount(research: BusinessResearch): number {
  return research.listing.reviewCount ?? 0;
}

function rating(research: BusinessResearch): number {
  return research.listing.rating ?? 0;
}

export function buildAuditOutput(research: BusinessResearch): AuditOutput {
  const reviewCountValue = reviewCount(research);
  const ratingValue = rating(research);
  const websiteUseful = hasUsefulWebsite(research);
  const orderAvailable = hasOnlineOrder(research);
  const menuPdf = hasMenuPdf(research);
  const directoryHits = research.directories.filter((item) => item.status === 'ok').length;
  const competitorCount = research.competitors.length;

  const scores: ScoreCard[] = [
    {
      label: 'Visibility',
      score: Math.min(10, 4 + (research.listing.name ? 2 : 0) + (directoryHits > 0 ? 2 : 0) + (competitorCount > 0 ? 1 : 0)),
      max: 10,
      note: research.listing.name ? 'Maps listing exists and additional mentions were found.' : 'Listing evidence is thin.'
    },
    {
      label: 'Reputation',
      score: Math.min(10, Math.round((ratingValue / 5) * 6) + Math.min(4, Math.floor(reviewCountValue / 50))),
      max: 10,
      note: `${reviewCountValue || 'No'} review snapshot${reviewCountValue === 1 ? '' : 's'} recorded.`
    },
    {
      label: 'Website',
      score: websiteUseful ? 8 : 3,
      max: 10,
      note: websiteUseful ? 'Website content is usable and crawlable.' : 'Website content is sparse or missing.'
    },
    {
      label: 'Conversion',
      score: orderAvailable ? 8 : menuPdf ? 5 : 3,
      max: 10,
      note: orderAvailable ? 'A conversion path was visible.' : menuPdf ? 'Menu appears to be a PDF or download-first.' : 'No strong conversion path found.'
    },
    {
      label: 'Competitiveness',
      score: competitorCount > 0 ? Math.max(4, 9 - competitorCount) : 4,
      max: 10,
      note: competitorCount > 0 ? `${competitorCount} competitors were identified from the local pack.` : 'No direct competitors were confidently identified.'
    }
  ];

  const opportunities: OpportunityItem[] = [];
  if (!research.listing.description && !research.listing.category) {
    opportunities.push({
      title: 'Fill in missing Google Business Profile fields',
      whyItMatters: 'Completeness helps local relevance and click confidence.',
      effort: 'Low',
      owner: 'You / staff'
    });
  }
  if (!websiteUseful) {
    opportunities.push({
      title: 'Make the website easier to use on mobile',
      whyItMatters: 'Most visitors arrive on phones and bounce quickly if the page is hard to use.',
      effort: 'Medium',
      owner: 'Web person'
    });
  }
  if (!research.directories.some((entry) => entry.status === 'ok' && entry.rating && entry.rating >= 4)) {
    opportunities.push({
      title: 'Systematize review requests',
      whyItMatters: 'More recent social proof reduces decision friction.',
      effort: 'Low',
      owner: 'You / staff'
    });
  }
  if (!orderAvailable && menuPdf) {
    opportunities.push({
      title: 'Replace PDF-first menu with a web page',
      whyItMatters: 'Menus that render in-browser are easier to scan and act on.',
      effort: 'Medium',
      owner: 'Web person'
    });
  }
  if (!orderAvailable && !menuPdf) {
    opportunities.push({
      title: 'Add a simple ordering or enquiry path',
      whyItMatters: 'Customers who cannot queue need a direct way to buy or book.',
      effort: 'High',
      owner: 'Web person'
    });
  }

  const findings: FindingItem[] = [
    {
      title: 'Google profile completeness',
      detail: research.listing.website ? 'Website link exists on the listing.' : 'Website link was not confidently detected.',
      severity: research.listing.website ? 'Low' : 'Medium'
    },
    {
      title: 'Review volume snapshot',
      detail: reviewCountValue > 100 ? `Review count is healthy at ${reviewCountValue}.` : reviewCountValue > 0 ? `Review count is present but modest at ${reviewCountValue}.` : 'No review count captured.',
      severity: reviewCountValue > 100 ? 'Low' : reviewCountValue > 0 ? 'Medium' : 'High'
    },
    {
      title: 'Website conversion path',
      detail: orderAvailable ? 'An online order or booking route was visible.' : 'No obvious order or booking route was captured.',
      severity: orderAvailable ? 'Low' : 'High'
    }
  ];

  const actionPlan = [
    {
      rank: 1,
      fix: opportunities[0]?.title ?? 'Tighten the most visible profile gap',
      whyItMatters: opportunities[0]?.whyItMatters ?? 'Highest-impact visibility improvement.',
      effort: opportunities[0]?.effort ?? 'Low',
      who: opportunities[0]?.owner ?? 'You / staff'
    },
    {
      rank: 2,
      fix: opportunities[1]?.title ?? 'Make the website easier to use on mobile',
      whyItMatters: opportunities[1]?.whyItMatters ?? 'Improves conversion on the majority device class.',
      effort: opportunities[1]?.effort ?? 'Medium',
      who: opportunities[1]?.owner ?? 'Web person'
    },
    {
      rank: 3,
      fix: opportunities[2]?.title ?? 'Create a steady review request process',
      whyItMatters: opportunities[2]?.whyItMatters ?? 'Recent reviews raise trust and click-through.',
      effort: opportunities[2]?.effort ?? 'Low',
      who: opportunities[2]?.owner ?? 'You / staff'
    }
  ];

  const limitations = [
    'Snapshot in time only; review counts and rankings change daily.',
    'Public data only; no private account access, analytics, or order-system access.',
    'Local-pack competitors are the visible set from the crawl location, not an exhaustive market map.'
  ];

  const riskMatrix: RiskFlag[] = [
    {
      flag: 'Missing GBP detail',
      severity: research.listing.website ? 'Low' : 'Medium',
      detail: research.listing.website ? 'Some listing details are available.' : 'A visible conversion and credibility gap remains.'
    },
    {
      flag: 'No online ordering',
      severity: orderAvailable ? 'Low' : 'Medium',
      detail: orderAvailable ? 'An ordering or booking route was found.' : 'Potential lost revenue for customers who want to pre-order.'
    },
    {
      flag: 'PDF menu on mobile',
      severity: menuPdf ? 'Medium' : 'Low',
      detail: menuPdf ? 'A PDF/menu-style asset appears to be part of the journey.' : 'No PDF-first menu was detected.'
    }
  ];

  const sourceLog = research.sources.map((source) => ({
    source: source.source,
    status: source.status,
    timestamp: source.capturedAt,
    notes: source.notes
  }));

  const summary = toSentence(
    `${research.businessName} has ${reviewCountValue || 'limited'} public review evidence, a ${ratingValue ? ratingValue.toFixed(1) : 'unrated'} Maps snapshot, and ${websiteUseful ? 'a usable website surface' : 'a thin web presence'}.`
  );

  return {
    slug: research.slug,
    businessName: research.businessName,
    capturedAt: new Date().toISOString(),
    summary,
    scores,
    opportunities,
    findings,
    actionPlan,
    limitations,
    internalNotes: {
      evidenceQuality: [
        `Maps listing: ${research.listing.status}`,
        `Website crawl: ${research.website.status}`,
        `Directory checks: ${research.directories.filter((entry) => entry.status === 'ok').length} successful`
      ],
      riskMatrix,
      sourceLog
    },
    raw: {
      research
    }
  };
}

function scoreBar(score: number, max: number): string {
  return `${Math.max(0, Math.min(score, max))}/${max}`;
}

function listToHtml(items: string[]): string {
  return `<ul>${items.map((item) => `<li>${item}</li>`).join('')}</ul>`;
}

function tableRows(rows: Array<Record<string, string>>): string {
  return rows
    .map((row) => `<tr>${Object.entries(row).map(([key, value]) => `<td data-label="${key}">${value}</td>`).join('')}</tr>`)
    .join('');
}

export function auditOutputToMarkdown(output: AuditOutput): string {
  const scoreLines = output.scores.map((score) => `- **${score.label}**: ${scoreBar(score.score, score.max)} - ${score.note}`);
  const opportunityLines = output.opportunities.map((item, index) => `${index + 1}. ${item.title} - ${item.whyItMatters} (${item.effort}, ${item.owner})`);
  const findingLines = output.findings.map((item) => `- **${item.title}** (${item.severity}): ${item.detail}`);
  const actionLines = output.actionPlan.map((item) => `${item.rank}. ${item.fix} - ${item.whyItMatters} (${item.effort}, ${item.who})`);

  return [
    `# Audit Output - ${output.businessName}`,
    '',
    `Generated: ${output.capturedAt}`,
    '',
    `## Executive Summary`,
    output.summary,
    '',
    `## Scores`,
    ...scoreLines,
    '',
    `## Top Opportunities`,
    ...opportunityLines,
    '',
    `## Detailed Findings`,
    ...findingLines,
    '',
    `## Priority Action Plan`,
    ...actionLines,
    '',
    `## Limitations & Caveats`,
    ...output.limitations.map((item) => `- ${item}`),
    '',
    `## Internal Notes`,
    `- Evidence quality: ${output.internalNotes.evidenceQuality.join('; ')}`,
    `- Risk matrix entries: ${output.internalNotes.riskMatrix.length}`,
    `- Source log entries: ${output.internalNotes.sourceLog.length}`
  ].join('\n');
}

export function businessResearchToMarkdown(research: BusinessResearch): string {
  const directoryRows = research.directories
    .map((entry) => `- **${entry.platform}**: ${entry.status}${entry.foundUrl ? ` (${entry.foundUrl})` : ''}${entry.notes ? ` - ${entry.notes}` : ''}`)
    .join('\n');

  const competitorRows = research.competitors
    .map((competitor, index) => `${index + 1}. ${competitor.name}${competitor.rating ? ` - ${competitor.rating.toFixed(1)}` : ''}${competitor.reviewCount ? ` (${competitor.reviewCount} reviews)` : ''}${competitor.note ? ` - ${competitor.note}` : ''}`)
    .join('\n');

  const websitePages = research.website.pages
    .map((page) => `- ${page.status}: ${page.url}${page.title ? ` - ${page.title}` : ''}${page.notes ? ` - ${page.notes}` : ''}`)
    .join('\n');

  return [
    `# Business Research - ${research.businessName}`,
    '',
    `Slug: ${research.slug}`,
    `Maps URL: ${research.canonicalUrl}`,
    `Captured: ${research.capturedAt}`,
    '',
    `## Google Maps Listing`,
    `- Status: ${research.listing.status}`,
    `- Name: ${research.listing.name ?? '[NOT FOUND]'}`,
    `- Category: ${research.listing.category ?? '[NOT FOUND]'}`,
    `- Rating: ${research.listing.rating ?? '[NOT FOUND]'}`,
    `- Review count: ${research.listing.reviewCount ?? '[NOT FOUND]'}`,
    `- Address: ${research.listing.address ?? '[NOT FOUND]'}`,
    `- Phone: ${research.listing.phone ?? '[NOT FOUND]'}`,
    `- Website: ${research.listing.website ?? '[NOT FOUND]'}`,
    '',
    `## Competitors`,
    competitorRows || '- [NOT FOUND]',
    '',
    `## Website Crawl`,
    websitePages || '- [NOT FOUND]',
    '',
    `## Directory Checks`,
    directoryRows || '- [NOT FOUND]',
    '',
    `## Evidence Sources`,
    ...research.sources.map((source) => `- ${source.source}: ${source.status}${source.notes ? ` - ${source.notes}` : ''}`)
  ].join('\n');
}

export function renderAuditReportHtml(output: AuditOutput, research: BusinessResearch): string {
  const scoreCards = output.scores
    .map(
      (score) => `
        <div class="gauge-card">
          <div class="gauge-label">${score.label}</div>
          <div class="gauge-value">${score.score}<span>/${score.max}</span></div>
          <div class="gauge-note">${score.note}</div>
        </div>`
    )
    .join('');

  const competitorCards = research.competitors
    .map(
      (competitor) => `
        <article class="competitor-card">
          <h4>${competitor.name}</h4>
          <div class="competitor-meta">${competitor.rating ? `${competitor.rating.toFixed(1)}/5` : 'No rating'}${competitor.reviewCount ? ` · ${competitor.reviewCount} reviews` : ''}</div>
          <p>${competitor.note ?? 'Identified from local pack evidence.'}</p>
        </article>`
    )
    .join('');

  const opportunityCards = output.opportunities
    .map(
      (item) => `
        <article class="opp-card">
          <h4>${item.title}</h4>
          <p>${item.whyItMatters}</p>
          <div class="opp-meta"><span>${item.effort}</span><span>${item.owner}</span></div>
        </article>`
    )
    .join('');

  const findingItems = output.findings
    .map(
      (finding, index) => `
        <details class="finding">
          <summary>${index + 1}. ${finding.title}</summary>
          <div class="finding-body">
            <span class="badge badge-${finding.severity.toLowerCase()}">${finding.severity}</span>
            <p>${finding.detail}</p>
          </div>
        </details>`
    )
    .join('');

  const actionRows = output.actionPlan
    .map(
      (item) => `
        <tr>
          <td data-label="#">${item.rank}</td>
          <td data-label="Fix">${item.fix}</td>
          <td data-label="Why it matters">${item.whyItMatters}</td>
          <td data-label="Effort"><span class="effort effort-${item.effort.toLowerCase()}">${item.effort}</span></td>
          <td data-label="Who">${item.who}</td>
        </tr>`
    )
    .join('');

  const directoryRows = research.directories
    .map(
      (entry) => `
        <tr>
          <td data-label="Platform">${entry.platform}</td>
          <td data-label="Status">${entry.status}</td>
          <td data-label="Rating">${entry.rating ?? '—'}</td>
          <td data-label="Reviews">${entry.reviewCount ?? '—'}</td>
          <td data-label="Last active">${entry.lastActive ?? '—'}</td>
          <td data-label="Notes">${entry.notes ?? '—'}</td>
        </tr>`
    )
    .join('');

  const internalRiskRows = output.internalNotes.riskMatrix
    .map(
      (item) => `
        <tr>
          <td data-label="Flag">${item.flag}</td>
          <td data-label="Severity"><span class="badge badge-${item.severity.toLowerCase()}">${item.severity}</span></td>
          <td data-label="Detail">${item.detail}</td>
        </tr>`
    )
    .join('');

  const sourceRows = output.internalNotes.sourceLog
    .map(
      (item) => `
        <tr>
          <td data-label="Source">${item.source}</td>
          <td data-label="Status">${item.status}</td>
          <td data-label="Timestamp">${item.timestamp}</td>
          <td data-label="Notes">${item.notes ?? '—'}</td>
        </tr>`
    )
    .join('');

  return `<!DOCTYPE html>
<html lang="en-GB">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Local Business Digital Audit — ${output.businessName}</title>
  <style>
    :root {
      --navy: #152238;
      --navy-light: #20324d;
      --coral: #e35d6a;
      --green: #0ea96e;
      --amber: #d97706;
      --red: #dc2626;
      --gray-50: #f9fafb;
      --gray-100: #f3f4f6;
      --gray-200: #e5e7eb;
      --gray-400: #9ca3af;
      --gray-600: #4b5563;
      --gray-800: #1f2937;
      --radius: 14px;
      --shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
    }
    * { box-sizing: border-box; }
    body { margin: 0; font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, sans-serif; background: linear-gradient(180deg, #f6f7fb 0%, #edf1f7 100%); color: var(--gray-800); }
    .wrap { max-width: 1120px; margin: 0 auto; padding: 32px 20px 64px; }
    .cover, .section { background: #fff; border-radius: var(--radius); box-shadow: var(--shadow); }
    .cover { padding: 34px; background: linear-gradient(135deg, var(--navy) 0%, var(--navy-light) 100%); color: #fff; margin-bottom: 22px; }
    .cover h1 { margin: 0; font-size: clamp(28px, 5vw, 42px); line-height: 1.1; }
    .subtitle { margin: 10px 0 0; max-width: 72ch; color: rgba(255,255,255,.82); }
    .cover-grid { display: grid; gap: 14px; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); margin-top: 24px; }
    .cover-item .label { font-size: 11px; letter-spacing: 1.4px; text-transform: uppercase; color: rgba(255,255,255,.54); }
    .cover-item .value { margin-top: 4px; font-size: 15px; font-weight: 600; }
    .section { padding: 24px; margin-bottom: 18px; }
    .section h2 { margin: 0 0 16px; font-size: 22px; }
    .muted { color: var(--gray-600); }
    .gauge-grid { display: grid; gap: 14px; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); }
    .gauge-card, .competitor-card, .opp-card { border: 1px solid var(--gray-200); border-radius: 12px; padding: 16px; background: var(--gray-50); }
    .gauge-value { font-size: 30px; font-weight: 800; margin-top: 8px; }
    .gauge-value span { color: var(--gray-400); font-size: 14px; font-weight: 600; }
    .gauge-note, .competitor-meta, .opp-meta { color: var(--gray-600); font-size: 13px; margin-top: 8px; }
    .competitor-grid, .opp-grid { display: grid; gap: 14px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
    .findings { display: grid; gap: 12px; }
    details.finding { border: 1px solid var(--gray-200); border-radius: 12px; overflow: hidden; background: #fff; }
    details.finding summary { cursor: pointer; padding: 16px 18px; font-weight: 700; }
    .finding-body { padding: 0 18px 18px; }
    .badge, .effort { display: inline-flex; align-items: center; border-radius: 999px; padding: 4px 10px; font-size: 12px; font-weight: 700; }
    .badge-low, .effort-low { background: #dcfce7; color: #166534; }
    .badge-medium, .effort-medium { background: #fef3c7; color: #92400e; }
    .badge-high, .effort-high { background: #fee2e2; color: #991b1b; }
    table { width: 100%; border-collapse: collapse; overflow: hidden; }
    th, td { padding: 14px 12px; border-bottom: 1px solid var(--gray-200); text-align: left; vertical-align: top; }
    th { color: var(--gray-600); font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
    .internal-notes { margin-top: 18px; padding: 22px; border-radius: var(--radius); background: #111827; color: #fff; }
    .internal-notes.hidden { display: block; }
    .internal-notes h2, .internal-notes h3 { color: #fff; }
    .section-toggle { margin: 14px 0 0; background: rgba(255,255,255,.12); color: #fff; border: 0; padding: 10px 14px; border-radius: 999px; cursor: pointer; }
    .hidden-panel { display: none; }
    .hidden-panel.open { display: block; }
    @media (max-width: 720px) {
      .wrap { padding-inline: 14px; }
      .section, .cover { padding: 18px; }
      table, thead, tbody, tr, th, td { display: block; width: 100%; }
      thead { display: none; }
      tr { border-bottom: 1px solid var(--gray-200); padding: 10px 0; }
      td { border: 0; padding: 6px 0; }
      td::before { content: attr(data-label) ": "; font-weight: 700; color: var(--gray-600); }
    }
  </style>
</head>
<body>
  <div class="wrap">
    <header class="cover">
      <div class="muted" style="text-transform:uppercase;letter-spacing:2px;font-size:11px;">Local Business Digital Audit</div>
      <h1>${output.businessName}</h1>
      <p class="subtitle">${output.summary}</p>
      <div class="cover-grid">
        <div class="cover-item"><div class="label">Maps listing</div><div class="value">${research.listing.rating ?? '—'} / ${research.listing.reviewCount ?? '—'} reviews</div></div>
        <div class="cover-item"><div class="label">Website</div><div class="value">${research.website.status}</div></div>
        <div class="cover-item"><div class="label">Competitors</div><div class="value">${research.competitors.length}</div></div>
        <div class="cover-item"><div class="label">Audit date</div><div class="value">${new Date(output.capturedAt).toLocaleString('en-GB')}</div></div>
      </div>
    </header>

    <section class="section">
      <h2>Executive Summary</h2>
      <p class="muted">${output.summary}</p>
    </section>

    <section class="section">
      <h2>Scores</h2>
      <div class="gauge-grid">${scoreCards}</div>
    </section>

    <section class="section">
      <h2>Competitor Snapshot</h2>
      <div class="competitor-grid">${competitorCards || '<p class="muted">No competitor data captured.</p>'}</div>
    </section>

    <section class="section">
      <h2>The 3 Biggest Opportunities</h2>
      <div class="opp-grid">${opportunityCards || '<p class="muted">No clear opportunities detected.</p>'}</div>
    </section>

    <section class="section">
      <h2>Detailed Findings</h2>
      <div class="findings">${findingItems}</div>
    </section>

    <section class="section">
      <h2>Priority Action Plan</h2>
      <table>
        <thead>
          <tr><th>#</th><th>Fix</th><th>Why it matters</th><th>Effort</th><th>Who</th></tr>
        </thead>
        <tbody>${actionRows}</tbody>
      </table>
    </section>

    <section class="section">
      <h2>Limitations &amp; Caveats</h2>
      <ul>${output.limitations.map((item) => `<li>${item}</li>`).join('')}</ul>
    </section>

    <section class="internal-notes hidden" id="internalNotes">
      <h2>Internal Notes</h2>
      <p class="muted" style="color:rgba(255,255,255,.72)">Not for client delivery.</p>
      <button class="section-toggle" id="toggleInternal">Toggle evidence details</button>
      <div class="hidden-panel" id="internalPanel">
        <h3>Evidence Quality</h3>
        <ul>${output.internalNotes.evidenceQuality.map((item) => `<li>${item}</li>`).join('')}</ul>

        <h3>Risk Matrix</h3>
        <table>
          <thead><tr><th>Flag</th><th>Severity</th><th>Detail</th></tr></thead>
          <tbody>${internalRiskRows}</tbody>
        </table>

        <h3>Source Log</h3>
        <table>
          <thead><tr><th>Source</th><th>Status</th><th>Timestamp</th><th>Notes</th></tr></thead>
          <tbody>${sourceRows}</tbody>
        </table>

        <h3>Directory Checks</h3>
        <table>
          <thead><tr><th>Platform</th><th>Status</th><th>Rating</th><th>Reviews</th><th>Last active</th><th>Notes</th></tr></thead>
          <tbody>${directoryRows}</tbody>
        </table>
      </div>
    </section>
  </div>
  <script>
    const toggle = document.getElementById('toggleInternal');
    const panel = document.getElementById('internalPanel');
    if (toggle && panel) {
      toggle.addEventListener('click', () => panel.classList.toggle('open'));
    }
  </script>
</body>
</html>`;
}

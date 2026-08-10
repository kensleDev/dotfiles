export type SourceStatus = 'ok' | 'blocked' | 'not_found' | 'manual' | 'error';

export interface SourceEvidence {
  source: string;
  status: SourceStatus;
  sourceUrl?: string;
  capturedAt: string;
  title?: string;
  notes?: string;
  rawText?: string;
  html?: string;
  links?: string[];
  facts?: Record<string, unknown>;
}

export interface ParsedMapsUrl {
  inputUrl: string;
  canonicalUrl: string;
  slug: string;
  placeId?: string;
  query?: string;
}

export interface GoogleMapsListing {
  source: 'google-maps';
  status: SourceStatus;
  sourceUrl: string;
  capturedAt: string;
  title?: string;
  name?: string;
  category?: string;
  description?: string;
  rating?: number;
  reviewCount?: number;
  address?: string;
  phone?: string;
  website?: string;
  hours?: string[];
  rawText?: string;
  links?: string[];
  notes?: string;
}

export interface CompetitorEntry {
  name: string;
  url?: string;
  rating?: number;
  reviewCount?: number;
  note?: string;
}

export interface WebsitePageSummary {
  url: string;
  title?: string;
  status: SourceStatus;
  text?: string;
  links?: string[];
  notes?: string;
}

export interface WebsiteSummary extends SourceEvidence {
  source: 'website';
  pages: WebsitePageSummary[];
  primaryDomain?: string;
  contactEmail?: string;
  contactPhone?: string;
  orderLinks?: string[];
  menuLinks?: string[];
}

export interface DirectoryPlatformSummary extends SourceEvidence {
  source: 'directories';
  platform: string;
  foundUrl?: string;
  rating?: number;
  reviewCount?: number;
  lastActive?: string;
  replyActivity?: string;
}

export interface BusinessResearch {
  slug: string;
  businessName: string;
  canonicalUrl: string;
  capturedAt: string;
  parsedUrl: ParsedMapsUrl;
  listing: GoogleMapsListing;
  competitors: CompetitorEntry[];
  website: WebsiteSummary;
  directories: DirectoryPlatformSummary[];
  sources: SourceEvidence[];
}

export interface ScoreCard {
  label: string;
  score: number;
  max: number;
  note: string;
}

export interface OpportunityItem {
  title: string;
  whyItMatters: string;
  effort: 'Low' | 'Medium' | 'High';
  owner: string;
}

export interface FindingItem {
  title: string;
  detail: string;
  severity: 'Low' | 'Medium' | 'High';
}

export interface RiskFlag {
  flag: string;
  severity: 'Low' | 'Medium' | 'High';
  detail: string;
}

export interface ActionItem {
  rank: number;
  fix: string;
  whyItMatters: string;
  effort: 'Low' | 'Medium' | 'High';
  who: string;
}

export interface AuditOutput {
  slug: string;
  businessName: string;
  capturedAt: string;
  summary: string;
  scores: ScoreCard[];
  opportunities: OpportunityItem[];
  findings: FindingItem[];
  actionPlan: ActionItem[];
  limitations: string[];
  internalNotes: {
    evidenceQuality: string[];
    riskMatrix: RiskFlag[];
    sourceLog: Array<{ source: string; status: string; timestamp: string; notes?: string }>;
  };
  raw: Record<string, unknown>;
}

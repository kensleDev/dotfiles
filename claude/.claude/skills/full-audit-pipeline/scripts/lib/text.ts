export function collapseWhitespace(value: string): string {
  return value.replace(/\s+/g, ' ').trim();
}

export function textLines(value: string): string[] {
  return value
    .split(/\r?\n/)
    .map((line) => collapseWhitespace(line))
    .filter(Boolean);
}

export function truncate(value: string, max = 220): string {
  if (value.length <= max) return value;
  return `${value.slice(0, max - 1).trimEnd()}…`;
}

export function toSentence(value: string): string {
  const trimmed = collapseWhitespace(value);
  if (!trimmed) return trimmed;
  return /[.!?]$/.test(trimmed) ? trimmed : `${trimmed}.`;
}

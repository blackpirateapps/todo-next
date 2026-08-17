import { Reference, ReferenceSmartAction } from '@/types/todo';

/**
 * Extract phone numbers, URLs, emails, and addresses from text cleanly and conservatively
 */
export function detectSmartActions(content: string): ReferenceSmartAction[] {
  if (!content || typeof content !== 'string') return [];

  const actions: ReferenceSmartAction[] = [];
  const trimmed = content.trim();

  // 1. Phone numbers
  // Matches international format (+91 98765 43210, +1-555-123-4567) or standard formats (9876543210, 555-123-4567, (555) 123-4567)
  const phoneRegex = /(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\+?\d{1,3}[-.\s]?\d{4,5}[-.\s]?\d{4,6}/g;
  const phoneMatches = trimmed.match(phoneRegex);
  if (phoneMatches) {
    for (const match of phoneMatches) {
      const cleanPhone = match.trim();
      const digitsOnly = cleanPhone.replace(/[^\d+]/g, '');
      if (digitsOnly.length >= 7 && digitsOnly.length <= 15) {
        if (!actions.some(a => a.value === cleanPhone)) {
          actions.push({
            type: 'phone',
            value: cleanPhone,
            label: `Call ${cleanPhone}`,
            actionUrl: `tel:${cleanPhone.replace(/\s+/g, '')}`
          });
        }
      }
    }
  }

  // 2. URLs
  const urlRegex = /(?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*/gi;
  const urlMatches = trimmed.match(urlRegex);
  if (urlMatches) {
    for (const match of urlMatches) {
      const cleanUrl = match.trim();
      const href = cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')
        ? cleanUrl
        : `https://${cleanUrl}`;
      if (!actions.some(a => a.value === cleanUrl)) {
        actions.push({
          type: 'url',
          value: cleanUrl,
          label: `Open ${cleanUrl.length > 25 ? cleanUrl.substring(0, 22) + '...' : cleanUrl}`,
          actionUrl: href
        });
      }
    }
  }

  // 3. Email addresses
  const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
  const emailMatches = trimmed.match(emailRegex);
  if (emailMatches) {
    for (const match of emailMatches) {
      const cleanEmail = match.trim();
      if (!actions.some(a => a.value === cleanEmail)) {
        actions.push({
          type: 'email',
          value: cleanEmail,
          label: `Email ${cleanEmail}`,
          actionUrl: `mailto:${cleanEmail}`
        });
      }
    }
  }

  // 4. Physical Address Detection (conservative)
  // Look for common address keywords (Road, Street, Ave, St, Rd, Blvd, Lane, Marg, Nagar, Bandra, etc.)
  const addressKeywords = /\b(Street|St\.?|Road|Rd\.?|Avenue|Ave\.?|Boulevard|Blvd\.?|Lane|Ln\.?|Drive|Dr\.?|Court|Ct\.?|Highway|Hwy\.?|Nagar|Marg|Sector|Plot|Floor|Apt|Suite|Apartment|Building)\b/i;
  const lines = trimmed.split('\n');
  for (const line of lines) {
    const trimmedLine = line.trim();
    if (trimmedLine.length >= 10 && addressKeywords.test(trimmedLine)) {
      // Check if it's not a pure URL or email
      if (!trimmedLine.startsWith('http') && !trimmedLine.includes('@') && !actions.some(a => a.type === 'address')) {
        const safeQuery = encodeURIComponent(trimmedLine);
        actions.push({
          type: 'address',
          value: trimmedLine,
          label: `Map "${trimmedLine.length > 20 ? trimmedLine.substring(0, 18) + '...' : trimmedLine}"`,
          actionUrl: `https://www.google.com/maps/search/?api=1&query=${safeQuery}`
        });
        break;
      }
    }
  }

  return actions;
}

/**
 * Format full reference for clipboard copy
 */
export function formatReferenceForCopy(reference: Reference): string {
  const parts: string[] = [];
  if (reference.title && reference.title.trim()) {
    parts.push(reference.title.trim());
  }
  if (reference.content && reference.content.trim()) {
    parts.push(reference.content.trim());
  }
  if (reference.tags && reference.tags.length > 0) {
    parts.push(reference.tags.join(' '));
  }
  return parts.join('\n');
}

/**
 * Extract tags (+project or @context or general tags) from text
 */
export function extractTagsFromText(text: string): string[] {
  if (!text) return [];
  const words = text.split(/\s+/);
  const tags = new Set<string>();

  for (const word of words) {
    if ((word.startsWith('+') || word.startsWith('@')) && word.length > 1) {
      tags.add(word);
    }
  }

  return Array.from(tags);
}

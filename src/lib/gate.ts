const GATE_KEY = 'e3087205509900d6c862f806ccd58d1d';

export async function generateGateToken(): Promise<string> {
  const ts = Math.floor(Date.now() / 30000).toString();
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey('raw', enc.encode(GATE_KEY), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const sig = await crypto.subtle.sign('HMAC', key, enc.encode(ts));
  const token = Array.from(new Uint8Array(sig)).map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 16);
  return `?t=${token}&ts=${ts}`;
}

export function isGatedDomain(domain: string): boolean {
  return domain.startsWith('max.') || domain.startsWith('claude.');
}

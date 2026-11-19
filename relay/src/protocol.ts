/**
 * Relay protocol version 1 (docs/plans/2026-11-20-sync-plan.md, P6). The
 * Dart side is `sync_messages.dart`; the two must agree field for field.
 * Blobs are unpadded base64url and stay opaque here.
 */
export const PROTOCOL_VERSION = 1;
export const MIN_PROTOCOL_VERSION = 1;

/** Largest message accepted: a compacted snapshot of a heavy user. */
export const MAX_MESSAGE_CHARS = 8 * 1024 * 1024;
/** Largest sealed frame, as base64url characters. */
export const MAX_FRAME_CHARS = 1024 * 1024;
export const MAX_FRAMES_PER_PUSH = 100;
/** Largest catch-up message sent; a longer backlog goes in several. */
export const MAX_CATCH_UP_CHARS = 4 * 1024 * 1024;

export interface DeviceInfo {
  deviceId: string;
  name: string;
  platform: string;
  publicKey: string;
}

export type ClientMessage =
  | {
      type: 'create';
      accountId: string;
      authVerifier: string;
      syncWrap: string;
      device: DeviceInfo;
    }
  | { type: 'enroll'; accountId: string; authSecret: string; device: DeviceInfo }
  | {
      type: 'hello';
      protocolVersion: number;
      accountId: string;
      deviceId: string;
      token: string;
      cursor: number;
    }
  | { type: 'push'; frames: { clientId: string; blob: string }[] }
  | { type: 'snapshot'; coversSeq: number; blob: string };

export type ErrorCode =
  | 'unauthorized'
  | 'revoked'
  | 'tooOld'
  | 'invalid'
  | 'exists'
  | 'rateLimited';

const BASE64URL = /^[A-Za-z0-9_-]*$/;

/** 16 bytes as unpadded base64url. */
export function isAccountId(value: string): boolean {
  return value.length === 22 && BASE64URL.test(value);
}

export function decodeBase64Url(text: string): Uint8Array {
  const b64 = text.replace(/-/g, '+').replace(/_/g, '/');
  const padded = b64 + '='.repeat((4 - (b64.length % 4)) % 4);
  const binary = atob(padded);
  const out = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) out[i] = binary.charCodeAt(i);
  return out;
}

export function encodeBase64Url(bytes: Uint8Array): string {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

class Invalid extends Error {}

function str(v: unknown, max = 4096): string {
  if (typeof v !== 'string' || max < v.length) throw new Invalid();
  return v;
}

function b64(v: unknown, max = 4096): string {
  const s = str(v, max);
  // A length of 1 mod 4 cannot encode whole bytes, and atob would throw
  // outside the parser.
  if (!BASE64URL.test(s) || s.length % 4 === 1) throw new Invalid();
  return s;
}

/** A 32-byte key, secret, or token: exactly 43 base64url characters. */
function key32(v: unknown): string {
  const s = b64(v, 43);
  if (s.length !== 43) throw new Invalid();
  return s;
}

function accountId(v: unknown): string {
  const s = str(v, 22);
  if (!isAccountId(s)) throw new Invalid();
  return s;
}

function int(v: unknown): number {
  if (typeof v !== 'number' || !Number.isSafeInteger(v) || v < 0) {
    throw new Invalid();
  }
  return v;
}

function obj(v: unknown): Record<string, unknown> {
  if (typeof v !== 'object' || v === null || Array.isArray(v)) {
    throw new Invalid();
  }
  return v as Record<string, unknown>;
}

function device(v: unknown): DeviceInfo {
  const d = obj(v);
  return {
    deviceId: str(d.deviceId, 64),
    name: str(d.name, 128),
    platform: str(d.platform, 16),
    publicKey: key32(d.publicKey),
  };
}

/** Parses one client message; null for anything malformed. */
export function parseClientMessage(text: string): ClientMessage | null {
  try {
    const m = obj(JSON.parse(text));
    switch (m.type) {
      case 'create':
        return {
          type: 'create',
          accountId: accountId(m.accountId),
          authVerifier: key32(m.authVerifier),
          syncWrap: b64(m.syncWrap, 256),
          device: device(m.device),
        };
      case 'enroll':
        return {
          type: 'enroll',
          accountId: accountId(m.accountId),
          authSecret: key32(m.authSecret),
          device: device(m.device),
        };
      case 'hello':
        return {
          type: 'hello',
          protocolVersion: int(m.protocolVersion),
          accountId: accountId(m.accountId),
          deviceId: str(m.deviceId, 64),
          token: key32(m.token),
          cursor: int(m.cursor),
        };
      case 'push': {
        if (!Array.isArray(m.frames) || MAX_FRAMES_PER_PUSH < m.frames.length) {
          return null;
        }
        return {
          type: 'push',
          frames: m.frames.map((f) => {
            const o = obj(f);
            return { clientId: str(o.clientId, 64), blob: b64(o.blob, MAX_FRAME_CHARS) };
          }),
        };
      }
      case 'snapshot':
        return {
          type: 'snapshot',
          coversSeq: int(m.coversSeq),
          blob: b64(m.blob, MAX_MESSAGE_CHARS),
        };
      default:
        return null;
    }
  } catch {
    return null;
  }
}

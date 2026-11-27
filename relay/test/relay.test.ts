import { SELF } from 'cloudflare:test';
import { describe, expect, it } from 'vitest';

import { encodeBase64Url } from '../src/protocol';

type Message = Record<string, unknown> & { type: string };

/** One device's socket with a queue of what the relay sent it. */
class Client {
  private readonly queue: Message[] = [];
  private readonly waiters: ((m: Message) => void)[] = [];

  private constructor(private readonly ws: WebSocket) {
    ws.addEventListener('message', (e) => {
      const m = JSON.parse(e.data as string) as Message;
      const waiter = this.waiters.shift();
      if (waiter) waiter(m);
      else this.queue.push(m);
    });
  }

  static async open(account: string, source = '192.0.2.1'): Promise<Client> {
    const res = await SELF.fetch(`https://relay.test/v1/connect?account=${account}`, {
      headers: { Upgrade: 'websocket', 'CF-Connecting-IP': source },
    });
    expect(res.status).toBe(101);
    const ws = res.webSocket!;
    ws.accept();
    return new Client(ws);
  }

  send(m: unknown): void {
    this.ws.send(typeof m === 'string' ? m : JSON.stringify(m));
  }

  next(): Promise<Message> {
    const m = this.queue.shift();
    if (m) return Promise.resolve(m);
    return new Promise((resolve) => this.waiters.push(resolve));
  }

  close(): void {
    this.ws.close();
  }
}

function randomBytes(n: number): Uint8Array {
  return crypto.getRandomValues(new Uint8Array(n));
}

/**
 * Bytes laid out as a client seals them: algId, keyVersion (big endian),
 * then [body]; the relay reads only the header. [prefix] bytes lead, as
 * the ephemeral public key of a device wrap does.
 */
function sealed(body: string, version = 1, prefix = 0): string {
  const text = new TextEncoder().encode(body);
  const out = new Uint8Array(prefix + 5 + text.length);
  out.set(randomBytes(prefix), 0);
  out[prefix] = 1;
  new DataView(out.buffer).setUint32(prefix + 1, version);
  out.set(text, prefix + 5);
  return encodeBase64Url(out);
}

async function sha256(bytes: Uint8Array): Promise<Uint8Array> {
  return new Uint8Array(await crypto.subtle.digest('SHA-256', bytes));
}

function device(id: string) {
  return {
    deviceId: id,
    name: id,
    platform: 'ios',
    publicKey: encodeBase64Url(randomBytes(32)),
    tag: encodeBase64Url(randomBytes(32)),
  };
}

async function newAccount() {
  const accountId = encodeBase64Url(randomBytes(16));
  const authSecret = randomBytes(32);
  return {
    accountId,
    authSecret: encodeBase64Url(authSecret),
    authVerifier: encodeBase64Url(await sha256(authSecret)),
    syncWrap: sealed('wrap'),
  };
}

/** Creates an account from device A and returns its socket and token. */
async function create(acct: Awaited<ReturnType<typeof newAccount>>) {
  const a = await Client.open(acct.accountId);
  a.send({
    type: 'create',
    protocolVersion: 1,
    accountId: acct.accountId,
    authVerifier: acct.authVerifier,
    syncWrap: acct.syncWrap,
    device: device('A'),
  });
  const welcome = await a.next();
  expect(welcome.type).toBe('welcome');
  expect(await a.next()).toEqual({ type: 'frames', frames: [] });
  return { a, token: welcome.token as string };
}

async function enroll(acct: Awaited<ReturnType<typeof newAccount>>, id: string) {
  const c = await Client.open(acct.accountId);
  c.send({
    type: 'enroll',
    protocolVersion: 1,
    accountId: acct.accountId,
    authSecret: acct.authSecret,
    device: device(id),
  });
  const welcome = await c.next();
  const frames = await c.next();
  return { c, welcome, frames };
}

const A1 = sealed('frame A');
const B1 = sealed('frame B');
const PRES = sealed('presence');
const SNAP = sealed('snapshot');

describe('relay', () => {
  it('creates an account and issues a token', async () => {
    const acct = await newAccount();
    const { token } = await create(acct);
    expect(token).toMatch(/^[A-Za-z0-9_-]{43}$/);
  });

  it('refuses to create an account twice', async () => {
    const acct = await newAccount();
    await create(acct);
    const again = await Client.open(acct.accountId);
    again.send({
      type: 'create',
      protocolVersion: 1,
      accountId: acct.accountId,
      authVerifier: acct.authVerifier,
      syncWrap: acct.syncWrap,
      device: device('X'),
    });
    expect(await again.next()).toEqual({ type: 'error', code: 'exists' });
  });

  it('enrolls with the sync key and hands out the wrap and devices', async () => {
    const acct = await newAccount();
    await create(acct);
    const { welcome } = await enroll(acct, 'B');
    expect(welcome.type).toBe('welcome');
    expect(welcome.syncWrap).toBe(acct.syncWrap);
    expect((welcome.devices as { deviceId: string }[]).map((d) => d.deviceId)).toEqual([
      'A',
      'B',
    ]);
  });

  it('refuses a wrong sync key, and stops trying after too many', async () => {
    const acct = await newAccount();
    await create(acct);
    const c = await Client.open(acct.accountId);
    const attempt = () =>
      c.send({
        type: 'enroll',
        protocolVersion: 1,
        accountId: acct.accountId,
        authSecret: encodeBase64Url(randomBytes(32)),
        device: device('M'),
      });
    for (let i = 0; i < 10; i++) {
      attempt();
      expect(await c.next()).toEqual({ type: 'error', code: 'unauthorized' });
    }
    attempt();
    expect(await c.next()).toEqual({ type: 'error', code: 'rateLimited' });
  });

  it('resumes with the token and refuses a forged one', async () => {
    const acct = await newAccount();
    const { token } = await create(acct);
    const ok = await Client.open(acct.accountId);
    ok.send({ type: 'hello', protocolVersion: 1, accountId: acct.accountId, deviceId: 'A', token, cursor: 0 });
    expect((await ok.next()).type).toBe('welcome');

    const forged = await Client.open(acct.accountId);
    forged.send({
      type: 'hello',
      protocolVersion: 1,
      accountId: acct.accountId,
      deviceId: 'A',
      token: encodeBase64Url(randomBytes(32)),
      cursor: 0,
    });
    expect(await forged.next()).toEqual({ type: 'error', code: 'unauthorized' });
  });

  it('orders frames, fans them out, and acknowledges them', async () => {
    const acct = await newAccount();
    const { a } = await create(acct);
    const { c: b } = await enroll(acct, 'B');

    a.send({ type: 'push', frames: [{ clientId: 'c1', blob: A1 }, { clientId: 'c2', blob: B1 }] });

    expect(await b.next()).toEqual({
      type: 'frames',
      frames: [
        { seq: 1, deviceId: 'A', blob: A1 },
        { seq: 2, deviceId: 'A', blob: B1 },
      ],
    });
    expect(await a.next()).toEqual({
      type: 'pushed',
      acks: [
        { clientId: 'c1', seq: 1 },
        { clientId: 'c2', seq: 2 },
      ],
    });
  });

  it('forwards presence to the other devices without storing it', async () => {
    const acct = await newAccount();
    const { a } = await create(acct);
    const { c: b } = await enroll(acct, 'B');

    a.send({ type: 'presence', blob: PRES });

    expect(await b.next()).toEqual({ type: 'presence', deviceId: 'A', blob: PRES });
    // Not kept: a device connecting later catches up on nothing.
    const { frames } = await enroll(acct, 'C');
    expect(frames).toEqual({ type: 'frames', frames: [] });
  });

  it('refuses presence before a session opens', async () => {
    const acct = await newAccount();
    await create(acct);
    const c = await Client.open(acct.accountId);

    c.send({ type: 'presence', blob: PRES });

    expect(await c.next()).toEqual({ type: 'error', code: 'unauthorized' });
  });

  it('catches a device up from its cursor', async () => {
    const acct = await newAccount();
    const { a, token } = await create(acct);
    a.send({ type: 'push', frames: [{ clientId: 'c1', blob: A1 }, { clientId: 'c2', blob: B1 }] });
    await a.next();

    const again = await Client.open(acct.accountId);
    again.send({ type: 'hello', protocolVersion: 1, accountId: acct.accountId, deviceId: 'A', token, cursor: 1 });
    await again.next();
    expect(await again.next()).toEqual({
      type: 'frames',
      frames: [{ seq: 2, deviceId: 'A', blob: B1 }],
    });
  });

  it('keeps a snapshot in place of the frames it covers', async () => {
    const acct = await newAccount();
    const { a } = await create(acct);
    a.send({ type: 'push', frames: [{ clientId: 'c1', blob: A1 }, { clientId: 'c2', blob: B1 }] });
    await a.next();

    a.send({ type: 'snapshot', coversSeq: 1, blob: SNAP });
    expect(await a.next()).toEqual({ type: 'stored', coversSeq: 1 });

    const { welcome, frames } = await enroll(acct, 'B');
    expect(welcome.snapshot).toEqual({ coversSeq: 1, blob: SNAP });
    expect(frames).toEqual({ type: 'frames', frames: [{ seq: 2, deviceId: 'A', blob: B1 }] });
  });

  it('refuses a snapshot ahead of the frames it claims to cover', async () => {
    const acct = await newAccount();
    const { a } = await create(acct);
    a.send({ type: 'snapshot', coversSeq: 5, blob: SNAP });
    expect(await a.next()).toEqual({ type: 'error', code: 'invalid' });
  });

  it('refuses pushes before a session opens', async () => {
    const acct = await newAccount();
    await create(acct);
    const stranger = await Client.open(acct.accountId);
    stranger.send({ type: 'push', frames: [{ clientId: 'c1', blob: A1 }] });
    expect(await stranger.next()).toEqual({ type: 'error', code: 'unauthorized' });
  });

  it('rejects malformed messages', async () => {
    const acct = await newAccount();
    const c = await Client.open(acct.accountId);
    c.send('not json');
    expect(await c.next()).toEqual({ type: 'error', code: 'invalid' });
    c.send({ type: 'push', frames: 'nope' });
    expect(await c.next()).toEqual({ type: 'error', code: 'invalid' });
  });

  it('rejects a connection without a valid account id', async () => {
    const res = await SELF.fetch('https://relay.test/v1/connect?account=short', {
      headers: { Upgrade: 'websocket' },
    });
    expect(res.status).toBe(400);
  });

  it("a stranger's failures do not lock out the account's devices", async () => {
    const acct = await newAccount();
    const { token } = await create(acct);
    const stranger = await Client.open(acct.accountId, '198.51.100.7');
    for (let i = 0; i < 10; i++) {
      stranger.send({
        type: 'enroll',
        protocolVersion: 1,
        accountId: acct.accountId,
        authSecret: encodeBase64Url(randomBytes(32)),
        device: device('M'),
      });
      await stranger.next();
    }
    for (let i = 0; i < 30; i++) {
      stranger.send({
        type: 'hello',
        protocolVersion: 1,
        accountId: acct.accountId,
        deviceId: 'A',
        token: encodeBase64Url(randomBytes(32)),
        cursor: 0,
      });
      await stranger.next();
    }

    const { welcome } = await enroll(acct, 'B');
    expect(welcome.type).toBe('welcome');
    const a = await Client.open(acct.accountId);
    a.send({ type: 'hello', protocolVersion: 1, accountId: acct.accountId, deviceId: 'A', token, cursor: 0 });
    expect((await a.next()).type).toBe('welcome');
  });

  it('rejects credentials of the wrong length', async () => {
    const acct = await newAccount();
    await create(acct);
    const c = await Client.open(acct.accountId);
    c.send({ type: 'enroll', protocolVersion: 1, accountId: acct.accountId, authSecret: 'A', device: device('M') });
    expect(await c.next()).toEqual({ type: 'error', code: 'invalid' });
    c.send({ type: 'hello', protocolVersion: 1, accountId: acct.accountId, deviceId: 'A', token: 'AAAA', cursor: 0 });
    expect(await c.next()).toEqual({ type: 'error', code: 'invalid' });
  });

  it('splits a long catch-up into several messages in seq order', async () => {
    const acct = await newAccount();
    const { a } = await create(acct);
    // 12 frames of ~0.9 MB: more than one 4 MB message.
    const blob = sealed('A'.repeat(675_000));
    for (let i = 0; i < 3; i++) {
      a.send({
        type: 'push',
        frames: Array.from({ length: 4 }, (_, j) => ({ clientId: `c${i}-${j}`, blob })),
      });
      await a.next();
    }

    const { c, welcome, frames } = await enroll(acct, 'B');
    expect(welcome.type).toBe('welcome');
    const seqs: number[] = [];
    let messages = 0;
    let m = frames;
    for (;;) {
      expect(m.type).toBe('frames');
      messages++;
      seqs.push(...(m.frames as { seq: number }[]).map((f) => f.seq));
      if (seqs.length === 12) {
        expect(m.more).toBeUndefined();
        break;
      }
      expect(m.more).toBe(true);
      m = await c.next();
    }
    expect(1 < messages).toBe(true);
    expect(seqs).toEqual(Array.from({ length: 12 }, (_, i) => i + 1));
  });

  describe('revoke', () => {
    /** A creates, B and C enroll; returns their sockets and tokens. */
    async function threeDevices() {
      const acct = await newAccount();
      const { a } = await create(acct);
      const b = await enroll(acct, 'B');
      const c = await enroll(acct, 'C');
      return { acct, a, b: b.c, bToken: b.welcome.token as string, c: c.c, cToken: c.welcome.token as string };
    }

    async function rotated() {
      const secret = randomBytes(32);
      return {
        authSecret: encodeBase64Url(secret),
        newAuthVerifier: encodeBase64Url(await sha256(secret)),
        newSyncWrap: sealed('wrap 2', 2),
      };
    }

    function revokeMessage(
      keys: Awaited<ReturnType<typeof rotated>>,
      target: string,
      wrapsFor: string[],
      opts: { coversSeq?: number; version?: number } = {},
    ) {
      const version = opts.version ?? 2;
      return {
        type: 'revoke',
        deviceId: target,
        newAuthVerifier: keys.newAuthVerifier,
        newSyncWrap: keys.newSyncWrap,
        deviceWraps: Object.fromEntries(wrapsFor.map((id) => [id, sealed(`keys for ${id}`, version, 32)])),
        deviceTags: Object.fromEntries(wrapsFor.map((id) => [id, encodeBase64Url(randomBytes(32))])),
        snapshot: { coversSeq: opts.coversSeq ?? 0, blob: sealed('state', version) },
      };
    }

    it('drops the device, re-keys the others, and locks out the old sync key', async () => {
      const { acct, a, b, bToken, c, cToken } = await threeDevices();
      a.send({ type: 'push', frames: [{ clientId: 'c1', blob: A1 }] });
      expect((await a.next()).type).toBe('pushed');
      expect((await b.next()).type).toBe('frames');
      expect((await c.next()).type).toBe('frames');
      const keys = await rotated();
      const message = revokeMessage(keys, 'C', ['A', 'B'], { coversSeq: 1 });
      a.send(message);

      expect(await a.next()).toEqual({ type: 'revoked', deviceId: 'C' });
      expect(await c.next()).toEqual({ type: 'error', code: 'revoked' });
      expect(await b.next()).toEqual({ type: 'error', code: 'rekeyed' });

      // The revoked device hears why, on resuming and on enrolling again.
      const c2 = await Client.open(acct.accountId);
      c2.send({ type: 'hello', protocolVersion: 1, accountId: acct.accountId, deviceId: 'C', token: cToken, cursor: 0 });
      expect(await c2.next()).toEqual({ type: 'error', code: 'revoked' });
      const c3 = await Client.open(acct.accountId);
      c3.send({ type: 'enroll', protocolVersion: 1, accountId: acct.accountId, authSecret: keys.authSecret, device: device('C') });
      expect(await c3.next()).toEqual({ type: 'error', code: 'revoked' });

      // The old sync key no longer enrolls anyone.
      const stranger = await Client.open(acct.accountId, '192.0.2.9');
      stranger.send({ type: 'enroll', protocolVersion: 1, accountId: acct.accountId, authSecret: acct.authSecret, device: device('D') });
      expect(await stranger.next()).toEqual({ type: 'error', code: 'unauthorized' });

      // A remaining device finds its wrap and the re-sealed state.
      const b2 = await Client.open(acct.accountId);
      b2.send({ type: 'hello', protocolVersion: 1, accountId: acct.accountId, deviceId: 'B', token: bToken, cursor: 0 });
      const welcome = await b2.next();
      expect(welcome.deviceWrap).toBe(message.deviceWraps.B);
      expect(welcome.syncWrap).toBe(keys.newSyncWrap);
      // B was behind the snapshot: it gets the state, and no retired frame.
      expect(welcome.snapshot).toEqual(message.snapshot);
      expect(await b2.next()).toEqual({ type: 'frames', frames: [] });
      const listed = welcome.devices as { deviceId: string; tag: string }[];
      expect(listed.map((d) => d.deviceId)).toEqual(['A', 'B']);
      // Tagged under the new sync key now.
      expect(listed.map((d) => d.tag)).toEqual([message.deviceTags.A, message.deviceTags.B]);

      // The new sync key enrolls a new device.
      const d = await Client.open(acct.accountId);
      d.send({ type: 'enroll', protocolVersion: 1, accountId: acct.accountId, authSecret: keys.authSecret, device: device('D') });
      const dWelcome = await d.next();
      expect(dWelcome.type).toBe('welcome');
      expect(dWelcome.deviceWrap).toBeUndefined();
    });

    it('refuses what a retired data key sealed', async () => {
      const { a } = await threeDevices();
      a.send(revokeMessage(await rotated(), 'C', ['A', 'B']));
      expect((await a.next()).type).toBe('revoked');

      a.send({ type: 'push', frames: [{ clientId: 'c1', blob: A1 }] });
      expect(await a.next()).toEqual({ type: 'error', code: 'rekeyed' });
      a.send({ type: 'snapshot', coversSeq: 0, blob: SNAP });
      expect(await a.next()).toEqual({ type: 'error', code: 'rekeyed' });
      a.send({ type: 'presence', blob: PRES });
      expect(await a.next()).toEqual({ type: 'error', code: 'rekeyed' });

      a.send({ type: 'push', frames: [{ clientId: 'c2', blob: sealed('new', 2) }] });
      expect((await a.next()).type).toBe('pushed');
    });

    it('refuses a snapshot that does not cover the head', async () => {
      const { a, b } = await threeDevices();
      a.send({ type: 'push', frames: [{ clientId: 'c1', blob: A1 }] });
      expect((await a.next()).type).toBe('pushed');
      a.send(revokeMessage(await rotated(), 'C', ['A', 'B'], { coversSeq: 0 }));
      expect(await a.next()).toEqual({ type: 'revoked', deviceId: 'C', refused: 'behind' });
      // Nothing changed: B still pushes under the current key.
      expect((await b.next()).type).toBe('frames');
      b.send({ type: 'push', frames: [{ clientId: 'c2', blob: B1 }] });
      expect((await b.next()).type).toBe('pushed');
    });

    it('refuses wraps that miss a remaining device', async () => {
      const { a } = await threeDevices();
      a.send(revokeMessage(await rotated(), 'C', ['A']));
      const refusal = await a.next();
      expect(refusal).toMatchObject({ type: 'revoked', deviceId: 'C', refused: 'devicesChanged' });
      // The current list goes along, for the retry.
      expect((refusal.devices as { deviceId: string }[]).map((d) => d.deviceId)).toEqual(['A', 'B', 'C']);
    });

    it('refuses to revoke itself or a device it does not know', async () => {
      const { a } = await threeDevices();
      a.send(revokeMessage(await rotated(), 'A', ['B', 'C']));
      expect(await a.next()).toEqual({ type: 'revoked', deviceId: 'A', refused: 'unknownDevice' });
      a.send(revokeMessage(await rotated(), 'Z', ['A', 'B', 'C']));
      expect(await a.next()).toEqual({ type: 'revoked', deviceId: 'Z', refused: 'unknownDevice' });
    });

    it('rejects a revocation that does not move the key version on', async () => {
      const { a } = await threeDevices();
      const keys = { ...(await rotated()), newSyncWrap: sealed('wrap 1', 1) };
      a.send(revokeMessage(keys, 'C', ['A', 'B'], { version: 1 }));
      expect(await a.next()).toEqual({ type: 'error', code: 'invalid' });
      // Wraps sealed under another version than the new sync wrap.
      a.send(revokeMessage(await rotated(), 'C', ['A', 'B'], { version: 3 }));
      expect(await a.next()).toEqual({ type: 'error', code: 'invalid' });
    });

    it('refuses wraps whose tags miss a remaining device', async () => {
      const { a } = await threeDevices();
      const message = revokeMessage(await rotated(), 'C', ['A', 'B']);
      delete (message.deviceTags as Record<string, string>).B;
      a.send(message);
      expect(await a.next()).toMatchObject({ type: 'revoked', refused: 'devicesChanged' });
    });

    it('rejects a device registered without a tag', async () => {
      const acct = await newAccount();
      const x = await Client.open(acct.accountId);
      const { tag: _, ...untagged } = device('X');
      x.send({
        type: 'create',
        protocolVersion: 1,
        accountId: acct.accountId,
        authVerifier: acct.authVerifier,
        syncWrap: acct.syncWrap,
        device: untagged,
      });
      expect(await x.next()).toEqual({ type: 'error', code: 'invalid' });
    });

    it('refuses a revocation before a session opens', async () => {
      const { acct } = await threeDevices();
      const s = await Client.open(acct.accountId);
      s.send(revokeMessage(await rotated(), 'C', ['A', 'B']));
      expect(await s.next()).toEqual({ type: 'error', code: 'unauthorized' });
    });
  });
});

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

  static async open(account: string): Promise<Client> {
    const res = await SELF.fetch(`https://relay.test/v1/connect?account=${account}`, {
      headers: { Upgrade: 'websocket' },
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

async function sha256(bytes: Uint8Array): Promise<Uint8Array> {
  return new Uint8Array(await crypto.subtle.digest('SHA-256', bytes));
}

function device(id: string) {
  return { deviceId: id, name: id, platform: 'ios', publicKey: encodeBase64Url(randomBytes(32)) };
}

async function newAccount() {
  const accountId = encodeBase64Url(randomBytes(16));
  const authSecret = randomBytes(32);
  return {
    accountId,
    authSecret: encodeBase64Url(authSecret),
    authVerifier: encodeBase64Url(await sha256(authSecret)),
    syncWrap: encodeBase64Url(randomBytes(72)),
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

    a.send({ type: 'push', frames: [{ clientId: 'c1', blob: 'AAAA' }, { clientId: 'c2', blob: 'BBBB' }] });

    expect(await b.next()).toEqual({
      type: 'frames',
      frames: [
        { seq: 1, deviceId: 'A', blob: 'AAAA' },
        { seq: 2, deviceId: 'A', blob: 'BBBB' },
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

  it('catches a device up from its cursor', async () => {
    const acct = await newAccount();
    const { a, token } = await create(acct);
    a.send({ type: 'push', frames: [{ clientId: 'c1', blob: 'AAAA' }, { clientId: 'c2', blob: 'BBBB' }] });
    await a.next();

    const again = await Client.open(acct.accountId);
    again.send({ type: 'hello', protocolVersion: 1, accountId: acct.accountId, deviceId: 'A', token, cursor: 1 });
    await again.next();
    expect(await again.next()).toEqual({
      type: 'frames',
      frames: [{ seq: 2, deviceId: 'A', blob: 'BBBB' }],
    });
  });

  it('keeps a snapshot in place of the frames it covers', async () => {
    const acct = await newAccount();
    const { a } = await create(acct);
    a.send({ type: 'push', frames: [{ clientId: 'c1', blob: 'AAAA' }, { clientId: 'c2', blob: 'BBBB' }] });
    await a.next();

    a.send({ type: 'snapshot', coversSeq: 1, blob: 'SNAP' });
    expect(await a.next()).toEqual({ type: 'stored', coversSeq: 1 });

    const { welcome, frames } = await enroll(acct, 'B');
    expect(welcome.snapshot).toEqual({ coversSeq: 1, blob: 'SNAP' });
    expect(frames).toEqual({ type: 'frames', frames: [{ seq: 2, deviceId: 'A', blob: 'BBBB' }] });
  });

  it('refuses a snapshot ahead of the frames it claims to cover', async () => {
    const acct = await newAccount();
    const { a } = await create(acct);
    a.send({ type: 'snapshot', coversSeq: 5, blob: 'SNAP' });
    expect(await a.next()).toEqual({ type: 'error', code: 'invalid' });
  });

  it('refuses pushes before a session opens', async () => {
    const acct = await newAccount();
    await create(acct);
    const stranger = await Client.open(acct.accountId);
    stranger.send({ type: 'push', frames: [{ clientId: 'c1', blob: 'AAAA' }] });
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
});

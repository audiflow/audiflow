import { DurableObject } from 'cloudflare:workers';

import type { Env } from './index';
import {
  type ClientMessage,
  type DeviceInfo,
  type ErrorCode,
  MAX_CATCH_UP_CHARS,
  MAX_MESSAGE_CHARS,
  MIN_PROTOCOL_VERSION,
  decodeBase64Url,
  encodeBase64Url,
  parseClientMessage,
} from './protocol';

/** What a socket is, kept across hibernation. */
interface Attachment {
  /** Where the connection comes from, to count its failed attempts. */
  source: string;
  deviceId?: string;
}

/** Failed resumes and creates per source and minute. */
const MAX_FAILED_OPENINGS_PER_MINUTE = 30;
/** Wrong sync keys per source and hour before enrolling is refused. */
const MAX_FAILED_ENROLLS_PER_HOUR = 10;
/** Frames read per page while catching a device up. */
const CATCH_UP_PAGE = 200;

/**
 * One account: orders, stores, and fans out sealed frames, and keeps the
 * latest compacted snapshot (plan P1). It reads routing fields only; every
 * value it stores is ciphertext it cannot open (plan S3).
 *
 * Sockets use the hibernation API, so an idle account costs nothing while
 * its devices stay connected.
 */
export class AccountRelay extends DurableObject<Env> {
  private readonly sql: SqlStorage;

  /**
   * Failed attempts by source. Only failures count, so a stranger who
   * knows the account id cannot lock its devices out; and the 256-bit
   * sync key makes guessing hopeless anyway, so the limits only bound
   * load. In memory only: a hibernated or evicted object starts counting
   * again, which bounds abuse per wake-up rather than exactly.
   */
  private readonly failedOpenings = new Map<string, number[]>();
  private readonly failedEnrolls = new Map<string, number[]>();

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env);
    this.sql = ctx.storage.sql;
    this.sql.exec(`
      CREATE TABLE IF NOT EXISTS account (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        account_id TEXT NOT NULL,
        verifier TEXT NOT NULL,
        sync_wrap TEXT NOT NULL,
        head INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
      CREATE TABLE IF NOT EXISTS device (
        device_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        platform TEXT NOT NULL,
        public_key TEXT NOT NULL,
        token_hash TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        revoked_at INTEGER
      );
      CREATE TABLE IF NOT EXISTS frame (
        seq INTEGER PRIMARY KEY,
        device_id TEXT NOT NULL,
        blob TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS snapshot (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        covers_seq INTEGER NOT NULL,
        blob TEXT NOT NULL
      );
    `);
  }

  override async fetch(request: Request): Promise<Response> {
    if (request.headers.get('Upgrade') !== 'websocket') {
      return new Response('expected a websocket', { status: 426 });
    }
    const pair = new WebSocketPair();
    this.ctx.acceptWebSocket(pair[1]);
    const source = request.headers.get('CF-Connecting-IP') ?? 'unknown';
    pair[1].serializeAttachment({ source } satisfies Attachment);
    return new Response(null, { status: 101, webSocket: pair[0] });
  }

  override async webSocketMessage(
    ws: WebSocket,
    raw: string | ArrayBuffer,
  ): Promise<void> {
    if (typeof raw !== 'string' || MAX_MESSAGE_CHARS < raw.length) {
      return this.error(ws, 'invalid');
    }
    const message = parseClientMessage(raw);
    if (message === null) return this.error(ws, 'invalid');
    await this.handle(ws, message);
  }

  private async handle(ws: WebSocket, m: ClientMessage): Promise<void> {
    switch (m.type) {
      case 'create':
        return this.onCreate(ws, m);
      case 'enroll':
        return this.onEnroll(ws, m);
      case 'hello':
        return this.onHello(ws, m);
      case 'push':
        return this.onPush(ws, m.frames);
      case 'snapshot':
        return this.onSnapshot(ws, m.coversSeq, m.blob);
    }
  }

  private async onCreate(
    ws: WebSocket,
    m: Extract<ClientMessage, { type: 'create' }>,
  ): Promise<void> {
    const source = this.source(ws);
    if (!this.withinBudget(this.failedOpenings, source, MINUTE, MAX_FAILED_OPENINGS_PER_MINUTE)) {
      return this.error(ws, 'rateLimited');
    }
    if (this.account() !== null) {
      recordFailure(this.failedOpenings, source);
      return this.error(ws, 'exists');
    }
    this.sql.exec(
      'INSERT INTO account (id, account_id, verifier, sync_wrap, created_at) VALUES (1, ?, ?, ?, ?)',
      m.accountId,
      m.authVerifier,
      m.syncWrap,
      Date.now(),
    );
    const token = await this.addDevice(m.device);
    this.admit(ws, m.device.deviceId, { cursor: 0, token });
  }

  private async onEnroll(
    ws: WebSocket,
    m: Extract<ClientMessage, { type: 'enroll' }>,
  ): Promise<void> {
    const source = this.source(ws);
    if (!this.withinBudget(this.failedEnrolls, source, HOUR, MAX_FAILED_ENROLLS_PER_HOUR)) {
      return this.error(ws, 'rateLimited');
    }
    const account = this.account();
    const verifier = await sha256(decodeBase64Url(m.authSecret));
    if (
      account === null ||
      account.account_id !== m.accountId ||
      !timingSafeEqual(verifier, decodeBase64Url(account.verifier))
    ) {
      recordFailure(this.failedEnrolls, source);
      return this.error(ws, 'unauthorized');
    }
    const existing = this.device(m.device.deviceId);
    if (existing !== null && existing.revoked_at !== null) {
      return this.error(ws, 'revoked');
    }
    const token = await this.addDevice(m.device);
    this.admit(ws, m.device.deviceId, { cursor: 0, token });
  }

  private async onHello(
    ws: WebSocket,
    m: Extract<ClientMessage, { type: 'hello' }>,
  ): Promise<void> {
    if (m.protocolVersion < MIN_PROTOCOL_VERSION) {
      return this.error(ws, 'tooOld');
    }
    const source = this.source(ws);
    if (!this.withinBudget(this.failedOpenings, source, MINUTE, MAX_FAILED_OPENINGS_PER_MINUTE)) {
      return this.error(ws, 'rateLimited');
    }
    const account = this.account();
    const device = this.device(m.deviceId);
    const presented = await sha256(decodeBase64Url(m.token));
    if (
      account === null ||
      account.account_id !== m.accountId ||
      device === null ||
      !timingSafeEqual(presented, decodeBase64Url(device.token_hash))
    ) {
      recordFailure(this.failedOpenings, source);
      return this.error(ws, 'unauthorized');
    }
    if (device.revoked_at !== null) return this.error(ws, 'revoked');
    this.admit(ws, m.deviceId, { cursor: m.cursor, token: null });
  }

  private onPush(
    ws: WebSocket,
    frames: { clientId: string; blob: string }[],
  ): void {
    const deviceId = this.authed(ws);
    if (deviceId === null) return this.error(ws, 'unauthorized');
    const acks: { clientId: string; seq: number }[] = [];
    const stored: { seq: number; deviceId: string; blob: string }[] = [];
    this.ctx.storage.transactionSync(() => {
      let head = this.head();
      for (const f of frames) {
        head += 1;
        this.sql.exec(
          'INSERT INTO frame (seq, device_id, blob) VALUES (?, ?, ?)',
          head,
          deviceId,
          f.blob,
        );
        acks.push({ clientId: f.clientId, seq: head });
        stored.push({ seq: head, deviceId, blob: f.blob });
      }
      this.sql.exec('UPDATE account SET head = ? WHERE id = 1', head);
    });
    // Others first, then the ack: each socket sees frames in seq order.
    const fanout = JSON.stringify({ type: 'frames', frames: stored });
    for (const other of this.ctx.getWebSockets()) {
      if (other !== ws && this.authed(other) !== null) send(other, fanout);
    }
    send(ws, JSON.stringify({ type: 'pushed', acks }));
  }

  private onSnapshot(ws: WebSocket, coversSeq: number, blob: string): void {
    if (this.authed(ws) === null) return this.error(ws, 'unauthorized');
    if (this.head() < coversSeq) return this.error(ws, 'invalid');
    this.ctx.storage.transactionSync(() => {
      const current = this.snapshot();
      // An older snapshot than the one held changes nothing.
      if (current !== null && coversSeq < current.covers_seq) return;
      this.sql.exec(
        'INSERT INTO snapshot (id, covers_seq, blob) VALUES (1, ?, ?) ON CONFLICT (id) DO UPDATE SET covers_seq = excluded.covers_seq, blob = excluded.blob',
        coversSeq,
        blob,
      );
      this.sql.exec('DELETE FROM frame WHERE seq <= ?', coversSeq);
    });
    send(ws, JSON.stringify({ type: 'stored', coversSeq }));
  }

  /**
   * Sends `welcome`, then the catch-up `frames` (possibly empty): after the
   * snapshot when one goes along, else after the cursor. An enrolling
   * device gets the snapshot even at cursor 0, since it has merged nothing.
   */
  private admit(
    ws: WebSocket,
    deviceId: string,
    opts: { cursor: number; token: string | null },
  ): void {
    ws.serializeAttachment({ source: this.source(ws), deviceId } satisfies Attachment);
    const account = this.account()!;
    const snapshot = this.snapshot();
    const sendSnapshot =
      snapshot !== null && (opts.token !== null || opts.cursor < snapshot.covers_seq);
    const devices = this.sql
      .exec<{ device_id: string; name: string; platform: string; public_key: string }>(
        'SELECT device_id, name, platform, public_key FROM device WHERE revoked_at IS NULL ORDER BY added_at',
      )
      .toArray()
      .map((d) => ({
        deviceId: d.device_id,
        name: d.name,
        platform: d.platform,
        publicKey: d.public_key,
      }));
    send(
      ws,
      JSON.stringify({
        type: 'welcome',
        minProtocolVersion: MIN_PROTOCOL_VERSION,
        ...(opts.token === null ? {} : { token: opts.token }),
        syncWrap: account.sync_wrap,
        ...(sendSnapshot
          ? { snapshot: { coversSeq: snapshot.covers_seq, blob: snapshot.blob } }
          : {}),
        devices,
      }),
    );
    this.sendCatchUp(ws, sendSnapshot ? snapshot.covers_seq : opts.cursor);
  }

  /**
   * Sends every frame after [after] in seq order, paged from storage and
   * split into messages of at most [MAX_CATCH_UP_CHARS], so a long backlog
   * never sits in memory whole. Always sends at least one (possibly empty)
   * message. Storage calls are synchronous, so no push interleaves.
   */
  private sendCatchUp(ws: WebSocket, after: number): void {
    let batch: { seq: number; deviceId: string; blob: string }[] = [];
    let chars = 0;
    let sent = false;
    const flush = () => {
      send(ws, JSON.stringify({ type: 'frames', frames: batch }));
      batch = [];
      chars = 0;
      sent = true;
    };
    let cursor = after;
    for (;;) {
      const page = this.sql
        .exec<{ seq: number; device_id: string; blob: string }>(
          'SELECT seq, device_id, blob FROM frame WHERE ? < seq ORDER BY seq LIMIT ?',
          cursor,
          CATCH_UP_PAGE,
        )
        .toArray();
      for (const f of page) {
        const size = f.blob.length + 64;
        if (batch.length !== 0 && MAX_CATCH_UP_CHARS < chars + size) flush();
        batch.push({ seq: f.seq, deviceId: f.device_id, blob: f.blob });
        chars += size;
        cursor = f.seq;
      }
      if (page.length < CATCH_UP_PAGE) break;
    }
    if (batch.length !== 0 || !sent) flush();
  }

  /** Registers or re-enrolls [device] and returns its new token. */
  private async addDevice(device: DeviceInfo): Promise<string> {
    const token = encodeBase64Url(crypto.getRandomValues(new Uint8Array(32)));
    const hash = encodeBase64Url(await sha256(decodeBase64Url(token)));
    this.sql.exec(
      'INSERT INTO device (device_id, name, platform, public_key, token_hash, added_at) VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT (device_id) DO UPDATE SET name = excluded.name, platform = excluded.platform, public_key = excluded.public_key, token_hash = excluded.token_hash',
      device.deviceId,
      device.name,
      device.platform,
      device.publicKey,
      hash,
      Date.now(),
    );
    return token;
  }

  private authed(ws: WebSocket): string | null {
    const a = ws.deserializeAttachment() as Attachment | null;
    return a?.deviceId ?? null;
  }

  private error(ws: WebSocket, code: ErrorCode): void {
    send(ws, JSON.stringify({ type: 'error', code }));
  }

  private source(ws: WebSocket): string {
    const a = ws.deserializeAttachment() as Attachment | null;
    return a?.source ?? 'unknown';
  }

  /** Whether [source] has failures left in the window; prunes old ones. */
  private withinBudget(
    failures: Map<string, number[]>,
    source: string,
    windowMs: number,
    max: number,
  ): boolean {
    const times = failures.get(source);
    if (times === undefined) return true;
    prune(times, windowMs);
    if (times.length === 0) {
      failures.delete(source);
      return true;
    }
    return times.length < max;
  }

  private account() {
    return (
      this.sql
        .exec<{ account_id: string; verifier: string; sync_wrap: string; head: number }>(
          'SELECT account_id, verifier, sync_wrap, head FROM account WHERE id = 1',
        )
        .toArray()[0] ?? null
    );
  }

  private device(deviceId: string) {
    return (
      this.sql
        .exec<{ token_hash: string; revoked_at: number | null }>(
          'SELECT token_hash, revoked_at FROM device WHERE device_id = ?',
          deviceId,
        )
        .toArray()[0] ?? null
    );
  }

  private snapshot() {
    return (
      this.sql
        .exec<{ covers_seq: number; blob: string }>(
          'SELECT covers_seq, blob FROM snapshot WHERE id = 1',
        )
        .toArray()[0] ?? null
    );
  }

  private head(): number {
    return this.account()?.head ?? 0;
  }
}

function send(ws: WebSocket, text: string): void {
  try {
    ws.send(text);
  } catch {
    // A socket closing under us; its device catches up on reconnect.
  }
}

async function sha256(bytes: Uint8Array): Promise<Uint8Array> {
  return new Uint8Array(await crypto.subtle.digest('SHA-256', bytes));
}

function timingSafeEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  return crypto.subtle.timingSafeEqual(a, b);
}

function prune(times: number[], windowMs: number): void {
  const cutoff = Date.now() - windowMs;
  while (times.length !== 0 && times[0]! < cutoff) times.shift();
}

function recordFailure(failures: Map<string, number[]>, source: string): void {
  const times = failures.get(source);
  if (times === undefined) failures.set(source, [Date.now()]);
  else times.push(Date.now());
}

const MINUTE = 60_000;
const HOUR = 3_600_000;

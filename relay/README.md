# audiflow relay

The relay for opt-in sync: a Cloudflare Worker with one Durable Object per account. It orders, stores, and fans out sealed frames and keeps the latest compacted snapshot. Every value it holds is ciphertext; it reads routing fields only.

Design: [`docs/architecture/user-data-sync.md`](../docs/architecture/user-data-sync.md) and [`docs/plans/2026-11-20-sync-plan.md`](../docs/plans/2026-11-20-sync-plan.md) (protocol P6). The Dart side of the protocol is `packages/audiflow_domain/lib/src/features/sync/protocol/sync_messages.dart`; the two must agree field for field.

## Develop

```sh
npm ci
npm test          # Vitest inside the Workers runtime (Miniflare)
npm run typecheck
npm run dev       # local relay on http://localhost:8787
```

Clients connect to `GET /v1/connect?account=<accountId>` with a WebSocket upgrade.

## Deploy

Not set up: deploying needs the owner's Cloudflare account and a relay URL per app flavor. CI does not run these tests yet; adding them is a workflow change.

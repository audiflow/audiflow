import { AccountRelay } from './account';
import { isAccountId } from './protocol';

export { AccountRelay };

export interface Env {
  ACCOUNT: DurableObjectNamespace<AccountRelay>;
}

/**
 * Routes `GET /v1/connect?account=<accountId>` to the account's Durable
 * Object. The account id is random and fixed for the account's life, so it
 * addresses the object without any lookup table (design doc, Accounts).
 */
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname !== '/v1/connect') {
      return new Response('not found', { status: 404 });
    }
    if (request.headers.get('Upgrade') !== 'websocket') {
      return new Response('expected a websocket', { status: 426 });
    }
    const account = url.searchParams.get('account');
    if (account === null || !isAccountId(account)) {
      return new Response('bad account', { status: 400 });
    }
    const stub = env.ACCOUNT.get(env.ACCOUNT.idFromName(account));
    return stub.fetch(request);
  },
} satisfies ExportedHandler<Env>;

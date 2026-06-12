# ASC + ARIA Rails API

Rails API backend for the private ASC + ARIA prototype.

## Boundaries

- Fake/sample data only.
- No real participant data, SSNs, DOBs, signatures, beneficiary data, documents, Relias data, or Airtable records.
- Controlled seeded knowledge and fake plan rules only.
- OpenRouter is optional and must stay behind Rails; browser clients must never receive API keys.
- Account-specific questions must route to secure support instead of being answered from model memory.
- No production authentication in this prototype stage.

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/rails server -p 3000
```

Optional OpenRouter-backed public ARIA responses:

```bash
OPENROUTER_API_KEY=...
OPENROUTER_MODEL=google/gemini-2.5-flash
OPENROUTER_OPEN_TIMEOUT_SECONDS=15
OPENROUTER_READ_TIMEOUT_SECONDS=45
OPENROUTER_APP_NAME="ASC ARIA Prototype"
OPENROUTER_SITE_URL=http://localhost:5173
```

When `OPENROUTER_API_KEY` is unset, public ARIA returns deterministic/template fallback responses.

Anonymous public chat writes are throttled with Rack::Attack:

```bash
RACK_ATTACK_ENABLED=true
PUBLIC_CHAT_SESSION_RATE_LIMIT=20
PUBLIC_CHAT_MESSAGE_RATE_LIMIT=60
PUBLIC_CHAT_RATE_PERIOD_SECONDS=60
```

Health check:

```text
GET /api/v1/health
```

Public seeded-data and ARIA endpoints:

```text
GET  /api/v1/bootstrap
GET  /api/v1/plan_rules
GET  /api/v1/knowledge_entries
POST /api/v1/chat/public_sessions
GET  /api/v1/chat/public_sessions/:token
POST /api/v1/chat/public_sessions/:token/messages
```

Admin endpoints require an `ASC_ARIA_ADMIN_API_TOKEN` environment variable and either an `Authorization: Bearer <token>` header or an `X-ASC-ARIA-ADMIN-TOKEN` header:

```text
GET /api/v1/admin/audit_events
```

`/api/v1/bootstrap` intentionally excludes the fake user roster so unauthenticated callers do not receive emails, phone numbers, or external identifiers.

CORS is limited to current public read-only endpoints plus the explicit public ARIA chat create/message routes. Future write routes should add explicit CORS rules only after their authentication/authorization boundary is defined.

## Verify

```bash
bin/rails test
bin/rubocop
bin/brakeman -q
bin/bundler-audit check
```

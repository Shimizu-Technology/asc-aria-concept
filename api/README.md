# ASC + ARIA Rails API

Rails API backend for the private ASC + ARIA prototype.

## Boundaries

- Fake/sample data only.
- No real participant data, SSNs, DOBs, signatures, beneficiary data, documents, Relias data, or Airtable records.
- Controlled seeded knowledge and fake plan rules only.
- OpenRouter, Resend, ClickSend, and Clerk secrets must stay behind Rails; browser clients must never receive provider secrets.
- Account-specific questions must route to passwordless secure support instead of being answered from model memory.
- Participant verification uses fake seeded directory entries unless ASC approves a trusted contact source.
- Live participant email/SMS sends are disabled by default and require explicit env flags.
- Clerk staff/admin JWT verification is supported, but Rails owns app roles, workflow, and audit logs.

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/rails server -p 3000
```

Optional OpenRouter-backed public ARIA responses. In local development/test, Rails loads `api/.env` through `dotenv-rails`:

```bash
OPENROUTER_API_KEY=...
OPENROUTER_MODEL=google/gemini-2.5-flash
OPENROUTER_OPEN_TIMEOUT_SECONDS=15
OPENROUTER_READ_TIMEOUT_SECONDS=45
OPENROUTER_APP_NAME="ASC ARIA Prototype"
OPENROUTER_SITE_URL=http://localhost:5173
```

When `OPENROUTER_API_KEY` is unset, public ARIA returns deterministic/template fallback responses.

Optional Clerk, Resend, and ClickSend configuration:

```bash
CLERK_JWKS_URL=
CLERK_ISSUER=
CLERK_AUDIENCE=
CLERK_SECRET_KEY=

RESEND_API_KEY=
MAILER_FROM_EMAIL=noreply@example.test
CLICKSEND_USERNAME=
CLICKSEND_API_KEY=
CLICKSEND_SENDER_ID=ASCTrust
LIVE_VERIFICATION_EMAILS_ENABLED=false
LIVE_VERIFICATION_SMS_ENABLED=false
DEMO_VERIFICATION_CODES_ENABLED=true
CONTACT_DIGEST_SECRET=
VERIFICATION_CODE_SECRET=
```

Anonymous public chat and secure handoff writes are throttled with Rack::Attack:

```bash
RACK_ATTACK_ENABLED=true
PUBLIC_CHAT_SESSION_RATE_LIMIT=20
PUBLIC_CHAT_MESSAGE_RATE_LIMIT=60
PUBLIC_CHAT_RATE_PERIOD_SECONDS=60
SECURE_HANDOFF_RATE_LIMIT=20
VERIFICATION_CHALLENGE_RATE_LIMIT=10
VERIFICATION_ATTEMPT_RATE_LIMIT=20
SECURE_HANDOFF_RATE_PERIOD_SECONDS=60
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
POST /api/v1/handoffs
GET  /api/v1/handoffs/:token
POST /api/v1/handoffs/:token/verification_challenges
POST /api/v1/handoffs/:token/verification_challenges/:challenge_token/verify
GET  /api/v1/secure_chat_sessions/:token
POST /api/v1/secure_chat_sessions/:token/messages
```

Staff/admin endpoints support Clerk staff bearer tokens. For local/prototype use, they also accept an `ASC_ARIA_ADMIN_API_TOKEN` environment variable and either an `Authorization: Bearer <token>` header or an `X-ASC-ARIA-ADMIN-TOKEN` header:

```text
GET /api/v1/auth/me
GET /api/v1/staff/sessions
GET /api/v1/staff/sessions/:id
GET /api/v1/admin/audit_events
```

`/api/v1/bootstrap` intentionally excludes the fake user roster so unauthenticated callers do not receive emails, phone numbers, or external identifiers.

CORS allows the explicit public ARIA chat and passwordless secure handoff endpoints needed by the frontend. Staff/admin endpoints still require Clerk bearer auth or the local prototype admin token.

## Verify

```bash
bin/rails test
bin/rubocop
bin/brakeman -q
bin/bundler-audit check
```

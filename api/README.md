# ASC + ARIA Rails API

Rails API backend for the private ASC + ARIA prototype.

## Boundaries

- Fake/sample data only.
- No real participant data, SSNs, DOBs, signatures, beneficiary data, documents, Relias data, or Airtable records.
- Controlled seeded knowledge and fake plan rules only.
- No live AI or production authentication in this foundation stage.

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/rails server -p 3000
```

Health check:

```text
GET /api/v1/health
```

Public seeded-data endpoints:

```text
GET /api/v1/bootstrap
GET /api/v1/plan_rules
GET /api/v1/knowledge_entries
```

Admin endpoints require an `ASC_ARIA_ADMIN_API_TOKEN` environment variable and either an `Authorization: Bearer <token>` header or an `X-ASC-ARIA-ADMIN-TOKEN` header:

```text
GET /api/v1/admin/audit_events
```

`/api/v1/bootstrap` intentionally excludes the fake user roster so unauthenticated callers do not receive emails, phone numbers, or external identifiers.

CORS is limited to current public read-only endpoints. Future write routes should add explicit CORS rules only after their authentication/authorization boundary is defined.

## Verify

```bash
bin/rails test
bin/rubocop
bin/brakeman -q
bin/bundler-audit check
```

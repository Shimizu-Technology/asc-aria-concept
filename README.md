# ASC + ARIA Digital Support

Digital support prototype for the ASC Trust / ARIA opportunity.

## Purpose

This is a private React/Vite + Rails prototype direction, not production code. It is intended for stakeholder review and uses public ASC Trust content plus fake/sample workflow data to show how a modern ASC website, participant support hub, public ARIA assistant, secure supervised support flow, and future form intake platform could fit together.

See:

- `docs/content-and-assets.md` for the public ASC Trust pages/assets reviewed, what was included locally, and the asset-approval boundary.
- `docs/asc-public-content.md` for the public ASC Trust pages/content checked and the demo-data boundary.
- `docs/architecture-and-rag-plan.md` for the recommended long-term React + Rails + Airtable/RAG architecture.
- `docs/secure-support-workflow.md` for the public-to-authenticated ARIA handoff, staff dashboard, Relias bridge, secure form intake opportunity, and admin/audit model.
- `docs/build-readiness-plan.md` for the recommended phased build sequence and acceptance criteria.
- `docs/rails-backed-prototype-plan.md` for the decided next build direction: a Rails + React prototype app with ARIA chat, simple secure handoff, secure form intake, and admin dashboards.
- `docs/rails-react-implementation-checklist.md` for the pre-build model/route/screen checklist and acceptance criteria.
- `docs/demo-script.md` for the recommended 3–5 minute stakeholder walkthrough.

## Current prototype includes

- ASC Trust website modernization concept using real public ASC structure, copy, imagery, logo, stats, values, forms, partners, and contact details
- Imported public ASC content index covering 45 public pages/posts, with source links and a staged 131-image public asset library for private review
- ASC-style responsive header with Account Login, Open Account, Contact Us, Request Proposal, public navigation, and discreet demo controls
- Participant support hub task cards
- Rails-backed public ARIA assistant with controlled responses, seeded knowledge/plan-rule context, optional OpenRouter, and account-specific secure handoff CTA
- Fake authenticated secure support page
- Saved-session participant chat mockup
- Staff/call-center dashboard queue
- Staff session detail with fake Relias bridge fields
- AI draft, staff approve/send, edit, and human-takeover controls
- Admin/audit preview with governance and traceability metrics
- Documented future phase for replacing external Jotform/PDF intake with secure in-app forms and staff submission dashboards
- Rails API foundation under `api/` with fake users/roles, fake Airtable-style plan rules, seeded ARIA knowledge entries, public chat sessions/messages, and audit-event support

## Important boundaries

- Public ASC website copy/images/logos are included for private stakeholder concept review only; production usage should be approved by ASC and replaced with official source assets where possible
- No real participant data
- No real authentication
- No live AI required; OpenRouter is optional and falls back to deterministic/template responses when unset
- No Relias, Airtable, Jotform replacement, secure form storage, or ASC integration
- Demo/sample workflow only

## Project structure

```text
asc-aria/
  web/   React/Vite frontend
  api/   Rails API backend
  docs/  architecture and prototype planning docs
```

Root npm scripts delegate to `web/` for convenience.

## Run locally

Frontend:

```bash
npm install
# Optional when Rails API is not on http://127.0.0.1:3000
# echo "VITE_API_BASE_URL=http://127.0.0.1:3000" > web/.env.local
npm run dev -- --host 127.0.0.1
```

Then open:

```text
http://127.0.0.1:5173
```

Rails API:

```bash
cd api
bundle install
bin/rails db:prepare
bin/rails server -p 3000
```

Optional OpenRouter-backed public ARIA responses:

```bash
# api/.env or shell environment
OPENROUTER_API_KEY=...
OPENROUTER_MODEL=google/gemini-2.5-flash
```

The model is configurable via `OPENROUTER_MODEL`. If no OpenRouter key is present, public ARIA uses deterministic/template fallback responses. Anonymous public chat write endpoints are rate-limited with Rack::Attack (`PUBLIC_CHAT_SESSION_RATE_LIMIT`, `PUBLIC_CHAT_MESSAGE_RATE_LIMIT`, and `PUBLIC_CHAT_RATE_PERIOD_SECONDS`).

API health check:

```text
http://127.0.0.1:3000/api/v1/health
```

Admin API endpoints require `ASC_ARIA_ADMIN_API_TOKEN` and an `Authorization: Bearer <token>` or `X-ASC-ARIA-ADMIN-TOKEN` header. Public bootstrap data intentionally excludes fake user email/phone/external identifier details. The public ARIA chat endpoints are intentionally public but only use fake/sample seeded context and route account-specific questions to secure support.

## Verify

```bash
npm run lint
npm run build
node web/scripts/desktop-check.mjs
node web/scripts/mobile-check.mjs

cd api
bin/rails test
bin/rubocop
bin/brakeman -q
bin/bundler-audit check
```

The check scripts use local Chrome/Chromium via `puppeteer-core` to verify mobile/desktop viewport dimensions and capture screenshots in `/tmp`. Set `CHECK_URL` if the dev server is running on a non-default port. Set `CHROME_PATH` or `PUPPETEER_EXECUTABLE_PATH` if Chrome/Chromium is not installed in a standard macOS, Linux, or Windows location.

## Capture prototype screenshots

With the dev server running:

```bash
node web/scripts/capture-screenshots.mjs
```

The script reads `CHECK_URL` and defaults to `http://127.0.0.1:5173`. Set `SCREENSHOT_DIR` to override the output directory and `CHROME_PATH` or `PUPPETEER_EXECUTABLE_PATH` to point at a custom Chrome/Chromium executable. Generated screenshot files:

- `/tmp/asc-aria-01-public-handoff.png`
- `/tmp/asc-aria-02-secure-auth.png`
- `/tmp/asc-aria-03-secure-chat.png`
- `/tmp/asc-aria-04-staff-needs-lookup.png`
- `/tmp/asc-aria-05-staff-draft-ready.png`
- `/tmp/asc-aria-06-admin-audit.png`
- `/tmp/asc-aria-07-mobile-public.png`
- `/tmp/asc-aria-08-mobile-secure-chat.png`

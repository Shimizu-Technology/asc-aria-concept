# ASC + ARIA Digital Support

Digital support prototype for the ASC Trust / ARIA opportunity.

## Purpose

This is a lightweight React/Vite concept, not production code. It is intended for stakeholder review and uses public ASC Trust content plus fake/sample participant workflow data to show how a modern ASC website, participant support hub, public ARIA assistant, and secure supervised support flow could fit together.

See:

- `docs/asc-public-content.md` for the public ASC Trust pages/content checked and the demo-data boundary.
- `docs/architecture-and-rag-plan.md` for the recommended long-term React + Rails + Airtable/RAG architecture.
- `docs/secure-support-workflow.md` for the public-to-authenticated ARIA handoff, staff dashboard, Relias bridge, and admin/audit model.
- `docs/build-readiness-plan.md` for the recommended phased build sequence and acceptance criteria.
- `docs/demo-script.md` for the recommended 3–5 minute stakeholder walkthrough.

## Current prototype includes

- Premium Apple/Stripe-inspired responsive homepage concept
- Participant support hub task cards
- Employer/plan sponsor credibility section
- Public ARIA assistant concept with account-specific secure handoff
- Fake authenticated secure support page
- Saved-session participant chat mockup
- Staff/call-center dashboard queue
- Staff session detail with fake Relias bridge fields
- AI draft, staff approve/send, edit, and human-takeover controls
- Admin/audit preview with governance and traceability metrics

## Important boundaries

- No real participant data
- No real authentication
- No real AI/API calls
- No Relias, Airtable, or ASC integration
- Demo/sample workflow only

## Run locally

```bash
npm install
npm run dev -- --host 127.0.0.1
```

Then open:

```text
http://127.0.0.1:5173
```

## Verify

```bash
npm run lint
npm run build
node scripts/desktop-check.mjs
node scripts/mobile-check.mjs
```

The check scripts use local Chrome via `puppeteer-core` to verify mobile/desktop viewport dimensions and capture screenshots in `/tmp`. Set `CHECK_URL` if the dev server is running on a non-default port.

## Capture prototype screenshots

With the dev server running:

```bash
node scripts/capture-screenshots.mjs
```

The script reads `CHECK_URL` and defaults to `http://127.0.0.1:5173`. Generated screenshot files:

- `/tmp/asc-aria-01-public-handoff.png`
- `/tmp/asc-aria-02-secure-auth.png`
- `/tmp/asc-aria-03-secure-chat.png`
- `/tmp/asc-aria-04-staff-needs-lookup.png`
- `/tmp/asc-aria-05-staff-draft-ready.png`
- `/tmp/asc-aria-06-admin-audit.png`
- `/tmp/asc-aria-07-mobile-public.png`
- `/tmp/asc-aria-08-mobile-secure-chat.png`

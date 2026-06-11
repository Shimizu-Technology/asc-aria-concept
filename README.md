# ASC + ARIA Digital Support Concept

Private proof-of-concept prototype for the ASC Trust / ARIA opportunity.

## Purpose

This is a lightweight React/Vite concept, not production code. It uses public ASC Trust content and sample-only participant workflow data to show how a modern ASC website, participant support hub, public ARIA assistant, and secure supervised support flow could fit together.

See:

- `docs/asc-public-content.md` for the public ASC Trust pages/content checked and the demo-data boundary.
- `docs/architecture-and-rag-plan.md` for the recommended long-term React + Rails + Airtable/RAG architecture.
- `docs/secure-support-workflow.md` for the public-to-authenticated ARIA handoff, staff dashboard, Relias bridge, and admin/audit model.
- `docs/build-readiness-plan.md` for the recommended phased build sequence and acceptance criteria.

## Current prototype includes

- Premium Apple/Stripe-inspired responsive homepage concept
- Participant support hub task cards
- Employer/plan sponsor credibility section
- Public ARIA assistant concept
- Secure supervised support workflow mockup
- Sample staff-review panel
- Forms/services organization section

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
npm run build
node scripts/desktop-check.mjs
node scripts/mobile-check.mjs
```

The check scripts use local Chrome via `puppeteer-core` to verify mobile/desktop viewport dimensions and capture screenshots in `/tmp`.

## Screenshots generated during verification

- `/tmp/asc-aria-desktop-puppeteer.png`
- `/tmp/asc-aria-mobile-puppeteer.png`

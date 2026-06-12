# ASC + ARIA build-readiness plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task once Leon approves build start.

**Goal:** Turn the current ASC + ARIA concept into an actual Rails + React prototype app that demonstrates public ARIA, simple secure handoff, staff review, fake Relias-bridge workflow, embedded secure form intake, admin submission queues, staff responses, and audit oversight using fake/sample data.

**Architecture:** Keep the current React/Vite public concept as the visual base. Add a Rails API backend so the prototype has real persistence, staff workflows, form submissions, status changes, notes/responses, and audit events.

**Tech Stack:** React + Vite + TypeScript frontend, Rails API backend, Neon/Postgres, Airtable sync later, Rails-orchestrated RAG later, Netlify frontend, Render backend.

---

## Current status

Already done:

- React/Vite ASC + ARIA modernization concept exists.
- Public GitHub repo exists: `https://github.com/Shimizu-Technology/asc-aria`
- Public ASC content/numbers documented in `docs/asc-public-content.md`.
- Public sitemap/content and asset boundary documented in `docs/content-and-assets.md`.
- Long-term architecture/RAG direction documented in `docs/architecture-and-rag-plan.md`.
- Secure handoff/staff workflow documented in `docs/secure-support-workflow.md`.
- Rails-backed prototype direction documented in `docs/rails-backed-prototype-plan.md`.
- Frontend moved into `web/` and Rails API foundation added under `api/`.
- Fake users/roles, fake Airtable-style plan rules, controlled ARIA knowledge entries, and audit-event API support added for the first foundation PR.

## Strategic build decision

Do not jump directly into a full production backend unless the goal is a paid pilot.

Recommended next build sequence:

1. **Frontend product prototype** — completed enough for stakeholder review; proves the website + ARIA direction.
2. **Rails + React prototype app** — decided next step; adds persistence, queues, audit events, controlled chatbot behavior, and fake-data form intake.
3. **Secure form intake expansion** — replace Jotform/PDF intake in concept with app-owned enrollment/request forms and staff submission queues.
4. **Airtable/RAG integration** — once ASC provides sample Airtable schema/export or approves use of real/sanitized data.
5. **Security/auth hardening** — once ASC requirements and identity-provider path are known.

## What we need before building the real backend

From ASC stakeholders:

- sample Airtable schema or sanitized export
- list of top 10-20 participant questions
- example plan-rule records
- clarification of what exact Relias fields associates use for 401(k) loan calls
- who should be staff vs supervisor vs admin
- whether ASC has existing login/SSO/participant portal expectations
- preferred disclaimer/compliance language
- whether chats can be saved and retention expectations
- whether ASC wants to replace Jotform/external form intake with secure in-app forms
- what enrollment/request forms collect sensitive information such as SSN, DOB, signatures, beneficiaries, or attachments
- who reviews form submissions and what statuses/workflows they use today
- whether this is just a demo, internal pilot, or external participant pilot

From Leon/Shimizu Technology:

- confirm the next artifact is the Rails-backed prototype vertical slice
- repo reorganization into `web/` + `api/` is complete in the foundation branch
- decide whether to use Clerk demo auth, mock auth, or Rails auth for the next stage
- decide proposal tier/scope before connecting real systems

## Recommended immediate next step

Build the **Rails + React prototype app** using fake/sample data.

Reason:

- The frontend concept now demonstrates the website + ARIA direction.
- The next useful proof is operational: persisted sessions, staff queues, form submissions, status changes, notes, and audit history.
- No real participant data is available yet, so the backend should start with seeded fake data.
- Relias integration is not available and should remain manual/fake in the prototype.
- Airtable schema/data is not available yet, so plan rules can start as fixtures/seeds.
- A Rails-backed prototype makes the pitch stronger by showing ASC a real support-operations platform, not just a screen mockup.

See `docs/rails-backed-prototype-plan.md` for the implementation plan and `docs/rails-react-implementation-checklist.md` for the task checklist.

## Frontend prototype acceptance criteria

The frontend-only POC should demonstrate:

- public ARIA widget
- account-specific question detection
- “Continue securely” CTA
- fake authentication/verification screen
- secure ARIA support page
- saved-session feel
- staff dashboard queue
- staff session detail
- fake Relias lookup fields
- AI draft response
- staff approve/edit/send flow
- admin/audit preview
- mobile and desktop responsive behavior

No real auth, real AI, real Airtable, real Relias, or real participant data should be used in this phase.

---

# Phase 1: Frontend secure workflow prototype

## Task 1: Add product routing/state structure

**Objective:** Add UI navigation/state for public, secure, staff, and admin views without adding backend dependencies.

**Files:**

- Modify: `web/src/App.tsx`
- Modify/create supporting components under `web/src/` if the current single-file app becomes hard to maintain

**Steps:**

1. Inspect current `web/src/App.tsx` structure.
2. Add lightweight view state such as:
   - `home`
   - `public-chat`
   - `secure-auth`
   - `secure-chat`
   - `staff-dashboard`
   - `staff-session`
   - `admin-dashboard`
3. Add navigation CTAs to jump between demo views.
4. Keep hardcoded data in the frontend for now.
5. Run `npm run build`.
6. Verify desktop/mobile checks still pass.

**Verification:**

```bash
npm run build
node web/scripts/desktop-check.mjs
node web/scripts/mobile-check.mjs
```

## Task 2: Public ARIA account-specific handoff

**Objective:** Show the public chat detecting an account-specific question and offering secure support.

**Files:**

- Modify: `web/src/App.tsx` or new chat component files

**Steps:**

1. Add a sample public chat conversation:
   - User asks: “I work for Bank of Mila. How much can I borrow from my 401(k)?”
   - ARIA explains that secure support is required.
2. Add buttons:
   - `Continue securely`
   - `General info only`
3. Make `Continue securely` move to the fake secure-auth view.
4. Include privacy/safety copy warning users not to enter SSN/account numbers in public chat.
5. Run build and viewport checks.

## Task 3: Fake secure authentication page

**Objective:** Demonstrate the transition from public chat to authenticated support without implementing real auth.

**Files:**

- Modify: `web/src/App.tsx` or create `SecureAuthView.tsx`

**Steps:**

1. Add a secure-auth screen with:
   - “Continue to secure ARIA support” heading
   - safe explanation of why authentication is required
   - fake verification checklist
   - button: `Verify and continue`
2. Preserve context from the public question visually:
   - topic: 401(k) loan
   - employer: Bank of Mila sample
   - reason: account-specific support requested
3. Button moves to secure chat view.
4. Run build and viewport checks.

## Task 4: Secure ARIA chat page

**Objective:** Show an authenticated saved support session.

**Files:**

- Modify: `web/src/App.tsx` or create `SecureChatView.tsx`

**Steps:**

1. Add secure chat layout with:
   - verified user/sample identity
   - employer/plan context
   - support status badge
   - conversation thread
   - privacy notice
2. Show ARIA saying staff verification is needed for loan amount.
3. Show status: `Waiting on ASC associate / Relias lookup`.
4. Add CTA/link to staff dashboard for demo purposes.
5. Run build and viewport checks.

## Task 5: Staff dashboard queue

**Objective:** Show how staff/call-center users monitor support sessions.

**Files:**

- Modify: `web/src/App.tsx` or create `StaffDashboardView.tsx`

**Steps:**

1. Add queue cards for sample sessions.
2. Include statuses:
   - Needs Relias Lookup
   - AI Draft Ready
   - Human Takeover
   - Resolved
3. Highlight the current sample session.
4. Show metadata:
   - participant name: sample only
   - employer
   - topic
   - waiting time
   - action needed
5. Clicking current session opens staff session detail view.
6. Run build and viewport checks.

## Task 6: Staff session detail + Relias bridge

**Objective:** Show staff manually entering verified Relias facts into structured fields.

**Files:**

- Modify: `web/src/App.tsx` or create `StaffSessionView.tsx`

**Steps:**

1. Add two-column/staked mobile layout:
   - conversation panel
   - action panel
2. Action panel includes:
   - detected employer/plan
   - matched plan rule summary
   - required Relias fields
   - fake verified balance
   - fake vested balance
   - fake active employee status
   - fake active loan count
3. Add button: `Generate ARIA draft`.
4. Show generated draft response after action.
5. Add buttons:
   - `Approve and send`
   - `Edit response`
   - `Take over chat`
6. Run build and viewport checks.

## Task 7: Admin/audit preview

**Objective:** Show supervisor/admin oversight and auditability.

**Files:**

- Modify: `web/src/App.tsx` or create `AdminDashboardView.tsx`

**Steps:**

1. Add admin dashboard preview with:
   - active sessions count
   - review queue count
   - escalated sessions count
   - common question trends
   - Airtable sync status sample
2. Add audit trail list for the sample session:
   - handoff created
   - user verified
   - staff viewed session
   - Relias lookup requested
   - verified facts entered
   - AI draft generated
   - staff approved response
3. Run build and viewport checks.

## Task 8: Update docs/demo script

**Objective:** Document how to present the secure workflow prototype to ASC stakeholders.

**Files:**

- Create: `docs/demo-script.md`
- Modify: `README.md`

**Steps:**

1. Add demo path:
   - public site
   - public ARIA question
   - secure handoff
   - fake auth
   - secure support session
   - staff dashboard
   - staff Relias bridge
   - admin/audit preview
2. Add explicit demo boundaries:
   - fake/sample participant data
   - no real Relias connection
   - no real Airtable data
   - no real auth in frontend-only POC
3. Link demo script from README.
4. Run build and checks.

---

# Phase 2: Rails API vertical slice

This is now the recommended next build stage if Leon wants to move beyond the visual concept.

## Backend slice goals

- create Rails API app under `api/`
- create Postgres models for sessions/messages/staff reviews/audit events
- seed fake/sample data
- expose API endpoints for:
  - secure chat sessions
  - staff queue
  - staff verified facts
  - AI draft placeholder
  - audit events
- connect React frontend to Rails API
- keep AI responses stubbed/template-based at first

## Initial Rails models

```text
User
Role
ParticipantProfile
StaffProfile
PublicChatSession
SecureChatSession
ChatMessage
HandoffToken
SupportRequest
StaffReview
StaffVerifiedFact
AiResponseDraft
AuditEvent
PlanRule
KnowledgeEntry
KnowledgeChunk
FormDefinition
FormFieldDefinition
FormSubmission
FormSubmissionFieldValue
FormSubmissionAttachment
FormSubmissionStatusEvent
FormSubmissionAssignment
FormSubmissionNote
FormSubmissionExport
```

## Initial API routes

```text
POST /api/v1/handoffs
POST /api/v1/handoffs/:token/verify_demo
GET  /api/v1/secure_chat_sessions/:id
POST /api/v1/secure_chat_sessions/:id/messages
GET  /api/v1/staff/sessions
GET  /api/v1/staff/sessions/:id
POST /api/v1/staff/sessions/:id/verified_facts
POST /api/v1/staff/sessions/:id/drafts
POST /api/v1/staff/sessions/:id/approve
GET  /api/v1/admin/audit_events
GET  /api/v1/forms
GET  /api/v1/forms/:id
POST /api/v1/form_submissions
GET  /api/v1/staff/form_submissions
GET  /api/v1/staff/form_submissions/:id
POST /api/v1/staff/form_submissions/:id/status
POST /api/v1/staff/form_submissions/:id/assign
POST /api/v1/staff/form_submissions/:id/notes
POST /api/v1/staff/form_submissions/:id/exports
```

## Backend verification

Minimum before calling backend slice done:

```bash
cd api
bin/rails db:prepare
bin/rails test
```

Frontend:

```bash
cd web
npm run build
```

Smoke test:

- create handoff
- verify demo user
- create secure chat session
- staff adds verified facts
- draft generated
- approve response
- audit events created
- submit sample form intake with fake data
- staff reviews form submission, changes status, adds note, and creates export event

---

# Phase 2b: Secure form intake + admin submissions

Start this after ASC confirms that replacing external Jotform/PDF intake is part of the pilot or paid build scope.

## Why it matters

ASC currently has at least one participant enrollment flow hosted outside the ASC site, such as:

```text
Retirement Plan Enrollment Form
https://form.jotform.com/250117028657859
```

This is a strong modernization opportunity because forms are not just content. They are operational workflows that can feed staff queues, audit logs, follow-up tasks, and eventually integrations.

## Goals

- replace external Jotform-style flows with secure ASC-owned forms
- keep participants inside the ASC website/app experience
- support plan-aware field routing and validation
- store submissions securely in Rails/Postgres
- show submissions in a staff/admin dashboard
- let staff assign, review, request more info, export, and complete submissions
- maintain audit history for views, status changes, notes, exports, and downloads

## Form intake boundaries

Do not handle real enrollment data until ASC approves the security model.

Required before real data:

- authentication or strong verification strategy
- encryption at rest for sensitive fields
- role-based access control
- audit logs for every staff/admin action
- file upload and attachment policy
- data retention/deletion policy
- PII-safe notification rules
- approved legal/disclaimer language

## Candidate forms

- retirement plan enrollment
- beneficiary update
- distribution/loan request intake or precheck
- participant contact information update
- employer/request-proposal intake
- document upload for staff review, if approved

## Acceptance criteria for a safe prototype

Frontend-only or fake-data backend demo can show:

- plan/form chooser
- dynamic form sections
- fake submission confirmation
- staff submission queue
- submission detail page
- status workflow: New → In Review → Needs More Info → Completed
- internal staff notes
- export/download placeholder
- audit event list

It must not collect or store real SSNs, DOBs, signatures, beneficiary data, or real documents until ASC approves the production security scope.

---

# Phase 3: Airtable/RAG integration

Start only after ASC provides sample Airtable schema/export or approves use of sanitized records.

Tasks:

- create Airtable import/sync service
- normalize Airtable rows into `PlanRule`
- add checksums and incremental update logic
- create `KnowledgeEntry` and `KnowledgeChunk` records
- start with full-text search or pgvector
- add retrieval events/audit log
- keep LLM answers constrained by retrieved/structured data

---

# Phase 4: Production-hardening discovery

Before any real participant data:

- choose auth provider
- confirm data retention policy
- confirm disclaimer/compliance language
- confirm who can view chats
- confirm Relias integration stance
- confirm model/provider/vendor requirements
- confirm incident/escalation process
- confirm hosting/security expectations

## Final near-term recommendation

The frontend concept has answered the first stakeholder question: the website + ARIA workflow direction is compelling.

Build the Rails + React prototype app next.

It should answer the next operational question:

> Can ASC manage ARIA support sessions, secure form submissions, staff review, notes, statuses, and audit history from one coherent platform?

Keep the prototype fake-data only until ASC approves the security/compliance scope for real participant data.

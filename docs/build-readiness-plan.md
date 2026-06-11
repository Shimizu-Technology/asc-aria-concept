# ASC + ARIA build-readiness plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task once Leon approves build start.

**Goal:** Turn the current ASC + ARIA concept into a production-shaped prototype that demonstrates public ARIA, secure authenticated handoff, staff review, Relias-bridge workflow, and admin/audit oversight using fake/sample data.

**Architecture:** Keep the current public React/Vite prototype as the visual base. Add a secure-support workflow and staff/admin dashboard screens in React first. Add Rails API only when persistence, role-based staff workflows, audit events, and realistic data modeling become necessary for the paid pilot / stronger POC.

**Tech Stack:** React + Vite + TypeScript frontend, Rails API backend, Neon/Postgres, Airtable sync later, Rails-orchestrated RAG later, Netlify frontend, Render backend.

---

## Current status

Already done:

- React/Vite ASC + ARIA concept exists.
- Public GitHub repo exists: `https://github.com/Shimizu-Technology/asc-aria`
- Public ASC content/numbers documented in `docs/asc-public-content.md`.
- Long-term architecture/RAG direction documented in `docs/architecture-and-rag-plan.md`.
- Secure handoff/staff workflow documented in `docs/secure-support-workflow.md`.

## Strategic build decision

Do not jump directly into a full production backend unless the goal is a paid pilot.

Recommended next build sequence:

1. **Frontend product prototype** — fastest way to show the right workflow to Mel/ASC.
2. **Rails API vertical slice** — once we want persistence, roles, queues, audit events, and realistic backend architecture.
3. **Airtable/RAG integration** — once ASC provides sample Airtable schema/export or approves use of real/sanitized data.
4. **Security/auth hardening** — once ASC requirements and identity-provider path are known.

## What we need before building the real backend

From Mel/ASC:

- sample Airtable schema or sanitized export
- list of top 10-20 participant questions
- example plan-rule records
- clarification of what exact Relias fields associates use for 401(k) loan calls
- who should be staff vs supervisor vs admin
- whether ASC has existing login/SSO/participant portal expectations
- preferred disclaimer/compliance language
- whether chats can be saved and retention expectations
- whether this is just a demo, internal pilot, or external participant pilot

From Leon/Shimizu Technology:

- decide whether next artifact is a polished frontend demo or a Rails-backed pilot
- decide if repo should be reorganized into `web/` + `api/` now or after frontend flow is complete
- decide whether to use Clerk demo auth, mock auth, or Rails auth for the next stage
- decide proposal tier/scope before connecting real systems

## Recommended immediate next step

Build a **frontend-only workflow prototype** of the secure handoff + staff dashboard before adding Rails.

Reason:

- Mel/ASC need to react to the product workflow first.
- No real participant data is available yet.
- Relias integration is not available.
- Airtable schema/data is not available yet.
- A polished workflow demo can make the Tier 3 scope feel concrete without overbuilding.

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

- Modify: `src/App.tsx`
- Modify/create supporting components under `src/` if the current single-file app becomes hard to maintain

**Steps:**

1. Inspect current `src/App.tsx` structure.
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
node scripts/desktop-check.mjs
node scripts/mobile-check.mjs
```

## Task 2: Public ARIA account-specific handoff

**Objective:** Show the public chat detecting an account-specific question and offering secure support.

**Files:**

- Modify: `src/App.tsx` or new chat component files

**Steps:**

1. Add a sample public chat conversation:
   - User asks: “I work for United. How much can I borrow from my 401(k)?”
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

- Modify: `src/App.tsx` or create `SecureAuthView.tsx`

**Steps:**

1. Add a secure-auth screen with:
   - “Continue to secure ARIA support” heading
   - safe explanation of why authentication is required
   - fake verification checklist
   - button: `Verify and continue`
2. Preserve context from the public question visually:
   - topic: 401(k) loan
   - employer: United Airlines sample
   - reason: account-specific support requested
3. Button moves to secure chat view.
4. Run build and viewport checks.

## Task 4: Secure ARIA chat page

**Objective:** Show an authenticated saved support session.

**Files:**

- Modify: `src/App.tsx` or create `SecureChatView.tsx`

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

- Modify: `src/App.tsx` or create `StaffDashboardView.tsx`

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

- Modify: `src/App.tsx` or create `StaffSessionView.tsx`

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

- Modify: `src/App.tsx` or create `AdminDashboardView.tsx`

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

**Objective:** Document how to present the secure workflow prototype to Mel/ASC.

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

Start this only after the frontend flow is approved or Leon decides the next artifact should be backend-backed.

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

Build Phase 1 first.

It will answer the most important stakeholder question:

> Does this secure handoff + staff-reviewed ARIA workflow make sense operationally for ASC?

Once Mel/ASC reacts positively, graduate to the Rails-backed vertical slice and formalize the pilot scope.

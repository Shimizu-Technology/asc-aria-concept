# ASC + ARIA Rails/React application prototype plan

**Status:** decided next implementation direction
**Last updated:** 2026-06-13
**Related docs:** `docs/build-readiness-plan.md`, `docs/architecture-and-rag-plan.md`, `docs/secure-support-workflow.md`, `docs/identity-and-access-plan.md`

## Decision

Build the next version as an actual **React frontend + Rails backend prototype app**.

The current frontend concept proves the ASC website modernization direction. The next step is to build a working private prototype that demonstrates the real product shape:

1. ARIA chatbot experience.
2. Simple public-to-secure handoff with passwordless participant verification.
3. Staff/admin dashboard for reviewing chats, using Clerk for internal staff auth later.
4. Embedded retirement/enrollment form based on ASC's current Jotform-style flow.
5. Admin dashboard for viewing and responding to form submissions.
6. Audit/status history that makes the compliance story concrete.

This is still a prototype. It must use fake/sample data only until ASC approves a production security/compliance scope.

## Product framing

> ASC Trust's next digital platform can be more than a redesigned website. It can become a secure participant-support operations layer: ARIA routes and explains, secure support handles account-specific questions, embedded forms replace disconnected third-party intake, and staff manage everything from one dashboard.

## What we are building now

A real working app, not just a static mockup:

```text
React/Vite frontend
  ↓ API calls
Rails API backend
  ↓ persistence
Postgres / SQLite locally, Neon later
```

The prototype should feel real to stakeholders even though every participant/account example is fake.

## Core scope

### 1. ARIA chatbot prototype

Goal: show how ARIA would answer general questions and route account-specific questions safely.

Build:

- public ARIA bottom-right chat widget — implemented with Rails-backed sessions/messages
- persisted public chat session — implemented
- deterministic intent detection for known sensitive/account-specific patterns — implemented
- local seeded knowledge for retirement-plan/general ASC information — implemented
- local seeded plan-rule data that mimics Airtable — implemented
- controlled/scripted fallback responses first — implemented
- optional LLM/OpenRouter through Rails only — implemented for safe public intents, defaulting to `google/gemini-2.5-flash` via `OPENROUTER_MODEL`

Important:

- Do not let ARIA freely browse the web at runtime.
- Do not let ARIA answer account-specific questions from model memory.
- Use curated public ASC content, seeded plan rules, and approved fake data.

### 2. Passwordless secure handoff

Goal: show a working public-to-secure workflow that is easy for non-technical participants and safe for account-specific support.

Build:

- handoff record/token when user asks an account-specific question
- fake seeded participant directory with sample email/phone contacts only
- fake passwordless verification page for secure email/SMS code
- verification challenge model that stores code digests, not raw codes
- provider-facing delivery layer shaped for Resend email and ClickSend SMS, with live sends disabled by default
- secure access session creation after verification
- secure chat session creation/resume
- status: waiting on staff/Relias verification
- staff queue entry
- audit events for handoff, challenge request, delivery attempt, verification, staff review, draft, approval

Important:

- Sending a code to a user-entered contact proves contact control only.
- It does not prove account ownership unless that contact is matched against a trusted ASC source.
- For prototype and early pilot, account-specific answers still require staff/Relias review.

### 3. Staff/admin chat dashboard

Goal: show how ASC staff would review and control ARIA responses.

Build:

- support-session queue
- secure-chat detail page
- conversation transcript
- fake Relias bridge fields
- matched fake plan-rule summary
- staff notes
- generate scripted ARIA draft
- approve/edit/send
- take-over placeholder
- audit trail

### 4. Embedded enrollment/form intake

Goal: show how ASC could replace external Jotform/PDF intake with a secure in-app flow.

Current-state reference:

```text
Retirement Plan Enrollment Form
https://form.jotform.com/250117028657859
```

Build a simplified fake-data version:

- form type
- how participant received the form
- employer/plan name
- participant name
- masked SSN/Tax ID placeholder field
- address/contact information
- general information section
- review step
- submit confirmation

Important:

- Use fake/sample data only.
- Do not collect or encourage real SSNs, DOBs, beneficiary data, signatures, or documents.
- Make any sensitive-looking fields clearly marked as sample/prototype fields.

### 5. Admin form-submission dashboard

Goal: show staff can operationally manage form submissions.

Build:

- form submission queue
- submission detail page
- status workflow
- staff assignment
- internal notes
- staff response/request-more-info field
- export packet placeholder
- audit/status event timeline

Statuses:

```text
New
In Review
Needs More Info
Ready for Processing
Completed
Archived
```

### 6. Admin/audit overview

Goal: connect chat and form workflows into one operational dashboard.

Build:

- cards for active support sessions
- cards for form submissions
- needs review count
- needs more info count
- completed today count
- recent audit events

## Fake data strategy

Because ASC has not provided Airtable/Relias access, mimic both systems safely.

### Fake Airtable / plan-rule records

Seed local `PlanRule` records such as:

```text
Bank of Mila 401(k)
- loans allowed: yes
- max active loans: 1
- max repayment term: 5 years
- notes: final eligibility subject to account status and plan documents

Guam Demo Employer 401(k)
- loans allowed: yes
- max active loans: 2
- max repayment term: 5 years

Pacific Sample 403(b)
- loans allowed: no
- notes: participants should contact ASC for alternatives
```

### Fake participant directory

Seed fake contact records for passwordless verification demos:

```text
Malia Santos Demo
- employer/plan: Bank of Mila 401(k)
- email: malia.demo@example.test
- phone: +16715550100
- active: yes

Tasi Cruz Demo
- employer/plan: Guam Demo Employer 401(k)
- email: tasi.demo@example.test
- phone: +16715550101
- active: yes
```

These records are not real participant data. They exist only to demonstrate the secure-code workflow and staff queue handoff.

### Fake Relias bridge values

Staff enters fake structured facts:

```text
verified_balance
vested_balance
active_employee_status
existing_active_loan_count
verified_by
verified_at
```

### Curated knowledge

Use:

- imported public ASC content already staged in `web/src/ascSiteData.ts`
- hand-authored fake educational snippets for 401(k) loan basics
- disclaimers and escalation language in app seeds
- optional public IRS/general retirement links as source references, not live runtime browsing

## Scope boundaries

### In scope

- Rails API backend.
- Local DB persistence.
- Fake/sample users and participants.
- Persisted chat sessions and messages.
- Simple secure handoff.
- Staff queue and staff session detail.
- Fake plan rules.
- Fake Relias bridge fields.
- Embedded enrollment/intake form using fake/sample data.
- Admin form-submission dashboard.
- Submission statuses, assignments, notes, responses, export placeholders, and audit events.
- Scripted/template ARIA responses first.
- Private/noindex deployment.

### Out of scope until ASC approves

- Real participant data.
- Real SSNs, DOBs, signatures, beneficiary data, or uploaded documents.
- Production Jotform replacement.
- Real Relias integration.
- Real Airtable sync.
- Real participant authentication/SSO or real participant contact sync.
- Live AI responses using sensitive participant context.
- Live email/SMS to real participants.
- Public launch.

## Recommended repo shape

Move toward the Shimizu Rails + React pattern:

```text
asc-aria/
  web/       # React/Vite frontend
  api/       # Rails API backend
  docs/      # architecture, demo, build plans
```

Recommended implementation approach:

1. Move the current Vite app into `web/`. — done in the foundation branch.
2. Add Rails API under `api/`. — done in the foundation branch.
3. Keep deployment split: Netlify for frontend, Render for API, Neon later for Postgres.

## Implementation phases

### Phase 0: PRD + build checklist

Before coding, create a concise implementation PRD/build checklist covering:

- screens
- models
- routes
- fake seed data
- security boundaries
- acceptance criteria
- deployment assumptions

### Phase 1: Rails API foundation

Build:

- Rails API app under `api/`
- database setup
- CORS for local frontend
- seed fake staff/participant/session data
- base JSON API structure
- audit event model and helper

Initial models:

```text
User
Role
ParticipantProfile
StaffProfile
AuditEvent
```

Acceptance criteria:

- Rails tests pass.
- API health endpoint works.
- Seeded users/roles can be loaded through Rails seeds/tests without exposing the user roster on public bootstrap.
- Audit events can be created from service actions.
- Admin audit endpoints require a prototype admin token until real auth/roles are implemented.

### Phase 2: ARIA chat + secure handoff

Build models:

```text
PublicChatSession
ParticipantDirectoryEntry
SecureAccessSession
SecureChatSession
ChatMessage
HandoffToken
VerificationChallenge
OutboundDelivery
SupportRequest
StaffReview
StaffVerifiedFact
AiResponseDraft
PlanRule
KnowledgeEntry
```

Initial routes:

```text
POST /api/v1/chat/public_sessions
POST /api/v1/chat/public_sessions/:token/messages
POST /api/v1/handoffs
GET  /api/v1/handoffs/:token
POST /api/v1/handoffs/:token/verification_challenges
POST /api/v1/handoffs/:token/verification_challenges/:id/verify
GET  /api/v1/secure_chat_sessions/:id
POST /api/v1/secure_chat_sessions/:id/messages
GET  /api/v1/staff/sessions
GET  /api/v1/staff/sessions/:id
POST /api/v1/staff/sessions/:id/verified_facts
POST /api/v1/staff/sessions/:id/drafts
POST /api/v1/staff/sessions/:id/approve
```

Acceptance criteria:

- user can ask public ARIA a general question — implemented for public sessions
- account-specific question creates secure handoff CTA — implemented; persisted `HandoffToken` comes next
- fake email/SMS verification creates/resumes secure access session and secure chat session
- staff queue shows session
- staff enters fake verified facts
- scripted ARIA draft is generated
- staff approval adds participant-visible message
- audit events are created throughout

### Phase 3: Embedded enrollment/form intake

Build models:

```text
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

Initial routes:

```text
GET  /api/v1/forms
GET  /api/v1/forms/:id
POST /api/v1/form_submissions
GET  /api/v1/staff/form_submissions
GET  /api/v1/staff/form_submissions/:id
POST /api/v1/staff/form_submissions/:id/status
POST /api/v1/staff/form_submissions/:id/assign
POST /api/v1/staff/form_submissions/:id/notes
POST /api/v1/staff/form_submissions/:id/response
POST /api/v1/staff/form_submissions/:id/exports
```

Acceptance criteria:

- participant can submit fake enrollment form
- submission appears in staff queue
- staff can update status
- staff can add internal note
- staff can add a response/request for more information
- export action creates placeholder export event
- all actions create audit/status history

### Phase 4: React frontend integration

Build/update screens:

```text
Public ASC homepage
Public ARIA chat widget
Secure verification page
Secure chat page
Staff support sessions queue
Staff support session detail
Enrollment form page
Form submission confirmation
Admin form submissions queue
Admin form submission detail
Admin/audit overview
```

Acceptance criteria:

- frontend reads/writes Rails state
- existing polished ASC visual design remains intact
- mobile and desktop remain clean
- no real sensitive data is requested
- all forms clearly indicate fake/sample prototype status where appropriate

### Phase 5: Private deploy

Deploy privately:

```text
Netlify -> React frontend
Render  -> Rails API
Neon    -> Postgres
```

Requirements:

- noindex,nofollow
- fake data only
- no public production positioning
- no real Jotform replacement until ASC approval
- no real participant submissions

## Security notes for form intake

If ASC later wants real form submissions, production requirements include:

- HTTPS-only flows
- authentication or strong verification
- encryption at rest for sensitive fields
- field-level masking/redaction in admin UI
- role-based staff/admin access
- full audit logs for views/updates/exports/downloads
- secure attachment storage and scanning policy
- retention/deletion policy
- PII-safe email/SMS notification rules
- vendor/security review for hosting, AI provider, and any third-party services

## Suggested stakeholder demo after this build

1. Open modern ASC homepage.
2. Ask ARIA a general question.
3. Ask an account-specific loan question.
4. Continue securely.
5. Show saved secure support session.
6. Open staff dashboard.
7. Staff enters fake verified facts and approves response.
8. Participant sees approved response.
9. Open embedded enrollment form.
10. Submit fake enrollment record.
11. Staff sees form submission in admin dashboard.
12. Staff updates status / adds note / shows audit trail.

## Next action before implementation

Rails foundation and public ARIA are now in place. The next implementation branch should build the passwordless secure handoff workflow with fake/sample data only.

Recommended next implementation branch:

```text
feature/secure-handoff-workflow
```

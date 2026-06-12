# ASC + ARIA Rails/React implementation checklist

**Status:** Phase 1–2 foundation branch in progress
**Last updated:** 2026-06-11
**Primary plan:** `docs/rails-backed-prototype-plan.md`

## Guiding principles

1. **Fake data only.** No real participant submissions, SSNs, DOBs, signatures, beneficiary data, Relias data, or Airtable data.
2. **Working architecture over static mockups.** Key workflows should persist through Rails.
3. **Controlled ARIA first.** Use deterministic classification, seeded knowledge, fake plan rules, and scripted/template responses before adding any live LLM.
4. **Staff stays in control.** Account-specific support requires staff review/approval.
5. **Secure form intake is a prototype.** The form should demonstrate workflow, not collect real sensitive data.
6. **Audit everything important.** Handoffs, verification, staff facts, drafts, approvals, form status changes, notes, responses, and exports should create audit/status events.
7. **Keep the ASC-facing UI polished.** Do not regress the website modernization design.

## Target repo shape

```text
asc-aria/
  web/       # React/Vite frontend
  api/       # Rails API backend
  docs/
```

First implementation PR decision:

- [x] Move current frontend into `web/` before adding Rails.
- [x] Add Rails API under `api/`.
- [x] Keep root npm scripts as convenience proxies to `web/`.

This keeps deployment/build docs clear while creating room for the Rails backend.

## Prototype user roles

| Role | Description |
|---|---|
| Public visitor | Uses public website and public ARIA chat. |
| Verified participant | Uses fake secure support and fake form submission. |
| Staff | Reviews support sessions and form submissions. |
| Admin/Supervisor | Views audit dashboard, all sessions, all submissions. |

For prototype, roles can be seeded/mock-authenticated.

## Fake seed data

### Users

- [x] `Malia Santos` — participant
- [x] `ASC Staff Demo` — staff
- [x] `ASC Supervisor Demo` — admin/supervisor

### Plan rules mimicking Airtable

- [x] `Bank of Mila 401(k)` — loans allowed, max 1 active loan, 5-year repayment
- [x] `Guam Demo Employer 401(k)` — loans allowed, max 2 active loans, 5-year repayment
- [x] `Pacific Sample 403(b)` — loans not allowed
- [x] `Demo Government Plan` — plan-specific caveats

### Knowledge entries

- [x] General 401(k) loan explanation
- [x] Loan vs withdrawal explanation
- [x] Repayment term caveat
- [ ] Leaving employment caveat
- [x] Educational/no tax/legal/investment advice disclaimer
- [x] Secure support escalation language

## Backend models

### Foundation

- [x] `User`
- [x] `Role`
- [x] `ParticipantProfile`
- [x] `StaffProfile`
- [x] `AuditEvent`

### Chat / ARIA

- [ ] `PublicChatSession`
- [ ] `SecureChatSession`
- [ ] `ChatMessage`
- [ ] `HandoffToken`
- [ ] `SupportRequest`
- [ ] `StaffReview`
- [ ] `StaffVerifiedFact`
- [ ] `AiResponseDraft`
- [x] `PlanRule`
- [x] `KnowledgeEntry`

### Form intake

- [ ] `FormDefinition`
- [ ] `FormFieldDefinition`
- [ ] `FormSubmission`
- [ ] `FormSubmissionFieldValue`
- [ ] `FormSubmissionStatusEvent`
- [ ] `FormSubmissionAssignment`
- [ ] `FormSubmissionNote`
- [ ] `FormSubmissionExport`

Attachment model can wait unless we decide to demo upload placeholders:

- [ ] `FormSubmissionAttachment` optional placeholder only

## API routes

### Health / bootstrap / seeded data

- [x] `GET /api/v1/health`
- [x] `GET /api/v1/bootstrap` optional public seeded UI data, excluding user roster/contact identifiers
- [x] `GET /api/v1/plan_rules`
- [x] `GET /api/v1/plan_rules/:id`
- [x] `GET /api/v1/knowledge_entries`
- [x] `GET /api/v1/knowledge_entries/:id`

### Public ARIA chat

- [ ] `POST /api/v1/chat/public_sessions`
- [ ] `GET /api/v1/chat/public_sessions/:id`
- [ ] `POST /api/v1/chat/public_sessions/:id/messages`

### Secure handoff / secure chat

- [ ] `POST /api/v1/handoffs`
- [ ] `POST /api/v1/handoffs/:token/verify_demo`
- [ ] `GET /api/v1/secure_chat_sessions/:id`
- [ ] `POST /api/v1/secure_chat_sessions/:id/messages`

### Staff support sessions

- [ ] `GET /api/v1/staff/sessions`
- [ ] `GET /api/v1/staff/sessions/:id`
- [ ] `POST /api/v1/staff/sessions/:id/verified_facts`
- [ ] `POST /api/v1/staff/sessions/:id/drafts`
- [ ] `POST /api/v1/staff/sessions/:id/approve`
- [ ] `POST /api/v1/staff/sessions/:id/take_over`
- [ ] `POST /api/v1/staff/sessions/:id/notes`

### Forms / submissions

- [ ] `GET /api/v1/forms`
- [ ] `GET /api/v1/forms/:id`
- [ ] `POST /api/v1/form_submissions`
- [ ] `GET /api/v1/staff/form_submissions`
- [ ] `GET /api/v1/staff/form_submissions/:id`
- [ ] `POST /api/v1/staff/form_submissions/:id/status`
- [ ] `POST /api/v1/staff/form_submissions/:id/assign`
- [ ] `POST /api/v1/staff/form_submissions/:id/notes`
- [ ] `POST /api/v1/staff/form_submissions/:id/response`
- [ ] `POST /api/v1/staff/form_submissions/:id/exports`

### Admin / audit

- [x] `GET /api/v1/admin/audit_events` with prototype admin token guard
- [ ] `GET /api/v1/admin/dashboard`

## Frontend screens

### Public website / ARIA

- [ ] Existing ASC homepage stays polished.
- [ ] Public ARIA chat panel calls Rails API.
- [ ] General question returns seeded educational answer.
- [ ] Account-specific question triggers secure handoff CTA.

### Secure support

- [ ] Fake verification screen consumes handoff token.
- [ ] Secure chat loads from Rails.
- [ ] Participant sees waiting-on-staff status.
- [ ] Approved staff response appears in secure chat.

### Staff support dashboard

- [ ] Support session queue.
- [ ] Session detail view.
- [ ] Conversation transcript.
- [ ] Fake Relias verified facts form.
- [ ] Generate draft button.
- [ ] Edit/approve/takeover controls.
- [ ] Audit timeline.

### Enrollment/form intake

- [ ] Enrollment form landing page.
- [ ] Form fields based on simplified Jotform-inspired structure.
- [ ] Clear fake/sample warning near sensitive-looking fields.
- [ ] Review step.
- [ ] Submit to Rails.
- [ ] Confirmation page.

### Staff form submissions dashboard

- [ ] Submission queue.
- [ ] Submission detail page.
- [ ] Status selector.
- [ ] Assignment selector or seeded assignment buttons.
- [ ] Internal notes.
- [ ] Staff response/request-more-info field.
- [ ] Export placeholder button.
- [ ] Status/audit timeline.

### Admin overview

- [ ] Active support sessions card.
- [ ] Form submissions card.
- [ ] Needs review card.
- [ ] Needs more info card.
- [ ] Recent audit events list.

## ARIA behavior v1

### Deterministic classifier

Classify messages as:

- [ ] `general_education`
- [ ] `form_routing`
- [ ] `plan_specific`
- [ ] `participant_specific`
- [ ] `high_risk_escalation`

### Response strategy

- [ ] General education: answer from seeded knowledge.
- [ ] Form routing: point to embedded form or forms section.
- [ ] Plan-specific: use seeded fake `PlanRule` with caveats.
- [ ] Participant-specific: create secure handoff / staff review.
- [ ] High-risk: route to staff and avoid advice.

### No live LLM in first implementation unless explicitly approved

- [ ] Start with template responses.
- [ ] Add OpenRouter/LLM only after the safe Rails workflow is working.

## Audit events to create

- [ ] public chat session created
- [ ] public message received
- [ ] secure handoff created
- [ ] demo verification completed
- [ ] secure session created
- [ ] staff viewed session
- [ ] staff entered verified facts
- [ ] ARIA draft generated
- [ ] staff approved response
- [ ] staff took over session
- [ ] form submission created
- [ ] staff viewed form submission
- [ ] form status changed
- [ ] form assigned/reassigned
- [ ] internal note added
- [ ] staff response added
- [ ] export placeholder created

## Acceptance criteria for the full prototype

- [ ] User can ask ARIA a general question and get a useful answer.
- [ ] User can ask an account-specific question and be routed to secure support.
- [ ] Secure support session persists in Rails.
- [ ] Staff can review session, enter fake facts, generate draft, approve response.
- [ ] User can see approved response in secure chat.
- [ ] User can submit fake enrollment form.
- [ ] Staff can see form submission, change status, add note, respond/request info.
- [ ] Admin can see unified audit history.
- [ ] No real PII is requested or stored.
- [ ] Lint/build/tests pass.
- [ ] App remains mobile-friendly.
- [ ] Private deploy works.

## Verification commands

Frontend:

```bash
cd web
npm run lint
npm run build
```

Backend:

```bash
cd api
bundle install
bin/rails db:prepare
bin/rails test
bin/rubocop
bin/brakeman -q
bin/bundler-audit check
```

End-to-end smoke checks:

- [ ] public chat → secure handoff
- [ ] staff approve response → participant sees response
- [ ] submit fake form → staff sees submission
- [ ] staff updates form → audit event appears

## Implementation branch

Recommended first branch:

```text
feature/rails-react-prototype-foundation
```

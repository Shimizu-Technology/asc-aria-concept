# ASC + ARIA full end-to-end demo plan

**Status:** next implementation plan after PR #6
**Target branch:** `feature/full-secure-support-demo`
**Goal:** move from prototype plumbing to a production-shaped demo flow that ASC can actually click through, review, and critique before we connect Airtable and any real ASC participant/customer systems.

## Why this is the next step

PR #6 establishes the secure handoff foundation: public ARIA can escalate, Rails creates handoff and verification records, Resend/ClickSend services exist, Clerk-backed staff auth exists, secure sessions persist, support requests are created, and audit events are recorded.

The remaining problem is product completeness. A client demo should not depend on hidden dev bypasses, env-only test users, static queue cards, visible demo codes, or hardcoded participants. The next PR should make the **app experience itself** feel real while still using safe fake/demo data.

The intended demo should answer:

> If ASC approved this direction, what would participants, staff, supervisors, and admins actually do every day?

## Product principles

1. **Real workflow, fake/demo data until ASC approves real data.**
   The demo should use real Rails records, real Clerk staff sign-in, real verification delivery to allowlisted demo contacts, real secure sessions, real staff queue rows, and real audit history.

2. **Participants do not need traditional accounts for first secure support.**
   Participants use passwordless email/SMS verification against a trusted participant directory record. Later, ASC may choose a participant portal/SSO path, but passwordless support should remain the low-friction first path.

3. **Verification proves contact control plus directory match, not account facts.**
   A verified code opens a secure support session for the matched participant directory entry. It does not authorize ARIA to reveal balances, eligibility, loan status, or Relias facts without staff/data verification.

4. **Staff/admins use Clerk. Rails owns authorization.**
   Clerk proves employee identity. Rails owns local users, roles, assignments, permissions, workflow state, and audit events.

5. **Provider keys stay server-side.**
   The browser never calls OpenRouter, Resend, ClickSend, Airtable, or future participant systems directly.

6. **No real ASC participant data until explicitly approved.**
   Use fake/demo participants and allowlisted test contacts. Real Airtable and participant/customer DB integrations come after ASC approves data handling.

## End-to-end demo flow

### Participant path

1. Visitor opens public ASC site.
2. Visitor asks ARIA a general question.
3. ARIA answers publicly with safe education and source-aware constraints.
4. Visitor asks an account-specific question, such as:
   - “How much can I borrow from my 401(k)?”
   - “Do I have an active loan?”
   - “Can I take a hardship withdrawal?”
5. Rails classifies the prompt as participant/account-specific.
6. ARIA explains that secure support is required.
7. Visitor clicks `Continue securely`.
8. Rails creates a short-lived `HandoffToken`.
9. Participant enters email or phone.
10. Rails normalizes the contact and matches it to a demo `ParticipantDirectoryEntry`.
11. Rails sends a real verification code by Resend or ClickSend only when the contact is allowlisted.
12. Participant enters the code.
13. Rails verifies the challenge, re-checks handoff expiry, creates:
    - `SecureAccessSession`
    - `SecureChatSession`
    - `SupportRequest`
    - audit events
14. Participant lands in a secure support room.
15. Participant can send secure messages.
16. Participant sees staff-approved responses or staff takeover messages.

### Staff path

1. Staff clicks `Staff view`.
2. Clerk requires sign-in.
3. Rails verifies Clerk JWT and local staff role.
4. Staff sees a Rails-backed support queue, not static demo cards.
5. Staff opens a support request.
6. Staff sees:
   - secure transcript
   - participant directory summary
   - plan/rule context
   - verification history
   - delivery/audit timeline
7. Staff can:
   - assign request to self
   - set status
   - add internal notes
   - request/manual-record Relias lookup
   - enter structured verified facts
   - generate ARIA draft
   - edit draft
   - approve and send
   - take over chat
8. Participant secure room updates with the approved/staff message.
9. Every staff action is audited.

### Admin/supervisor path

1. Admin/supervisor signs in through Clerk.
2. Rails verifies supervisor/admin role.
3. Admin can manage demo staff and participants.
4. Admin can view audit trail and provider delivery logs.
5. Admin can inspect prompt/model/provider settings for the demo.
6. Admin can create and maintain demo knowledge/plan rules before Airtable is connected.

## Next PR scope

### 1. Remove demo-bypass feel from the app experience

Keep test helpers for automated tests, but the clickable product flow should not depend on:

- visible demo code in normal live-send mode
- env-only participant setup as the only way to create a demo participant
- static staff queue cards
- static admin audit lists
- staff/admin route access without Rails authorization

### 2. Admin-created demo participants

Add admin UI and API for demo participant directory entries.

Backend:

- `GET /api/v1/admin/participant_directory_entries`
- `POST /api/v1/admin/participant_directory_entries`
- `PATCH /api/v1/admin/participant_directory_entries/:id`
- `DELETE` or deactivate endpoint

Fields:

- display name
- external identifier
- employer name
- plan name
- status
- email contact input
- phone contact input
- masked email/phone display
- metadata/fake-data flag

Security:

- continue HMAC matching
- do not expose raw contact values in participant-facing responses
- if admins need to edit/view contacts, use encryption-at-rest or write-only contact update fields plus masked display

### 3. Staff/admin user management

Add admin UI and API for local staff users.

Backend:

- `GET /api/v1/admin/users`
- `POST /api/v1/admin/users`
- `PATCH /api/v1/admin/users/:id`
- deactivate/reactivate endpoint
- optional invite/resend endpoint when Clerk invite API is ready

Fields:

- name
- email
- role: staff, supervisor, admin
- status
- Clerk ID
- invitation status
- last sign-in

Rules:

- staff can see staff queue
- supervisor/admin can see admin/audit
- admin token fallback remains local/dev/emergency only
- no shared staff accounts

### 4. Real verification delivery for demo contacts

Make live demo verification clear and safe.

Requirements:

- real Resend email code for allowlisted test email
- real ClickSend SMS code for allowlisted test phone
- no visible demo code when live sends are enabled
- clear UI copy: “We sent a code if this contact matches ASC records.”
- delivery log visible to admin/staff, not public participant UI
- resend code flow with rate limits
- expiry and failed-attempt messaging

### 5. Rails-backed staff queue

Replace static queue with real `SupportRequest` data.

Staff queue should show:

- participant display name
- employer/plan
- topic
- status
- priority
- last activity
- assigned staff

Staff request detail should show:

- secure transcript
- participant directory summary
- handoff summary/original question
- verification metadata
- plan/rule context
- staff notes
- approved/queued participant response state

### 6. Staff response workflow

Add persisted staff actions and messages.

Needed capabilities:

- add internal note
- enter structured verified facts
- generate draft from verified facts + plan rules
- edit draft
- approve/send response to participant
- take over chat and send staff message
- resolve/close request

Potential models:

- `StaffNote`
- `VerifiedFactSet` or JSON metadata on `SupportRequest`
- `StaffResponseDraft`
- or start with fields on `SupportRequest` if keeping scope small

Audit events:

- support request viewed
- assigned
- status changed
- internal note added
- Relias lookup requested/completed manually
- verified facts entered
- draft generated
- draft edited
- response approved
- staff takeover started
- request resolved

### 7. Participant secure room completion

Participant secure chat should display:

- system welcome
- copied original question
- secure participant messages
- staff-approved response
- staff takeover messages
- current status

Add polling first if websockets are too much for this PR.

### 8. Admin audit dashboard

Replace static audit with real records.

Admin should filter/search by:

- participant/support request
- action
- actor
- date
- auditable type

Admin should see provider deliveries:

- email/SMS channel
- masked recipient
- provider
- status
- error text when failed
- timestamps

### 9. Knowledge, prompt, and Airtable-ready layer

Before Airtable integration, make the internal Rails tables the canonical demo source:

- `KnowledgeEntry`
- `PlanRule`
- prompt/system instructions config

Admin or seed-driven management should support:

- active/inactive entries
- source labels
- categories
- prompt version label
- safe answer policy text

Later Airtable sync should write into these same Rails tables instead of the frontend reading Airtable directly.

## Future integrations after demo approval

### Airtable

Purpose:

- curated plan rules
- form routing data
- knowledge snippets
- prompt/source metadata

Approach:

- Rails-only Airtable client
- sync job imports approved records into Rails tables
- Rails stores last sync state and source IDs
- ARIA retrieval uses Rails DB, not Airtable directly

### ASC participant/customer contact source

Options to confirm with ASC:

- Relias-approved export
- participant portal/contact system
- SFTP/export workflow
- minimal encrypted participant directory maintained by ASC staff
- API if available

Requirements before real data:

- ASC approval of data source and fields
- retention policy
- access-control policy
- encryption strategy
- audit trail review
- incident/revocation process

## Acceptance criteria for the next PR

The next PR is done when a reviewer can:

1. Sign in as admin/supervisor through Clerk.
2. Create or verify a demo participant directory record in the admin UI.
3. Create or verify a demo staff user in the admin UI.
4. Ask public ARIA an account-specific question.
5. Continue securely.
6. Receive a real email code to an allowlisted demo address.
7. Receive a real SMS code to an allowlisted demo phone when configured.
8. Verify the code and enter a secure participant room.
9. Send a secure participant message.
10. Sign in as staff and see the support request in a real Rails-backed queue.
11. Open the request, view transcript/context, add note or verified facts.
12. Draft/edit/approve a response.
13. See the approved response in the participant room.
14. Sign in as admin/supervisor and see the full audit trail.
15. Run automated tests without sending real provider messages.

## Non-goals for the next PR

- Real ASC participant/customer database integration.
- Real Airtable sync to production ASC tables.
- Storing real SSNs, DOBs, account numbers, balances, signatures, beneficiary data, uploaded documents, or Relias records.
- Fully automated account-specific AI answers without staff verification.
- Public launch or indexing.

## Demo safety settings

Keep these defaults until explicitly changed for a controlled demo:

```bash
LIVE_VERIFICATION_ALLOWLIST_REQUIRED=true
DEMO_VERIFICATION_CODES_ENABLED=false # when live email/SMS is enabled
```

Only allowlisted contacts that Leon/ASC controls should receive real verification codes.

## Recommended implementation order

1. Admin role/route hardening cleanup from PR #6 if any remains.
2. Admin participant-directory CRUD.
3. Admin staff-user CRUD and Clerk invite/resend shape.
4. Rails-backed staff queue UI.
5. Secure chat participant/staff message persistence polish.
6. Staff response workflow and audit events.
7. Provider delivery status/admin visibility.
8. Knowledge/prompt management and improved ARIA instructions.
9. End-to-end smoke tests and demo script.

## One-sentence client explanation

ASC gets a public education assistant, a secure participant handoff, real staff oversight, and auditable support operations first; once everyone agrees on the workflow, we connect Airtable and ASC-approved participant contact data behind the same Rails-controlled interfaces.

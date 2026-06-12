# ASC + ARIA secure support workflow

**Status:** architecture decision / build-readiness note  
**Last updated:** 2026-06-11  
**Related:** `docs/architecture-and-rag-plan.md`

## Core decision

ARIA should have two modes:

1. **Public ARIA** — general education, routing, FAQs, forms, and safe non-account-specific help.
2. **Secure ARIA Support** — authenticated participant support where messages are saved, staff can monitor/review, and account-specific questions can be handled with human oversight.

The public website chatbot should not become the place where sensitive account-specific support happens. When a participant asks for personal eligibility, balance, loan amount, existing loan status, or anything requiring Relias/account verification, ARIA should hand the user off to a dedicated authenticated support page.

## Recommended handoff model

```text
Public ASC website / ARIA widget
  ↓
User asks account-specific question
  ↓
ARIA says secure support is required
  ↓
User clicks “Continue securely”
  ↓
Rails creates a short-lived handoff token
  ↓
User authenticates on a secure support page
  ↓
Secure chat session is created / resumed
  ↓
Staff dashboard can monitor, review, and intervene
```

The user experience should feel continuous, but the technical boundary should be clear:

> Public ARIA is the front door. Secure ARIA is the private support room.

## Why not keep everything in the public widget?

A public floating chat widget is good for short general questions. It is not ideal for account-specific financial-services support.

Risks with keeping sensitive support inside the same public widget:

- unclear public/private boundary for users
- cramped UI for disclosures, verification, support status, and staff handoff
- harder session timeout / re-authentication handling
- harder staff review and saved transcript behavior
- higher chance that users enter sensitive data before proper authentication
- worse compliance story

Recommended product pattern:

```text
Public widget = education + routing
Authenticated page = saved private support session
Staff dashboard = human oversight + Relias bridge
Admin dashboard = governance, analytics, audit, knowledge controls
```

## Public ARIA behavior

Public ARIA can answer:

- how 401(k) loans generally work
- general difference between loan and withdrawal
- where to find forms
- how to contact ASC
- general retirement/support FAQ content
- what ARIA can help with
- public ASC services and locations

Public ARIA should not answer:

- “How much can I borrow?”
- “Am I eligible?”
- “What is my current balance?”
- “Do I already have an active loan?”
- “Can I withdraw today?”
- “What does my specific account allow?”
- anything requiring identity, account, balance, loan, employment status, or Relias verification

When asked an account-specific question, Public ARIA should say something like:

> I can explain general 401(k) loan rules here, but to answer how much you may personally be eligible to borrow, ASC needs to verify your identity and account information securely. Would you like to continue in secure support?

Buttons:

```text
[Continue securely] [General info only]
```

## Secure ARIA support behavior

Secure ARIA lives on an authenticated page, for example:

```text
/secure/aria
/secure/aria/sessions/:id
support.asctrust.com/aria
```

The secure page should show:

- authenticated identity / verification status
- topic and employer/plan context
- privacy notice
- saved conversation history
- status indicator
- clear human escalation option
- session timeout / re-authentication behavior

Possible support statuses:

```text
secure_active
needs_staff_review
waiting_on_relias_lookup
ai_draft_ready
staff_approved
human_takeover
escalated
resolved
closed
```

## Handoff token

When a public chat needs secure support, Rails should create a short-lived handoff record.

Possible fields:

```text
handoff_token
public_session_id
summary
intent
detected_employer_or_plan
reason_for_handoff
expires_at
used_at
authenticated_user_id
secure_chat_session_id
```

The handoff should preserve only safe context:

- original general question
- topic, such as `401k_loan`
- employer/plan if the user provided it
- public transcript summary
- why secure support is needed

It should not preserve sensitive unauthenticated personal data. Public ARIA should discourage users from typing SSNs, account numbers, or private account details before authentication.

## Authentication options

Prototype options:

- mocked verification screen for concept demo
- Clerk demo login
- email magic link
- SMS/phone OTP
- Rails/JWT demo auth

Production options should be decided after ASC security discovery:

- existing ASC/Relias identity provider, if possible
- SSO / SAML / OIDC
- Auth0 / Okta / Microsoft Entra ID
- Clerk if approved
- custom Rails auth plus identity proofing

Important principle:

> Authentication confirms who is in the secure support session. Authorization and support workflow still live in Rails.

## Staff dashboard requirement

A staff dashboard is required for the safe version of ARIA.

The staff dashboard should support:

- queue of active sessions
- review-needed sessions
- Relias lookup tasks
- AI draft review
- human takeover
- escalation
- resolved/closed sessions
- staff notes
- audit history

Queue statuses:

```text
Open
Needs Review
Needs Relias Lookup
Waiting on Staff
AI Draft Ready
Human Takeover
Escalated
Resolved
```

## Staff session detail view

The staff detail screen should include two major areas.

### Conversation panel

- participant-visible messages
- ARIA messages
- staff messages
- system events
- staff-only notes
- source/citation references
- internal AI summary

### Action panel

- detected intent
- detected employer/plan
- matched Airtable source records
- structured plan-rule summary
- retrieved knowledge chunks/sources
- whether Relias data is needed
- required staff input fields
- AI draft response
- approve/edit/send/take-over controls

## Relias bridge pattern

For v1/pilot, staff manually checks Relias.

Staff should enter verified Relias values into structured fields, not into a freeform AI prompt.

Example structured fields:

```text
verified_balance
vested_balance
active_employee_status
existing_active_loan_count
verification_notes
verified_by_staff_user_id
verified_at
```

Why structured fields matter:

- less sensitive data passed to the LLM
- easier auditability
- deterministic calculations are possible
- fewer hallucination risks
- clearer compliance story

The system should avoid the pattern:

> Staff types private data into a random AI box and asks AI to decide.

Preferred pattern:

> Staff enters minimum verified facts into controlled fields. Rails applies deterministic plan-rule logic and gives the LLM only the context needed to draft a safe explanation.

## Staff response flow

```text
Secure user asks specific question
  ↓
Rails retrieves structured plan rules
  ↓
Rails determines Relias data is required
  ↓
Staff review task is created
  ↓
Staff checks Relias manually
  ↓
Staff enters structured verified facts
  ↓
Rails calculates / frames the allowed response
  ↓
LLM drafts plain-English response
  ↓
Staff approves, edits, sends, or takes over
  ↓
Audit trail records all actions
```

## Secure form intake + admin submissions

The same secure-support architecture can also replace external form tools such as Jotform for high-trust participant intake.

Observed current-state example:

```text
Retirement Plan Enrollment Form
https://form.jotform.com/250117028657859
```

This kind of flow should eventually live inside ASC's own secure web experience rather than sending participants to a third-party form host.

### Why this belongs in the ASC platform

- keeps participants inside the ASC digital experience
- creates a cleaner mobile-friendly enrollment path
- gives ASC staff one dashboard for submissions, notes, statuses, and follow-up
- improves auditability over who viewed/processed sensitive submissions
- allows plan-aware form routing and validation over time
- avoids treating forms as disconnected PDFs/Jotforms/live-chat handoffs

### Important boundary

This is not just a frontend form. Retirement/enrollment forms can include sensitive information such as SSN/Tax ID, DOB, address, beneficiary information, employment/plan data, signatures, and attachments.

Do not build real submission handling until the backend/security phase includes:

- Rails/Postgres persistence
- encryption at rest for sensitive fields
- role-based staff/admin access
- audit events for viewing, editing, exporting, and status changes
- data retention/deletion policy
- secure file upload/attachment policy
- participant verification/authentication path
- approved notification rules that do not leak PII

### Recommended submission workflow

```text
Participant chooses a form
  ↓
ARIA or page routing confirms form type / plan context
  ↓
Secure form collects required fields
  ↓
Participant reviews and submits
  ↓
Staff submission queue receives item
  ↓
Staff assigns, reviews, requests more info, exports, or completes
  ↓
Audit trail records submission lifecycle
```

### Staff submission statuses

```text
New
In Review
Needs More Info
Ready for Processing
Exported
Completed
Rejected / Not Applicable
Archived
```

### Admin submission dashboard should support

- queue of all form submissions
- filters by form type, employer/plan, status, assigned staff, and date
- staff assignment/reassignment
- internal notes
- participant follow-up requests
- PDF/CSV export or packet generation
- attachment viewing/downloading with audit logs
- status history
- retention/archive controls

## Admin dashboard requirement

Admin/supervisor users need broader oversight.

Admin dashboard should support:

- all active and historical sessions
- staff assignment/reassignment
- escalations
- analytics
- unanswered question review
- AI confidence/risk flags
- audit logs
- knowledge/source management
- Airtable sync status
- prompt/version settings
- role/permission management

Possible roles:

### Super Admin

- all users/staff/sessions
- settings
- knowledge sources
- audit log
- model/provider configuration
- role management

### Supervisor

- all sessions or team sessions
- assign/reassign staff
- review escalations
- approve sensitive responses
- view reports

### Staff / Call Center

- assigned sessions
- unassigned queue
- review/action panel
- limited participant context
- staff notes

### Compliance / Read-only Reviewer

- transcripts
- source usage
- AI drafts and staff edits
- audit events
- reporting exports

## Data model sketch

Minimum backend models for secure support:

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
StaffAssignment
StaffReview
StaffVerifiedFact
AiResponseDraft
PlanRule
KnowledgeEntry
KnowledgeChunk
RetrievalEvent
AuditEvent
```

Suggested visibility fields for messages:

```text
sender_type: participant | aria | staff | system
visibility: participant_visible | staff_only | admin_only
```

Suggested audit events:

- handoff token created
- user authenticated
- secure session created
- staff viewed session
- staff assigned/reassigned
- Relias lookup requested
- verified fact entered
- AI draft generated
- staff edited draft
- response approved/sent
- human takeover started
- session escalated/resolved/closed

## Classification / escalation rules

ARIA should classify each message into one of these broad categories:

### Safe general

Answer directly from public/approved knowledge.

Examples:

- “What is a 401(k) loan?”
- “Is a loan different from a withdrawal?”
- “Where are the forms?”

### Plan-specific but not participant-specific

Can answer only from structured plan-rule data and with caveats.

Examples:

- “Does my employer's plan allow loans?”
- “How many loans does this plan allow?”

### Participant-specific

Requires secure authenticated support and possibly staff/Relias lookup.

Examples:

- “How much can I borrow?”
- “Am I eligible?”
- “What is my balance?”
- “Can I take another loan?”

### High-risk / always staff review

Requires escalation or staff review.

Examples:

- tax/legal advice
- hardship withdrawals
- divorce/QDRO
- death/beneficiary questions
- terminated employee questions
- loan default
- complaints
- self-harm/distress
- uncertainty or low confidence

## POC demonstration scope

The prototype should simulate the full workflow without real sensitive data.

Recommended POC screens:

1. Public ARIA widget asks/answers a general 401(k) loan question.
2. User asks an account-specific question.
3. ARIA offers “Continue securely.”
4. Fake authentication/verification screen.
5. Secure ARIA support page with saved-session feel.
6. Staff dashboard queue shows the session as `Needs Relias Lookup`.
7. Staff detail view shows required fields.
8. Staff enters fake/sample verified values.
9. ARIA draft appears.
10. Staff approves/sends.
11. Participant sees approved response in secure chat.
12. Admin/audit preview shows source/staff/action history.

POC data must remain fake/sample/sanitized.

## Final product framing

Use this language with ASC stakeholders:

> ARIA starts as a public assistant for general education and routing. When a participant asks something account-specific, ARIA moves them into a secure authenticated support session. From there, ASC staff can monitor, verify Relias information manually when needed, approve AI-drafted responses, or take over the conversation. Every message, source, staff action, and response is saved in an audit trail.

# ASC + ARIA identity and access plan

**Status:** architecture decision for secure support implementation
**Last updated:** 2026-06-13
**Related docs:** `docs/secure-support-workflow.md`, `docs/rails-backed-prototype-plan.md`, `docs/architecture-and-rag-plan.md`

## Decision summary

Use different access patterns for participants and ASC staff.

```text
Participants/customers
  Passwordless secure access by email link, email code, or SMS code.
  No required username/password account for the first secure support pilot.

ASC staff/admins
  Clerk invite-only staff login.
  Rails owns roles, permissions, support workflow, and audit logs.
```

The goal is to keep the participant experience easy for non-technical users while preserving a clear private support boundary.

## Core distinction

Sending a code to an email or phone number only proves contact control.

It does **not** prove that the person owns a specific retirement account unless that contact method is matched against a trusted ASC participant/contact source.

```text
User-entered email/phone + successful code
  = controls that contact method

Email/phone matched to ASC/Relias/approved participant directory + successful code
  = stronger verified participant access

Participant-specific answer involving balances, eligibility, active loans, or Relias facts
  = still requires staff/Relias verification until ASC approves deeper integration
```

This is the most important security/product rule for secure ARIA.

## Participant access UX

Participants should not need to create a traditional account just to continue a support conversation.

Recommended public-to-secure flow:

```text
Public ARIA widget
  ↓
Participant asks account-specific question
  ↓
ARIA says secure support is required
  ↓
Participant clicks “Continue securely”
  ↓
Rails creates short-lived HandoffToken
  ↓
Secure page asks for email or mobile number on file with ASC
  ↓
Rails creates VerificationChallenge
  ↓
Resend sends secure email link/code OR ClickSend sends SMS code
  ↓
Participant enters code / opens link
  ↓
Rails creates SecureAccessSession + SecureChatSession + SupportRequest
  ↓
Staff dashboard can review/intervene
```

Participant-facing wording should be plain:

> To protect your retirement information, ASC needs to verify you before continuing. Enter the email or mobile number ASC has on file for you. If it matches ASC records, we’ll send a secure code.

Avoid words like “authenticate,” “identity proofing,” “handoff token,” or “portal” in participant UI.

## Anti-enumeration rule

Public verification endpoints must use generic responses.

If the contact is blank, invalid, not found, inactive, or already rate-limited, the public response should still be generic:

> If that information matches ASC records, we’ll send a secure code.

Do not reveal whether an email/phone exists in ASC data.

Staff/admin screens may show direct delivery status because those screens are authenticated and authorized.

## Contact source strategy

### Prototype

Use fake seeded participant directory entries only.

```text
ParticipantDirectoryEntry
- fake external participant id
- safe display name
- employer/plan
- demo email
- demo phone
- active flag
```

No real ASC participant contact data.
No real sends unless explicit test flags and approved test recipients are configured.

### Pilot

Two acceptable pilot patterns:

1. **Manual verification pilot**
   - Participant receives passwordless secure access.
   - Staff still verifies identity/account details manually in Relias before account-specific answers.
   - Safest if ASC cannot approve a contact-data sync yet.

2. **Minimal approved contact directory**
   - ASC provides an approved minimal directory or export containing contact methods on file.
   - Rails matches against this directory to send codes.
   - Still avoid storing balances, DOBs, SSNs, beneficiary data, documents, or Relias facts.

### Production

Preferred production path:

- integrate with ASC’s existing participant portal, Relias-adjacent identity source, SSO/OIDC provider, or an ASC-approved participant contact service.

Fallback production path:

- store a minimal encrypted participant directory in Rails/Postgres, with ASC-approved retention, access control, audit logging, import process, and security review.

## Staff/admin access

Use Clerk for ASC employee login.

```text
ASC admin invites employee
  ↓
Employee signs in with Clerk
  ↓
Frontend sends Clerk JWT to Rails
  ↓
Rails verifies JWT and resolves local User/Role
  ↓
Rails authorizes staff/admin endpoints
```

Staff users should have individual accounts. No shared logins.

Roles:

```text
Super Admin      full system/settings/audit/model/role access
Supervisor       all/team sessions, assignment, escalation, approvals
Staff            assigned/unassigned support queue and session work
Compliance       read-only transcripts, source usage, audit/reporting
```

Clerk confirms staff identity. Rails remains the source of truth for app roles, permissions, staff assignments, and audit events.

## Email/SMS provider plan

Use existing Shimizu patterns:

- **Resend** for secure email links/codes.
- **ClickSend** for SMS codes.
- Provider secrets live only in Rails env.
- Frontend never calls Resend or ClickSend directly.
- Critical sends create delivery records and audit events.
- Live sends require explicit env/config gating.

Recommended delivery model:

```text
OutboundDelivery
- channel: email | sms
- provider: resend | clicksend
- recipient_masked
- recipient_digest
- provider_message_id
- status
- sent_at
- delivered_at
- failed_at
- metadata
```

For this app, a lighter one-off `OutboundDelivery` is enough initially. The fuller DPG `OutreachDelivery` resend/status pattern can be adopted later if ASC needs delivery dashboards, failed resend queues, or webhook-driven reporting.

## Verification challenge model

Store challenge codes safely.

```text
VerificationChallenge
- handoff_token_id
- participant_directory_entry_id optional
- channel: email | sms
- contact_digest
- contact_masked
- code_digest
- expires_at
- attempts_count
- sent_at
- verified_at
- consumed_at
- ip_address_digest optional
- user_agent_digest optional
```

Rules:

- never store raw code after creation
- short expiration window, such as 10 minutes
- max attempts per challenge
- rate limits per IP/contact/handoff token
- consume or invalidate after successful use
- audit challenge requested/sent/verified/failed/expired

## Secure session/history behavior

For early prototype/pilot, participants land directly in the active secure support session after verification.

Later, add a participant-facing support history page:

```text
My Secure Support
- Open requests
- Waiting on ASC
- Resolved requests
- Continue previous conversation
```

Access to history can still be passwordless. A participant enters the email/phone on file, receives a code/link, and sees only support requests tied to that verified contact/participant record.

Staff/admins should be able to view all secure support requests according to role.

## Account-specific answer rule

Even after passwordless verification, ARIA should not automatically provide account-specific answers unless the required source data is trusted and approved.

Early pilot rule:

```text
Passwordless verification opens secure support.
Staff verifies account facts manually in Relias.
Rails records structured verified facts.
ARIA drafts only staff-reviewed responses.
Staff approves/sends final answer.
```

This avoids the unsafe pattern of passing private account data directly into a freeform AI prompt.

## Implementation target for next PR

Build the prototype version with fake data:

- `HandoffToken`
- `ParticipantDirectoryEntry` seeded with fake contacts
- `VerificationChallenge`
- `OutboundDelivery` or lightweight delivery log
- `SecureAccessSession`
- `SecureChatSession`
- `SupportRequest`
- fake email/SMS challenge flow with provider interfaces stubbed unless explicitly configured
- staff queue visibility
- audit events for the full handoff/verification lifecycle

No real ASC participant data. No live SMS/email by default. No account-specific answers without staff review.

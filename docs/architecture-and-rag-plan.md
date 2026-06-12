# ASC + ARIA architecture and RAG plan

**Status:** planning direction for a production-shaped prototype  
**Last updated:** 2026-06-11  
**Related docs:** `docs/asc-public-content.md`

## Executive summary

The recommended long-term stack for ASC + ARIA is:

```text
React/Vite frontend
Rails API backend
Neon PostgreSQL
Airtable sync for plan-rule source data
Rails-orchestrated RAG / rule retrieval
LLM provider for explanation, classification, and summaries
Optional FastAPI AI service later only if Python-heavy AI infrastructure becomes necessary
```

The key architectural principle is:

> Do not simply dump plan rules into a vector database and let the AI infer eligibility. Sync ASC's Airtable plan-rule data into structured Rails/Postgres tables, use deterministic logic for exact plan-rule checks, use RAG for approved explanatory context, and use the LLM to explain, summarize, and prepare staff-reviewed responses.

## Final tech stack recommendation

### Frontend

**React + Vite + TypeScript**

Responsibilities:

- modern ASC public website experience
- participant support hub
- ARIA chat UI
- secure/supervised support flow UI
- staff review dashboard
- admin/knowledge-management screens later
- SEO/metadata handled the same way Shimizu Technology has handled other React client sites

Why React/Vite instead of Next.js:

- aligns with Shimizu Technology's established React + Rails pattern
- deploys cleanly to Netlify
- avoids coupling ASC's long-term business backend to a Next.js full-stack app
- sufficient for this site's SEO needs with good metadata, semantic pages, sitemap, and optional prerender/static export techniques if needed

### Backend

**Rails API**

Responsibilities:

- users, roles, and permissions
- chat sessions and chat messages
- staff review queue
- support requests
- secure form intake and submissions
- Airtable sync
- structured plan-rule tables
- knowledge base and retrieval
- AI orchestration
- audit logs
- source/citation records
- future Relias integration boundary if ASC approval ever becomes possible
- future reporting/analytics

Why Rails:

- ASC is a business workflow / financial-services support platform, not just an AI chatbot
- Rails is strong for relational workflows, auditability, admin state, background jobs, and long-term maintainability
- it matches Leon/Shimizu Technology's strongest production pattern

### Database

**Neon PostgreSQL**

Responsibilities:

- app data
- secure form submissions and staff workflow state
- synced plan rules
- normalized knowledge entries/chunks
- chat/session history
- staff-review records
- audit events
- optional embeddings via `pgvector` if available/appropriate

### Auth

Prototype options:

- Clerk if polished third-party login is needed quickly
- Rails/JWT demo auth if simpler for the prototype

Production principle:

- identity provider should be finalized after ASC security/compliance discovery
- Rails should still own app roles/permissions even if identity is delegated to Clerk/Auth0/Entra/etc.

### AI provider

Prototype:

- OpenRouter is acceptable for experimentation/model comparison

Production:

- likely direct OpenAI, Anthropic, Azure OpenAI, AWS Bedrock, Google Vertex, or another ASC-approved provider
- final choice depends on vendor/security review, data retention, subprocessors, auditability, and cost

### Optional later service

**FastAPI AI service only if needed**

Add later for:

- heavy document ingestion
- advanced PDF parsing
- batch embeddings
- reranking
- custom evals
- local/custom models
- Python-only AI libraries

Do not start with FastAPI unless the AI layer outgrows Rails. Rails should remain the source of truth and workflow controller.

## Deployment target

Current deployment pattern:

```text
Netlify  -> React frontend
Render   -> Rails API backend
Neon     -> PostgreSQL
Render   -> optional FastAPI AI service later, if needed
```

## Source systems from discovery notes

Discovery notes describe two ASC systems relevant to ARIA:

### Relias

- secure retirement-plan administration system
- holds participant/account-specific data
- examples: balances, account status, possibly existing loan count/status
- difficult to get approval for direct integration
- should not be integrated in the first version

### Airtable

- houses employer/plan-specific rules
- examples:
  - plan allows no loans
  - plan allows one loan
  - plan allows two loans
  - plan-specific nuances for each employer plan, using only ASC-approved or sanitized source records in prototypes
- less sensitive than Relias because it is rules/reference data rather than personal account data
- practical first integration target

### Jotform / external form links

- the current ASC public experience includes at least one external Jotform enrollment flow
- example observed: Retirement Plan Enrollment Form hosted at `form.jotform.com/250117028657859`
- the form collects sensitive participant information, including SSN/Tax ID fields
- good candidate for future replacement with ASC-owned secure form intake inside the app
- should not be reimplemented until backend, auth, storage, audit, retention, and staff workflow requirements are defined

## Recommended data architecture

```text
Airtable
  ↓ incremental sync
Rails API / Postgres
  ↓
Structured plan-rule tables + knowledge entries/chunks
  ↓
Deterministic rule checks + RAG retrieval
  ↓
ARIA response + staff review workflow
```

Airtable can remain the staff-maintained source of truth initially. Rails should sync it into Postgres so the application has controlled, auditable, queryable data.

## Structured rules vs RAG

Use both, but for different purposes.

### Structured rules

Use structured tables for exact plan checks:

- employer / plan name
- plan identifier
- loans allowed: yes/no
- max active loans
- max repayment term
- plan-specific loan limitations
- hardship/distribution flags
- eligibility notes
- source Airtable record ID
- effective date
- last reviewed date
- active/inactive status
- checksum/version

Rails should query these rules directly.

Example:

```text
User: "I work for Bank of Mila. Can I take two loans?"

Rails:
1. identify employer/plan = Bank of Mila sample plan
2. query structured plan rules
3. check max active loans
4. retrieve explanatory context
5. ask the LLM to explain the result safely
```

The LLM should not be the authority on whether a specific plan allows two loans. Rails/structured rules should be.

### Knowledge chunks / RAG

Use chunks and embeddings/full-text search for explanatory context:

- how 401(k) loans generally work
- ASC-approved loan-risk explanation
- tax distinction between loan vs withdrawal
- repayment concepts
- leaving-employment considerations
- plan-specific notes written in natural language
- FAQ answers approved by ASC staff
- disclaimers and escalation language

The LLM can use retrieved chunks to produce plain-English explanations, summaries, and staff drafts.

## Vector database position

The vector index should be a derived search index, not the source of truth.

Source of truth:

```text
Airtable or Postgres structured rules/knowledge records
```

Derived index:

```text
knowledge chunks + embeddings / pgvector / future vector DB
```

Start with Postgres full-text search and/or `pgvector` before adding a separate vector database. Add Pinecone/Qdrant/Weaviate/etc. only if ASC's document scale or retrieval needs justify it.

## Incremental update strategy

Avoid full rebuilds for small rule changes.

Each Airtable record should store locally:

- `airtable_record_id`
- `airtable_updated_at`
- normalized content checksum
- local version
- active/inactive status
- last synced timestamp

Sync process:

1. Pull Airtable records by schedule or webhook.
2. Compare Airtable updated timestamp and content checksum.
3. If unchanged, do nothing.
4. If changed:
   - update structured rule row
   - regenerate only affected knowledge chunks
   - regenerate only affected embeddings/search index rows
   - log the change
5. If removed/disabled in Airtable:
   - mark inactive rather than hard-delete immediately
   - keep audit trail

## ARIA request flow

```text
Participant asks question
  ↓
Rails saves user message
  ↓
Rails classifies intent
  ↓
Rails extracts employer/plan if provided
  ↓
Rails queries structured rules
  ↓
Rails retrieves approved knowledge chunks
  ↓
Rails determines if account-specific Relias data is required
  ↓
If safe/general: generate and return ARIA response
If sensitive/account-specific: create staff review item
  ↓
Staff can manually check Relias and enter safe facts
  ↓
ARIA drafts or displays a staff-reviewed response
  ↓
Rails logs sources, decisions, staff actions, and final response
```

## Human-in-the-loop Relias boundary

For v1 / pilot, do not connect directly to Relias.

Instead:

1. Participant asks ARIA about a 401(k) loan.
2. ARIA identifies employer/plan and retrieves Airtable-synced rules.
3. If account-specific data is needed, ARIA flags staff review.
4. ASC associate checks Relias manually.
5. Associate enters safe facts into the staff dashboard, such as:
   - verified balance
   - vested balance, if applicable
   - active/inactive employee status
   - existing active loan count
6. Rails combines staff-entered facts + structured plan rules + approved explanatory content.
7. ARIA prepares a response for staff approval or supervised delivery.

## Secure form intake + admin submissions

A strong future extension is to replace external Jotform enrollment/intake flows with secure, ASC-owned forms inside the website/app.

Recommended product framing:

> ASC participants should not have to leave the ASC digital experience to complete high-trust enrollment or request forms. Sensitive intake should happen in a secure ASC-owned flow with staff review, audit history, and controlled exports/handoffs.

This should be treated as a backend/security phase, not a frontend-only prototype feature.

### Participant-facing form flow

Possible embedded flows:

- retirement plan enrollment
- beneficiary update request
- distribution/loan intake precheck
- contact/update information
- request proposal / employer intake
- document upload for ASC staff review, if approved

User experience:

```text
Participant opens ASC form
  ↓
Form explains privacy and required information
  ↓
User completes plan-aware fields
  ↓
User reviews before submit
  ↓
Rails stores encrypted submission and attachments
  ↓
Staff queue receives new submission
  ↓
Staff reviews, requests more info, exports, or marks completed
  ↓
Audit trail records every action
```

### Admin/staff submission dashboard

Staff should be able to:

- view new submissions
- filter by form type, employer/plan, status, assigned staff, and date
- assign/reassign submissions
- add internal notes
- request more information from the participant
- mark statuses such as `new`, `in_review`, `needs_info`, `ready_for_processing`, `completed`, `rejected`, `archived`
- export PDF/CSV packets when ASC needs offline or third-party processing
- see submission history and audit events

### Suggested form models

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

### Security requirements

Because enrollment forms may collect SSNs, addresses, DOBs, signatures, beneficiary details, and other sensitive data, production requirements should include:

- HTTPS-only secure submission flow
- authenticated or strongly verified submission where appropriate
- encryption at rest for sensitive field values
- field-level redaction/masking in admin UI
- role-based access control
- staff/admin audit logs
- attachment scanning and access controls
- data retention and deletion policy approved by ASC
- notification policy that avoids sending sensitive data over email/SMS
- no sensitive form values passed into public ARIA prompts or general LLM context

### Relationship to ARIA

ARIA can help users find the right form and explain general requirements, but should not collect SSNs or sensitive enrollment details in public chat.

Safe pattern:

```text
Public ARIA helps identify the right form
  ↓
Secure form flow collects sensitive data
  ↓
Admin dashboard manages submissions
  ↓
Staff can use ARIA summaries only from approved, minimal, redacted context
```

## Staff dashboard requirements

The staff dashboard should show:

- conversation transcript
- detected intent
- detected employer/plan
- matched Airtable source record(s)
- relevant plan-rule fields
- retrieved knowledge chunks/sources
- whether Relias data is required
- required staff input fields
- AI-generated summary
- suggested response
- approve/edit/send/take-over controls
- audit history

This is the main product value: ARIA is not just a chatbot; it is a supervised support workflow that helps staff answer consistently and faster.

## Safety and compliance boundaries

ARIA should not:

- give financial, tax, legal, or investment advice
- claim final eligibility without account-specific verification
- invent plan rules
- answer from model memory when approved ASC data is missing
- expose or collect sensitive account information in a public chat
- treat vector search results as authoritative by themselves

ARIA should:

- answer from approved ASC data
- cite/source internally what it used
- escalate when uncertain or account-specific
- distinguish education from advice
- log source IDs, prompt versions, and staff actions
- use disclaimers approved by ASC/compliance

## Prototype scope using this architecture

The current public prototype can be evolved without becoming throwaway.

Next POC build direction:

1. Convert/organize toward a production-shaped monorepo:

```text
asc-aria/
  web/       # React/Vite frontend
  api/       # Rails API, when backend work begins
  docs/      # architecture, data boundaries, demo script
```

2. Add ARIA chat UI and staff dashboard screens in React.
3. Add Rails API only when ready to demonstrate persistence/workflow.
4. Seed Rails with sample public ASC content and fake/sample plan-rule data.
5. Model Airtable sync shape, even if the first data import is a fixture/CSV.
6. Show structured rule checks + RAG-shaped retrieval in a safe sample flow.
7. Keep all participant/account examples fake or sanitized.

## Final recommendation

Build toward:

```text
React + Rails API + Neon Postgres + Airtable sync + Rails-orchestrated RAG
```

Keep FastAPI as a future optional AI-specialist service, not the core app backend.

Position the product as:

> A supervised participant-support platform where ARIA answers from ASC-approved plan-rule knowledge, escalates account-specific questions to staff, and gives associates a clear review/intervention workflow.

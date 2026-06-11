# ASC + ARIA stakeholder demo script

**Purpose:** Walk ASC stakeholders through the concept without implying this is production code or an ASC-approved final design.

**Recommended opening line:**

> I put together a lightweight concept for what ASC Trust’s next website could feel like if the current public site were modernized and ARIA were built in as a safe support layer. It uses public ASC website content/assets and fake/sample workflow data. This is not production code, not an ASC-approved final design, and not connected to Relias, Airtable, authentication, or live AI. The goal is to make both the replacement-site direction and the ARIA workflow easier to react to.

## 3–5 minute walkthrough

### 1. Modernized ASC public website

Start on the public site concept.

Talking points:

- This is intentionally framed as an ASC Trust website modernization, not just a standalone chatbot demo.
- ASC already has strong trust signals: scale, regional presence, retirement-plan credibility, partners, values, testimonials, and contact locations.
- The opportunity is to keep that institutional trust while making the participant journey clearer, more mobile-friendly, and easier to route.
- The imported content index shows how ASC’s 45 public pages/posts and public asset library could be reorganized into a searchable, source-linked information architecture.
- ARIA should feel like part of ASC's support experience, not a random chatbot bolted onto the old site.

### 2. ARIA as the support layer

Show the ARIA card on the homepage and the participant support hub.

Talking points:

- ARIA stands for **Automated Retirement Information System**.
- Public ARIA can answer general questions, explain forms, and route users.
- Public ARIA should warn participants not to enter SSNs, account numbers, or private account details.
- Public ARIA should not answer personal balance, eligibility, or loan-amount questions.

### 3. Secure handoff

Click **Continue securely**.

Talking points:

- When a participant asks an account-specific question, ARIA moves them into secure support.
- This gives ASC a clean authentication/privacy boundary.
- In this prototype, verification is fake. Production auth would be decided after ASC security discovery.

### 4. Secure participant support session

Click **Verify and continue**.

Talking points:

- The secure page has saved-session behavior and clearer privacy expectations.
- ARIA can preserve the safe context from the public question.
- Account-specific answers wait for ASC staff review.

### 5. Staff dashboard and Relias bridge

Click **Open staff dashboard**.

Talking points:

- Staff stays in control.
- For v1, Relias remains manual: an ASC associate checks Relias and enters only the minimum safe verified facts.
- Structured fields are safer than asking staff to paste sensitive details into an AI prompt.
- ARIA drafts a response, but staff can approve, edit, or take over.

Recommended demo path:

1. Click **Generate ARIA draft**.
2. Optionally click **Edit response** and show that the response can be reviewed.
3. Click **Approve and send**.
4. Click **View participant secure chat** to show the approved response.

### 6. Admin / audit view

Open the admin/audit view.

Talking points:

- Supervisors need visibility into sessions, staff actions, source usage, unanswered questions, and escalations.
- The production system should log handoffs, verification, Relias lookup requests, staff-entered facts, AI drafts, edits, approvals, and final responses.
- This is the compliance story: ARIA is supervised, source-grounded, and auditable.

## Boundaries to state clearly

- Public ASC copy/images/logos are used for private stakeholder concept review and should be replaced with ASC-approved source assets before production.
- No real participant data.
- No real authentication.
- No live AI calls.
- No Relias integration.
- No Airtable integration yet.
- No tax, legal, investment, or financial advice.
- Final eligibility must be subject to ASC review and plan documents.

## Recommended close

> If this workflow direction makes sense, the responsible next step is a bounded discovery or pilot scope: confirm Airtable schema, top call-center questions, Relias fields staff uses, authentication requirements, disclaimers, audit retention, and who approves ARIA responses before building a production system.

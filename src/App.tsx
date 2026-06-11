import { useMemo, useState } from 'react'
import './App.css'

type View = 'home' | 'secure' | 'staff' | 'admin'
type StaffState = 'needs_lookup' | 'draft_ready' | 'editing' | 'human_takeover' | 'approved'

type ParticipantTask = {
  title: string
  helper: string
  response: string
  startsSecureHandoff?: boolean
}

const stats = [
  { value: '675+', label: 'retirement plans managed' },
  { value: '50,000+', label: 'participants represented' },
  { value: '$1B+', label: 'assets managed' },
  { value: '5', label: 'locations in the region' },
]

const participantTasks: ParticipantTask[] = [
  {
    title: 'Enroll in my plan',
    helper: 'See enrollment steps',
    response: 'A production participant hub could route this to enrollment instructions, login guidance, and plan-specific forms once ASC approves the source content.',
  },
  {
    title: 'Find a form',
    helper: 'Open form finder',
    response: 'ARIA can help narrow down the correct form category without asking for private account data in public chat.',
  },
  {
    title: 'Understand 401(k) loans',
    helper: 'Try secure handoff',
    response: 'Loan education can start publicly, but personal borrowing amounts and eligibility should move into secure support.',
    startsSecureHandoff: true,
  },
  {
    title: 'Read my statement',
    helper: 'Explain statement terms',
    response: 'Public ARIA could explain common statement terms. Anything involving balances or account status would require secure verification.',
  },
  {
    title: 'Update beneficiaries',
    helper: 'Find next steps',
    response: 'ARIA can point participants to general beneficiary-update guidance and escalate sensitive or legal edge cases to staff.',
  },
  {
    title: 'Contact ASC',
    helper: 'See support options',
    response: 'The hub can offer the right support channel based on topic, urgency, and whether the question requires private account review.',
  },
]

const sampleSession = {
  participant: 'Malia Santos',
  employer: 'Bank of Mila',
  plan: 'Sample Bank of Mila 401(k)',
  topic: '401(k) loan inquiry',
  intent: 'Participant-specific loan eligibility',
  handoffReason: 'Requested personal borrowing amount and eligibility',
  planRule: 'Loans allowed • 1 active loan maximum • 5-year general repayment term • final eligibility subject to plan documents and account status',
  verifiedFacts: {
    balance: '$100,000.00',
    vestedBalance: '$100,000.00',
    employmentStatus: 'Active employee',
    activeLoans: '0 active loans',
  },
}

const defaultDraftText =
  'Based on the verified sample balance and sample plan rules, you may be eligible to request a 401(k) loan up to applicable plan and IRS limits. Final eligibility, loan amount, repayment terms, and required forms must be confirmed by ASC and the governing plan documents. This is educational support only and is not tax, legal, investment, or financial advice.'

const baseAuditEvents = [
  'Public ARIA detected account-specific question',
  'Secure handoff token created',
  'Participant completed demo verification',
  'Staff review task opened',
  'Relias lookup requested for balance and active loan count',
  'Verified facts entered by ASC staff',
]

function App() {
  const [view, setView] = useState<View>('home')
  const [isVerified, setIsVerified] = useState(false)
  const [staffState, setStaffState] = useState<StaffState>('needs_lookup')
  const [draftText, setDraftText] = useState(defaultDraftText)

  const statusLabel = useMemo(() => {
    switch (staffState) {
      case 'approved':
        return 'Response approved and sent'
      case 'human_takeover':
        return 'ASC staff has taken over the conversation'
      case 'editing':
        return 'Draft open for staff editing'
      case 'draft_ready':
        return 'AI draft ready for staff approval'
      case 'needs_lookup':
      default:
        return 'Waiting on ASC associate / Relias lookup'
    }
  }, [staffState])

  const scrollToTop = () => window.scrollTo({ top: 0, behavior: 'smooth' })

  const goSecure = (options?: { freshHandoff?: boolean; verifiedSession?: boolean }) => {
    if (options?.freshHandoff) {
      setIsVerified(false)
      setStaffState('needs_lookup')
      setDraftText(defaultDraftText)
    }
    if (options?.verifiedSession) setIsVerified(true)
    setView('secure')
    scrollToTop()
  }

  const goStaff = () => {
    setView('staff')
    scrollToTop()
  }

  const goAdmin = () => {
    setView('admin')
    scrollToTop()
  }

  const goHome = () => {
    setView('home')
    scrollToTop()
  }

  const resetDemo = () => {
    setView('home')
    setIsVerified(false)
    setStaffState('needs_lookup')
    setDraftText(defaultDraftText)
    scrollToTop()
  }

  return (
    <main className="site-shell">
      <nav className="top-nav" aria-label="Main navigation">
        <button className="brand brand-button" onClick={goHome} aria-label="ASC Trust concept home">
          <span className="brand-mark">ASC</span>
          <span>
            <strong>ASC Trust</strong>
            <small>Automated Retirement Information System Concept</small>
          </span>
        </button>
        <div className="nav-links" aria-label="Concept sections">
          <button onClick={goHome}>Public site</button>
          <button onClick={() => goSecure()}>Secure support</button>
          <button onClick={goStaff}>Staff dashboard</button>
          <button onClick={goAdmin}>Admin/audit</button>
        </div>
        <div className="nav-actions">
          <button className="reset-link" onClick={resetDemo}>Reset demo</button>
          <button className="login-link" onClick={() => goSecure({ freshHandoff: true })}>Continue securely</button>
        </div>
      </nav>

      {view === 'home' && <PublicSiteView onSecure={() => goSecure({ freshHandoff: true })} onStaff={goStaff} />}
      {view === 'secure' && (
        <SecureSupportView
          isVerified={isVerified}
          setIsVerified={setIsVerified}
          statusLabel={statusLabel}
          staffState={staffState}
          draftText={draftText}
          onStaff={goStaff}
        />
      )}
      {view === 'staff' && (
        <StaffDashboardView
          staffState={staffState}
          setStaffState={setStaffState}
          draftText={draftText}
          setDraftText={setDraftText}
          onSecure={() => goSecure({ verifiedSession: true })}
          onAdmin={goAdmin}
        />
      )}
      {view === 'admin' && <AdminDashboardView staffState={staffState} onStaff={goStaff} />}

      <footer className="site-footer">
        <strong>ASC + ARIA Secure Support Concept</strong>
        <span>Public ASC content + fake/sample participant workflow data only. Not connected to Relias, Airtable, or live AI.</span>
      </footer>
    </main>
  )
}

function PublicSiteView({ onSecure, onStaff }: { onSecure: () => void; onStaff: () => void }) {
  const [showGeneralInfo, setShowGeneralInfo] = useState(false)
  const [selectedTask, setSelectedTask] = useState<ParticipantTask | null>(null)

  const handleTaskClick = (task: ParticipantTask) => {
    if (task.startsSecureHandoff) {
      onSecure()
      return
    }
    setSelectedTask(task)
  }

  return (
    <>
      <section id="hero" className="hero-section">
        <div className="hero-copy">
          <p className="eyebrow">Retirement Plan Leader in Micronesia</p>
          <h1><span>Retirement</span><span>support,</span><span>made clearer.</span></h1>
          <p className="hero-lede">
            ASC Trust helps participants, employers, and communities plan for a stronger financial future — one paycheck at a time.
          </p>
          <div className="hero-actions" aria-label="Primary actions">
            <a className="primary-button" href="#participants">I’m a participant</a>
            <button className="secondary-button" onClick={onStaff}>Preview staff flow</button>
          </div>
        </div>

        <aside className="aria-preview-card" aria-label="ARIA secure handoff preview">
          <div className="card-topline">
            <span className="status-dot" />
            <span>Public ARIA is online</span>
          </div>
          <div className="acronym-box">
            <span>ARIA</span>
            <strong>Automated Retirement Information System</strong>
          </div>
          <h2><span>Helpful answers first.</span><span>Secure handoff when</span><span>it becomes personal.</span></h2>
          <div className="chat-window mini">
            <p className="message aria">Buenos! I can help with forms, general 401(k) questions, and next steps.</p>
            <p className="message user">I work for Bank of Mila. How much can I borrow from my 401(k)?</p>
            <p className="message aria">
              To answer how much you may personally be eligible to borrow, ASC needs to verify your identity and account information securely.
            </p>
          </div>
          <div className="handoff-actions">
            <button className="secure-button" onClick={onSecure}>Continue securely</button>
            <button className="ghost-button" onClick={() => setShowGeneralInfo(true)}>General info only</button>
          </div>
          {showGeneralInfo && (
            <div className="inline-info-card" role="status">
              <strong>General 401(k) loan info stays public.</strong>
              <span>ARIA can explain common loan concepts and forms here, but personal eligibility, balances, and loan counts move to secure support.</span>
            </div>
          )}
          <ComplianceNotice compact />
        </aside>
      </section>

      <section className="stats-strip" aria-label="ASC Trust public credibility stats">
        {stats.map((stat) => (
          <div className="stat" key={stat.label}>
            <strong>{stat.value}</strong>
            <span>{stat.label}</span>
          </div>
        ))}
      </section>

      <section id="participants" className="split-section participant-section">
        <div>
          <p className="eyebrow">Participant support hub</p>
          <h2>One clear place to start — before ARIA routes the complex parts.</h2>
          <p>
            The public experience stays safe and useful: education, routing, forms, and support paths. Account-specific questions move to authenticated support where staff can monitor and intervene.
          </p>
          {selectedTask && (
            <div className="selected-task-card" role="status">
              <span>Selected task</span>
              <strong>{selectedTask.title}</strong>
              <p>{selectedTask.response}</p>
            </div>
          )}
        </div>
        <div className="task-grid" aria-label="Participant task cards">
          {participantTasks.map((task) => (
            <button onClick={() => handleTaskClick(task)} className="task-card" key={task.title}>
              <span>{task.title}</span>
              <small>{task.helper} →</small>
            </button>
          ))}
        </div>
      </section>

      <section id="workflow" className="aria-section">
        <div className="section-heading">
          <p className="eyebrow">The safe handoff model</p>
          <h2>Public chat is the front door. Secure ARIA is the private support room.</h2>
        </div>
        <div className="handoff-map" aria-label="Secure handoff workflow map">
          {['Public question', 'Account-specific intent', 'Secure verification', 'Saved support session', 'Staff Relias bridge', 'Approved response'].map((step, index) => (
            <div className="handoff-step" key={step}>
              <span>{index + 1}</span>
              <strong>{step}</strong>
            </div>
          ))}
        </div>
      </section>
    </>
  )
}

function SecureSupportView({
  isVerified,
  setIsVerified,
  statusLabel,
  staffState,
  draftText,
  onStaff,
}: {
  isVerified: boolean
  setIsVerified: (value: boolean) => void
  statusLabel: string
  staffState: StaffState
  draftText: string
  onStaff: () => void
}) {
  return (
    <section className="app-view secure-app-view">
      <div className="view-heading">
        <p className="eyebrow">Secure ARIA support</p>
        <h1><span>Private support,</span><span>with staff oversight.</span></h1>
        <p>
          This proof of concept simulates the authenticated support room where messages are saved, staff can review, and account-specific questions can be handled safely.
        </p>
      </div>

      {!isVerified ? (
        <div className="auth-layout">
          <div className="auth-card">
            <span className="badge">Demo verification</span>
            <h2>Continue to secure support</h2>
            <p>
              ARIA can explain general rules publicly, but loan eligibility and borrowing amounts require a private support session.
            </p>
            <div className="context-box">
              <span>Handoff reason</span>
              <strong>{sampleSession.handoffReason}</strong>
              <small>Topic: {sampleSession.topic} • Employer: {sampleSession.employer}</small>
            </div>
            <ComplianceNotice compact />
            <button className="primary-button" onClick={() => setIsVerified(true)}>Verify and continue</button>
          </div>
          <div className="checklist-card">
            <h3>Secure page adds</h3>
            <ul>
              <li>Identity/verification boundary</li>
              <li>Saved transcript and session status</li>
              <li>Staff review queue visibility</li>
              <li>Audit trail for sources and actions</li>
            </ul>
          </div>
        </div>
      ) : (
        <div className="secure-session-grid">
          <div className="secure-chat-card">
            <div className="panel-header stacked">
              <span>Verified participant</span>
              <strong>{sampleSession.participant}</strong>
              <small>{sampleSession.employer} • {sampleSession.plan}</small>
            </div>
            <div className={`session-status ${staffState}`}>{statusLabel}</div>
            <div className="chat-window contained tall">
              <p className="message aria">You’re now in secure ARIA support. I’ll keep this session private and save the transcript for ASC review.</p>
              <p className="message user">I work for Bank of Mila. How much can I borrow from my 401(k)?</p>
              <p className="message aria">I found the sample plan-rule record for your employer, but ASC staff needs to verify your balance and active loan count before an account-specific response can be approved.</p>
              <p className="message system-note">System: Staff review task created — Needs Relias Lookup.</p>
              {staffState === 'human_takeover' && <p className="message staff">An ASC associate has joined this secure support session and can continue the conversation directly.</p>}
              {staffState === 'approved' && <p className="message aria">{draftText}</p>}
            </div>
          </div>

          <aside className="support-side-card">
            <h3>What moved from public chat</h3>
            <div className="review-list compact">
              <div><span>Intent</span><strong>{sampleSession.intent}</strong></div>
              <div><span>Plan</span><strong>{sampleSession.employer}</strong></div>
              <div><span>Next action</span><strong>Staff verifies Relias facts</strong></div>
            </div>
            <ComplianceNotice compact />
            <button className="approve-button" onClick={onStaff}>Open staff dashboard</button>
          </aside>
        </div>
      )}
    </section>
  )
}

function StaffDashboardView({
  staffState,
  setStaffState,
  draftText,
  setDraftText,
  onSecure,
  onAdmin,
}: {
  staffState: StaffState
  setStaffState: (state: StaffState) => void
  draftText: string
  setDraftText: (text: string) => void
  onSecure: () => void
  onAdmin: () => void
}) {
  const showDraft = staffState === 'draft_ready' || staffState === 'editing' || staffState === 'approved'
  const canApprove = showDraft && staffState !== 'approved'
  const canGenerateDraft = staffState === 'needs_lookup'
  const canEdit = showDraft && staffState !== 'approved'
  const canTakeOver = staffState !== 'approved' && staffState !== 'human_takeover' && staffState !== 'editing'

  const generateDraft = () => {
    setDraftText(defaultDraftText)
    setStaffState('draft_ready')
  }

  return (
    <section className="app-view staff-app-view">
      <div className="view-heading compact-heading">
        <p className="eyebrow">ASC staff dashboard</p>
        <h1><span>Human-in-the-loop</span><span>support operations.</span></h1>
        <p>
          Call-center staff monitor secure chats, complete manual Relias lookups, enter structured verified facts, and approve or take over ARIA responses.
        </p>
      </div>

      <div className="staff-grid">
        <aside className="queue-panel">
          <div className="panel-header stacked">
            <span>Review queue</span>
            <strong>4 active sessions</strong>
          </div>
          <QueueItem active name={sampleSession.participant} status="Needs Relias Lookup" topic="401(k) loan" />
          <QueueItem name="Jon Reyes" status="AI Draft Ready" topic="Beneficiary update" />
          <QueueItem name="Ana Cruz" status="Human Takeover" topic="Hardship question" />
          <QueueItem name="Kai Flores" status="Resolved" topic="Find a form" />
        </aside>

        <div className="staff-detail-panel">
          <div className="detail-topline">
            <div>
              <p className="eyebrow">Current session</p>
              <h2>{sampleSession.participant}</h2>
              <p>{sampleSession.employer} • {sampleSession.topic}</p>
            </div>
            <span className={`status-pill ${staffState}`}>{getStaffStatusText(staffState)}</span>
          </div>

          <div className="staff-columns">
            <div className="staff-card transcript-card">
              <h3>Conversation</h3>
              <div className="chat-window contained">
                <p className="message user">How much can I borrow from my 401(k)?</p>
                <p className="message aria">I need ASC staff to verify account-specific information before answering that.</p>
                {showDraft && <p className="message system-note">System: ARIA draft generated for staff review. See the action panel before approving or editing.</p>}
                {staffState === 'editing' && <p className="message system-note">System: Staff is editing the ARIA draft before approval.</p>}
                {staffState === 'human_takeover' && <p className="message staff">Staff takeover started. ARIA is no longer drafting this response.</p>}
                {staffState === 'approved' && <p className="message system-note">System: Staff approved response and sent it to the secure participant chat.</p>}
              </div>
            </div>

            <div className="staff-card action-card">
              <h3>Relias bridge + plan rules</h3>
              <div className="context-box muted">
                <span>Matched plan rule</span>
                <strong>{sampleSession.planRule}</strong>
              </div>
              <div className="fact-grid">
                <Fact label="Verified balance" value={sampleSession.verifiedFacts.balance} />
                <Fact label="Vested balance" value={sampleSession.verifiedFacts.vestedBalance} />
                <Fact label="Employment" value={sampleSession.verifiedFacts.employmentStatus} />
                <Fact label="Existing loans" value={sampleSession.verifiedFacts.activeLoans} />
              </div>
              <p className="fine-print">Demo only: staff enters structured verified facts instead of typing sensitive data into a freeform AI prompt.</p>
              {showDraft && (
                <div className="draft-box">
                  <span>ARIA draft for staff review</span>
                  {staffState === 'editing' ? (
                    <textarea
                      value={draftText}
                      onChange={(event) => setDraftText(event.target.value)}
                      aria-label="Edit ARIA draft response"
                    />
                  ) : (
                    <p>{draftText}</p>
                  )}
                </div>
              )}
              <ComplianceNotice compact />
              <div className="button-row">
                <button className="secondary-button" onClick={generateDraft} disabled={!canGenerateDraft}>Generate ARIA draft</button>
                <button className="primary-button" onClick={() => setStaffState('approved')} disabled={!canApprove}>Approve and send</button>
              </div>
              <div className="button-row secondary-row">
                {staffState === 'editing' ? (
                  <button className="ghost-button" onClick={() => setStaffState('draft_ready')}>Save edited draft</button>
                ) : (
                  <button className="ghost-button" onClick={() => setStaffState('editing')} disabled={!canEdit}>Edit response</button>
                )}
                <button className="ghost-button" onClick={() => setStaffState('human_takeover')} disabled={!canTakeOver}>
                  {staffState === 'human_takeover' ? 'Takeover active' : 'Take over chat'}
                </button>
              </div>
            </div>
          </div>

          <div className="handoff-actions lower-actions">
            <button className="ghost-button" onClick={onSecure}>View participant secure chat</button>
            <button className="ghost-button" onClick={onAdmin}>Open admin/audit view</button>
          </div>
        </div>
      </div>
    </section>
  )
}

function AdminDashboardView({ staffState, onStaff }: { staffState: StaffState; onStaff: () => void }) {
  const auditEvents = useMemo(() => {
    if (staffState === 'human_takeover') return [...baseAuditEvents, 'Staff took over secure participant chat']
    if (staffState === 'approved') return [...baseAuditEvents, 'ARIA draft generated from plan rules + verified facts', 'Staff approved supervised response']
    if (staffState === 'draft_ready' || staffState === 'editing') return [...baseAuditEvents, 'ARIA draft generated from plan rules + verified facts']
    return baseAuditEvents
  }, [staffState])

  return (
    <section className="app-view admin-app-view">
      <div className="view-heading compact-heading">
        <p className="eyebrow">Admin + audit preview</p>
        <h1><span>Oversight for</span><span>safe AI support.</span></h1>
        <p>
          Supervisors and compliance reviewers need visibility into sessions, source usage, staff actions, unanswered questions, and knowledge updates.
        </p>
      </div>

      <div className="admin-metrics">
        <Metric value="18" label="active secure sessions" />
        <Metric value="6" label="need staff review" />
        <Metric value="2" label="high-risk escalations" />
        <Metric value="98%" label="source-linked responses" />
      </div>

      <div className="admin-grid">
        <div className="admin-card">
          <div className="panel-header stacked">
            <span>Sample audit trail</span>
            <strong>{sampleSession.participant} • {getStaffStatusText(staffState)}</strong>
          </div>
          <ol className="audit-list">
            {auditEvents.map((event, index) => (
              <li key={event}>
                <span>{String(index + 1).padStart(2, '0')}</span>
                <strong>{event}</strong>
              </li>
            ))}
          </ol>
        </div>

        <div className="admin-card governance-card">
          <h3>Governance controls</h3>
          <div className="review-list compact">
            <div><span>Airtable sync</span><strong>Last checked 8:42 AM</strong></div>
            <div><span>Knowledge source</span><strong>Plan rules v0.3 sample</strong></div>
            <div><span>Auth mode</span><strong>Demo verification</strong></div>
            <div><span>Model mode</span><strong>Scripted POC, no live AI</strong></div>
            <div><span>Required disclaimers</span><strong>Education only; ASC review required</strong></div>
            <div><span>Retention</span><strong>To be defined with ASC</strong></div>
          </div>
          <button className="approve-button" onClick={onStaff}>Return to staff review</button>
        </div>
      </div>
    </section>
  )
}

function ComplianceNotice({ compact = false }: { compact?: boolean }) {
  return (
    <div className={`compliance-notice ${compact ? 'compact' : ''}`}>
      <strong>Educational concept only.</strong>
      <span>ARIA should not provide tax, legal, investment, or financial advice. Final eligibility and account-specific answers require ASC review and plan documents.</span>
    </div>
  )
}

function QueueItem({ name, status, topic, active = false }: { name: string; status: string; topic: string; active?: boolean }) {
  return (
    <article className={`queue-item ${active ? 'active' : ''}`} aria-current={active ? 'true' : undefined}>
      <span>{status}</span>
      <strong>{name}</strong>
      <small>{topic}</small>
    </article>
  )
}

function Fact({ label, value }: { label: string; value: string }) {
  return (
    <div className="fact-card">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  )
}

function Metric({ value, label }: { value: string; label: string }) {
  return (
    <div className="metric-card">
      <strong>{value}</strong>
      <span>{label}</span>
    </div>
  )
}

function getStaffStatusText(staffState: StaffState) {
  switch (staffState) {
    case 'draft_ready':
      return 'Draft ready'
    case 'editing':
      return 'Editing draft'
    case 'human_takeover':
      return 'Human takeover'
    case 'approved':
      return 'Approved'
    case 'needs_lookup':
    default:
      return 'Needs lookup'
  }
}

export default App

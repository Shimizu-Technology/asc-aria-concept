import type { MouseEvent } from 'react'
import { useMemo, useState } from 'react'
import './App.css'
import { ascImageAssets, ascPages } from './ascSiteData'

type View = 'home' | 'secure' | 'staff' | 'admin'
type StaffState = 'needs_lookup' | 'draft_ready' | 'editing' | 'human_takeover' | 'approved'

type ParticipantTask = {
  title: string
  helper: string
  response: string
  startsSecureHandoff?: boolean
}

type FormCategory = {
  title: string
  forms: string[]
}

const asset = (name: string) => `/asc-assets/${name}`

const stats = [
  { value: '675+', label: 'retirement plans managed' },
  { value: '50,000+', label: 'participants represented' },
  { value: '$1B+', label: 'assets managed' },
  { value: '5', label: 'locations throughout the region' },
]

const publicNavItems = [
  { label: 'About ASC', href: '#story' },
  { label: 'Services', href: '#services' },
  { label: 'Serving Participants', href: '#participants' },
  { label: 'Forms', href: '#forms' },
  { label: 'ARIA Support', href: '#resources' },
  { label: 'Resources', href: '#content-index' },
]

const contentSectionOrder = ['Home', 'About ASC', 'Services', 'Serving Participants', 'Investments', 'Resources', 'Contact', 'Legal']

const ascContentSections = contentSectionOrder
  .map((title) => ({ title, count: ascPages.filter((page) => page.section === title).length }))
  .filter((section) => section.count > 0)

const services = [
  {
    title: 'Retirement Plans',
    body: 'Plan design, compliance, administration, recordkeeping, reporting, and audit support for employer-sponsored retirement plans.',
  },
  {
    title: 'Participant Education',
    body: 'On-site meetings, quarterly statements, retirement report cards, welcome kits, and one-on-one advisory conversations.',
  },
  {
    title: 'IRA and Savings Programs',
    body: 'Support for Individual Retirement Accounts, Guam College Savings Plans, and other long-term savings needs.',
  },
  {
    title: 'Benefits Administration',
    body: 'Administration support for Health Savings Accounts, Section 125 Cafeteria Plans, and charitable giving programs.',
  },
]

const values = [
  {
    title: 'Participants Come First',
    icon: 'icon-participants-first.png',
    body: 'ASC Trust is sustained by the faith that participants place in us. Their trust is built on our integrity and our advocacy of their interests.',
  },
  {
    title: 'Superior Products',
    icon: 'icon-products.png',
    body: 'Products must delight customers, exceed expectations, and raise the standard that has come before.',
  },
  {
    title: 'Entrepreneurial Spirit',
    icon: 'icon-entrepreneurial.png',
    body: 'Independent thought, agile decision making, and creative solutions keep the organization moving forward.',
  },
  {
    title: 'Uncompromising Ethics',
    icon: 'icon-ethics.png',
    body: 'ASC requires everyone in the organization to adhere to the highest ethical standards.',
  },
  {
    title: 'Great People',
    icon: 'icon-people.png',
    body: 'Every person who works at ASC Trust contributes to the success of clients, participants, and the wider community.',
  },
  {
    title: 'Financial Success',
    icon: 'icon-finance.png',
    body: 'Financial success is used to further ASC’s purpose in harmony with its values.',
  },
]

const participantTasks: ParticipantTask[] = [
  {
    title: 'Enroll in my plan',
    helper: 'See enrollment steps',
    response: 'Find enrollment instructions, login guidance, and plan-specific forms in one place.',
  },
  {
    title: 'Find a form',
    helper: 'Open form finder',
    response: 'ARIA can ask a few safe routing questions, narrow the form category, and keep private account facts out of public chat.',
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
    response: 'ARIA can explain common statement terms. Anything involving balances or account status requires secure verification.',
  },
  {
    title: 'Update beneficiaries',
    helper: 'Find next steps',
    response: 'ARIA can point participants to general beneficiary-update guidance and escalate sensitive or legal edge cases to staff.',
  },
  {
    title: 'Contact ASC',
    helper: 'See support options',
    response: 'ASC can route you to the right support channel based on topic, urgency, and whether the question requires private account review.',
  },
]

const formCategories: FormCategory[] = [
  {
    title: '401(k) / 403(b)',
    forms: ['Enrollment/Change Form', 'Hardship Request Form', 'Distribution Form', 'Loan Form', 'Census Form', 'Spousal Consent Form'],
  },
  {
    title: 'GCC/GDOE/UOG 403(b)',
    forms: ['403(b) Enrollment/Change Form', '403(b) Distribution Form', '403(b) Loan Form', '403(b) Hardship Request Form'],
  },
  {
    title: 'NMI DC Retirement Forms',
    forms: ['NMI Enrollment/Change Form', 'NMI Hardship Request Form', 'NMI Distribution Form', 'NMI Spousal Consent Form', 'NMI Loan Form'],
  },
  {
    title: 'Guam College Savings Plan',
    forms: ['529 College Savings Enrollment Form', '529 College Savings Contribution Change Form', '529 College Savings Distribution Form'],
  },
  {
    title: 'Individual Retirement Accounts',
    forms: ['IRA Enrollment Form', 'IRA Distribution Form', 'Spousal Consent Form'],
  },
  {
    title: 'HSA and Section 125',
    forms: ['ASC HSA Enrollment Form', 'ASC HSA Distribution Form', 'Dependent Care Claim Form', 'Medical Care Expense Form'],
  },
]

const locations = [
  {
    region: 'Guam',
    address: ['120 Father Dueñas Avenue', 'Suite 110', 'Hagåtña, GU 96910'],
    phone: 'Main 671.477.2724',
    extra: 'Toll-free from US 866.577.9049',
  },
  {
    region: 'Saipan',
    address: ['PO Box 10001', 'PMB 201', 'Saipan, MP 96950'],
    phone: 'Main 670.235.2724/5',
  },
  {
    region: 'Micronesia',
    address: ['P.O. Box 2113', 'Kolonia, PNI 96941'],
    phone: 'Main 691.320.7470',
  },
]

const sampleSession = {
  participant: 'Malia Santos',
  employer: 'Bank of Mila',
  plan: 'Bank of Mila 401(k)',
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
  'Based on the verified balance and plan rules, you may be eligible to request a 401(k) loan up to applicable plan and IRS limits. Final eligibility, loan amount, repayment terms, and required forms must be confirmed by ASC and the governing plan documents. This is educational support only and is not tax, legal, investment, or financial advice.'

const baseAuditEvents = [
  'Public ARIA detected account-specific question',
  'Secure handoff token created',
  'Participant completed secure verification',
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
        return 'Waiting on ASC staff verification'
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

  const goHomeSection = (sectionId: string) => {
    setView('home')
    window.setTimeout(() => {
      document.getElementById(sectionId)?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }, 0)
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
      <SiteHeader
        goHome={goHome}
        goHomeSection={goHomeSection}
        goSecure={() => goSecure()}
        goStaff={goStaff}
        goAdmin={goAdmin}
        resetDemo={resetDemo}
      />

      {view === 'home' && <PublicSiteView onSecure={() => goSecure({ freshHandoff: true })} />}
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
    </main>
  )
}

function SiteHeader({
  goHome,
  goHomeSection,
  goSecure,
  goStaff,
  goAdmin,
  resetDemo,
}: {
  goHome: () => void
  goHomeSection: (sectionId: string) => void
  goSecure: () => void
  goStaff: () => void
  goAdmin: () => void
  resetDemo: () => void
}) {
  const handleSectionClick = (event: MouseEvent<HTMLAnchorElement>, href: string) => {
    if (!href.startsWith('#')) return

    event.preventDefault()
    goHomeSection(href.slice(1))
  }

  const openExternal = { target: '_blank', rel: 'noopener noreferrer' }

  return (
    <header className="asc-header">
      <div className="utility-bar" aria-label="ASC Trust utility navigation">
        <span>Retirement plan leader in Micronesia</span>
        <div className="utility-actions">
          <a href="https://www.yourbenefitaccount.com/ascpac/" {...openExternal}>Account Login</a>
          <a href="https://www.asctrust.com/serving-participants/enroll-now/" {...openExternal}>Open Account</a>
          <a href="#contact" onClick={(event) => handleSectionClick(event, '#contact')}>Contact Us</a>
          <a href="https://www.asctrust.com/request-a-proposal/" {...openExternal}>Request Proposal</a>
        </div>
      </div>

      <nav className="main-nav" aria-label="Main navigation">
        <button className="logo-button" onClick={goHome} aria-label="ASC Trust home">
          <img src={asset('asc-logo.png')} alt="ASC Trust" />
        </button>

        <div className="public-nav-links" aria-label="ASC public site sections">
          {publicNavItems.map((item) => (
            <a key={item.label} href={item.href} onClick={(event) => handleSectionClick(event, item.href)}>
              {item.label}
            </a>
          ))}
          <button onClick={goSecure}>Secure Support</button>
        </div>

        <div className="demo-controls" aria-label="ARIA workflow controls">
          <button className="demo-chip" onClick={resetDemo}>Start over</button>
          <button className="demo-chip" onClick={goStaff}>Staff view</button>
          <button className="demo-chip" onClick={goAdmin}>Audit view</button>
          <button className="secure-cta" onClick={goSecure}>Continue securely</button>
        </div>
      </nav>
    </header>
  )
}

function PublicSiteView({ onSecure }: { onSecure: () => void }) {
  const [showGeneralInfo, setShowGeneralInfo] = useState(false)
  const [selectedTask, setSelectedTask] = useState<ParticipantTask | null>(null)
  const [selectedFormCategory, setSelectedFormCategory] = useState<FormCategory>(formCategories[0])
  const [contentFilter, setContentFilter] = useState('Services')

  const visibleContentPages = useMemo(() => {
    if (contentFilter === 'All') return ascPages
    return ascPages.filter((page) => page.section === contentFilter)
  }, [contentFilter])

  const featuredContentPage = visibleContentPages[0] ?? ascPages[0]
  const showcasedAssets = ascImageAssets.slice(0, 48)

  const handleTaskClick = (task: ParticipantTask) => {
    if (task.startsSecureHandoff) {
      onSecure()
      return
    }
    setSelectedTask(task)
  }

  return (
    <>
      <section id="home" className="asc-hero">
        <div className="hero-panel">
          <p className="eyebrow">Retirement Plan Leader in Micronesia</p>
          <h1>Local retirement expertise. A clearer digital front door.</h1>
          <p className="hero-lede">
            ASC Trust helps participants, employers, and communities plan for a successful retirement — one paycheck at a time. ARIA adds clear guidance for general questions and a secure path when support becomes personal.
          </p>
          <div className="hero-actions" aria-label="Primary actions">
            <a className="primary-button" href="#participants">Explore participant support</a>
            <button className="secondary-button" onClick={onSecure}>Continue securely</button>
          </div>
        </div>

        <div className="hero-image-stage" aria-label="ASC Trust team and ARIA support">
          <img src={asset('take-control-hero.jpg')} alt="ASC Trust participants looking over Guam" />
          <div className="hero-image-tint" />
          <aside className="aria-preview-card">
            <div className="card-topline">
              <span className="status-dot" />
              <span>ARIA support</span>
            </div>
            <h2>Answers first. Secure handoff when it becomes personal.</h2>
            <div className="chat-window mini">
              <p className="message aria">Buenos! I can help with forms, general 401(k) questions, and next steps.</p>
              <p className="message user">I work for Bank of Mila. How much can I borrow from my 401(k)?</p>
              <p className="message aria">To answer that, ASC needs to verify your identity and account information securely.</p>
            </div>
            <div className="handoff-actions">
              <button className="secure-button" onClick={onSecure}>Continue securely</button>
              <button className="ghost-button" onClick={() => setShowGeneralInfo(true)}>General info only</button>
            </div>
            {showGeneralInfo && (
              <div className="inline-info-card" role="status">
                <strong>General 401(k) loan education stays public.</strong>
                <span>Personal eligibility, balances, and active loan counts move to secure support.</span>
              </div>
            )}
          </aside>
        </div>
      </section>

      <section className="stats-strip" aria-label="ASC Trust public credibility stats">
        {stats.map((stat) => (
          <div className="stat" key={stat.label}>
            <strong>{stat.value}</strong>
            <span>{stat.label}</span>
          </div>
        ))}
      </section>

      <section id="story" className="story-section">
        <div className="image-offset-card">
          <img src={asset('asc-team.jpg')} alt="ASC Trust team" />
        </div>
        <div className="section-copy">
          <p className="eyebrow">Our Story</p>
          <h2>ASC Trust is a proven leader.</h2>
          <p>
            We’re the largest provider of retirement plan management services in Micronesia. To best serve clients, ASC’s team of more than 60 professionals are located in five locations throughout the region.
          </p>
          <p>
            For the past three decades, ASC Trust has created innovative products and services designed to help plan participants save for a successful retirement, one paycheck at a time.
          </p>
          <div className="story-callout">
            <strong>Local service, clearer access</strong>
            <span>Trusted regional expertise, practical participant education, and secure support when questions depend on account details.</span>
          </div>
        </div>
      </section>

      <section id="services" className="services-section">
        <div className="section-heading compact">
          <p className="eyebrow">Services</p>
          <h2>One place for ASC’s full range of services.</h2>
          <p>
            ASC Trust supports employers, participants, and partners with retirement plans, benefit programs, education, and long-term savings guidance.
          </p>
        </div>
        <div className="service-grid">
          {services.map((service) => (
            <article className="service-card" key={service.title}>
              <span />
              <h3>{service.title}</h3>
              <p>{service.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section id="participants" className="participant-section">
        <div className="participant-copy">
          <p className="eyebrow">Serving Participants</p>
          <h2>Take control. Stay on track. Maximize contributions.</h2>
          <p>
            Get practical guidance for enrollment, forms, statements, contributions, and common retirement questions. When an answer depends on account records, ARIA moves the conversation to secure support.
          </p>
          {selectedTask && (
            <div className="selected-task-card" role="status">
              <span>Selected task</span>
              <strong>{selectedTask.title}</strong>
              <p>{selectedTask.response}</p>
            </div>
          )}
          <div className="participant-chart-row">
            <img src={asset('chart-take-control.jpg')} alt="Take Control retirement savings chart" />
            <img src={asset('chart-stay-on-track.jpg')} alt="Stay on Track retirement progress chart" />
            <img src={asset('chart-maximize.jpg')} alt="Maximize contributions retirement savings chart" />
          </div>
        </div>
        <div className="task-grid" aria-label="Participant task cards">
          {participantTasks.map((task) => (
            <button onClick={() => handleTaskClick(task)} className="task-card" key={task.title}>
              <span>{task.title}</span>
              <small>{task.helper}</small>
            </button>
          ))}
        </div>
      </section>

      <section className="values-section">
        <div className="section-heading center">
          <p className="eyebrow">Our Core Values</p>
          <h2>Values that guide every relationship.</h2>
        </div>
        <div className="values-grid">
          {values.map((value) => (
            <article className="value-card" key={value.title}>
              <img src={asset(value.icon)} alt="" aria-hidden="true" />
              <h3>{value.title}</h3>
              <p>{value.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section id="forms" className="forms-modern-section">
        <div className="forms-visual">
          <img src={asset('forms-hero.jpg')} alt="ASC Trust forms and support" />
          <div className="forms-caption">
            <strong>Forms finder</strong>
            <span>Not all plans accept every online form. ARIA can route first, then confirm with ASC when needed.</span>
          </div>
        </div>
        <div className="forms-panel">
          <p className="eyebrow">Forms</p>
          <h2>Make the form library feel searchable instead of intimidating.</h2>
          <p>
            Browse common ASC form categories and start with the paperwork most likely to match your plan and request.
          </p>
          <div className="form-picker" aria-label="Form category picker">
            {formCategories.map((category) => (
              <button
                className={category.title === selectedFormCategory.title ? 'active' : ''}
                key={category.title}
                onClick={() => setSelectedFormCategory(category)}
              >
                {category.title}
              </button>
            ))}
          </div>
          <div className="form-results" role="status">
            <strong>{selectedFormCategory.title}</strong>
            <ul>
              {selectedFormCategory.forms.map((form) => <li key={form}>{form}</li>)}
            </ul>
          </div>
        </div>
      </section>

      <section id="resources" className="aria-section">
        <div className="section-heading">
          <p className="eyebrow">The safe handoff model</p>
          <h2>Get the right answer in the right setting.</h2>
          <p>
            ARIA can answer general questions, help visitors find forms, and explain common retirement topics. When a participant asks something account-specific, ARIA moves the conversation into a saved, staff-reviewed support flow.
          </p>
        </div>
        <div className="handoff-map" aria-label="Secure handoff workflow map">
          {['Public question', 'Personal account question', 'Secure verification', 'Saved support session', 'ASC staff review', 'Approved response'].map((step, index) => (
            <div className="handoff-step" key={step}>
              <span>{String(index + 1).padStart(2, '0')}</span>
              <strong>{step}</strong>
            </div>
          ))}
        </div>
      </section>

      <section id="content-index" className="content-index-section">
        <div className="section-heading compact">
          <p className="eyebrow">Resources</p>
          <h2>Explore ASC services, participant tools, and planning resources.</h2>
          <p>
            Browse information across ASC Trust services, participant resources, investments, forms, and contact pages. For account-specific questions, continue securely so ASC can verify your details.
          </p>
        </div>

        <div className="content-filter-row" aria-label="Filter ASC resource pages">
          <button className={contentFilter === 'All' ? 'active' : ''} onClick={() => setContentFilter('All')}>
            All <span>{ascPages.length}</span>
          </button>
          {ascContentSections.map((section) => (
            <button
              className={contentFilter === section.title ? 'active' : ''}
              key={section.title}
              onClick={() => setContentFilter(section.title)}
            >
              {section.title} <span>{section.count}</span>
            </button>
          ))}
        </div>

        <div className="content-library-layout">
          <article className="featured-content-card">
            {featuredContentPage.heroImage && (
              <img src={featuredContentPage.heroImage} alt="" loading="lazy" aria-hidden="true" />
            )}
            <div>
              <span className="badge">{featuredContentPage.section}</span>
              <h3>{featuredContentPage.title}</h3>
              <p>{featuredContentPage.summary}</p>
              {featuredContentPage.highlights.length > 0 && (
                <ul>
                  {featuredContentPage.highlights.slice(0, 4).map((highlight) => <li key={highlight}>{highlight}</li>)}
                </ul>
              )}
              <a className="source-link" href={featuredContentPage.sourceUrl} target="_blank" rel="noopener noreferrer">
                Learn more
              </a>
            </div>
          </article>

          <div className="content-page-grid" aria-live="polite">
            {visibleContentPages.map((page) => (
              <article className="content-page-card" key={page.slug}>
                {page.heroImage && <img src={page.heroImage} alt="" loading="lazy" aria-hidden="true" />}
                <div>
                  <span>{page.section}</span>
                  <h3>{page.title}</h3>
                  <p>{page.summary}</p>
                  <a href={page.sourceUrl} target="_blank" rel="noopener noreferrer">Learn more</a>
                </div>
              </article>
            ))}
          </div>
        </div>

        <div className="asset-library-panel">
          <div>
            <p className="eyebrow">In the community</p>
            <h3>Local people, planning tools, and regional service brought forward visually.</h3>
            <p>
              ASC’s visual system pairs trusted local imagery with practical education, service categories, and clear participant guidance.
            </p>
          </div>
          <div className="asset-mosaic" aria-label="ASC image gallery">
            {showcasedAssets.map((image) => (
              <a href={image.sourceUrl} target="_blank" rel="noopener noreferrer" key={image.src} aria-label={`View ASC image: ${image.label}`}>
                <img src={image.src} alt="" loading="lazy" decoding="async" />
              </a>
            ))}
          </div>
        </div>
      </section>

      <section className="proof-section">
        <div className="testimonial-card">
          <p className="eyebrow">What Clients Are Saying</p>
          <blockquote>
            “Not only did ASC Trust break this notion, they surpassed my expectations. We were able to start a plan that was both fairly priced and made sense with what we were looking for.”
          </blockquote>
          <cite>Bill Beery, General Manager, Tutujan Hill Group</cite>
        </div>
        <div className="partners-card">
          <p className="eyebrow">Our Partners</p>
          <p>
            ASC Trust combines local personal service with support from industry-leading partners that help manage technology and investments.
          </p>
          <img src={asset('partners.png')} alt="ASC Trust partner logos: BGIS, Fidelity Investments, and FIS" />
          <small>Partners are not employed by or affiliated with ASC Trust.</small>
        </div>
      </section>

      <section id="contact" className="modern-footer">
        <div>
          <img src={asset('asc-logo.png')} alt="ASC Trust" />
          <p>
            ASC Trust is the leader of retirement plan management in Micronesia, helping participants and employers plan for a successful retirement one paycheck at a time.
          </p>
        </div>
        <div className="location-grid">
          {locations.map((location) => (
            <article className="location-card" key={location.region}>
              <h3>{location.region}</h3>
              {location.address.map((line) => <span key={line}>{line}</span>)}
              <strong>{location.phone}</strong>
              {location.extra && <small>{location.extra}</small>}
            </article>
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
          Secure ARIA support keeps the conversation private, saves the session for ASC staff, and protects account-specific questions with human oversight.
        </p>
      </div>

      {!isVerified ? (
        <div className="auth-layout">
          <div className="auth-card">
            <span className="badge">Secure verification</span>
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
            <h3>Secure support includes</h3>
            <ul>
              <li>Identity/verification boundary</li>
              <li>Saved transcript and session status</li>
              <li>Staff review queue visibility</li>
              <li>Audit trail for staff actions</li>
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
              <p className="message aria">I found the plan-rule record for your employer, but ASC staff needs to verify your balance and active loan count before an account-specific response can be approved.</p>
              <p className="message system-note">System: Staff verification requested.</p>
              {staffState === 'human_takeover' && <p className="message staff">An ASC associate has joined this secure support session and can continue the conversation directly.</p>}
              {staffState === 'approved' && <p className="message aria">{draftText}</p>}
            </div>
          </div>

          <aside className="support-side-card">
            <h3>What moved from public chat</h3>
            <div className="review-list compact">
              <div><span>Intent</span><strong>{sampleSession.intent}</strong></div>
              <div><span>Plan</span><strong>{sampleSession.employer}</strong></div>
              <div><span>Next action</span><strong>Staff verifies account details</strong></div>
              <div><span>Status</span><strong>{statusLabel}</strong></div>
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
              <div className="context-box">
                <span>Matched plan rule</span>
                <strong>{sampleSession.planRule}</strong>
              </div>
              <div className="fact-grid">
                <Fact label="Verified balance" value={sampleSession.verifiedFacts.balance} />
                <Fact label="Vested balance" value={sampleSession.verifiedFacts.vestedBalance} />
                <Fact label="Employment" value={sampleSession.verifiedFacts.employmentStatus} />
                <Fact label="Existing loans" value={sampleSession.verifiedFacts.activeLoans} />
              </div>
              <p className="fine-print">Staff enters structured verified facts instead of typing sensitive data into a freeform AI prompt.</p>
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
        <p className="eyebrow">Admin + audit</p>
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
            <span>Audit trail</span>
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
            <div><span>Knowledge source</span><strong>Plan rules knowledge base</strong></div>
            <div><span>Auth mode</span><strong>Secure verification</strong></div>
            <div><span>Model mode</span><strong>Supervised response workflow</strong></div>
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
      <strong>Educational support only.</strong>
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

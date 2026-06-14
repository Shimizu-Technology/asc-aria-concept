# ASC + ARIA prototype seeds.
# Fake/sample data only. Do not put real participant, Relias, Airtable, or ASC production data here.

roles = [
  [ "participant", "Fake participant role for prototype secure support." ],
  [ "staff", "ASC staff demo role for reviewing support sessions and form submissions." ],
  [ "supervisor", "ASC supervisor demo role for admin and audit review." ],
  [ "admin", "System admin demo role." ]
].to_h do |name, description|
  role = Role.find_or_initialize_by(name: name)
  role.description = description
  role.save!
  [ name, role ]
end

malia = User.find_or_initialize_by(email: "malia.santos@example.test")
malia.assign_attributes(name: "Malia Santos", role: roles.fetch("participant"), status: "active")
malia.save!
malia.create_participant_profile!(
  employer_name: "Bank of Mila",
  plan_name: "Bank of Mila 401(k)",
  external_identifier: "DEMO-PARTICIPANT-001",
  phone: "671-555-0101"
) unless malia.participant_profile

test_participant_email = ENV["ASC_ARIA_TEST_PARTICIPANT_EMAIL"].presence || "malia.demo@example.test"
test_participant_phone = ENV["ASC_ARIA_TEST_PARTICIPANT_PHONE"].presence || "671-555-0100"
test_staff_email = ENV["ASC_ARIA_STAFF_EMAIL"].presence || "staff@example.test"
test_staff_name = ENV["ASC_ARIA_STAFF_NAME"].presence || "ASC Staff Demo"

participant_directory_entries = [
  {
    external_identifier: "DEMO-DIRECTORY-001",
    display_name: "Malia Santos Demo",
    email: test_participant_email,
    phone: test_participant_phone,
    employer_name: "Bank of Mila",
    plan_name: "Bank of Mila 401(k)",
    metadata: { fake_data_only: true, note: "Seeded passwordless verification demo contact." }
  },
  {
    external_identifier: "DEMO-DIRECTORY-002",
    display_name: "Tasi Cruz Demo",
    email: "tasi.demo@example.test",
    phone: "671-555-0101",
    employer_name: "Guam Demo Employer",
    plan_name: "Guam Demo Employer 401(k)",
    metadata: { fake_data_only: true, note: "Seeded passwordless verification demo contact." }
  }
]

participant_directory_entries.each do |attributes|
  entry = ParticipantDirectoryEntry.find_or_initialize_by(external_identifier: attributes.fetch(:external_identifier))
  entry.assign_attributes(attributes.merge(status: "active"))
  entry.save!
end

staff = User.find_or_initialize_by(email: test_staff_email)
staff.assign_attributes(name: test_staff_name, role: roles.fetch("staff"), status: "active")
staff.save!
staff.create_staff_profile!(
  title: "Participant Support Associate",
  department: "Participant Support"
) unless staff.staff_profile

supervisor = User.find_or_initialize_by(email: "supervisor@example.test")
supervisor.assign_attributes(name: "ASC Supervisor Demo", role: roles.fetch("supervisor"), status: "active")
supervisor.save!
supervisor.create_staff_profile!(
  title: "Support Supervisor",
  department: "Participant Support"
) unless supervisor.staff_profile

plan_rules = [
  {
    employer_name: "Bank of Mila",
    plan_name: "Bank of Mila 401(k)",
    plan_type: "401(k)",
    loans_allowed: true,
    max_active_loans: 1,
    max_repayment_years: 5,
    hardship_allowed: true,
    distribution_notes: "Seeded sample rule: final eligibility depends on account status, plan documents, and ASC staff verification.",
    source_label: "Seeded fake Airtable-style plan rule",
    effective_on: Date.new(2026, 1, 1)
  },
  {
    employer_name: "Guam Demo Employer",
    plan_name: "Guam Demo Employer 401(k)",
    plan_type: "401(k)",
    loans_allowed: true,
    max_active_loans: 2,
    max_repayment_years: 5,
    hardship_allowed: true,
    distribution_notes: "Seeded sample rule: participant must remain subject to plan and IRS limits.",
    source_label: "Seeded fake Airtable-style plan rule",
    effective_on: Date.new(2026, 1, 1)
  },
  {
    employer_name: "Pacific Sample Education",
    plan_name: "Pacific Sample 403(b)",
    plan_type: "403(b)",
    loans_allowed: false,
    max_active_loans: 0,
    max_repayment_years: nil,
    hardship_allowed: true,
    distribution_notes: "Seeded sample rule: loans are not available; route participant to ASC staff for alternatives.",
    source_label: "Seeded fake Airtable-style plan rule",
    effective_on: Date.new(2026, 1, 1)
  },
  {
    employer_name: "Demo Government Plan",
    plan_name: "Demo Government DC Plan",
    plan_type: "Defined Contribution",
    loans_allowed: true,
    max_active_loans: 1,
    max_repayment_years: 5,
    hardship_allowed: false,
    distribution_notes: "Seeded sample rule: government-plan requests may require additional staff review.",
    source_label: "Seeded fake Airtable-style plan rule",
    effective_on: Date.new(2026, 1, 1)
  }
]

plan_rules.each do |attributes|
  rule = PlanRule.find_or_initialize_by(
    employer_name: attributes.fetch(:employer_name),
    plan_name: attributes.fetch(:plan_name)
  )
  rule.assign_attributes(attributes.merge(active: true))
  rule.save!
end

knowledge_entries = [
  {
    category: "401k_loans",
    title: "401(k) loan basics",
    content: "A 401(k) loan lets a participant borrow from eligible vested retirement funds when the plan allows loans. Final eligibility depends on plan rules, account status, available vested balance, and applicable IRS limits.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "401k_loans",
    title: "Loan vs withdrawal",
    content: "A loan is generally repaid back into the participant's retirement account. A withdrawal permanently removes funds and may have tax consequences. ARIA should keep this educational and route account-specific questions to secure support.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "401k_loans",
    title: "Repayment term caveat",
    content: "General-purpose retirement plan loans commonly use repayment terms up to five years, but the governing plan documents and ASC review determine the actual options for a participant.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "401k_loans",
    title: "Leaving employment caveat",
    content: "Leaving employment can change available retirement-plan options and may affect loan, distribution, or rollover paths. Participants should confirm their employment status and plan rules with ASC before acting.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "retirement_plan_basics",
    title: "Common retirement plan categories",
    content: "Common employer retirement plan categories include 401(k) plans for many private employers, 403(b) plans for certain nonprofit or education employers, profit-sharing or defined-contribution arrangements, and government retirement plans. The exact options available to a participant depend on the employer's adopted plan documents.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "401k_plan_types",
    title: "Common 401(k) plan features and types",
    content: "Public education can describe common 401(k) variations such as traditional pre-tax 401(k) contributions, Roth 401(k) contributions when offered, safe harbor 401(k) designs, SIMPLE 401(k) plans for some smaller employers, and individual or solo 401(k) plans for self-employed owners. A single employer plan may combine several features, and ASC staff should confirm the actual adopted plan provisions.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "401k_plan_types",
    title: "Traditional versus Roth contribution basics",
    content: "Traditional 401(k) contributions are generally made before taxes and may be taxable when distributed. Roth 401(k) contributions are generally made after taxes and may allow qualified tax-free withdrawals. ARIA should keep this educational and avoid tax advice; participants should confirm their plan options and consult qualified advisors for tax questions.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "401k_plan_types",
    title: "Employer contribution basics",
    content: "Some employer plans include matching, safe harbor, discretionary, or profit-sharing contributions. Whether those features exist, how they vest, and how they affect a participant's account depends on the employer's plan documents and ASC review.",
    source_label: "Seeded ASC educational prototype content"
  },
  {
    category: "secure_support",
    title: "Account-specific escalation",
    content: "When a participant asks about personal balance, eligibility, loan amount, or active loan count, ARIA should move the conversation to secure support so ASC can verify identity and account details.",
    source_label: "Seeded ASC support policy prototype content"
  },
  {
    category: "forms",
    title: "Enrollment form routing",
    content: "ARIA can help a participant find enrollment and plan forms, but sensitive enrollment details should be collected only in a secure form flow, not in public chat.",
    source_label: "Seeded ASC forms prototype content"
  },
  {
    category: "disclaimers",
    title: "Educational support only",
    content: "ARIA provides educational support only and should not provide tax, legal, investment, or financial advice. Final eligibility and account-specific answers require ASC review and plan documents.",
    source_label: "Seeded ASC disclaimer prototype content"
  }
]

knowledge_entries.each do |attributes|
  entry = KnowledgeEntry.find_or_initialize_by(
    category: attributes.fetch(:category),
    title: attributes.fetch(:title)
  )
  entry.assign_attributes(attributes.merge(active: true))
  entry.save!
end

prototype_seed_event = AuditEvent.find_or_initialize_by(action: "prototype_seeded", actor: supervisor)
prototype_seed_event.metadata = {
  message: "Seeded fake users, fake Airtable-style plan rules, and controlled ARIA knowledge entries.",
  fake_data_only: true
}
prototype_seed_event.occurred_at ||= Time.current
prototype_seed_event.save!

puts "Seeded #{Role.count} roles, #{User.count} users, #{ParticipantDirectoryEntry.count} participant directory entries, #{PlanRule.count} plan rules, #{KnowledgeEntry.count} knowledge entries."

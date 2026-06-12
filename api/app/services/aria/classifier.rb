module Aria
  class Classifier
    Result = Struct.new(
      :intent,
      :handoff_required,
      :handoff_reason,
      :topic,
      :matched_plan_rule,
      :knowledge_categories,
      :safety_flags,
      keyword_init: true
    )

    PARTICIPANT_SPECIFIC_PATTERN = /\b(my|i|me|mine|myself)\b/i
    ACCOUNT_DETAIL_PATTERN = /\b(balance|borrow|loan amount|eligible|eligibility|vested|account|active loan|withdraw|distribution|hardship|take out|how much can i|can i borrow)\b/i
    HIGH_RISK_PATTERN = /\b(tax advice|legal advice|investment advice|should i invest|what fund should i|guarantee|avoid taxes|lawsuit|sue|suicide|self[- ]harm)\b/i
    FORM_PATTERN = /\b(form|forms|enroll|enrollment|beneficiar|distribution|hardship|spousal consent|submit|paperwork|document)\b/i
    LOAN_PATTERN = /\b(401\(?k\)?|403\(?b\)?|loan|borrow|repay|repayment|vested)\b/i

    def initialize(message)
      @message = message.to_s.strip
      @normalized_message = @message.downcase
    end

    def call
      plan_rule = matched_plan_rule

      if high_risk?
        return result(
          intent: "high_risk_escalation",
          handoff_required: true,
          handoff_reason: "Asked for advice or support that requires ASC staff review.",
          topic: "High-risk support request",
          matched_plan_rule: plan_rule,
          knowledge_categories: %w[disclaimers secure_support],
          safety_flags: [ "advice_or_escalation_required" ]
        )
      end

      if participant_specific?(plan_rule)
        return result(
          intent: "participant_specific",
          handoff_required: true,
          handoff_reason: "Asked for account-specific eligibility, balance, or borrowing details.",
          topic: "Account-specific retirement plan support",
          matched_plan_rule: plan_rule,
          knowledge_categories: %w[401k_loans secure_support disclaimers],
          safety_flags: [ "requires_identity_or_account_verification" ]
        )
      end

      if form_routing?
        return result(
          intent: "form_routing",
          handoff_required: false,
          handoff_reason: nil,
          topic: "Forms and enrollment routing",
          matched_plan_rule: plan_rule,
          knowledge_categories: %w[forms secure_support disclaimers],
          safety_flags: []
        )
      end

      if plan_specific?(plan_rule)
        return result(
          intent: "plan_specific",
          handoff_required: false,
          handoff_reason: nil,
          topic: "Seeded plan-rule explanation",
          matched_plan_rule: plan_rule,
          knowledge_categories: %w[401k_loans secure_support disclaimers],
          safety_flags: []
        )
      end

      result(
        intent: "general_education",
        handoff_required: false,
        handoff_reason: nil,
        topic: "General retirement education",
        matched_plan_rule: plan_rule,
        knowledge_categories: %w[401k_loans forms secure_support disclaimers],
        safety_flags: []
      )
    end

    private

    attr_reader :message, :normalized_message

    def result(**attributes)
      Result.new(**attributes)
    end

    def participant_specific?(plan_rule)
      return true if message.match?(PARTICIPANT_SPECIFIC_PATTERN) && message.match?(ACCOUNT_DETAIL_PATTERN)
      return true if normalized_message.include?("i work for") && message.match?(ACCOUNT_DETAIL_PATTERN)
      return true if plan_rule.present? && normalized_message.match?(/\b(how much|eligible|can i|my)\b/) && message.match?(ACCOUNT_DETAIL_PATTERN)

      false
    end

    def high_risk?
      message.match?(HIGH_RISK_PATTERN)
    end

    def form_routing?
      message.match?(FORM_PATTERN)
    end

    def plan_specific?(plan_rule)
      plan_rule.present?
    end

    def matched_plan_rule
      @matched_plan_rule ||= PlanRule.active
        .matching_public_message(normalized_message)
        .order(:employer_name, :plan_name)
        .first
    end
  end
end

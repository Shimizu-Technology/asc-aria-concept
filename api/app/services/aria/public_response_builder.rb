module Aria
  class PublicResponseBuilder
    Response = Struct.new(:content, :metadata, keyword_init: true)
    MAX_RESPONSE_CONTENT_LENGTH = ChatMessage::MAX_CONTENT_LENGTH

    def initialize(message:, classification:, client: Ai::OpenRouterClient.new)
      @message = message.to_s.strip
      @classification = classification
      @client = client
    end

    def call
      return controlled_handoff_response if classification.handoff_required

      ai_response = build_ai_response if client.configured?
      return ai_response if ai_response.present?

      fallback_response
    end

    private

    attr_reader :message, :classification, :client

    def controlled_handoff_response
      Response.new(
        content: handoff_content,
        metadata: base_metadata.merge(
          ai_used: false,
          response_mode: "controlled_handoff",
          handoff_required: true,
          handoff_reason: classification.handoff_reason
        )
      )
    end

    def build_ai_response
      response = client.chat(messages: prompt_messages, temperature: 0.2, max_tokens: 450)
      return nil unless response.success?

      Response.new(
        content: bounded_content(response.content),
        metadata: base_metadata.merge(
          ai_used: true,
          response_mode: "openrouter_grounded",
          model: response.model,
          handoff_required: false
        )
      )
    end

    def fallback_response
      Response.new(
        content: fallback_content,
        metadata: base_metadata.merge(
          ai_used: false,
          response_mode: "template_fallback",
          model: client.model,
          handoff_required: false,
          openrouter_configured: client.configured?
        )
      )
    end

    def bounded_content(content)
      content.to_s.strip.truncate(MAX_RESPONSE_CONTENT_LENGTH, omission: "…")
    end

    def prompt_messages
      [
        { role: "system", content: system_prompt },
        { role: "user", content: user_prompt }
      ]
    end

    def system_prompt
      <<~PROMPT.squish
        You are ARIA, ASC Trust's public educational support assistant for a private prototype.
        Use only the provided prototype context. Do not browse the web. Do not answer from memory when the context is insufficient.
        Never provide tax, legal, investment, or financial advice. Never answer account-specific eligibility, balance, loan amount, active-loan-count, or personal distribution questions.
        If a question requires personal account review, say the participant should continue securely with ASC staff.
        Keep answers concise, warm, and practical. Mention that final eligibility depends on ASC review and plan documents when relevant.
      PROMPT
    end

    def user_prompt
      context = {
        intent: classification.intent,
        topic: classification.topic,
        question: message,
        matched_plan_rule: classification.matched_plan_rule&.as_api_json,
        knowledge_entries: knowledge_entries.map(&:as_api_json)
      }

      <<~PROMPT
        Public ARIA question and approved context:
        #{JSON.pretty_generate(context)}

        Answer the participant using only this context. If the context does not contain the answer, explain the safe next step instead of guessing.
      PROMPT
    end

    def handoff_content
      case classification.intent
      when "high_risk_escalation"
        "That question needs ASC staff review rather than a public chat answer. I can explain general concepts, but tax, legal, investment, urgent, or highly personal questions should move to secure support so ASC can review the right context."
      else
        "I can explain general retirement-plan concepts here, but that question depends on personal account details such as balance, vested amount, eligibility, or active loans. Please continue securely so ASC can verify your information and review the answer before it is sent."
      end
    end

    def fallback_content
      case classification.intent
      when "form_routing"
        "I can help route you to the right ASC form category. Enrollment, distribution, hardship, beneficiary, and loan forms can vary by plan, so start with the forms section and continue securely if the request involves personal account details or sensitive information."
      when "plan_specific"
        plan_specific_fallback
      else
        general_education_fallback
      end
    end

    def plan_specific_fallback
      rule = classification.matched_plan_rule
      if rule.present?
        "For the seeded #{rule.plan_name} prototype record: #{rule.loan_summary}. #{rule.distribution_notes} This is educational support only; final eligibility and account-specific answers require ASC review and the governing plan documents."
      else
        "Some retirement plans allow loans or distributions and others do not. The exact options depend on the employer's plan documents and account status. I can explain general concepts publicly, but personal eligibility should continue securely with ASC staff."
      end
    end

    def general_education_fallback
      disclaimer = knowledge_entries.find { |entry| entry.category == "disclaimers" }
      disclaimer_text = disclaimer&.content || "ARIA provides educational support only and does not provide tax, legal, investment, or financial advice."

      return [ plan_type_fallback_content, disclaimer_text ].join(" ") if plan_type_question?

      educational_entries = knowledge_entries.select { |entry| [ "401k_loans", "retirement_plan_basics" ].include?(entry.category) }
      body = educational_entries.first(2).map(&:content)
      body << fallback_general_sentence if body.empty?
      body << disclaimer_text
      body.join(" ")
    end

    def plan_type_fallback_content
      "Common 401(k) variations include traditional pre-tax 401(k) contributions, Roth 401(k) contributions when offered, safe harbor 401(k) designs, SIMPLE 401(k) plans for some smaller employers, and individual or solo 401(k) plans for self-employed owners. An employer plan can combine several features, so ASC staff should confirm the actual adopted plan provisions."
    end

    def plan_type_question?
      normalized_message = message.downcase
      asks_for_plan_types = normalized_message.match?(/\b(type|types|kind|kinds|variation|variations)\b/) &&
        normalized_message.match?(/\b(401\(?k\)?|retirement plan|retirement plans|plan|plans)\b/)
      names_specific_plan_type = normalized_message.match?(
        /\b(traditional 401\(?k\)?|roth 401\(?k\)?|safe harbor|simple 401\(?k\)?|solo 401\(?k\)?|individual 401\(?k\)?|403\(?b\)?|government plan|profit[- ]sharing)\b/
      )

      asks_for_plan_types || names_specific_plan_type
    end

    def fallback_general_sentence
      "A retirement plan can include different employer-sponsored savings arrangements and features. The exact options depend on the employer's plan documents and ASC review."
    end

    def base_metadata
      {
        intent: classification.intent,
        topic: classification.topic,
        safety_flags: classification.safety_flags,
        knowledge_entry_ids: knowledge_entries.map(&:id),
        source_labels: source_labels,
        matched_plan_rule_id: classification.matched_plan_rule&.id
      }
    end

    def source_labels
      labels = knowledge_entries.map(&:source_label)
      labels << classification.matched_plan_rule.source_label if classification.matched_plan_rule.present?
      labels.compact.uniq
    end

    def knowledge_entries
      @knowledge_entries ||= KnowledgeEntry
        .active
        .where(category: classification.knowledge_categories)
        .order(:category, :title)
        .to_a
    end
  end
end

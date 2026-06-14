class OutboundDelivery < ApplicationRecord
  CHANNELS = %w[email sms].freeze
  PROVIDERS = %w[resend clicksend demo].freeze
  STATUSES = %w[queued sent delivered delivery_skipped failed].freeze

  belongs_to :verification_challenge, optional: true

  validates :channel, presence: true, inclusion: { in: CHANNELS }
  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :recipient_digest, presence: true
  validates :recipient_masked, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }

  def mark_sent!(provider_message_id: nil, metadata: {})
    update!(
      status: "sent",
      provider_message_id: provider_message_id.presence || self.provider_message_id,
      sent_at: Time.current,
      last_event_at: Time.current,
      metadata: (self.metadata || {}).merge(metadata || {})
    )
  end

  def mark_failed!(error:, provider_status_code: nil, provider_error_code: nil, metadata: {})
    update!(
      status: "failed",
      provider_status_text: error,
      provider_status_code: provider_status_code,
      provider_error_code: provider_error_code,
      failed_at: Time.current,
      last_event_at: Time.current,
      metadata: (self.metadata || {}).merge(metadata || {})
    )
  end

  def as_api_json
    {
      id: id,
      channel: channel,
      provider: provider,
      recipient_masked: recipient_masked,
      provider_message_id: provider_message_id,
      status: status,
      provider_status_code: provider_status_code,
      provider_status_text: provider_status_text,
      sent_at: sent_at&.iso8601,
      delivered_at: delivered_at&.iso8601,
      failed_at: failed_at&.iso8601,
      metadata: metadata || {}
    }
  end
end

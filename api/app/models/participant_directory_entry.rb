class ParticipantDirectoryEntry < ApplicationRecord
  STATUSES = %w[active inactive].freeze

  attr_accessor :email, :phone

  has_many :handoff_tokens, dependent: :nullify
  has_many :verification_challenges, dependent: :nullify
  has_many :secure_access_sessions, dependent: :restrict_with_exception
  has_many :secure_chat_sessions, dependent: :restrict_with_exception
  has_many :support_requests, dependent: :restrict_with_exception

  validates :external_identifier, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :employer_name, presence: true
  validates :plan_name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :email_or_phone_present

  before_validation :normalize_contacts

  scope :active, -> { where(status: "active") }

  def self.find_active_by_contact(channel:, contact:)
    case channel.to_s
    when "email"
      normalized = SecureSupport::Contact.normalize_email(contact)
      return nil if normalized.blank?

      active.find_by(email_digest: SecureSupport::Contact.digest(normalized))
    when "sms"
      normalized = SecureSupport::Contact.normalize_phone(contact)
      return nil if normalized.blank?

      active.find_by(phone_digest: SecureSupport::Contact.digest(normalized))
    end
  end

  def masked_email
    email_masked
  end

  def masked_phone
    phone_masked
  end

  def as_api_json
    {
      id: id,
      display_name: display_name,
      employer_name: employer_name,
      plan_name: plan_name,
      status: status,
      masked_email: email_masked,
      masked_phone: phone_masked
    }
  end

  private

  def normalize_contacts
    normalized_email = SecureSupport::Contact.normalize_email(email)
    normalized_phone = SecureSupport::Contact.normalize_phone(phone)

    if normalized_email.present?
      self.email_digest = SecureSupport::Contact.digest(normalized_email)
      self.email_masked = SecureSupport::Contact.mask_email(normalized_email)
    end

    if normalized_phone.present?
      self.phone_digest = SecureSupport::Contact.digest(normalized_phone)
      self.phone_masked = SecureSupport::Contact.mask_phone(normalized_phone)
    end
  end

  def email_or_phone_present
    return if email_digest.present? || phone_digest.present?

    errors.add(:base, "must include a valid email or phone")
  end
end

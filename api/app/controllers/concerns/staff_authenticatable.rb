require "digest"

module StaffAuthenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_staff_or_admin_token!
    return if authenticate_admin_token_fallback?

    staff_user = staff_user_from_clerk_bearer
    if staff_user&.staff?
      @current_user = staff_user
      return
    end

    if configured_admin_token.blank? && !ClerkAuth.configured?
      render json: { error: "Staff authentication is not configured" }, status: :service_unavailable
    else
      render json: { error: "Staff authentication failed" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def staff_user_from_clerk_bearer
    token = bearer_token_from_request
    return nil if token.blank?

    decoded = ClerkAuth.verify(token)
    return nil unless decoded

    if decoded["test_user_id"].present?
      return User.includes(:role).find_by(id: decoded["test_user_id"])
    end

    clerk_id = decoded["sub"].to_s
    email = email_from_claims(decoded)
    email ||= ClerkAuth.fetch_user_email(clerk_id)
    return nil if clerk_id.blank?

    user = User.includes(:role).find_by(clerk_id: clerk_id)
    user ||= find_invited_user_by_email(email)
    user = link_clerk_id_if_needed(user, clerk_id)
    return nil unless user

    user.update!(last_sign_in_at: Time.current, invitation_status: "accepted", accepted_at: user.accepted_at || Time.current)
    user
  end

  def link_clerk_id_if_needed(user, clerk_id)
    return nil unless user
    return user if user.clerk_id == clerk_id
    return nil if user.clerk_id.present?

    user.with_lock do
      user.reload
      if user.clerk_id == clerk_id
        user
      elsif user.clerk_id.present?
        nil
      else
        user.update!(clerk_id: clerk_id)
        user
      end
    end
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.warn("[StaffAuthenticatable] Clerk linking race recovered for user_id=#{user&.id}: #{e.class}")
    User.includes(:role).find_by(clerk_id: clerk_id)
  end

  def find_invited_user_by_email(email)
    return nil if email.blank?

    User.includes(:role).find_by("LOWER(email) = ?", email.downcase)
  end

  def email_from_claims(decoded)
    direct = decoded["email"] || decoded["email_address"] || decoded["primary_email_address"]
    return direct if direct.present?

    nested = decoded.dig("user", "email") || decoded.dig("user", "email_address") || decoded.dig("user", "primary_email_address")
    return nested if nested.present?

    addresses = decoded["email_addresses"] || decoded.dig("user", "email_addresses")
    return nil unless addresses.is_a?(Array)

    primary_id = decoded["primary_email_address_id"] || decoded.dig("user", "primary_email_address_id")
    primary = addresses.find { |address| address.is_a?(Hash) && address["id"] == primary_id }
    first = primary || addresses.find { |address| address.is_a?(Hash) }
    first&.dig("email_address") || first&.dig("email")
  end

  def authenticate_admin_token_fallback?
    token = admin_api_token_from_request.to_s
    return false unless secure_token_match?(token, configured_admin_token)

    true
  end

  def configured_admin_token
    ENV["ASC_ARIA_ADMIN_API_TOKEN"].to_s
  end

  def admin_api_token_from_request
    bearer_token = bearer_token_from_request
    bearer_token.presence || request.headers["X-ASC-ARIA-ADMIN-TOKEN"].presence
  end

  def bearer_token_from_request
    request.authorization.to_s.match(/\ABearer\s+(.+)\z/)&.[](1)
  end

  def secure_token_match?(provided_token, configured_token)
    return false if provided_token.blank? || configured_token.blank?

    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(provided_token),
      Digest::SHA256.hexdigest(configured_token)
    )
  end
end

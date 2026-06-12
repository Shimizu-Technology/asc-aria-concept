# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.use Rack::Attack

Rack::Attack.cache.store = if Rails.env.test?
  ActiveSupport::Cache::MemoryStore.new
else
  Rails.cache
end
Rack::Attack.enabled = ActiveModel::Type::Boolean.new.cast(ENV.fetch("RACK_ATTACK_ENABLED", "true"))

public_chat_session_limit = Integer(ENV.fetch("PUBLIC_CHAT_SESSION_RATE_LIMIT", "20"))
public_chat_message_limit = Integer(ENV.fetch("PUBLIC_CHAT_MESSAGE_RATE_LIMIT", "60"))
public_chat_rate_period = Integer(ENV.fetch("PUBLIC_CHAT_RATE_PERIOD_SECONDS", "60")).seconds

Rack::Attack.throttle("public chat session creates by ip", limit: public_chat_session_limit, period: public_chat_rate_period) do |request|
  request.ip if request.post? && request.path == "/api/v1/chat/public_sessions"
end

Rack::Attack.throttle("public chat messages by ip", limit: public_chat_message_limit, period: public_chat_rate_period) do |request|
  if request.post? && request.path.match?(%r{\A/api/v1/chat/public_sessions/[^/]+/messages\z})
    request.ip
  end
end

Rack::Attack.throttled_responder = lambda do |_request|
  body = {
    error: "Rate limit exceeded. Please wait a moment before continuing."
  }.to_json

  [ 429, { "Content-Type" => "application/json" }, [ body ] ]
end

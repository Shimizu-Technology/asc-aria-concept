# Be sure to restart your server when you modify this file.

frontend_origins = ENV.fetch(
  "FRONTEND_ORIGINS",
  "http://localhost:5173,http://127.0.0.1:5173,http://localhost:5197,http://127.0.0.1:5197,http://localhost:5198,http://127.0.0.1:5198"
).split(",").map(&:strip).reject(&:blank?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*frontend_origins)

    public_read_methods = [ :get, :head, :options ]

    resource "/api/v1/health",
      headers: :any,
      methods: public_read_methods,
      expose: [ "Content-Type" ]

    resource "/api/v1/bootstrap",
      headers: :any,
      methods: public_read_methods,
      expose: [ "Content-Type" ]

    resource "/api/v1/plan_rules*",
      headers: :any,
      methods: public_read_methods,
      expose: [ "Content-Type" ]

    resource "/api/v1/knowledge_entries*",
      headers: :any,
      methods: public_read_methods,
      expose: [ "Content-Type" ]

    resource "/api/v1/chat/public_sessions*",
      headers: :any,
      methods: [ :get, :post, :head, :options ],
      expose: [ "Content-Type" ]

    resource "/api/v1/handoffs*",
      headers: :any,
      methods: [ :get, :post, :head, :options ],
      expose: [ "Content-Type" ]

    resource "/api/v1/secure_chat_sessions*",
      headers: :any,
      methods: [ :get, :post, :head, :options ],
      expose: [ "Content-Type" ]

    resource "/api/v1/auth/me",
      headers: :any,
      methods: [ :get, :head, :options ],
      expose: [ "Content-Type" ]

    resource "/api/v1/staff*",
      headers: :any,
      methods: [ :get, :post, :head, :options ],
      expose: [ "Content-Type" ]
  end
end

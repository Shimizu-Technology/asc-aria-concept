ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActionDispatch
  class IntegrationTest
    setup do
      Rack::Attack.cache.store.clear if defined?(Rack::Attack)
    end
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def with_replaced_method(receiver, method_name, replacement)
      singleton_class = class << receiver; self; end
      had_singleton_method = singleton_class.method_defined?(method_name) || singleton_class.private_method_defined?(method_name)
      original_method = receiver.method(method_name) if receiver.respond_to?(method_name, true)

      singleton_class.define_method(method_name, replacement)
      yield
    ensure
      if had_singleton_method && original_method
        singleton_class.define_method(method_name, original_method)
      else
        begin
          singleton_class.remove_method(method_name)
        rescue NameError
          nil
        end
      end
    end

    def with_env(overrides)
      previous = overrides.each_with_object({}) do |(key, _value), memo|
        memo[key] = ENV.key?(key) ? ENV[key] : :__missing__
      end

      overrides.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end

      yield
    ensure
      previous&.each do |key, value|
        value == :__missing__ ? ENV.delete(key) : ENV[key] = value
      end
    end
  end
end

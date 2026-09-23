ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    def create_user(role: :requester, **attrs)
      suffix = SecureRandom.hex(4)
      User.create!(
        name: attrs[:name] || "User #{role.to_s.titleize}",
        email: attrs[:email] || "#{role}-#{suffix}@resolve.ai",
        password: attrs[:password] || "password123",
        password_confirmation: attrs[:password] || "password123",
        role: role
      )
    end

    def build_occurrence(reporter:, **attrs)
      Occurrence.new(
        {
          reporter: reporter,
          title: "Test occurrence",
          description: "Test occurrence description.",
          location: "Block B, 3rd floor",
          category: :lighting,
          priority: :medium
        }.merge(attrs)
      )
    end

    def create_occurrence(reporter:, **attrs)
      build_occurrence(reporter: reporter, **attrs).tap(&:save!)
    end
  end
end

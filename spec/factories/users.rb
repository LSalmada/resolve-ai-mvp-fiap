# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Usuário #{n}" }
    sequence(:email) { |n| "user#{n}@resolve.ai" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :requester }

    trait :requester do
      role { :requester }
    end

    trait :manager do
      sequence(:name) { |n| "Gestor #{n}" }
      role { :manager }
    end
  end
end

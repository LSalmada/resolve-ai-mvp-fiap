# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :occurrence
    association :user
    body { "Comentário de acompanhamento." }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :occurrence do
    association :reporter, factory: :user
    sequence(:title) { |n| "Ocorrência #{n}" }
    description { "Descrição da ocorrência para o teste." }
    location { "Bloco B, 3º andar" }
    category { :lighting }
    priority { :medium }

    trait :with_photo do
      after(:build) do |occurrence|
        occurrence.photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/photo.png")),
          filename: "photo.png",
          content_type: "image/png"
        )
      end
    end
  end
end

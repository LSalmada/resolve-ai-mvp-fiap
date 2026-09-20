# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :occurrence, inverse_of: :comments
  belongs_to :user, inverse_of: :comments

  validates :body, presence: true, length: { maximum: 2_000 }
end

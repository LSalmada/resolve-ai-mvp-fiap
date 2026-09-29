# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment do
  it "requires a body" do
    comment = build(:comment, body: "")

    expect(comment).not_to be_valid
    expect(comment.errors[:body]).to include(I18n.t("errors.messages.blank"))
  end
end

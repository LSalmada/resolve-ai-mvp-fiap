# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentPolicy do
  let(:owner) { create(:user, :requester) }
  let(:other) { create(:user, :requester) }
  let(:manager) { create(:user, :manager) }
  let(:occurrence) { create(:occurrence, reporter: owner) }
  let(:comment) { build(:comment, occurrence: occurrence, user: owner) }

  it "lets the owner and a manager comment; another requester cannot" do
    expect(described_class.new(owner, comment)).to be_create
    expect(described_class.new(manager, comment)).to be_create
    expect(described_class.new(other, comment)).not_to be_create
  end
end

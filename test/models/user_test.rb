require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "public registration defaults to requester" do
    user = User.create!(
      name: "New Person",
      email: "nova@resolve.ai",
      password: "password123"
    )

    assert user.requester?
    refute user.manager?
  end

  test "requires name" do
    user = User.new(email: "no-name@resolve.ai", password: "password123")

    refute user.valid?
    assert_includes user.errors[:name], I18n.t("errors.messages.blank")
  end
end

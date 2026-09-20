require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "requires a body" do
    requester = create_user
    occurrence = create_occurrence(reporter: requester)
    comment = Comment.new(occurrence: occurrence, user: requester, body: "")

    refute comment.valid?
    assert_includes comment.errors[:body], I18n.t("errors.messages.blank")
  end
end

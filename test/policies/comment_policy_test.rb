require "test_helper"

class CommentPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = create_user
    @other = create_user
    @gestor = create_user(role: :manager)
    @occurrence = create_occurrence(reporter: @owner)
  end

  test "owner and gestor can comment; other requester cannot" do
    comment = Comment.new(occurrence: @occurrence, body: "Test")

    assert CommentPolicy.new(@owner, comment).create?
    assert CommentPolicy.new(@gestor, comment).create?
    refute CommentPolicy.new(@other, comment).create?
  end
end

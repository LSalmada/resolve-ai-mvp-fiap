# frozen_string_literal: true

require "test_helper"

class Components::AppLayoutTest < ActionView::TestCase
  test "renders sidebar chrome and page content" do
    html = Components::AppLayout.new(user: manager_user).render_in(view) { "conteúdo" }

    assert_includes html, "Resolve Aí"
    assert_includes html, "Ocorrências"
    assert_includes html, "Dashboard"
    assert_includes html, "conteúdo"
    assert_includes html, 'data-controller="ruby-ui--sidebar"'
    assert_includes html, "ruby-ui--theme-toggle"
  end

  test "hides dashboard for requesters" do
    html = Components::AppLayout.new(user: requester_user).render_in(view) { "conteúdo" }

    assert_includes html, "Ocorrências"
    refute_includes html, "Dashboard"
  end

  private

  def manager_user
    User.new(name: "Síndica", email: "manager@resolve.ai", role: :manager)
  end

  def requester_user
    User.new(name: "Lucas", email: "requester@resolve.ai", role: :requester)
  end
end

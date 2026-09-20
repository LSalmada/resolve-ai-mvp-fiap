# frozen_string_literal: true

require "test_helper"

class Components::AppLayoutTest < ActionView::TestCase
  test "renders sidebar chrome and page content" do
    html = Components::AppLayout.new.render_in(view) { "conteúdo" }

    assert_includes html, "Resolve Aí"
    assert_includes html, "Ocorrências"
    assert_includes html, "Dashboard"
    assert_includes html, "conteúdo"
    assert_includes html, 'data-controller="ruby-ui--sidebar"'
  end
end

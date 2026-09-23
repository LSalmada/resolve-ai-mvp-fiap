# frozen_string_literal: true

require "test_helper"

class Components::ThemeModeButtonTest < ActionView::TestCase
  test "renders ruby ui theme toggle" do
    html = Components::ThemeModeButton.new.render_in(view)

    assert_includes html, "ruby-ui--theme-toggle"
    assert_includes html, "ruby-ui--toggle"
    assert_includes html, 'aria-label="Toggle theme"'
  end
end

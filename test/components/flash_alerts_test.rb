# frozen_string_literal: true

require "test_helper"

class Components::FlashAlertsTest < ActionView::TestCase
  test "renders flash with auto-dismiss controller" do
    view.flash[:notice] = "Signed in successfully."

    html = Components::FlashAlerts.new.render_in(view)

    assert_includes html, 'data-controller="flash"'
    assert_includes html, 'data-turbo-temporary="true"'
    assert_includes html, "Signed in successfully."
    assert_includes html, "Sucesso"
  end

  test "skips blank messages" do
    view.flash[:notice] = ""

    html = Components::FlashAlerts.new.render_in(view)

    refute_includes html, 'data-controller="flash"'
  end
end

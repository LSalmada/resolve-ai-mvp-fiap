# frozen_string_literal: true

require "test_helper"

class RubyUiTest < ActiveSupport::TestCase
  test "layout components are available" do
    %i[
      Button Card Table Badge Form Dialog DropdownMenu Tabs Alert
      Avatar Select Sidebar Textarea Input Sheet Separator Skeleton
    ].each do |name|
      assert RubyUI.const_defined?(name), "expected RubyUI::#{name}"
    end
  end

  test "button renders merged tailwind classes" do
    html = RubyUI::Button.new.call { "Salvar" }

    assert_includes html, "Salvar"
    assert_includes html, "bg-primary"
  end
end

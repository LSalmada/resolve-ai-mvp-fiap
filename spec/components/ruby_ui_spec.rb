# frozen_string_literal: true

require "rails_helper"

RSpec.describe RubyUI do
  it "exposes the layout components used by the app" do
    %i[
      Button Card Table Badge Form Dialog DropdownMenu Tabs Alert
      Avatar Select Sidebar Textarea Input Sheet Separator Skeleton
      Toggle ThemeToggle
    ].each do |name|
      expect(described_class.const_defined?(name)).to be(true), "expected RubyUI::#{name}"
    end
  end

  it "renders a button with merged Tailwind classes" do
    html = RubyUI::Button.new.call { "Salvar" }

    expect(html).to include("Salvar")
    expect(html).to include("bg-primary")
  end
end

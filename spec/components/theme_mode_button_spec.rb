# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::ThemeModeButton, type: :view do
  it "renders the RubyUI theme toggle" do
    html = described_class.new.render_in(view)

    expect(html).to include("ruby-ui--theme-toggle")
    expect(html).to include("ruby-ui--toggle")
    expect(html).to include('aria-label="Toggle theme"')
  end
end

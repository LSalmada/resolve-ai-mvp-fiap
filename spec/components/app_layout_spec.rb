# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::AppLayout, type: :view do
  it "renders sidebar chrome and page content" do
    html = described_class.new(user: build(:user, :manager, name: "Síndica")).render_in(view) { "conteúdo" }

    expect(html).to include("Resolve Aí")
    expect(html).to include("Ocorrências")
    expect(html).to include("Dashboard")
    expect(html).to include("conteúdo")
    expect(html).to include('data-controller="ruby-ui--sidebar"')
    expect(html).to include("ruby-ui--theme-toggle")
  end

  it "hides the dashboard for requesters" do
    html = described_class.new(user: build(:user, :requester, name: "Lucas")).render_in(view) { "conteúdo" }

    expect(html).to include("Ocorrências")
    expect(html).not_to include("Dashboard")
  end
end

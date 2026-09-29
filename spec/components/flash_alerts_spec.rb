# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::FlashAlerts, type: :view do
  it "renders flash with the auto-dismiss controller" do
    view.flash[:notice] = "Signed in successfully."

    html = described_class.new.render_in(view)

    expect(html).to include('data-controller="flash"')
    expect(html).to include("data-turbo-temporary")
    expect(html).to include("Signed in successfully.")
    expect(html).to include("Sucesso")
  end

  it "skips blank messages" do
    view.flash[:notice] = ""

    html = described_class.new.render_in(view)

    expect(html).not_to include('data-controller="flash"')
  end
end

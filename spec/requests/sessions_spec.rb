# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  it "signs in a valid user" do
    user = create(:user, email: "login@resolve.ai")

    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }

    expect(response).to redirect_to(occurrences_path)
    follow_redirect!
    expect(response.body).to include('data-controller="flash"')
    expect(response.body).to include("data-turbo-temporary")
    expect(response.body).to include("Sucesso")
  end

  it "keeps the form on invalid credentials" do
    post user_session_path, params: {
      user: { email: "missing@resolve.ai", password: "wrong" }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Entrar")
    expect(response.body).to include("Atenção")
  end
end

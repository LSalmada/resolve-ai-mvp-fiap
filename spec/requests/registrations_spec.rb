# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign up", type: :request do
  let(:valid_params) do
    {
      user: {
        name: "Novo morador",
        email: "register@resolve.ai",
        password: "password123",
        password_confirmation: "password123"
      }
    }
  end

  it "renders the sign up form" do
    get new_user_registration_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Criar conta")
    expect(response.body).to include('name="user[name]"')
    expect(response.body).to include(new_user_session_path)
  end

  it "creates a requester, signs them in and redirects to occurrences" do
    expect { post user_registration_path, params: valid_params }.to change(User.requester, :count).by(1)

    expect(response).to redirect_to(occurrences_path)
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sua conta foi criada com sucesso")
  end

  it "ignores a spoofed manager role and always creates a requester" do
    expect do
      post user_registration_path, params: { user: valid_params[:user].merge(role: "manager") }
    end.to change(User.requester, :count).by(1)

    user = User.find_by!(email: "register@resolve.ai")
    expect(user).to be_requester
    expect(user).not_to be_manager
  end

  it "re-renders the form with errors when the email is already taken" do
    create(:user, email: "register@resolve.ai")

    expect { post user_registration_path, params: valid_params }.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("já está em uso")
    expect(response.body).to include('value="Novo morador"')
  end

  it "re-renders the form with errors when the passwords do not match" do
    params = { user: valid_params[:user].merge(password_confirmation: "different123") }

    expect { post user_registration_path, params: params }.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("não confere com Senha")
  end
end

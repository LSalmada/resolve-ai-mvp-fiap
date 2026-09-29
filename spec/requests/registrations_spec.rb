# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign up", type: :request do
  it "ignores a spoofed manager role and always creates a requester" do
    expect do
      post user_registration_path, params: {
        user: {
          name: "Novo morador",
          email: "register@resolve.ai",
          password: "password123",
          password_confirmation: "password123",
          role: "manager"
        }
      }
    end.to change(User.requester, :count).by(1)

    user = User.find_by!(email: "register@resolve.ai")
    expect(user).to be_requester
    expect(user).not_to be_manager
  end
end

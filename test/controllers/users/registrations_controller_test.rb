require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "sign up ignores a spoofed manager role" do
    assert_difference -> { User.requester.count }, 1 do
      post user_registration_path, params: {
        user: {
          name: "New Resident",
          email: "register@resolve.ai",
          password: "password123",
          password_confirmation: "password123",
          role: "manager"
        }
      }
    end

    user = User.find_by!(email: "register@resolve.ai")
    assert user.requester?
    refute user.manager?
  end
end

# frozen_string_literal: true

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "signs in a valid user" do
    user = create_user(email: "login@resolve.ai")

    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }

    assert_redirected_to occurrences_path
    follow_redirect!

    assert_select "[data-controller='flash'][data-turbo-temporary='true']"
    assert_select "h5", text: "Sucesso"
  end

  test "keeps the form on invalid credentials" do
    post user_session_path, params: {
      user: { email: "missing@resolve.ai", password: "wrong" }
    }

    assert_response :unprocessable_entity
    assert_select "h3", text: "Entrar"
    assert_select "h5", text: "Atenção"
  end
end

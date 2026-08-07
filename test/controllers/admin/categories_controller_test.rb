require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated visitors to login" do
    get admin_categories_path
    assert_redirected_to new_session_path
  end

  test "blocks caixa role from admin routes" do
    sign_in_as(users(:one)) # role: caixa
    get admin_categories_path
    assert_redirected_to root_path
  end

  test "allows admin role" do
    sign_in_as(users(:two)) # role: admin
    get admin_categories_path
    assert_response :success
  end
end

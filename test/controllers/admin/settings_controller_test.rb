require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated visitors to login" do
    get edit_admin_setting_path
    assert_redirected_to new_session_path
  end

  test "blocks caixa role" do
    sign_in_as(users(:one))
    get edit_admin_setting_path
    assert_redirected_to root_path
  end

  test "admin can view and update the settings" do
    sign_in_as(users(:two))

    get edit_admin_setting_path
    assert_response :success

    patch admin_setting_path, params: {
      setting: { restaurant_name: "Cantina da Maria", receipt_printer_name: "Balcão", kitchen_printer_name: "Cozinha", default_service_fee_percent: 12 }
    }

    assert_redirected_to edit_admin_setting_path
    setting = Setting.instance
    assert_equal "Cantina da Maria", setting.restaurant_name
    assert_equal "Balcão", setting.receipt_printer_name
    assert_equal "Cozinha", setting.kitchen_printer_name
    assert_equal 12, setting.default_service_fee_percent
  end
end

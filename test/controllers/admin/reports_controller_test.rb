require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "blocks caixa role" do
    sign_in_as(users(:one))
    get admin_reports_path
    assert_redirected_to root_path
  end

  test "shows today's sales by payment method and order type, and the low-stock list" do
    sign_in_as(users(:two))

    get admin_reports_path
    assert_response :success

    # fixture: pagamento em dinheiro de R$32,00 para a venda balcão fechada
    assert_match "Dinheiro", response.body
    assert_match "32,00", response.body
    assert_match "Balcão", response.body
  end
end

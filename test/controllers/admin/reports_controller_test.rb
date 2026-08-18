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

  test "shows fiado purchases, settlements and the remaining balance separately, per customer" do
    sign_in_as(users(:two))

    get admin_reports_path

    assert_response :success
    # fixture: Maria comprou 18,00 fiado hoje, quitou 10,00 -> ainda deve 8,00
    assert_match "Maria Souza", response.body
    assert_match "18,00", response.body
    assert_match "10,00", response.body
    assert_match "8,00", response.body
  end

  test "only_owing filters out customers who are fully settled" do
    sign_in_as(users(:two))
    joao = customers(:joao)
    order = Order.create!(order_type: :balcao, opened_by: users(:two))
    order.order_items.create!(product: products(:feijoada), quantity: 1)
    order.payments.create!(cash_session: cash_sessions(:aberta), method: :fiado, amount: order.total, customer: joao, recorded_by: users(:two))
    joao.fiado_settlements.create!(cash_session: cash_sessions(:aberta), method: :pix, amount: order.total, recorded_by: users(:two))
    assert_equal 0, joao.reload.fiado_balance

    get admin_reports_path(only_owing: 1)

    assert_response :success
    assert_no_match "João Silva", response.body
    assert_match "Maria Souza", response.body # ainda deve 8,00, continua aparecendo
  end
end

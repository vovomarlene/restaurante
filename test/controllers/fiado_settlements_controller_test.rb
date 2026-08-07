require "test_helper"

class FiadoSettlementsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) } # role: caixa

  test "registering a settlement reduces the customer's fiado balance" do
    customer = customers(:maria)
    assert_equal 8.00, customer.fiado_balance

    post customer_fiado_settlements_path(customer), params: { fiado_settlement: { method: "dinheiro", amount: 8.00 } }

    assert_redirected_to customer_path(customer)
    assert_equal 0, customer.reload.fiado_balance
  end

  test "cannot settle more than the customer owes" do
    customer = customers(:maria)

    post customer_fiado_settlements_path(customer), params: { fiado_settlement: { method: "dinheiro", amount: 999 } }

    assert_response :unprocessable_entity
    assert_equal 8.00, customer.reload.fiado_balance
  end

  test "requires an open cash session" do
    CashSession.open.update_all(status: CashSession.statuses[:fechada])
    customer = customers(:maria)

    post customer_fiado_settlements_path(customer), params: { fiado_settlement: { method: "dinheiro", amount: 5 } }

    assert_response :unprocessable_entity
    assert_equal 8.00, customer.reload.fiado_balance
  end
end

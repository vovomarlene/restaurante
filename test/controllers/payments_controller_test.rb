require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:two)) }

  test "new redirects with a clear message when the cash session is closed" do
    cash_sessions(:aberta).update!(status: :fechada)
    order = orders(:mesa_aberta)

    get new_order_payment_path(order)

    assert_redirected_to order_path(order)
    follow_redirect!
    assert_match "abrir o caixa", response.body
  end

  test "create is blocked the same way when the cash session is closed" do
    cash_sessions(:aberta).update!(status: :fechada)
    order = orders(:mesa_aberta)

    assert_no_difference "Payment.count" do
      post order_payments_path(order), params: { payment: { method: "dinheiro", amount: 10 } }
    end

    assert_redirected_to order_path(order)
  end

  test "create registers a payment when the cash session is open" do
    order = orders(:mesa_aberta)

    assert_difference "Payment.count", 1 do
      post order_payments_path(order), params: { payment: { method: "dinheiro", amount: order.balance_due } }
    end

    assert order.reload.fechado?
  end
end

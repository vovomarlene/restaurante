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

  test "create backdates the payment when launched_on is given, for entering old fiado debts" do
    order = orders(:mesa_aberta)

    post order_payments_path(order), params: {
      payment: { method: "fiado", amount: order.balance_due, customer_id: customers(:maria).id, launched_on: "05/01/2025" }
    }

    payment = order.payments.last
    assert_equal Date.new(2025, 1, 5), payment.created_at.to_date
  end

  test "create rejects an invalid launched_on instead of silently ignoring it" do
    order = orders(:mesa_aberta)

    assert_no_difference "Payment.count" do
      post order_payments_path(order), params: { payment: { method: "dinheiro", amount: order.balance_due, launched_on: "não é uma data" } }
    end

    assert_response :unprocessable_entity
  end
end

require "test_helper"

# Cobre o fluxo ponta a ponta do PDV descrito no plano: abrir caixa, abrir
# uma mesa, lançar itens, pagar dividido e conferir que a mesa volta a ficar livre.
class PdvFlowTest < ActionDispatch::IntegrationTest
  setup do
    # garante que não há caixa aberto vindo de fixtures, sem violar as
    # associações restritas de cash_movements/payments
    CashSession.open.update_all(status: CashSession.statuses[:fechada])
    sign_in_as(users(:one)) # role: caixa
  end

  test "abrir caixa, montar uma comanda de mesa e pagar dividido fecha a comanda e libera a mesa" do
    post cash_session_path, params: { cash_session: { opening_amount: 100 } }
    assert_redirected_to cash_session_path

    table = dining_tables(:mesa_dois)
    post orders_path, params: { order: { order_type: "mesa", dining_table_id: table.id } }
    order = Order.order(:created_at).last
    assert_redirected_to order_path(order)
    assert table.reload.ocupada?

    post order_order_items_path(order), params: { order_item: { product_id: products(:feijoada).id, quantity: 1 } }
    assert_equal 1, order.order_items.active.count

    total = order.reload.total
    split = (total / 2).round(2)

    post order_payments_path(order), params: { payment: { method: "pix", amount: split } }
    post order_payments_path(order), params: { payment: { method: "dinheiro", amount: order.reload.balance_due, amount_received: order.reload.balance_due } }

    order.reload
    assert order.fechado?
    assert table.reload.livre?
  end

  test "não é possível iniciar uma venda sem caixa aberto" do
    assert_no_difference "Order.count" do
      post orders_path, params: { order: { order_type: "balcao" } }
    end

    assert_redirected_to tables_path
  end
end

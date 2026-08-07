require "test_helper"

# Cobre o fluxo ponta a ponta de venda fiado: fechar uma comanda com fiado,
# conferir que ela aparece no filtro de clientes devedores, e quitar a dívida.
class FiadoFlowTest < ActionDispatch::IntegrationTest
  setup do
    CashSession.open.update_all(status: CashSession.statuses[:fechada])
    sign_in_as(users(:one)) # role: caixa
  end

  test "vender fiado fecha a comanda, aparece no filtro de devedores e some após quitar" do
    post cash_session_path, params: { cash_session: { opening_amount: 100 } }

    customer = Customer.create!(name: "Pedro Alves", phone: "11966665555")

    post orders_path, params: { order: { order_type: "balcao" } }
    order = Order.order(:created_at).last

    post order_order_items_path(order), params: { order_item: { product_id: products(:feijoada).id, quantity: 1 } }
    total = order.reload.total

    post order_payments_path(order), params: { payment: { method: "fiado", amount: total, customer_id: customer.id } }

    order.reload
    assert order.fechado?
    assert_equal total, customer.reload.fiado_balance

    get customers_path(fiado: 1)
    assert_match "Pedro Alves", response.body

    post customer_fiado_settlements_path(customer), params: { fiado_settlement: { method: "pix", amount: total } }
    assert_equal 0, customer.reload.fiado_balance

    get customers_path(fiado: 1)
    assert_no_match "Pedro Alves", response.body
  end
end

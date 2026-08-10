require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "total sums subtotal and service fee for a mesa order" do
    order = orders(:mesa_aberta)
    # fixture: 2x Refrigerante a R$6,00 = 12,00; taxa de serviço 10%
    assert_equal 12.00, order.subtotal
    assert_equal 1.20, order.service_fee_amount
    assert_equal 13.20, order.total
  end

  test "balcao orders have no service fee" do
    order = orders(:balcao_fechada)
    assert_equal 0, order.service_fee_amount
    assert_equal order.subtotal, order.total
  end

  test "creating a second open order for an already-occupied table is rejected" do
    other = Order.new(order_type: :mesa, dining_table: orders(:mesa_aberta).dining_table, opened_by: users(:one))

    assert_not other.valid?
    assert other.errors[:dining_table].present?
  end

  test "opening a mesa order occupies the table" do
    table = dining_tables(:mesa_dois)
    assert table.livre?

    order = Order.create!(order_type: :mesa, dining_table: table, opened_by: users(:one))

    assert table.reload.ocupada?
    assert_equal order, table.open_order
  end

  test "cancel! cancels all active items and frees the table" do
    order = orders(:mesa_aberta)

    assert order.cancel!
    assert order.reload.cancelado?
    assert order.order_items.active.none?
    assert order.dining_table.reload.livre?
  end

  test "cancel! refuses to cancel an order that is not open" do
    order = orders(:balcao_fechada)

    assert_not order.cancel!
    assert order.errors[:base].present?
  end

  test "cancel! destroys an order that never had any items, instead of leaving a cancelado shell" do
    order = Order.create!(order_type: :balcao, opened_by: users(:one))

    assert order.cancel!
    assert_not Order.exists?(order.id)
  end

  test "total_before_cancellation still shows what a cancelled order was worth" do
    order = orders(:mesa_aberta)

    order.cancel!

    assert_equal 0, order.total
    assert_equal 13.20, order.total_before_cancellation
  end

  test "a new delivery order starts pendente and advances one stage at a time" do
    order = Order.create!(
      order_type: :delivery, opened_by: users(:one),
      customer_name: "Maria", delivery_address: "Rua das Flores, 123", delivery_fee: 5
    )
    assert order.delivery_pendente?

    order.advance_delivery_status!
    assert order.reload.delivery_em_preparo?

    order.advance_delivery_status!
    assert order.reload.delivery_saiu_para_entrega?

    order.advance_delivery_status!
    assert order.reload.delivery_entregue?

    # já no último estágio: não avança mais nem levanta erro
    order.advance_delivery_status!
    assert order.reload.delivery_entregue?
  end

  test "delivery_fee is included in the total but there is no service fee" do
    order = Order.create!(
      order_type: :delivery, opened_by: users(:one),
      customer_name: "Maria", delivery_address: "Rua das Flores, 123", delivery_fee: 5
    )
    order.order_items.create!(product: products(:feijoada), quantity: 1)

    assert_equal 0, order.service_fee_amount
    assert_equal 37.00, order.total # 32,00 (feijoada) + 5,00 (entrega)
  end

  test "refund! reverses stock, creates a Refund per payment, and cancels the order" do
    ingredient = ingredients(:feijao)
    stock_before = ingredient.current_stock

    # monta a venda por código de verdade (não fixture) pra disparar a baixa
    # de estoque automática, e assim poder conferir o estorno dela depois
    order = Order.create!(order_type: :balcao, opened_by: users(:two))
    order.order_items.create!(product: products(:feijoada), quantity: 1)
    order.payments.create!(cash_session: cash_sessions(:aberta), method: :dinheiro, amount: order.total, recorded_by: users(:two))
    assert order.close!(closed_by: users(:two))
    assert_equal stock_before - 0.3, ingredient.reload.current_stock
    total_paid = order.total

    assert order.refund!(reason: "Cliente reclamou", recorded_by: users(:two))

    order.reload
    assert order.cancelado?
    assert order.order_items.active.none?
    assert_equal stock_before, ingredient.reload.current_stock

    refund = Refund.find_by(payment: order.payments.first)
    assert refund.present?
    assert_equal total_paid, refund.amount
    assert_equal "Cliente reclamou", refund.reason
  end

  test "refund! requires the order to be fechado" do
    order = orders(:mesa_aberta)

    assert_not order.refund!(reason: "teste", recorded_by: users(:two))
    assert order.errors[:base].present?
  end

  test "refund! requires a reason" do
    order = orders(:balcao_fechada)

    assert_not order.refund!(reason: "", recorded_by: users(:two))
    assert order.errors[:base].present?
  end

  test "refund! requires an open cash session" do
    CashSession.open.update_all(status: CashSession.statuses[:fechada])
    order = orders(:balcao_fechada)

    assert_not order.refund!(reason: "teste", recorded_by: users(:two))
    assert order.errors[:base].present?
  end
end

require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:two)) }

  test "receipt shows items, totals and payments for a closed order" do
    get receipt_order_path(orders(:balcao_fechada))

    assert_response :success
    assert_match "Feijoada", response.body
    assert_match "32,00", response.body
    assert_match "Dinheiro", response.body
  end

  test "receipt as json returns pre-formatted totals for the print builder" do
    get receipt_order_path(orders(:balcao_fechada), format: :json)

    assert_response :success
    json = response.parsed_body
    assert_equal "R$ 32,00", json["total_label"]
    assert_equal 1, json["items"].size
    assert_equal "Feijoada", json["items"].first["product_name"]
    assert_equal "Dinheiro", json["payments"].first["method_label"]
  end

  test "receipt json uses the configured restaurant name, falling back to the app default" do
    get receipt_order_path(orders(:balcao_fechada), format: :json)
    assert_equal "Restaurante PDV", response.parsed_body["restaurant_name"]

    Setting.instance.update!(restaurant_name: "Cantina da Maria")

    get receipt_order_path(orders(:balcao_fechada), format: :json)
    assert_equal "Cantina da Maria", response.parsed_body["restaurant_name"]
  end

  test "kitchen_ticket json only returns items not yet sent" do
    order = orders(:mesa_aberta)

    get kitchen_ticket_order_path(order, format: :json)

    assert_response :success
    json = response.parsed_body
    assert_equal 1, json["items"].size
    assert_equal "Refrigerante", json["items"].first["product_name"]
  end

  test "kitchen_ticket_confirm marks the given items sent, so a follow-up call excludes them" do
    order = orders(:mesa_aberta)
    item = order_items(:mesa_aberta_refrigerante)

    post kitchen_ticket_confirm_order_path(order), params: { order_item_ids: [ item.id ] }
    assert_response :no_content
    assert item.reload.sent_to_kitchen_at.present?

    get kitchen_ticket_order_path(order, format: :json)
    assert_equal [], response.parsed_body["items"]
  end

  test "kitchen_ticket_confirm ignores ids that do not belong to the given order" do
    order = orders(:mesa_aberta)
    foreign_item = order_items(:balcao_fechada_feijoada)

    post kitchen_ticket_confirm_order_path(order), params: { order_item_ids: [ foreign_item.id ] }

    assert_nil foreign_item.reload.sent_to_kitchen_at
  end

  test "kitchen_ticket is blocked for an order that is not open" do
    get kitchen_ticket_order_path(orders(:balcao_fechada), format: :json)

    assert_response :unprocessable_entity
  end

  test "toggle_service_fee removes the fee, then a second call reactivates the default" do
    order = orders(:mesa_aberta)
    assert_equal 10, order.service_fee_percent

    patch toggle_service_fee_order_path(order)
    assert_redirected_to order_path(order)
    assert_equal 0, order.reload.service_fee_percent

    patch toggle_service_fee_order_path(order)
    assert_equal 10, order.reload.service_fee_percent
  end

  test "toggle_service_fee is blocked for an order that is not open" do
    order = orders(:balcao_fechada)

    patch toggle_service_fee_order_path(order)

    assert_redirected_to order_path(order)
    assert_equal 0, order.reload.service_fee_percent
  end

  test "cancel blocks non-admins from an aberto order stuck with a payment" do
    order = orders(:mesa_aberta)
    order.payments.create!(cash_session: cash_sessions(:aberta), method: :dinheiro, amount: 5, recorded_by: users(:two))

    sign_in_as(users(:one))
    get cancel_order_path(order)

    assert_redirected_to orders_path
    assert order.reload.aberto?
  end

  test "cancel (POST) as admin refunds an aberto order stuck with a payment" do
    order = orders(:mesa_aberta)
    order.payments.create!(cash_session: cash_sessions(:aberta), method: :dinheiro, amount: 5, recorded_by: users(:two))
    order_items(:mesa_aberta_refrigerante).cancel!

    post cancel_order_path(order), params: { reason: "Comanda travada" }

    assert_redirected_to orders_path
    assert order.reload.cancelado?
  end
end

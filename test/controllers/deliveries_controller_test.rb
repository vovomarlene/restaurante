require "test_helper"

class DeliveriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) } # role: caixa, fixture "aberta" cash session já está aberta

  test "creates a delivery order and lists it pending in the kanban" do
    post deliveries_path, params: { order: { customer_name: "Maria", customer_phone: "11999999999", delivery_address: "Rua A, 1", delivery_fee: 5 } }

    order = Order.delivery.order(:created_at).last
    assert_redirected_to order_path(order)
    assert order.delivery_pendente?

    get deliveries_path
    assert_response :success
    assert_match "Maria", response.body
  end

  test "advance moves the order to the next delivery stage" do
    order = Order.create!(order_type: :delivery, opened_by: users(:one), customer_name: "João", delivery_address: "Rua B, 2")

    patch advance_delivery_path(order)

    assert_redirected_to deliveries_path
    assert order.reload.delivery_em_preparo?
  end
end

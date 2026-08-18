require "test_helper"

class ComandasControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:two)) }

  test "index lists open mesa comandas" do
    get comandas_path

    assert_response :success
    assert_match "Mesa #{orders(:mesa_aberta).dining_table.number}", response.body
  end

  test "Nova comanda opens a mesa order without requiring a dining_table" do
    assert_difference "Order.count", 1 do
      post orders_path, params: { order: { order_type: "mesa" } }
    end

    order = Order.mesa.order(:created_at).last
    assert_nil order.dining_table
    assert_redirected_to order_path(order)
  end
end

require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "unit_price snapshots the product price at creation and ignores later price changes" do
    order = orders(:mesa_aberta)
    item = order.order_items.create!(product: products(:refrigerante), quantity: 1)
    assert_equal products(:refrigerante).price, item.unit_price

    products(:refrigerante).update!(price: 99.00)

    assert_equal 6.00, item.reload.unit_price
  end

  test "cannot add items to an order that is not open" do
    order = orders(:balcao_fechada)
    item = order.order_items.new(product: products(:refrigerante), quantity: 1)

    assert_not item.valid?
    assert item.errors[:order].present?
  end

  test "cancel! marks the item as cancelado and excludes it from the order total" do
    item = order_items(:mesa_aberta_refrigerante)
    order = item.order

    assert item.cancel!
    assert item.cancelado?
    assert_not_includes order.order_items.active, item
  end

  test "creating an item deducts stock for each ingredient in the product's ficha técnica" do
    ingredient = ingredients(:feijao)
    starting_stock = ingredient.current_stock

    order = orders(:mesa_aberta)
    item = order.order_items.create!(product: products(:feijoada), quantity: 2)

    # ficha técnica: 0,3kg de feijão por feijoada, 2 feijoadas = 0,6kg
    assert_equal starting_stock - 0.6, ingredient.reload.current_stock
    assert_equal 1, item.stock_movements.count
    assert item.stock_movements.first.venda?
  end

  test "cancel! reverses the stock deduction with a new estorno row, never editing the original" do
    ingredient = ingredients(:feijao)

    order = orders(:mesa_aberta)
    item = order.order_items.create!(product: products(:feijoada), quantity: 1)
    stock_after_sale = ingredient.reload.current_stock

    item.cancel!

    assert_equal stock_after_sale + 0.3, ingredient.reload.current_stock
    assert_equal 2, item.stock_movements.count
    assert item.stock_movements.venda.first.persisted?
    assert item.stock_movements.estorno.exists?
  end

  test "a product with no ficha técnica does not touch inventory" do
    category = categories(:bebidas)
    product = Product.create!(name: "Água sem receita", price: 4.00, category: category)

    assert_no_difference -> { StockMovement.count } do
      orders(:mesa_aberta).order_items.create!(product: product, quantity: 1)
    end
  end

  test "pending_kitchen only includes active items not yet sent to the kitchen" do
    order = orders(:mesa_aberta)
    pending = order.order_items.active.create!(product: products(:feijoada), quantity: 1)
    already_sent = order.order_items.active.create!(product: products(:refrigerante), quantity: 1)
    already_sent.update!(sent_to_kitchen_at: Time.current)

    assert_includes order.order_items.pending_kitchen, pending
    assert_not_includes order.order_items.pending_kitchen, already_sent
  end
end

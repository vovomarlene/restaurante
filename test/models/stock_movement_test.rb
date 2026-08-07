require "test_helper"

class StockMovementTest < ActiveSupport::TestCase
  test "record! creates a ledger row and updates the ingredient's current_stock atomically" do
    ingredient = ingredients(:feijao)
    starting_stock = ingredient.current_stock

    movement = StockMovement.record!(ingredient: ingredient, quantity: -2, origin: :venda)

    assert_equal starting_stock - 2, ingredient.reload.current_stock
    assert_equal ingredient.current_stock, movement.balance_after
  end

  test "does not block current_stock from going negative (not gated, only flagged)" do
    ingredient = ingredients(:feijao)
    ingredient.update!(current_stock: 1)

    assert_difference -> { ingredient.reload.current_stock }, -5 do
      StockMovement.record!(ingredient: ingredient, quantity: -5, origin: :venda)
    end

    assert ingredient.current_stock.negative?
  end

  test "requires a reason for manual entries and adjustments" do
    movement = StockMovement.new(ingredient: ingredients(:feijao), quantity: 5, origin: :manual)
    assert_not movement.valid?
    assert movement.errors[:reason].present?
  end
end

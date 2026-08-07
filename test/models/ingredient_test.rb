require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "low_stock scope returns only ingredients at or below their minimum" do
    low = ingredients(:feijao)
    low.update!(current_stock: 4, min_stock: 5)

    ok = ingredients(:refrigerante_lata)
    ok.update!(current_stock: 50, min_stock: 10)

    assert_includes Ingredient.low_stock, low
    assert_not_includes Ingredient.low_stock, ok
  end
end

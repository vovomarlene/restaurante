class RecipeItem < ApplicationRecord
  belongs_to :product
  belongs_to :ingredient

  validates :quantity, numericality: { greater_than: 0 }
  validates :ingredient_id, uniqueness: { scope: :product_id }
end

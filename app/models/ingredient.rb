class Ingredient < ApplicationRecord
  enum :unit, { un: 0, g: 1, kg: 2, ml: 3, l: 4 }

  has_many :recipe_items, dependent: :restrict_with_error
  has_many :products, through: :recipe_items
  has_many :stock_movements, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :min_stock, numericality: { greater_than_or_equal_to: 0 }
  # Estoque inicial não pode ser negativo, mas depois disso a baixa automática
  # de vendas não é bloqueada por saldo insuficiente (ver StockMovement) —
  # current_stock pode ficar negativo, sinalizado via low_stock, não travado.
  validates :current_stock, numericality: { greater_than_or_equal_to: 0 }, on: :create

  scope :active, -> { where(active: true) }
  scope :low_stock, -> { where("current_stock <= min_stock") }
end

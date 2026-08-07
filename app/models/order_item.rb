class OrderItem < ApplicationRecord
  enum :status, { ativo: 0, cancelado: 1 }

  belongs_to :order
  belongs_to :product
  has_many :stock_movements, dependent: :restrict_with_error

  before_validation :set_unit_price, on: :create

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }
  validate :order_is_open, on: :create

  after_create :deduct_stock!

  scope :active, -> { where(status: :ativo) }
  scope :pending_kitchen, -> { where(sent_to_kitchen_at: nil) }

  def total_price
    quantity * unit_price
  end

  def cancel!
    update!(status: :cancelado)
    reverse_stock_movements!
    true
  end

  private

  def set_unit_price
    self.unit_price ||= product&.price
  end

  def order_is_open
    errors.add(:order, "não está aberta") unless order&.aberto?
  end

  # Para cada insumo da ficha técnica do produto, registra a baixa
  # proporcional à quantidade vendida. Produtos sem ficha técnica (ex:
  # itens de revenda cadastrados sem receita) simplesmente não mexem em estoque.
  def deduct_stock!
    product.recipe_items.each do |recipe_item|
      StockMovement.record!(
        ingredient: recipe_item.ingredient,
        quantity: -(recipe_item.quantity * quantity),
        origin: :venda,
        order_item: self
      )
    end
  end

  # Nunca edita/apaga o movimento original — cria um estorno com o sinal
  # invertido, mantendo o ledger auditável.
  def reverse_stock_movements!
    stock_movements.where(origin: :venda).find_each do |movement|
      StockMovement.record!(
        ingredient: movement.ingredient,
        quantity: -movement.quantity,
        origin: :estorno,
        order_item: self
      )
    end
  end
end

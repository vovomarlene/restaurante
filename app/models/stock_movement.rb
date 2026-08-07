class StockMovement < ApplicationRecord
  enum :origin, { manual: 0, venda: 1, ajuste: 2, estorno: 3 }

  belongs_to :ingredient
  belongs_to :order_item, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  validates :quantity, numericality: { other_than: 0 }
  validates :reason, presence: true, if: -> { manual? || ajuste? }

  # Único ponto de escrita de estoque do sistema: cria o registro no ledger
  # e atualiza ingredient.current_stock atomicamente, com lock de linha para
  # que vendas concorrentes do mesmo insumo sejam serializadas corretamente.
  def self.record!(ingredient:, quantity:, origin:, order_item: nil, created_by: nil, reason: nil)
    ingredient.with_lock do
      balance = ingredient.current_stock + quantity

      movement = create!(
        ingredient: ingredient,
        quantity: quantity,
        origin: origin,
        order_item: order_item,
        created_by: created_by,
        reason: reason,
        balance_after: balance
      )

      ingredient.update!(current_stock: balance)
      movement
    end
  end
end

class Customer < ApplicationRecord
  has_many :payments, dependent: :restrict_with_error
  has_many :fiado_settlements, dependent: :restrict_with_error

  validates :name, presence: true

  scope :active, -> { where(active: true) }
  default_scope { order(:name) }

  # Soma líquida (desconta estornos) — uma compra fiado cancelada não deve
  # continuar contando como dívida do cliente.
  def fiado_total
    payments.fiado.sum(&:net_amount)
  end

  def fiado_paid_total
    fiado_settlements.sum(:amount)
  end

  def fiado_balance
    (fiado_total - fiado_paid_total).round(2)
  end
end

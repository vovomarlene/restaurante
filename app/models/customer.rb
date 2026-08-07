class Customer < ApplicationRecord
  has_many :payments, dependent: :restrict_with_error
  has_many :fiado_settlements, dependent: :restrict_with_error

  validates :name, presence: true

  scope :active, -> { where(active: true) }
  default_scope { order(:name) }

  def fiado_total
    payments.fiado.sum(:amount)
  end

  def fiado_paid_total
    fiado_settlements.sum(:amount)
  end

  def fiado_balance
    (fiado_total - fiado_paid_total).round(2)
  end
end

class DiningTable < ApplicationRecord
  enum :status, { livre: 0, ocupada: 1 }

  has_many :orders, dependent: :restrict_with_error

  validates :number, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
  default_scope { order(:number) }

  def open_order
    orders.open.first
  end
end

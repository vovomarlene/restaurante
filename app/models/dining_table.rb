class DiningTable < ApplicationRecord
  enum :status, { livre: 0, ocupada: 1 }

  has_many :orders, dependent: :restrict_with_error

  validates :number, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
  default_scope { order(:number) }

  after_update_commit :broadcast_status, if: :saved_change_to_status?

  def open_order
    orders.open.first
  end

  private

  def broadcast_status
    broadcast_replace_to "mesas",
      target: ActionView::RecordIdentifier.dom_id(self),
      partial: "tables/table_card",
      locals: { table: self }
  end
end

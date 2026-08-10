class Refund < ApplicationRecord
  belongs_to :payment
  belongs_to :cash_session
  belongs_to :recorded_by, class_name: "User"

  validates :amount, numericality: { greater_than: 0 }
  validates :reason, presence: true
  validate :cash_session_is_open, on: :create

  private

  def cash_session_is_open
    errors.add(:cash_session, "está fechada") if cash_session && !cash_session.aberta?
  end
end

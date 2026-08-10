class Payment < ApplicationRecord
  enum :method, { dinheiro: 0, cartao_debito: 1, cartao_credito: 2, pix: 3, fiado: 4 }

  belongs_to :order
  belongs_to :cash_session
  belongs_to :recorded_by, class_name: "User"
  belongs_to :customer, optional: true
  has_many :refunds, dependent: :restrict_with_error

  validates :amount, numericality: { greater_than: 0 }
  validates :amount_received, numericality: { greater_than_or_equal_to: :amount }, if: -> { dinheiro? && amount_received.present? }
  validates :customer, presence: true, if: :fiado?
  validate :order_is_open, on: :create
  validate :cash_session_is_open, on: :create

  def troco
    return 0 unless dinheiro? && amount_received

    (amount_received - amount).round(2)
  end

  def net_amount
    amount - refunds.sum(:amount)
  end

  private

  def order_is_open
    errors.add(:order, "não está aberta") unless order&.aberto?
  end

  def cash_session_is_open
    errors.add(:cash_session, "está fechada") if cash_session && !cash_session.aberta?
  end
end

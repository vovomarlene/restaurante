class FiadoSettlement < ApplicationRecord
  enum :method, { dinheiro: 0, cartao_debito: 1, cartao_credito: 2, pix: 3 }

  belongs_to :customer
  belongs_to :cash_session
  belongs_to :recorded_by, class_name: "User"

  validates :amount, numericality: { greater_than: 0 }
  validate :cash_session_is_open, on: :create
  validate :amount_not_greater_than_balance, on: :create

  private

  def cash_session_is_open
    errors.add(:cash_session, "está fechada") if cash_session && !cash_session.aberta?
  end

  def amount_not_greater_than_balance
    return unless customer && amount

    errors.add(:amount, "não pode ser maior que o saldo devedor do cliente") if amount > customer.fiado_balance
  end
end

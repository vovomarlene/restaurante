class CashSession < ApplicationRecord
  enum :status, { aberta: 0, fechada: 1 }

  belongs_to :opened_by, class_name: "User"
  belongs_to :closed_by, class_name: "User", optional: true

  has_many :cash_movements, dependent: :restrict_with_error
  has_many :payments, dependent: :restrict_with_error
  has_many :fiado_settlements, dependent: :restrict_with_error
  has_many :refunds, dependent: :restrict_with_error

  validates :opening_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_opened_at, on: :create

  scope :open, -> { where(status: :aberta) }

  def self.current
    open.first
  end

  def sangrias_total
    cash_movements.where(movement_type: :sangria).sum(:amount)
  end

  def suprimentos_total
    cash_movements.where(movement_type: :suprimento).sum(:amount)
  end

  def cash_sales_total
    payments.where(method: :dinheiro).sum(:amount)
  end

  def fiado_settlements_cash_total
    fiado_settlements.where(method: :dinheiro).sum(:amount)
  end

  def refunds_cash_total
    refunds.joins(:payment).where(payments: { method: :dinheiro }).sum(:amount)
  end

  def compute_expected_amount
    opening_amount + cash_sales_total + fiado_settlements_cash_total + suprimentos_total - sangrias_total - refunds_cash_total
  end

  # Retorna true/false (como `save`) em vez de levantar exceção, para que a
  # controller trate a recusa como um erro de validação comum.
  def close!(closed_by:, closing_amount:, closing_notes: nil)
    with_lock do
      unless aberta?
        errors.add(:base, "Esta sessão de caixa já está fechada.")
        return false
      end

      expected = compute_expected_amount

      update!(
        status: :fechada,
        closed_by: closed_by,
        closed_at: Time.current,
        closing_amount: closing_amount,
        closing_notes: closing_notes,
        expected_amount: expected,
        difference_amount: (closing_amount.to_d - expected).round(2)
      )
    end

    true
  end

  private

  def set_opened_at
    self.opened_at ||= Time.current
  end
end

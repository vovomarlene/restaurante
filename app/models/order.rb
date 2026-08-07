class Order < ApplicationRecord
  DEFAULT_SERVICE_FEE_PERCENT = 10.0
  DELIVERY_STATUS_FLOW = %w[pendente em_preparo saiu_para_entrega entregue].freeze

  enum :order_type, { mesa: 0, balcao: 1, delivery: 2 }
  enum :status, { aberto: 0, fechado: 1, cancelado: 2 }
  enum :delivery_status, { pendente: 0, em_preparo: 1, saiu_para_entrega: 2, entregue: 3, cancelado: 4 }, prefix: :delivery

  belongs_to :dining_table, optional: true
  belongs_to :opened_by, class_name: "User"
  belongs_to :closed_by, class_name: "User", optional: true

  has_many :order_items, dependent: :restrict_with_error
  has_many :payments, dependent: :restrict_with_error

  validates :dining_table, presence: true, if: :mesa?
  validates :customer_name, :delivery_address, presence: true, if: :delivery?
  validate :table_not_already_open, on: :create, if: :mesa?
  validate :cash_session_must_be_open, on: :create

  before_validation :set_opened_at, on: :create
  before_validation :set_default_service_fee, on: :create, if: :mesa?
  before_validation :set_default_delivery_status, on: :create, if: :delivery?
  after_create :occupy_table, if: :mesa?

  scope :open, -> { where(status: :aberto) }

  def subtotal
    order_items.active.sum("quantity * unit_price")
  end

  def service_fee_amount
    return 0 unless mesa?

    (subtotal * service_fee_percent / 100).round(2)
  end

  def total
    subtotal + service_fee_amount + delivery_fee
  end

  def amount_paid
    payments.sum(:amount)
  end

  def balance_due
    (total - amount_paid).round(2)
  end

  # Os métodos abaixo retornam true/false (como `save`) em vez de levantar
  # exceção, para que a controller trate a recusa como um erro de validação comum.
  def close!(closed_by:)
    with_lock do
      unless aberto?
        errors.add(:base, "Comanda já está fechada ou cancelada.")
        return false
      end

      unless balance_due.zero?
        errors.add(:base, "Ainda falta pagar #{balance_due} para fechar a comanda.")
        return false
      end

      update!(status: :fechado, closed_at: Time.current, closed_by: closed_by)
      free_table
    end

    true
  end

  def cancel!
    with_lock do
      unless aberto?
        errors.add(:base, "Só é possível cancelar uma comanda aberta.")
        return false
      end

      if payments.exists?
        errors.add(:base, "Não é possível cancelar uma comanda que já recebeu pagamento.")
        return false
      end

      order_items.active.each(&:cancel!)
      update!(status: :cancelado, closed_at: Time.current)
      free_table
    end

    true
  end

  # Avança para o próximo estágio do preparo/entrega. Não faz nada além do
  # último estágio (entregue) — o pedido é encerrado via pagamento, não aqui.
  def advance_delivery_status!
    return unless delivery?

    next_status = DELIVERY_STATUS_FLOW[DELIVERY_STATUS_FLOW.index(delivery_status).to_i + 1]
    update!(delivery_status: next_status) if next_status
  end

  private

  def set_opened_at
    self.opened_at ||= Time.current
  end

  def set_default_service_fee
    self.service_fee_percent = DEFAULT_SERVICE_FEE_PERCENT if service_fee_percent.to_f.zero?
  end

  def set_default_delivery_status
    self.delivery_status ||= :pendente
  end

  def occupy_table
    dining_table.update!(status: :ocupada)
  end

  def free_table
    dining_table&.update!(status: :livre)
  end

  def table_not_already_open
    return unless dining_table

    errors.add(:dining_table, "já está ocupada") if dining_table.orders.open.exists?
  end

  def cash_session_must_be_open
    errors.add(:base, "É necessário abrir o caixa antes de iniciar uma venda.") unless CashSession.current.present?
  end
end

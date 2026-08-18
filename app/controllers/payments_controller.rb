class PaymentsController < ApplicationController
  before_action :set_order
  before_action :require_open_cash_session, only: [ :new, :create ]
  before_action :set_payment, only: [ :edit, :update ]
  before_action :require_admin, only: [ :edit, :update ]

  def new
    # Construído sem passar pela associação @order.payments — isso evita que
    # o registro novo (ainda sem "method") fique em cache no array em memória
    # da associação e apareça como um pagamento fantasma na lista abaixo.
    @payment = Payment.new(order: @order, amount: @order.balance_due, launched_on: Date.current.strftime("%d/%m/%Y"))
  end

  def create
    @payment = Payment.new(payment_params.merge(order: @order))
    @payment.cash_session = CashSession.current
    @payment.recorded_by = Current.user

    if @payment.launched_on.present?
      begin
        @payment.created_at = Date.strptime(@payment.launched_on, "%d/%m/%Y").in_time_zone
      rescue Date::Error
        @payment.errors.add(:base, "Data de lançamento inválida.")
        render :new, status: :unprocessable_entity
        return
      end
    end

    if @payment.save
      @order.close!(closed_by: Current.user) if @order.balance_due.zero?
      redirect_after_payment
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Corrige a forma de pagamento de um lançamento já registrado (ex: marcou
  # "Dinheiro" por engano, era Pix). Só o método/valor recebido/cliente —
  # não mexe no valor, isso evitaria reabrir a conta de balance_due da
  # comanda de um jeito difícil de auditar.
  def edit
  end

  def update
    if @payment.refunds.exists?
      redirect_to order_path(@order), alert: "Este pagamento já foi estornado — não dá pra corrigir a forma de pagamento dele."
      return
    end

    if @payment.update(edit_payment_params)
      redirect_to order_path(@order), notice: "Forma de pagamento corrigida."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def redirect_after_payment
    if @order.reload.fechado?
      redirect_to @order, notice: "Pagamento registrado. Comanda fechada."
    else
      redirect_to new_order_payment_path(@order), notice: "Pagamento registrado. Restante a pagar: #{helpers.number_to_currency(@order.balance_due, unit: 'R$ ', separator: ',', delimiter: '.')}"
    end
  end

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_payment
    @payment = @order.payments.find(params[:id])
  end

  def require_open_cash_session
    return if CashSession.current

    redirect_to @order, alert: "É necessário abrir o caixa antes de registrar um pagamento."
  end

  def payment_params
    params.expect(payment: [ :method, :amount, :amount_received, :customer_id, :launched_on ])
  end

  def edit_payment_params
    params.expect(payment: [ :method, :amount_received, :customer_id ])
  end
end

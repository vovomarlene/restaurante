class PaymentsController < ApplicationController
  before_action :set_order
  before_action :require_open_cash_session

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

  def require_open_cash_session
    return if CashSession.current

    redirect_to @order, alert: "É necessário abrir o caixa antes de registrar um pagamento."
  end

  def payment_params
    params.expect(payment: [ :method, :amount, :amount_received, :customer_id, :launched_on ])
  end
end

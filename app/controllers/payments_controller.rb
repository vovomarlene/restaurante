class PaymentsController < ApplicationController
  before_action :set_order

  def new
    # Construído sem passar pela associação @order.payments — isso evita que
    # o registro novo (ainda sem "method") fique em cache no array em memória
    # da associação e apareça como um pagamento fantasma na lista abaixo.
    @payment = Payment.new(order: @order, amount: @order.balance_due)
  end

  def create
    @payment = Payment.new(payment_params.merge(order: @order))
    @payment.cash_session = CashSession.current
    @payment.recorded_by = Current.user

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

  def payment_params
    params.expect(payment: [ :method, :amount, :amount_received, :customer_id ])
  end
end

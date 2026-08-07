class FiadoSettlementsController < ApplicationController
  before_action :set_customer

  def new
    # Construído sem passar pela associação @customer.fiado_settlements — ver
    # o mesmo comentário em PaymentsController#new.
    @settlement = FiadoSettlement.new(customer: @customer, amount: @customer.fiado_balance)
  end

  def create
    @settlement = FiadoSettlement.new(settlement_params.merge(customer: @customer))
    @settlement.cash_session = CashSession.current
    @settlement.recorded_by = Current.user

    if @settlement.save
      redirect_to @customer, notice: "Pagamento registrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:customer_id])
  end

  def settlement_params
    params.expect(fiado_settlement: [ :method, :amount, :notes ])
  end
end

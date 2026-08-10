class CustomersController < ApplicationController
  include PeriodFilterable

  before_action :set_customer, only: [ :show, :edit, :update, :destroy ]

  def index
    customers = Customer.active.to_a
    customers = customers.select { |customer| customer.fiado_balance.positive? } if params[:fiado].present?
    @pagy, @customers = pagy_array(customers)
  end

  def show
    @date = params[:date].present? ? Date.strptime(params[:date], "%d/%m/%Y") : Date.current
    @period = PeriodFilterable::PERIODS.include?(params[:period]) ? params[:period] : "mensal"
    range = period_range(@date, @period)

    @fiado_payments = @customer.payments.fiado.includes(:order).where(created_at: range).order(created_at: :desc)
    @fiado_settlements = @customer.fiado_settlements.where(created_at: range).order(created_at: :desc)
    @period_fiado_total = @fiado_payments.sum(&:net_amount)
    @period_settled_total = @fiado_settlements.sum(:amount)
  rescue Date::Error
    redirect_to customer_path(@customer), alert: "Data inválida."
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to @customer, notice: "Cliente criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Cliente atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.destroy
      redirect_to customers_path, notice: "Cliente removido."
    else
      redirect_to customers_path, alert: @customer.errors.full_messages.to_sentence
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.expect(customer: [ :name, :phone, :address, :notes, :active ])
  end
end

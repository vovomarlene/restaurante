class CustomersController < ApplicationController
  before_action :set_customer, only: [ :show, :edit, :update, :destroy ]

  def index
    @customers = Customer.active
    @customers = @customers.select { |customer| customer.fiado_balance.positive? } if params[:fiado].present?
  end

  def show
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

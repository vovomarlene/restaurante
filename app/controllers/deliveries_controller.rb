class DeliveriesController < ApplicationController
  def index
    @orders = Order.delivery.open.order(:opened_at)
  end

  def new
    @order = Order.new(order_type: :delivery)
  end

  def create
    @order = Order.new(delivery_params)
    @order.order_type = :delivery
    @order.opened_by = Current.user

    if @order.save
      redirect_to @order
    else
      render :new, status: :unprocessable_entity
    end
  end

  def advance
    order = Order.delivery.find(params[:id])
    order.advance_delivery_status!
    redirect_to deliveries_path
  end

  private

  def delivery_params
    params.expect(order: [ :customer_name, :customer_phone, :delivery_address, :delivery_fee ])
  end
end

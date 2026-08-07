class OrderItemsController < ApplicationController
  before_action :set_order

  def create
    @order_item = @order.order_items.new(order_item_params)
    @order_item.save

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @order, alert: @order_item.errors.full_messages.to_sentence.presence }
    end
  end

  def destroy
    @order_item = @order.order_items.find(params[:id])
    @order_item.cancel!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @order }
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def order_item_params
    params.expect(order_item: [ :product_id, :quantity, :notes ])
  end
end

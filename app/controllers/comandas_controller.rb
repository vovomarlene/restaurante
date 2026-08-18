class ComandasController < ApplicationController
  def index
    @orders = Order.mesa.open.order(:opened_at)
  end
end

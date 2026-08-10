class BalcaoController < ApplicationController
  def index
    @orders = Order.balcao.open.order(:opened_at)
  end
end

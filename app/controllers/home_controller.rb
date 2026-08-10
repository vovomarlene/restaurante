class HomeController < ApplicationController
  def index
    @cash_session = CashSession.current

    sales_today = Order.fechado.where(opened_at: Date.current.all_day).to_a
    @sales_today_total = sales_today.sum(&:total)
    @sales_today_count = sales_today.size

    @open_orders_count = Order.aberto.count
    @low_stock_count = Ingredient.active.low_stock.count
  end
end

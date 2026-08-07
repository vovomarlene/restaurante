class Admin::ReportsController < Admin::BaseController
  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    range = @date.beginning_of_day..@date.end_of_day

    payments_in_range = Payment.joins(:order).where(created_at: range)

    @sales_by_method = payments_in_range.group(:method).sum(:amount)
    @sales_by_order_type = payments_in_range.group("orders.order_type").sum(:amount)
    @total_sales = @sales_by_method.values.sum

    @top_products = OrderItem.joins(:order, :product)
      .where(status: :ativo)
      .where(orders: { status: :fechado, closed_at: range })
      .group("products.name")
      .order(Arel.sql("SUM(order_items.quantity) DESC"))
      .limit(10)
      .sum(:quantity)

    @low_stock_ingredients = Ingredient.active.low_stock

    @cash_sessions = CashSession.where(status: :fechada).order(closed_at: :desc).limit(20)
  rescue Date::Error
    redirect_to admin_reports_path, alert: "Data inválida."
  end
end

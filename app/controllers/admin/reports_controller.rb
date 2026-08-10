class Admin::ReportsController < Admin::BaseController
  PERIODS = %w[diario semanal mensal].freeze

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @period = PERIODS.include?(params[:period]) ? params[:period] : "diario"
    range = period_range(@date, @period)

    # Exclui pagamentos estornados — uma venda cancelada não deve contar
    # como receita do dia.
    payments_in_range = Payment.joins(:order).where(created_at: range).where.not(id: Refund.select(:payment_id))

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

  private

  def period_range(date, period)
    case period
    when "semanal" then date.beginning_of_week.beginning_of_day..date.end_of_week.end_of_day
    when "mensal" then date.beginning_of_month.beginning_of_day..date.end_of_month.end_of_day
    else date.beginning_of_day..date.end_of_day
    end
  end
end

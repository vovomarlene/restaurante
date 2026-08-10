class Admin::ReportsController < Admin::BaseController
  include PeriodFilterable

  def index
    @date = params[:date].present? ? Date.strptime(params[:date], "%d/%m/%Y") : Date.current
    @period = PeriodFilterable::PERIODS.include?(params[:period]) ? params[:period] : "diario"
    range = period_range(@date, @period)

    # Exclui pagamentos estornados — uma venda cancelada não deve contar
    # como receita do dia.
    payments_in_range = Payment.joins(:order).where(created_at: range).where.not(id: Refund.select(:payment_id))

    @sales_by_method = payments_in_range.group(:method).sum(:amount)
    @sales_by_order_type = payments_in_range.group("orders.order_type").sum(:amount)
    @total_sales = @sales_by_method.values.sum

    @fiado_by_customer = payments_in_range.where(method: :fiado).joins(:customer)
      .group("customers.name").order("customers.name").sum(:amount)

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

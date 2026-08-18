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

    # Comprou no período vs. quitou no período são duas coisas diferentes —
    # uma venda fiado de R$50 já paga não deve continuar parecendo dívida
    # em aberto só porque caiu dentro do período filtrado.
    purchased_by_customer_id = payments_in_range.where(method: :fiado).group(:customer_id).sum(:amount)
    settled_by_customer_id = FiadoSettlement.where(created_at: range).group(:customer_id).sum(:amount)
    customer_ids = (purchased_by_customer_id.keys + settled_by_customer_id.keys).compact.uniq

    @fiado_report = Customer.where(id: customer_ids).map { |customer|
      {
        customer: customer,
        purchased: purchased_by_customer_id[customer.id] || 0,
        settled: settled_by_customer_id[customer.id] || 0,
        balance: customer.fiado_balance
      }
    }.sort_by { |row| row[:customer].name }

    @only_owing = params[:only_owing].present?
    @fiado_report = @fiado_report.select { |row| row[:balance].positive? } if @only_owing

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

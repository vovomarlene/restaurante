class OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :receipt, :kitchen_ticket, :kitchen_ticket_confirm, :cancel, :toggle_service_fee ]
  before_action :require_open_order, only: [ :kitchen_ticket, :kitchen_ticket_confirm ]

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    range = @date.beginning_of_day..@date.end_of_day

    @orders = Order.where(opened_at: range).order(opened_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @pagy, @orders = pagy(@orders)
  rescue Date::Error
    redirect_to orders_path, alert: "Data inválida."
  end

  def create
    @order = Order.new(order_params)
    @order.order_type ||= "balcao"
    @order.opened_by = Current.user

    if @order.save
      redirect_to @order
    else
      redirect_to tables_path, alert: @order.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to tables_path, alert: "Essa mesa acabou de ser aberta por outro operador."
  end

  def show
    @categories = Category.active.includes(:products)
  end

  def receipt
    respond_to do |format|
      format.html
      format.json { render json: receipt_json(@order) }
    end
  end

  # Itens ainda não enviados à cozinha. Só devolve/exibe — não marca nada
  # como enviado (isso só acontece em #kitchen_ticket_confirm, depois que a
  # impressão realmente deu certo no navegador).
  def kitchen_ticket
    @items = pending_kitchen_items(@order)

    respond_to do |format|
      format.html
      format.json { render json: kitchen_ticket_json(@order, @items) }
    end
  end

  # Chamado pelo JS só depois que qz.print() resolveu com sucesso.
  def kitchen_ticket_confirm
    ids = Array(params[:order_item_ids]).map(&:to_i)
    pending_kitchen_items(@order).where(id: ids).update_all(sent_to_kitchen_at: Time.current)
    head :no_content
  end

  # GET mostra a confirmação (com motivo, se a comanda já estiver fechada);
  # POST executa. Comanda aberta sem pagamento: cancel! (qualquer usuário).
  # Comanda fechada/paga: refund! (só admin, motivo obrigatório).
  def cancel
    if @order.fechado? && !current_user_admin?
      redirect_to orders_path, alert: "Só administradores podem estornar uma venda já paga."
      return
    end

    return unless request.post?

    if @order.aberto?
      if @order.cancel!
        redirect_to orders_path, notice: "Comanda cancelada."
      else
        redirect_to orders_path, alert: @order.errors.full_messages.to_sentence
      end
    elsif @order.fechado?
      if @order.refund!(reason: params[:reason], recorded_by: Current.user)
        redirect_to orders_path, notice: "Venda estornada."
      else
        redirect_to cancel_order_path(@order), alert: @order.errors.full_messages.to_sentence
      end
    else
      redirect_to orders_path, alert: "Esta comanda já está cancelada."
    end
  end

  # A taxa de serviço é opcional por lei — o cliente pode recusar. Alterna
  # entre 0% (removida) e o padrão, só enquanto a comanda ainda está aberta.
  def toggle_service_fee
    unless @order.mesa? && @order.aberto?
      redirect_to @order, alert: "Não é possível alterar a taxa de serviço desta comanda."
      return
    end

    if @order.service_fee_percent.to_f.positive?
      @order.update!(service_fee_percent: 0)
      redirect_to @order, notice: "Taxa de serviço removida."
    else
      @order.update!(service_fee_percent: Order::DEFAULT_SERVICE_FEE_PERCENT)
      redirect_to @order, notice: "Taxa de serviço reativada."
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def require_open_order
    head :unprocessable_entity unless @order.aberto?
  end

  def pending_kitchen_items(order)
    order.order_items.active.pending_kitchen.includes(:product).order(:created_at)
  end

  def order_params
    params.expect(order: [ :order_type, :dining_table_id ])
  end

  def order_subtitle(order)
    if order.mesa?
      "Mesa #{order.dining_table.number}"
    elsif order.balcao?
      "Venda balcão ##{order.id}"
    else
      "Delivery — #{order.customer_name}"
    end
  end

  def currency(value)
    helpers.number_to_currency(value, unit: "R$", separator: ",", delimiter: ".")
  end

  def printed_restaurant_name
    PrinterSetting.instance.restaurant_name.presence || t("app.name")
  end

  def receipt_json(order)
    {
      restaurant_name: printed_restaurant_name,
      subtitle: order_subtitle(order),
      date_label: I18n.l(order.closed_at || order.opened_at, format: :long),
      items: order.order_items.active.includes(:product).order(:created_at).map { |item|
        { quantity: item.quantity, product_name: item.product.name, total_price_label: currency(item.total_price) }
      },
      subtotal_label: currency(order.subtotal),
      service_fee: order.mesa? ? { percent: order.service_fee_percent.to_i, amount_label: currency(order.service_fee_amount) } : nil,
      delivery_fee_label: order.delivery? ? currency(order.delivery_fee) : nil,
      total_label: currency(order.total),
      payments: order.payments.map { |payment|
        { method_label: t("enums.payment.method.#{payment.method}"), amount_label: currency(payment.amount) }
      }
    }
  end

  def kitchen_ticket_json(order, items)
    {
      restaurant_name: printed_restaurant_name,
      subtitle: order_subtitle(order),
      date_label: I18n.l(Time.current, format: :short),
      items: items.map { |item|
        { id: item.id, quantity: item.quantity, product_name: item.product.name, notes: item.notes }
      }
    }
  end
end

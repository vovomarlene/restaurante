class OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :receipt, :kitchen_ticket, :kitchen_ticket_confirm ]
  before_action :require_open_order, only: [ :kitchen_ticket, :kitchen_ticket_confirm ]

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

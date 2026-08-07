class Admin::StockMovementsController < Admin::BaseController
  before_action :set_ingredient

  def index
    @stock_movements = @ingredient.stock_movements.order(created_at: :desc)
  end

  def new
  end

  def create
    direction = params.dig(:stock_movement, :direction)
    quantity = params.dig(:stock_movement, :quantity).to_d.abs
    quantity = -quantity if direction == "saida"

    StockMovement.record!(
      ingredient: @ingredient,
      quantity: quantity,
      origin: direction == "saida" ? :ajuste : :manual,
      reason: params.dig(:stock_movement, :reason),
      created_by: Current.user
    )

    redirect_to admin_ingredient_stock_movements_path(@ingredient), notice: "Movimento registrado."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:ingredient_id])
  end
end

class Admin::IngredientsController < Admin::BaseController
  before_action :set_ingredient, only: %i[ edit update destroy ]

  def index
    @pagy, @ingredients = pagy(Ingredient.order(:name))
  end

  def new
    @ingredient = Ingredient.new(unit: :un)
  end

  def create
    @ingredient = Ingredient.new(ingredient_params_on_create)

    if @ingredient.save
      redirect_to admin_ingredients_path, notice: "Insumo criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ingredient.update(ingredient_params_on_update)
      redirect_to admin_ingredients_path, notice: "Insumo atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @ingredient.destroy
      redirect_to admin_ingredients_path, notice: "Insumo removido."
    else
      redirect_to admin_ingredients_path, alert: @ingredient.errors.full_messages.to_sentence
    end
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end

  # current_stock só pode ser definido na criação (estoque inicial). A partir
  # daí, qualquer mudança deve passar pelo ledger de StockMovement (fase 4).
  def ingredient_params_on_create
    params.expect(ingredient: [ :name, :unit, :current_stock, :min_stock, :active ])
  end

  def ingredient_params_on_update
    params.expect(ingredient: [ :name, :unit, :min_stock, :active ])
  end
end

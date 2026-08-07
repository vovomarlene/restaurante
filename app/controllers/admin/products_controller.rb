class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[ edit update destroy ]

  def index
    @products = Product.includes(:category).order(:name)
  end

  def new
    @product = Product.new
    @product.recipe_items.build
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_products_path, notice: "Produto criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Produto atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      redirect_to admin_products_path, notice: "Produto removido."
    else
      redirect_to admin_products_path, alert: @product.errors.full_messages.to_sentence
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.expect(product: [ :name, :description, :price, :category_id, :active,
      recipe_items_attributes: [[ :id, :ingredient_id, :quantity, :_destroy ]] ])
  end
end

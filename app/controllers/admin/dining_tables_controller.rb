class Admin::DiningTablesController < Admin::BaseController
  before_action :set_dining_table, only: %i[ edit update destroy ]

  def index
    @dining_tables = DiningTable.all
  end

  def new
    @dining_table = DiningTable.new
  end

  def create
    @dining_table = DiningTable.new(dining_table_params)

    if @dining_table.save
      redirect_to admin_dining_tables_path, notice: "Mesa criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @dining_table.update(dining_table_params)
      redirect_to admin_dining_tables_path, notice: "Mesa atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @dining_table.destroy
      redirect_to admin_dining_tables_path, notice: "Mesa removida."
    else
      redirect_to admin_dining_tables_path, alert: @dining_table.errors.full_messages.to_sentence
    end
  end

  private

  def set_dining_table
    @dining_table = DiningTable.find(params[:id])
  end

  def dining_table_params
    params.expect(dining_table: [ :number, :capacity, :active ])
  end
end

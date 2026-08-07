class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.integer :unit, null: false, default: 0
      t.decimal :current_stock, precision: 12, scale: 3, null: false, default: 0
      t.decimal :min_stock, precision: 12, scale: 3, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
  end
end

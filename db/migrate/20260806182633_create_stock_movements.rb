class CreateStockMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_movements do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :quantity, precision: 12, scale: 3, null: false
      t.integer :origin, null: false
      t.references :order_item, null: true, foreign_key: true
      t.references :created_by, null: true, foreign_key: { to_table: :users }
      t.decimal :balance_after, precision: 12, scale: 3, null: false
      t.text :reason

      t.timestamps
    end
  end
end

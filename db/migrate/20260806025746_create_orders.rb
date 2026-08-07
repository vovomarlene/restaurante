class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.integer :order_type, null: false
      t.integer :status, null: false, default: 0
      t.integer :delivery_status
      t.references :dining_table, null: true, foreign_key: true
      t.references :opened_by, null: false, foreign_key: { to_table: :users }
      t.references :closed_by, null: true, foreign_key: { to_table: :users }
      t.string :customer_name
      t.string :customer_phone
      t.text :delivery_address
      t.decimal :delivery_fee, precision: 10, scale: 2, null: false, default: 0
      t.decimal :service_fee_percent, precision: 5, scale: 2, null: false, default: 0
      t.datetime :opened_at, null: false
      t.datetime :closed_at
      t.text :notes

      t.timestamps
    end

    add_index :orders, :order_type
    add_index :orders, :status
    # Só pode haver uma comanda aberta por mesa ao mesmo tempo.
    add_index :orders, :dining_table_id, unique: true,
      where: "status = 0 AND dining_table_id IS NOT NULL",
      name: "index_orders_on_open_dining_table"
  end
end

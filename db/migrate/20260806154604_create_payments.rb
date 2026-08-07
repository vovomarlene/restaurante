class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :cash_session, null: false, foreign_key: true
      t.integer :method, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :amount_received, precision: 10, scale: 2
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

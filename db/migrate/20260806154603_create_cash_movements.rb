class CreateCashMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :cash_movements do |t|
      t.references :cash_session, null: false, foreign_key: true
      t.integer :movement_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :reason, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

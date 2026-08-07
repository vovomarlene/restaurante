class CreateFiadoSettlements < ActiveRecord::Migration[8.1]
  def change
    create_table :fiado_settlements do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :cash_session, null: false, foreign_key: true
      t.integer :method, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }
      t.text :notes

      t.timestamps
    end
  end
end

class CreateRefunds < ActiveRecord::Migration[8.1]
  def change
    create_table :refunds do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :cash_session, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :reason, null: false
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

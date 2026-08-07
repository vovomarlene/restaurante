class CreateCashSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :cash_sessions do |t|
      t.references :opened_by, null: false, foreign_key: { to_table: :users }
      t.references :closed_by, null: true, foreign_key: { to_table: :users }
      t.decimal :opening_amount, precision: 10, scale: 2, null: false, default: 0
      t.text :opening_notes
      t.decimal :closing_amount, precision: 10, scale: 2
      t.text :closing_notes
      t.integer :status, null: false, default: 0
      t.datetime :opened_at, null: false
      t.datetime :closed_at
      t.decimal :expected_amount, precision: 10, scale: 2
      t.decimal :difference_amount, precision: 10, scale: 2

      t.timestamps
    end

    # Só pode haver uma sessão de caixa aberta no sistema inteiro por vez.
    add_index :cash_sessions, :status, unique: true, where: "status = 0",
      name: "index_cash_sessions_on_open_status"
  end
end

class CreateDiningTables < ActiveRecord::Migration[8.1]
  def change
    create_table :dining_tables do |t|
      t.integer :number, null: false
      t.integer :capacity
      t.integer :status, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :dining_tables, :number, unique: true
  end
end

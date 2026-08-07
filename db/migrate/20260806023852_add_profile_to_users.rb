class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :active, :boolean, null: false, default: true

    add_index :users, :role
  end
end

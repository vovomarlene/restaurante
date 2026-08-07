class AddCustomerToPayments < ActiveRecord::Migration[8.1]
  def change
    add_reference :payments, :customer, null: true, foreign_key: true
  end
end

class AddRestaurantNameToPrinterSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :printer_settings, :restaurant_name, :string
  end
end

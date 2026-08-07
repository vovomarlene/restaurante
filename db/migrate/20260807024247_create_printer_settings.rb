class CreatePrinterSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :printer_settings do |t|
      t.string :receipt_printer_name
      t.string :kitchen_printer_name

      t.timestamps
    end
  end
end

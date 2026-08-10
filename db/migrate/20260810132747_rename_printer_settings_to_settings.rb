# printer_settings virou a tabela de configurações gerais do sistema (nome
# do restaurante, impressoras e agora a taxa de serviço padrão) — o nome
# "printer_settings" não fazia mais sentido pro escopo.
class RenamePrinterSettingsToSettings < ActiveRecord::Migration[8.1]
  def change
    rename_table :printer_settings, :settings
    add_column :settings, :default_service_fee_percent, :decimal, precision: 5, scale: 2, default: 10.0, null: false
  end
end

class PrinterSetting < ApplicationRecord
  # Linha única de configuração (nomes das impressoras no SO/QZ Tray) —
  # não há histórico nem múltiplas lojas, então um singleton simples basta.
  def self.instance
    first_or_create!
  end
end

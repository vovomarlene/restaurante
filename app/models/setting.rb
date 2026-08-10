class Setting < ApplicationRecord
  # Linha única de configuração (nome do restaurante, impressoras, taxa de
  # serviço padrão) — não há histórico nem múltiplas lojas, então um
  # singleton simples basta.
  def self.instance
    first_or_create!
  end
end

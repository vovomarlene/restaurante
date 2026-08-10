# Compartilhado entre telas que filtram por dia/semana/mês (Relatórios,
# histórico de fiado do cliente) — mantém o mesmo período padrão em todo
# lugar em vez de cada controller reinventar o cálculo do range.
module PeriodFilterable
  extend ActiveSupport::Concern

  PERIODS = %w[diario semanal mensal].freeze

  private

  def period_range(date, period)
    case period
    when "semanal" then date.beginning_of_week.beginning_of_day..date.end_of_week.end_of_day
    when "mensal" then date.beginning_of_month.beginning_of_day..date.end_of_month.end_of_day
    else date.beginning_of_day..date.end_of_day
    end
  end
end

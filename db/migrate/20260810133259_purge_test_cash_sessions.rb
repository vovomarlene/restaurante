# Limpeza pontual pedida pelo dono do restaurante: os caixas fechados até
# agora foram todos de teste durante a configuração do sistema. Mantém só o
# caixa aberto no momento do deploy (o "de hoje") e remove os demais junto
# com toda a cadeia de registros presos a eles — pagamentos, comandas
# daqueles pagamentos, itens, baixas de estoque, estornos e sangrias/
# suprimentos. Não mexe em nada ligado ao caixa que fica aberto.
class PurgeTestCashSessions < ActiveRecord::Migration[8.1]
  def up
    session_ids = select_values("SELECT id FROM cash_sessions WHERE status <> 0")
    return if session_ids.empty?

    session_ids_sql = session_ids.join(",")

    order_ids = select_values(<<~SQL)
      SELECT DISTINCT order_id FROM payments WHERE cash_session_id IN (#{session_ids_sql})
    SQL
    order_ids_sql = order_ids.join(",")

    if order_ids.any?
      execute <<~SQL
        DELETE FROM stock_movements
        WHERE order_item_id IN (SELECT id FROM order_items WHERE order_id IN (#{order_ids_sql}))
      SQL
    end

    execute "DELETE FROM refunds WHERE cash_session_id IN (#{session_ids_sql})"

    if order_ids.any?
      execute "DELETE FROM order_items WHERE order_id IN (#{order_ids_sql})"
    end

    execute "DELETE FROM payments WHERE cash_session_id IN (#{session_ids_sql})"
    execute "DELETE FROM cash_movements WHERE cash_session_id IN (#{session_ids_sql})"
    execute "DELETE FROM fiado_settlements WHERE cash_session_id IN (#{session_ids_sql})"

    if order_ids.any?
      execute "DELETE FROM orders WHERE id IN (#{order_ids_sql})"
    end

    execute "DELETE FROM cash_sessions WHERE id IN (#{session_ids_sql})"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

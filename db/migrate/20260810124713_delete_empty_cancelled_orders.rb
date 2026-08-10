# Comandas canceladas que nunca tiveram nenhum item lançado (aberturas por
# engano, cliques duplicados) não têm valor de histórico — só poluem a tela
# de Vendas com linhas "Cancelada — R$ 0,00". Remove as que já existem;
# daqui pra frente Order#cancel! já evita criar novas (ver commit).
class DeleteEmptyCancelledOrders < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      DELETE FROM orders
      WHERE status = 2
        AND id NOT IN (SELECT DISTINCT order_id FROM order_items)
        AND id NOT IN (SELECT DISTINCT order_id FROM payments)
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

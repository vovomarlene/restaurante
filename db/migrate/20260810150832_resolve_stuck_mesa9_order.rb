# Correção pontual pedida pelo dono do restaurante: a comanda da Mesa 9
# aberta às 10/08/2026 11:02 ficou travada — provavelmente um pagamento
# parcial foi registrado e depois os itens foram removidos, deixando a
# comanda com R$0,00 mas ainda "aberta" e com pagamento associado (cancel!
# recusa por já ter pagamento; refund! recusava por não estar fechada — sem
# saída pela tela). Order#refund! agora aceita esse caso (ver commit), então
# usa a mesma rotina de estorno normal em vez de mexer direto no banco.
class ResolveStuckMesa9Order < ActiveRecord::Migration[8.1]
  def up
    order = Order.joins(:dining_table)
      .where(dining_tables: { number: 9 }, status: :aberto)
      .where(opened_at: Time.zone.parse("2026-08-10 11:02:00")..Time.zone.parse("2026-08-10 11:02:59"))
      .first

    return unless order

    ok =
      if order.requires_refund?
        order.refund!(
          reason: "Comanda travada por bug (pagamento parcial após remoção de itens) — resolvida em manutenção.",
          recorded_by: order.opened_by
        )
      else
        order.cancel!
      end

    raise "Falha ao resolver a comanda ##{order.id}: #{order.errors.full_messages.to_sentence}" unless ok
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

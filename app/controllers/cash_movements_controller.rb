class CashMovementsController < ApplicationController
  def create
    @cash_session = CashSession.current
    @cash_movement = @cash_session&.cash_movements&.new(cash_movement_params)
    @cash_movement&.created_by = Current.user

    if @cash_movement&.save
      redirect_to cash_session_path, notice: "Movimento registrado."
    else
      redirect_to cash_session_path, alert: @cash_movement&.errors&.full_messages&.to_sentence || "Nenhum caixa aberto."
    end
  end

  private

  def cash_movement_params
    params.expect(cash_movement: [ :movement_type, :amount, :reason ])
  end
end

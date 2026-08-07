class CashSessionsController < ApplicationController
  def show
    @cash_session = CashSession.current
    redirect_to new_cash_session_path unless @cash_session
  end

  def new
    if CashSession.current
      redirect_to cash_session_path
    else
      @cash_session = CashSession.new
    end
  end

  def create
    @cash_session = CashSession.new(cash_session_params)
    @cash_session.opened_by = Current.user

    if @cash_session.save
      redirect_to cash_session_path, notice: "Caixa aberto."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to cash_session_path, alert: "Já existe um caixa aberto."
  end

  def close
    @cash_session = CashSession.current

    if @cash_session&.close!(closed_by: Current.user, closing_amount: params[:closing_amount], closing_notes: params[:closing_notes])
      redirect_to cash_session_summary_path(@cash_session), notice: "Caixa fechado."
    else
      redirect_to cash_session_path, alert: @cash_session&.errors&.full_messages&.to_sentence || "Nenhum caixa aberto."
    end
  end

  def summary
    @cash_session = CashSession.find(params[:id])
  end

  private

  def cash_session_params
    params.expect(cash_session: [ :opening_amount, :opening_notes ])
  end
end

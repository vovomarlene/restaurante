require "test_helper"

# Cobre o fluxo de fechamento de caixa descrito no plano: abrir caixa,
# registrar sangria e suprimento, fechar e conferir a diferença calculada.
class CashCloseFlowTest < ActionDispatch::IntegrationTest
  setup do
    CashSession.open.update_all(status: CashSession.statuses[:fechada])
    sign_in_as(users(:two)) # role: admin
  end

  test "abrir caixa, sangria, suprimento e fechar calcula a diferença corretamente" do
    post cash_session_path, params: { cash_session: { opening_amount: 100 } }
    session = CashSession.current
    assert session.aberta?

    post cash_movements_path, params: { cash_movement: { movement_type: "sangria", amount: 30, reason: "Troco para o motoboy" } }
    post cash_movements_path, params: { cash_movement: { movement_type: "suprimento", amount: 20, reason: "Reforço de caixa" } }

    # esperado = 100 (abertura) + 0 (vendas em dinheiro) + 20 (suprimento) - 30 (sangria) = 90
    assert_equal 90.00, session.reload.compute_expected_amount

    patch close_cash_session_path, params: { closing_amount: 85 }
    assert_redirected_to cash_session_summary_path(session)

    session.reload
    assert session.fechada?
    assert_equal 90.00, session.expected_amount
    assert_equal(-5.00, session.difference_amount)
    assert_nil CashSession.current
  end
end

require "test_helper"

class CashSessionTest < ActiveSupport::TestCase
  test "compute_expected_amount sums opening, cash sales and suprimentos, minus sangrias" do
    session = cash_sessions(:aberta)
    # fixture: opening 100,00 + suprimento 50,00 - sangria 20,00 = 130,00 (sem vendas em dinheiro ainda)
    assert_equal 130.00, session.compute_expected_amount
  end

  test "only one open cash session is allowed system-wide (DB-level guard)" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      CashSession.create!(opened_by: users(:one), opening_amount: 50, status: :aberta, opened_at: Time.current)
    end
  end

  test "close! records expected/counted amounts and the difference (sobra)" do
    session = cash_sessions(:aberta)

    assert session.close!(closed_by: users(:two), closing_amount: 135.00, closing_notes: "Tudo certo")
    session.reload

    assert session.fechada?
    assert_equal 130.00, session.expected_amount
    assert_equal 5.00, session.difference_amount
  end

  test "close! records a negative difference when cash is missing (falta)" do
    session = cash_sessions(:aberta)

    session.close!(closed_by: users(:two), closing_amount: 120.00)

    assert_equal(-10.00, session.reload.difference_amount)
  end

  test "close! refuses to close an already closed session" do
    session = cash_sessions(:fechada)

    assert_not session.close!(closed_by: users(:two), closing_amount: 100.00)
    assert session.errors[:base].present?
  end

  test "compute_expected_amount includes fiado settlements paid in cash" do
    session = cash_sessions(:fechada)
    # fixture: abertura 100,00 + venda em dinheiro 32,00 + fiado quitado em dinheiro 10,00
    assert_equal 10.00, session.fiado_settlements_cash_total
    assert_equal 142.00, session.compute_expected_amount
  end

  test "refunds paid in cash are subtracted from the expected amount" do
    session = cash_sessions(:aberta)
    # fixture: venda em dinheiro de R$20 estornada de volta no mesmo valor
    assert_equal 20.00, session.refunds_cash_total
    # não muda o esperado da sessão "aberta" (venda e estorno se cancelam),
    # ver comentário do fixture em test/fixtures/refunds.yml
    assert_equal 130.00, session.compute_expected_amount
  end
end

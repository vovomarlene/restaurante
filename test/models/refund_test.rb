require "test_helper"

class RefundTest < ActiveSupport::TestCase
  test "requires a reason and a positive amount" do
    refund = Refund.new(payment: payments(:balcao_fechada_pagamento), cash_session: cash_sessions(:aberta), recorded_by: users(:two))

    assert_not refund.valid?
    assert refund.errors[:reason].present?
    assert refund.errors[:amount].present?
  end

  test "cannot be created against a closed cash session" do
    refund = Refund.new(
      payment: payments(:balcao_fechada_pagamento), cash_session: cash_sessions(:fechada),
      amount: 10, reason: "Teste", recorded_by: users(:two)
    )

    assert_not refund.valid?
    assert refund.errors[:cash_session].present?
  end
end

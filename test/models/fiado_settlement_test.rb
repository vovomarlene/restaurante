require "test_helper"

class FiadoSettlementTest < ActiveSupport::TestCase
  test "cannot settle more than the customer's outstanding balance" do
    settlement = FiadoSettlement.new(
      customer: customers(:maria), cash_session: cash_sessions(:aberta),
      method: :dinheiro, amount: 999, recorded_by: users(:two)
    )

    assert_not settlement.valid?
    assert settlement.errors[:amount].present?
  end

  test "can settle up to the outstanding balance" do
    settlement = FiadoSettlement.new(
      customer: customers(:maria), cash_session: cash_sessions(:aberta),
      method: :dinheiro, amount: customers(:maria).fiado_balance, recorded_by: users(:two)
    )

    assert settlement.valid?
  end

  test "cannot be created against a closed cash session" do
    settlement = FiadoSettlement.new(
      customer: customers(:maria), cash_session: cash_sessions(:fechada),
      method: :dinheiro, amount: 1, recorded_by: users(:two)
    )

    assert_not settlement.valid?
    assert settlement.errors[:cash_session].present?
  end
end

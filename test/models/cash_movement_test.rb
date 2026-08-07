require "test_helper"

class CashMovementTest < ActiveSupport::TestCase
  test "requires a positive amount and a reason" do
    movement = CashMovement.new(cash_session: cash_sessions(:aberta), movement_type: :sangria, created_by: users(:two))

    assert_not movement.valid?
    assert movement.errors[:amount].present?
    assert movement.errors[:reason].present?
  end

  test "cannot be created against a closed cash session" do
    movement = CashMovement.new(
      cash_session: cash_sessions(:fechada), movement_type: :sangria, amount: 10, reason: "Teste", created_by: users(:two)
    )

    assert_not movement.valid?
    assert movement.errors[:cash_session].present?
  end
end

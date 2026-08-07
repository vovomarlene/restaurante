require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  test "troco is the difference between amount received and amount, for cash payments" do
    payment = Payment.new(method: :dinheiro, amount: 30.00, amount_received: 50.00)
    assert_equal 20.00, payment.troco
  end

  test "troco is zero for non-cash payment methods" do
    payment = Payment.new(method: :pix, amount: 30.00)
    assert_equal 0, payment.troco
  end

  test "cannot pay an order that is not open" do
    payment = payments(:balcao_fechada_pagamento).order.payments.new(
      cash_session: cash_sessions(:aberta), method: :dinheiro, amount: 10, recorded_by: users(:two)
    )

    assert_not payment.valid?
    assert payment.errors[:order].present?
  end

  test "cannot register a payment against a closed cash session" do
    payment = orders(:mesa_aberta).payments.new(
      cash_session: cash_sessions(:fechada), method: :dinheiro, amount: 10, recorded_by: users(:two)
    )

    assert_not payment.valid?
    assert payment.errors[:cash_session].present?
  end

  test "fiado payments require a customer" do
    payment = orders(:mesa_aberta).payments.new(
      cash_session: cash_sessions(:aberta), method: :fiado, amount: 10, recorded_by: users(:two)
    )

    assert_not payment.valid?
    assert payment.errors[:customer].present?
  end

  test "fiado payments do not count as cash in the register" do
    session = cash_sessions(:fechada)
    # fixture: só o pagamento em dinheiro (R$32,00) deve contar; o fiado (R$18,00) não
    assert_equal 32.00, session.cash_sales_total
  end
end

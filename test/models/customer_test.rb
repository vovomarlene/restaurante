require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "fiado_balance is total sold on credit minus what was already settled" do
    # fixture: Maria comprou R$18,00 fiado e já pagou R$10,00
    assert_equal 8.00, customers(:maria).fiado_balance
  end

  test "a customer with no fiado purchases has a zero balance" do
    assert_equal 0, customers(:joao).fiado_balance
  end

  test "a refunded fiado payment no longer counts as debt" do
    customer = customers(:maria)
    payment = payments(:balcao_fiado_pagamento)

    Refund.create!(payment: payment, cash_session: cash_sessions(:aberta), amount: payment.amount, reason: "Estorno total", recorded_by: users(:two))

    # fiado_total zera (18,00 - 18,00 estornado); só resta a quitação de R$10 já feita antes
    assert_equal 0, customer.fiado_total
    assert_equal(-10.00, customer.fiado_balance)
  end

  test "requires a name" do
    customer = Customer.new(name: "")
    assert_not customer.valid?
    assert customer.errors[:name].present?
  end
end

require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "fiado_balance is total sold on credit minus what was already settled" do
    # fixture: Maria comprou R$18,00 fiado e já pagou R$10,00
    assert_equal 8.00, customers(:maria).fiado_balance
  end

  test "a customer with no fiado purchases has a zero balance" do
    assert_equal 0, customers(:joao).fiado_balance
  end

  test "requires a name" do
    customer = Customer.new(name: "")
    assert_not customer.valid?
    assert customer.errors[:name].present?
  end
end

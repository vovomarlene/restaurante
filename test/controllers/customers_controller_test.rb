require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) } # role: caixa — clientes é operação do dia a dia, não só admin

  test "index lists all active customers" do
    get customers_path
    assert_response :success
    assert_match "Maria Souza", response.body
    assert_match "João Silva", response.body
  end

  test "index filtered by fiado only shows customers with an outstanding balance" do
    get customers_path(fiado: 1)

    assert_response :success
    assert_match "Maria Souza", response.body
    assert_no_match "João Silva", response.body
  end

  test "creates a new customer" do
    assert_difference "Customer.count", 1 do
      post customers_path, params: { customer: { name: "Ana Lima", phone: "11977776666" } }
    end

    assert_redirected_to customer_path(Customer.find_by!(name: "Ana Lima"))
  end
end

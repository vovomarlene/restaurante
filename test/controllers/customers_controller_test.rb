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

  test "show lists this month's fiado activity by default and always shows the total balance" do
    maria = customers(:maria)
    # fixture: comprou 18,00 fiado, pagou 10,00 -> saldo 8,00
    assert_equal 8.00, maria.fiado_balance

    get customer_path(maria)

    assert_response :success
    assert_match "comanda ##{payments(:balcao_fiado_pagamento).order_id}", response.body
    assert_match "8,00", response.body
  end

  test "show filters fiado activity by the given period, without touching the total balance" do
    maria = customers(:maria)

    get customer_path(maria, period: "diario", date: "01/01/2020")

    assert_response :success
    assert_no_match "comanda ##{payments(:balcao_fiado_pagamento).order_id}", response.body
    # o saldo total continua aparecendo mesmo sem nenhuma atividade no período filtrado
    assert_match "8,00", response.body
  end
end

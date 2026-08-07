# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@restaurante.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "restaurante123")

admin = User.find_or_initialize_by(email_address: admin_email)
admin.assign_attributes(name: "Administrador", role: :admin, active: true)
admin.password = admin_password if admin.new_record?
admin.save!

puts "Admin: #{admin_email} / senha: #{admin_password}" if admin.previously_new_record?

bebidas = Category.find_or_create_by!(name: "Bebidas") { |c| c.position = 1 }
pratos = Category.find_or_create_by!(name: "Pratos") { |c| c.position = 2 }

refrigerante_lata = Ingredient.find_or_create_by!(name: "Refrigerante lata 350ml") do |i|
  i.unit = :un
  i.current_stock = 50
  i.min_stock = 10
end

feijao = Ingredient.find_or_create_by!(name: "Feijão") do |i|
  i.unit = :kg
  i.current_stock = 20
  i.min_stock = 5
end

refrigerante = Product.find_or_create_by!(name: "Refrigerante lata") do |p|
  p.category = bebidas
  p.price = 6.00
  p.description = "Lata 350ml"
end
refrigerante.recipe_items.find_or_create_by!(ingredient: refrigerante_lata) { |ri| ri.quantity = 1 }

feijoada = Product.find_or_create_by!(name: "Feijoada") do |p|
  p.category = pratos
  p.price = 32.00
  p.description = "Porção individual"
end
feijoada.recipe_items.find_or_create_by!(ingredient: feijao) { |ri| ri.quantity = 0.3 }

(1..6).each do |number|
  DiningTable.find_or_create_by!(number: number) { |t| t.capacity = number.even? ? 4 : 2 }
end

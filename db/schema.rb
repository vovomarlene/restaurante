# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_10_133259) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cash_movements", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "cash_session_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.integer "movement_type", null: false
    t.string "reason", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_cash_movements_on_cash_session_id"
    t.index ["created_by_id"], name: "index_cash_movements_on_created_by_id"
  end

  create_table "cash_sessions", force: :cascade do |t|
    t.datetime "closed_at"
    t.bigint "closed_by_id"
    t.decimal "closing_amount", precision: 10, scale: 2
    t.text "closing_notes"
    t.datetime "created_at", null: false
    t.decimal "difference_amount", precision: 10, scale: 2
    t.decimal "expected_amount", precision: 10, scale: 2
    t.datetime "opened_at", null: false
    t.bigint "opened_by_id", null: false
    t.decimal "opening_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.text "opening_notes"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_id"], name: "index_cash_sessions_on_closed_by_id"
    t.index ["opened_by_id"], name: "index_cash_sessions_on_opened_by_id"
    t.index ["status"], name: "index_cash_sessions_on_open_status", unique: true, where: "(status = 0)"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "address"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_customers_on_name"
  end

  create_table "dining_tables", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_dining_tables_on_number", unique: true
  end

  create_table "fiado_settlements", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "cash_session_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.integer "method", null: false
    t.text "notes"
    t.bigint "recorded_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_fiado_settlements_on_cash_session_id"
    t.index ["customer_id"], name: "index_fiado_settlements_on_customer_id"
    t.index ["recorded_by_id"], name: "index_fiado_settlements_on_recorded_by_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.decimal "current_stock", precision: 12, scale: 3, default: "0.0", null: false
    t.decimal "min_stock", precision: 12, scale: 3, default: "0.0", null: false
    t.string "name", null: false
    t.integer "unit", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "notes"
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "sent_to_kitchen_at"
    t.integer "status", default: 0, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "closed_at"
    t.bigint "closed_by_id"
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.string "customer_phone"
    t.text "delivery_address"
    t.decimal "delivery_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "delivery_status"
    t.bigint "dining_table_id"
    t.text "notes"
    t.datetime "opened_at", null: false
    t.bigint "opened_by_id", null: false
    t.integer "order_type", null: false
    t.decimal "service_fee_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_id"], name: "index_orders_on_closed_by_id"
    t.index ["dining_table_id"], name: "index_orders_on_dining_table_id"
    t.index ["dining_table_id"], name: "index_orders_on_open_dining_table", unique: true, where: "((status = 0) AND (dining_table_id IS NOT NULL))"
    t.index ["opened_by_id"], name: "index_orders_on_opened_by_id"
    t.index ["order_type"], name: "index_orders_on_order_type"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "amount_received", precision: 10, scale: 2
    t.bigint "cash_session_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.integer "method", null: false
    t.bigint "order_id", null: false
    t.bigint "recorded_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_payments_on_cash_session_id"
    t.index ["customer_id"], name: "index_payments_on_customer_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["recorded_by_id"], name: "index_payments_on_recorded_by_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["name"], name: "index_products_on_name"
  end

  create_table "recipe_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity", precision: 10, scale: 3, null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_items_on_ingredient_id"
    t.index ["product_id", "ingredient_id"], name: "index_recipe_items_on_product_id_and_ingredient_id", unique: true
    t.index ["product_id"], name: "index_recipe_items_on_product_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "cash_session_id", null: false
    t.datetime "created_at", null: false
    t.bigint "payment_id", null: false
    t.text "reason", null: false
    t.bigint "recorded_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_refunds_on_cash_session_id"
    t.index ["payment_id"], name: "index_refunds_on_payment_id"
    t.index ["recorded_by_id"], name: "index_refunds_on_recorded_by_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "default_service_fee_percent", precision: 5, scale: 2, default: "10.0", null: false
    t.string "kitchen_printer_name"
    t.string "receipt_printer_name"
    t.string "restaurant_name"
    t.datetime "updated_at", null: false
  end

  create_table "stock_movements", force: :cascade do |t|
    t.decimal "balance_after", precision: 12, scale: 3, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.bigint "ingredient_id", null: false
    t.bigint "order_item_id"
    t.integer "origin", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_stock_movements_on_created_by_id"
    t.index ["ingredient_id"], name: "index_stock_movements_on_ingredient_id"
    t.index ["order_item_id"], name: "index_stock_movements_on_order_item_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", default: "", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "cash_movements", "cash_sessions"
  add_foreign_key "cash_movements", "users", column: "created_by_id"
  add_foreign_key "cash_sessions", "users", column: "closed_by_id"
  add_foreign_key "cash_sessions", "users", column: "opened_by_id"
  add_foreign_key "fiado_settlements", "cash_sessions"
  add_foreign_key "fiado_settlements", "customers"
  add_foreign_key "fiado_settlements", "users", column: "recorded_by_id"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "dining_tables"
  add_foreign_key "orders", "users", column: "closed_by_id"
  add_foreign_key "orders", "users", column: "opened_by_id"
  add_foreign_key "payments", "cash_sessions"
  add_foreign_key "payments", "customers"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "users", column: "recorded_by_id"
  add_foreign_key "products", "categories"
  add_foreign_key "recipe_items", "ingredients"
  add_foreign_key "recipe_items", "products"
  add_foreign_key "refunds", "cash_sessions"
  add_foreign_key "refunds", "payments"
  add_foreign_key "refunds", "users", column: "recorded_by_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "stock_movements", "ingredients"
  add_foreign_key "stock_movements", "order_items"
  add_foreign_key "stock_movements", "users", column: "created_by_id"
end

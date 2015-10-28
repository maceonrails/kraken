# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151027134129) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "choices", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.text     "address"
    t.date     "join_at"
    t.date     "expires"
    t.string   "email"
    t.string   "phone"
    t.string   "mobile"
    t.string   "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.string   "name"
    t.uuid     "product_id"
    t.text     "outlets",                                                                                                                                   array: true
    t.datetime "created_at",                                                                                                                   null: false
    t.datetime "updated_at",                                                                                                                   null: false
    t.uuid     "updated_by"
    t.datetime "start_date"
    t.datetime "end_date"
    t.time     "start_time",                          default: '2000-01-01 00:00:00'
    t.time     "end_time",                            default: '2000-01-01 23:59:00'
    t.text     "days",                                default: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],              array: true
    t.decimal  "amount",     precision: 25, scale: 2
    t.string   "percentage"
  end

  create_table "inventories", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "company_id"
    t.string   "name"
    t.integer  "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventory_outlets", force: :cascade do |t|
    t.uuid     "outlet_id"
    t.uuid     "inventory_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "order_items", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "order_id"
    t.uuid     "product_id"
    t.integer  "quantity"
    t.uuid     "choice_id"
    t.string   "note"
    t.uuid     "payment_id"
    t.boolean  "served"
    t.boolean  "void",                                      default: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "paid",                                      default: false
    t.string   "void_note"
    t.integer  "void_quantity",                             default: 0
    t.string   "saved_choice"
    t.boolean  "take_away",                                 default: false
    t.uuid     "void_by"
    t.integer  "paid_quantity",                             default: 0
    t.integer  "printed_quantity",                          default: 0
    t.integer  "pay_quantity",                              default: 0
    t.integer  "oc_quantity",                               default: 0
    t.uuid     "oc_by"
    t.string   "oc_note"
    t.decimal  "paid_amount",      precision: 25, scale: 2
    t.decimal  "tax_amount",       precision: 25, scale: 2
    t.decimal  "discount_amount",  precision: 25, scale: 2
    t.integer  "discount_id"
  end

  add_index "order_items", ["discount_id"], name: "index_order_items_on_discount_id", using: :btree
  add_index "order_items", ["void_by"], name: "index_order_items_on_void_by", using: :btree

  create_table "orders", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.uuid     "table_id"
    t.uuid     "servant_id"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "waiting",                                   default: true
    t.integer  "queue_number"
    t.uuid     "discount_by"
    t.integer  "person"
    t.decimal  "discount_amount",  precision: 25, scale: 2
    t.decimal  "discount_percent", precision: 25, scale: 2
    t.uuid     "cashier_id"
    t.string   "struck_id"
    t.boolean  "created",                                   default: false
    t.boolean  "pantry_created",                            default: false
    t.string   "debit_amount"
    t.string   "credit_amount"
    t.string   "cash_amount"
    t.string   "debit_name"
    t.string   "debit_number"
    t.string   "credit_name"
    t.string   "credit_number"
  end

  add_index "orders", ["struck_id"], name: "index_orders_on_struck_id", using: :btree

  create_table "outlets", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.text     "address"
    t.uuid     "company_id"
    t.string   "email"
    t.string   "phone"
    t.string   "mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.hstore   "taxs"
  end

  create_table "payments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "order_id"
    t.string   "payment_type"
    t.boolean  "void"
    t.string   "note"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.decimal  "amount",       precision: 25, scale: 2
    t.decimal  "discount",     precision: 25, scale: 2
  end

  create_table "printers", force: :cascade do |t|
    t.string   "name"
    t.string   "printer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "default"
  end

  create_table "product_categories", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "company_id"
    t.string   "name"
    t.boolean  "is_valid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_choices", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "product_id"
    t.uuid     "choice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_discounts", force: :cascade do |t|
    t.uuid     "product_id"
    t.integer  "discount_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "product_discounts", ["discount_id"], name: "index_product_discounts_on_discount_id", using: :btree
  add_index "product_discounts", ["product_id"], name: "index_product_discounts_on_product_id", using: :btree

  create_table "product_images", force: :cascade do |t|
    t.string   "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_outlets", force: :cascade do |t|
    t.uuid     "outlet_id"
    t.uuid     "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_sub_categories", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "product_category_id"
    t.string   "name"
    t.boolean  "is_valid"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "product_varians", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "product_id"
    t.string   "name"
    t.string   "picture"
    t.string   "default_price"
    t.boolean  "active",        default: true
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "product_varians", ["active"], name: "index_product_varians_on_active", using: :btree

  create_table "products", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "company_id"
    t.string   "name"
    t.string   "picture"
    t.boolean  "active",                                           default: true
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.text     "description"
    t.string   "category"
    t.uuid     "updated_by"
    t.string   "picture_extension"
    t.text     "picture_base64"
    t.uuid     "product_sub_category_id"
    t.boolean  "available",                                        default: true
    t.boolean  "sold_out",                                         default: false
    t.decimal  "price",                   precision: 25, scale: 2
    t.decimal  "default_price",           precision: 25, scale: 2
    t.uuid     "tenant_id"
  end

  add_index "products", ["active"], name: "index_products_on_active", using: :btree
  add_index "products", ["category"], name: "index_products_on_category", using: :btree

  create_table "profiles", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.string   "name"
    t.text     "address"
    t.string   "phone"
    t.date     "join_at"
    t.date     "contract_until"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "synchronizes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tables", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "location"
    t.boolean  "splited",    default: false
    t.uuid     "order_id"
    t.uuid     "parent_id"
    t.integer  "status"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "occupied",   default: false
  end

  add_index "tables", ["location"], name: "index_tables_on_location", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "token",                  default: "", null: false
    t.integer  "role",                   default: 5
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.uuid     "company_id"
    t.uuid     "outlet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_login"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["token"], name: "index_users_on_token", unique: true, using: :btree

  add_foreign_key "inventories", "companies"
  add_foreign_key "inventory_outlets", "inventories"
  add_foreign_key "inventory_outlets", "outlets"
  add_foreign_key "order_items", "discounts"
  add_foreign_key "outlets", "companies"
  add_foreign_key "product_categories", "companies"
  add_foreign_key "product_discounts", "discounts"
  add_foreign_key "product_discounts", "products"
  add_foreign_key "product_outlets", "outlets"
  add_foreign_key "product_outlets", "products"
  add_foreign_key "product_varians", "products"
  add_foreign_key "products", "companies"
  add_foreign_key "profiles", "users", on_delete: :cascade
  add_foreign_key "users", "companies"
  add_foreign_key "users", "outlets"
end

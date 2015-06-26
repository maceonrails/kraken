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

ActiveRecord::Schema.define(version: 20150526145300) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

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

  create_table "outlets", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.text     "address"
    t.uuid     "company_id"
    t.string   "email"
    t.string   "phone"
    t.string   "mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_categories", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "company_id"
    t.string   "name"
    t.boolean  "valid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_outlets", force: :cascade do |t|
    t.uuid     "outlet_id"
    t.uuid     "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.uuid     "product_category_id"
    t.string   "name"
    t.string   "picture"
    t.boolean  "active",              default: true
    t.string   "default_price"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "products", ["active"], name: "index_products_on_active", using: :btree

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

  create_table "tables", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "location"
    t.boolean  "splited",    default: false
    t.uuid     "order_id"
    t.uuid     "parent_id"
    t.integer  "status"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["token"], name: "index_users_on_token", unique: true, using: :btree

  add_foreign_key "inventories", "companies"
  add_foreign_key "inventory_outlets", "inventories"
  add_foreign_key "inventory_outlets", "outlets"
  add_foreign_key "outlets", "companies"
  add_foreign_key "product_categories", "companies"
  add_foreign_key "product_outlets", "outlets"
  add_foreign_key "product_outlets", "products"
  add_foreign_key "product_varians", "products"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "product_categories"
  add_foreign_key "profiles", "users", on_delete: :cascade
  add_foreign_key "users", "companies"
  add_foreign_key "users", "outlets"
end

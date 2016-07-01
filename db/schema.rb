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

ActiveRecord::Schema.define(version: 20160701123149) do

  create_table "items", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.string   "title",        limit: 255
    t.text     "body",         limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "stocks_count", limit: 4,     default: 0
  end

  add_index "items", ["user_id"], name: "index_items_on_user_id", using: :btree

  create_table "items_tags", force: :cascade do |t|
    t.integer  "tag_id",     limit: 4
    t.integer  "item_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "items_tags", ["item_id"], name: "index_items_tags_on_item_id", using: :btree
  add_index "items_tags", ["tag_id"], name: "index_items_tags_on_tag_id", using: :btree

  create_table "stocks", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "item_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "stocks", ["item_id"], name: "index_stocks_on_item_id", using: :btree
  add_index "stocks", ["user_id"], name: "index_stocks_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "items_count", limit: 4,   default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "uid",                    limit: 255
    t.string   "provider",               limit: 255
    t.string   "name",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "items", "users"
  add_foreign_key "items_tags", "items"
  add_foreign_key "items_tags", "tags"
  add_foreign_key "stocks", "items"
  add_foreign_key "stocks", "users"
end

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130604122828) do

  create_table "shifts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "role"
    t.text     "description"
    t.integer  "fk_user_worker"
    t.string   "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "shifts", ["end_time", "user_id"], :name => "index_shifts_on_end_time_and_user_id"
  add_index "shifts", ["end_time"], :name => "index_shifts_on_end_time"
  add_index "shifts", ["fk_user_worker"], :name => "index_shifts_on_fk_user_worker"
  add_index "shifts", ["start_time", "user_id"], :name => "index_shifts_on_start_time_and_user_id"
  add_index "shifts", ["start_time"], :name => "index_shifts_on_start_time"
  add_index "shifts", ["status"], :name => "index_shifts_on_status"
  add_index "shifts", ["user_id"], :name => "index_shifts_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "sign_up_stage"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end

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

ActiveRecord::Schema.define(:version => 20130611175541) do

  create_table "firm_permissions", :force => true do |t|
    t.integer  "firm_id"
    t.integer  "user_id"
    t.boolean  "status"
    t.integer  "type"
    t.boolean  "admin"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "firm_permissions", ["firm_id"], :name => "index_firm_permissions_on_firm_id"
  add_index "firm_permissions", ["type"], :name => "index_firm_permissions_on_type"
  add_index "firm_permissions", ["user_id", "firm_id", "type"], :name => "index_firm_permissions_on_user_id_and_firm_id_and_type", :unique => true
  add_index "firm_permissions", ["user_id"], :name => "index_firm_permissions_on_user_id"

  create_table "firms", :force => true do |t|
    t.string   "name"
    t.string   "branch"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "sign_up_code"
  end

  create_table "shift_requests", :force => true do |t|
    t.integer  "shift_id"
    t.integer  "worker_id"
    t.integer  "manager_id"
    t.boolean  "worker_status"
    t.boolean  "manager_status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "shift_requests", ["manager_id"], :name => "index_shift_requests_on_manager_id"
  add_index "shift_requests", ["shift_id", "worker_id"], :name => "index_shift_requests_on_shift_id_and_worker_id", :unique => true
  add_index "shift_requests", ["shift_id"], :name => "index_shift_requests_on_shift_id"
  add_index "shift_requests", ["worker_id"], :name => "index_shift_requests_on_worker_id"
  add_index "shift_requests", ["worker_status", "manager_status"], :name => "index_shift_requests_on_worker_status_and_manager_status"

  create_table "shifts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "start_datetime"
    t.string   "role"
    t.text     "description"
    t.integer  "fk_user_worker"
    t.string   "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "duration_mins"
    t.datetime "end_datetime"
    t.integer  "business_id"
  end

  add_index "shifts", ["fk_user_worker"], :name => "index_shifts_on_fk_user_worker"
  add_index "shifts", ["start_datetime", "user_id"], :name => "index_shifts_on_start_time_and_user_id"
  add_index "shifts", ["start_datetime"], :name => "index_shifts_on_start_time"
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
    t.string   "business_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end

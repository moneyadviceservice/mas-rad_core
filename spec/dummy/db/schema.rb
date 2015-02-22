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

ActiveRecord::Schema.define(version: 20150222092417) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accreditations", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "accreditations_advisers", id: false, force: :cascade do |t|
    t.integer "adviser_id",       null: false
    t.integer "accreditation_id", null: false
  end

  add_index "accreditations_advisers", ["adviser_id", "accreditation_id"], name: "advisers_accreditations_index", unique: true, using: :btree

  create_table "advisers", force: :cascade do |t|
    t.string   "reference_number",                  null: false
    t.string   "name",                              null: false
    t.integer  "firm_id",                           null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "confirmed_disclaimer",              null: false
    t.string   "postcode",             default: "", null: false
    t.integer  "travel_distance",      default: 0,  null: false
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "advisers_professional_bodies", id: false, force: :cascade do |t|
    t.integer "adviser_id",           null: false
    t.integer "professional_body_id", null: false
  end

  add_index "advisers_professional_bodies", ["adviser_id", "professional_body_id"], name: "advisers_professional_bodies_index", unique: true, using: :btree

  create_table "advisers_professional_standings", id: false, force: :cascade do |t|
    t.integer "adviser_id",               null: false
    t.integer "professional_standing_id", null: false
  end

  add_index "advisers_professional_standings", ["adviser_id", "professional_standing_id"], name: "advisers_professional_standings_index", unique: true, using: :btree

  create_table "advisers_qualifications", id: false, force: :cascade do |t|
    t.integer "adviser_id",       null: false
    t.integer "qualification_id", null: false
  end

  add_index "advisers_qualifications", ["adviser_id", "qualification_id"], name: "advisers_qualifications_index", unique: true, using: :btree

  create_table "allowed_payment_methods", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "allowed_payment_methods_firms", id: false, force: :cascade do |t|
    t.integer "firm_id",                   null: false
    t.integer "allowed_payment_method_id", null: false
  end

  add_index "allowed_payment_methods_firms", ["firm_id", "allowed_payment_method_id"], name: "firms_allowed_payment_methods_index", unique: true, using: :btree

  create_table "firms", force: :cascade do |t|
    t.integer  "fca_number",                                  null: false
    t.string   "registered_name",                             null: false
    t.string   "email_address"
    t.string   "telephone_number"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "address_line_one"
    t.string   "address_line_two"
    t.string   "address_town"
    t.string   "address_county"
    t.string   "address_postcode"
    t.boolean  "free_initial_meeting"
    t.integer  "initial_meeting_duration_id"
    t.integer  "minimum_fixed_fee"
    t.integer  "retirement_income_products_percent"
    t.integer  "pension_transfer_percent"
    t.integer  "long_term_care_percent"
    t.integer  "equity_release_percent"
    t.integer  "inheritance_tax_and_estate_planning_percent"
    t.integer  "wills_and_probate_percent"
    t.integer  "other_percent"
    t.integer  "parent_id"
    t.float    "latitude"
    t.float    "longitude"
  end

  add_index "firms", ["initial_meeting_duration_id"], name: "index_firms_on_initial_meeting_duration_id", using: :btree

  create_table "firms_in_person_advice_methods", id: false, force: :cascade do |t|
    t.integer "firm_id",                    null: false
    t.integer "in_person_advice_method_id", null: false
  end

  add_index "firms_in_person_advice_methods", ["firm_id", "in_person_advice_method_id"], name: "firms_in_person_advice_methods_index", unique: true, using: :btree

  create_table "firms_initial_advice_fee_structures", id: false, force: :cascade do |t|
    t.integer "firm_id",                         null: false
    t.integer "initial_advice_fee_structure_id", null: false
  end

  add_index "firms_initial_advice_fee_structures", ["firm_id", "initial_advice_fee_structure_id"], name: "firms_initial_advice_fee_structures_index", unique: true, using: :btree

  create_table "firms_investment_sizes", id: false, force: :cascade do |t|
    t.integer "firm_id",            null: false
    t.integer "investment_size_id", null: false
  end

  add_index "firms_investment_sizes", ["firm_id", "investment_size_id"], name: "firms_investment_sizes_index", unique: true, using: :btree

  create_table "firms_ongoing_advice_fee_structures", id: false, force: :cascade do |t|
    t.integer "firm_id",                         null: false
    t.integer "ongoing_advice_fee_structure_id", null: false
  end

  add_index "firms_ongoing_advice_fee_structures", ["firm_id", "ongoing_advice_fee_structure_id"], name: "firms_ongoing_advice_fee_structures_index", unique: true, using: :btree

  create_table "firms_other_advice_methods", id: false, force: :cascade do |t|
    t.integer "firm_id",                null: false
    t.integer "other_advice_method_id", null: false
  end

  add_index "firms_other_advice_methods", ["firm_id", "other_advice_method_id"], name: "firms_other_advice_methods_index", unique: true, using: :btree

  create_table "in_person_advice_methods", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "initial_advice_fee_structures", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "initial_meeting_durations", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "investment_sizes", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "lookup_advisers", force: :cascade do |t|
    t.string   "reference_number", null: false
    t.string   "name",             null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "lookup_firms", force: :cascade do |t|
    t.integer  "fca_number",                   null: false
    t.string   "registered_name", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lookup_firms", ["fca_number"], name: "index_lookup_firms_on_fca_number", unique: true, using: :btree

  create_table "lookup_subsidiaries", force: :cascade do |t|
    t.integer  "fca_number",              null: false
    t.string   "name",       default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "lookup_subsidiaries", ["fca_number"], name: "index_lookup_subsidiaries_on_fca_number", using: :btree

  create_table "ongoing_advice_fee_structures", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "other_advice_methods", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "principals", force: :cascade do |t|
    t.integer  "fca_number"
    t.string   "token"
    t.string   "website_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "job_title"
    t.string   "email_address"
    t.string   "telephone_number"
    t.boolean  "confirmed_disclaimer", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "principals", ["fca_number"], name: "index_principals_on_fca_number", unique: true, using: :btree
  add_index "principals", ["token"], name: "index_principals_on_token", unique: true, using: :btree

  create_table "professional_bodies", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "professional_standings", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

  create_table "qualifications", force: :cascade do |t|
    t.string   "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "order",      default: 0, null: false
  end

end

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

ActiveRecord::Schema.define(version: 20150819195311) do

  create_table "articles", force: :cascade do |t|
    t.integer  "publisher_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",           limit: 255
    t.string   "path",          limit: 255
    t.string   "domain",        limit: 255
    t.integer  "visits",        limit: 4,   default: 0
    t.integer  "num_responses", limit: 4,   default: 0
  end

  add_index "articles", ["publisher_id"], name: "index_articles_on_publisher_id", using: :btree

  create_table "artquestions", force: :cascade do |t|
    t.integer  "article_id",  limit: 4
    t.integer  "question_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "artquestions", ["article_id"], name: "index_artquestions_on_article_id", using: :btree
  add_index "artquestions", ["question_id"], name: "index_artquestions_on_question_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.integer  "researcher_id",     limit: 4
    t.boolean  "random"
    t.boolean  "complete",                                               default: false
    t.integer  "limit",             limit: 4,                                            null: false
    t.boolean  "target_gender",                                          default: false
    t.boolean  "target_male",                                            default: true
    t.boolean  "target_female",                                          default: true
    t.boolean  "target_other",                                           default: true
    t.boolean  "target_age",                                             default: false
    t.integer  "age_range_lower",   limit: 4,                            default: 0
    t.integer  "age_range_upper",   limit: 4,                            default: 99
    t.boolean  "target_categories",                                      default: false
    t.string   "title",             limit: 255
    t.decimal  "cost",                          precision: 15, scale: 2, default: 0.0
    t.decimal  "taxes",                         precision: 15, scale: 2, default: 0.0
    t.boolean  "all_publishers",                                         default: false
  end

  add_index "campaigns", ["researcher_id"], name: "index_campaigns_on_researcher_id", using: :btree

  create_table "campaigns_categories", id: false, force: :cascade do |t|
    t.integer "campaign_id", limit: 4
    t.integer "category_id", limit: 4
  end

  add_index "campaigns_categories", ["campaign_id"], name: "index_campaigns_categories_on_campaign_id", using: :btree
  add_index "campaigns_categories", ["category_id"], name: "index_campaigns_categories_on_category_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "choices", force: :cascade do |t|
    t.text     "text",               limit: 65535
    t.integer  "question_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "num_responses",      limit: 4,     default: 0
  end

  add_index "choices", ["question_id"], name: "index_choices_on_question_id", using: :btree

  create_table "maxmind_geolite_city_blocks", id: false, force: :cascade do |t|
    t.integer "start_ip_num", limit: 8, null: false
    t.integer "end_ip_num",   limit: 8, null: false
    t.integer "loc_id",       limit: 8, null: false
  end

  add_index "maxmind_geolite_city_blocks", ["end_ip_num", "start_ip_num"], name: "index_maxmind_geolite_city_blocks_on_end_ip_num_range", unique: true, using: :btree
  add_index "maxmind_geolite_city_blocks", ["loc_id"], name: "index_maxmind_geolite_city_blocks_on_loc_id", using: :btree
  add_index "maxmind_geolite_city_blocks", ["start_ip_num"], name: "index_maxmind_geolite_city_blocks_on_start_ip_num", unique: true, using: :btree

  create_table "maxmind_geolite_city_location", id: false, force: :cascade do |t|
    t.integer "loc_id",      limit: 8,   null: false
    t.string  "country",     limit: 255, null: false
    t.string  "region",      limit: 255, null: false
    t.string  "city",        limit: 255
    t.string  "postal_code", limit: 255, null: false
    t.float   "latitude",    limit: 24
    t.float   "longitude",   limit: 24
    t.integer "metro_code",  limit: 4
    t.integer "area_code",   limit: 4
  end

  add_index "maxmind_geolite_city_location", ["loc_id"], name: "index_maxmind_geolite_city_location_on_loc_id", unique: true, using: :btree

  create_table "payouts", force: :cascade do |t|
    t.integer  "publisher_id",    limit: 4
    t.decimal  "amount",                      precision: 15, scale: 2,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alpha_id",        limit: 255
    t.string   "paypal_item_id",  limit: 255
    t.decimal  "fees",                        precision: 15, scale: 2
    t.string   "paypal_batch_id", limit: 255
    t.string   "status",          limit: 255,                          default: "NEW", null: false
  end

  create_table "publishers", force: :cascade do |t|
    t.string   "email",                  limit: 255,                          default: "",    null: false
    t.string   "encrypted_password",     limit: 255,                          default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                            default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alpha_id",               limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "name",                   limit: 255
    t.string   "domain",                 limit: 255
    t.string   "icon_filename",          limit: 255
    t.boolean  "allow_sponsored"
    t.boolean  "verified"
    t.integer  "category_id",            limit: 4
    t.string   "logo_file_name",         limit: 255
    t.string   "logo_content_type",      limit: 255
    t.integer  "logo_file_size",         limit: 4
    t.datetime "logo_updated_at"
    t.decimal  "total_earnings",                     precision: 15, scale: 2, default: 0.0
    t.decimal  "paid",                               precision: 15, scale: 2, default: 0.0
    t.string   "blog_name",              limit: 255
    t.boolean  "free_demographics",                                           default: false
    t.boolean  "questions_active",                                            default: true
  end

  add_index "publishers", ["category_id"], name: "index_publishers_on_category_id", using: :btree
  add_index "publishers", ["confirmation_token"], name: "index_publishers_on_confirmation_token", unique: true, using: :btree
  add_index "publishers", ["email"], name: "index_publishers_on_email", unique: true, using: :btree
  add_index "publishers", ["name"], name: "index_publishers_on_name", using: :btree
  add_index "publishers", ["reset_password_token"], name: "index_publishers_on_reset_password_token", unique: true, using: :btree

  create_table "pubquestions", force: :cascade do |t|
    t.integer  "publisher_id", limit: 4
    t.integer  "question_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pubquestions", ["publisher_id"], name: "index_pubquestions_on_publisher_id", using: :btree
  add_index "pubquestions", ["question_id"], name: "index_pubquestions_on_question_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "text",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alpha_id",        limit: 255
    t.integer  "count",           limit: 4,     default: 0
    t.integer  "limit",           limit: 4
    t.boolean  "over",                          default: false
    t.boolean  "multiple_choice",               default: true,  null: false
    t.string   "demographic",     limit: 255
    t.boolean  "test",                          default: false
    t.integer  "campaign_id",     limit: 4
    t.boolean  "use_images",                    default: false
    t.integer  "num_responses",   limit: 4,     default: 0
    t.boolean  "random",                        default: false
  end

  add_index "questions", ["campaign_id"], name: "index_questions_on_campaign_id", using: :btree

  create_table "readers", force: :cascade do |t|
    t.string   "alpha_id",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender",       limit: 255
    t.string   "age",          limit: 255
    t.string   "last_page",    limit: 255
    t.string   "last_ip",      limit: 255
    t.string   "initial_page", limit: 255
    t.string   "initial_ip",   limit: 255
    t.string   "city",         limit: 255
    t.string   "region",       limit: 255
    t.string   "country",      limit: 255
    t.string   "timezone",     limit: 255
  end

  create_table "researchers", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",        null: false
    t.string   "encrypted_password",     limit: 255, default: "",        null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alpha_id",               limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "name",                   limit: 255
    t.boolean  "allow_custom"
    t.string   "sponsor_text",           limit: 255
    t.string   "sponsor_link",           limit: 255
    t.string   "logo_text_hex",          limit: 255, default: "#FFFFFF"
    t.string   "logo_background_hex",    limit: 255, default: "#FFBF3F"
    t.boolean  "verified"
    t.string   "company_name",           limit: 255
    t.string   "website",                limit: 255
    t.boolean  "use_custom_colors",                  default: true
    t.boolean  "admin",                              default: false
  end

  add_index "researchers", ["confirmation_token"], name: "index_researchers_on_confirmation_token", unique: true, using: :btree
  add_index "researchers", ["email"], name: "index_researchers_on_email", unique: true, using: :btree
  add_index "researchers", ["name"], name: "index_researchers_on_name", using: :btree
  add_index "researchers", ["reset_password_token"], name: "index_researchers_on_reset_password_token", unique: true, using: :btree

  create_table "responses", force: :cascade do |t|
    t.text     "text",        limit: 65535
    t.integer  "question_id", limit: 4
    t.integer  "choice_id",   limit: 4
    t.string   "full_url",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reader_id",   limit: 4
    t.integer  "article_id",  limit: 4
  end

  add_index "responses", ["article_id"], name: "index_responses_on_article_id", using: :btree
  add_index "responses", ["choice_id"], name: "index_responses_on_choice_id", using: :btree
  add_index "responses", ["question_id"], name: "index_responses_on_question_id", using: :btree
  add_index "responses", ["reader_id", "question_id"], name: "index_responses_on_reader_id_and_question_id", using: :btree
  add_index "responses", ["reader_id"], name: "index_responses_on_reader_id", using: :btree

  create_table "visits", force: :cascade do |t|
    t.integer  "reader_id",  limit: 4
    t.integer  "article_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "visits", ["article_id"], name: "index_visits_on_article_id", using: :btree
  add_index "visits", ["reader_id"], name: "index_visits_on_reader_id", using: :btree

end

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

ActiveRecord::Schema.define(:version => 20140509001806) do

  create_table "achievements", :force => true do |t|
    t.text     "award"
    t.string   "short_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "file_links", :force => true do |t|
    t.text     "description"
    t.text     "url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "fitbit_activities", :force => true do |t|
    t.integer  "fitbit_profile_id"
    t.integer  "steps"
    t.integer  "floors"
    t.date     "date_logged"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "fitbit_bodies", :force => true do |t|
    t.integer  "fitbit_profile_id"
    t.date     "date_logged"
    t.float    "weight"
    t.float    "bmi"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "fitbit_profiles", :force => true do |t|
    t.string   "fitbit_user_id"
    t.integer  "user_id"
    t.string   "request_token"
    t.string   "request_secret"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "verifier"
    t.boolean  "body",           :default => true
    t.boolean  "activities",     :default => true
    t.boolean  "sleep",          :default => true
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "fitbit_sleeps", :force => true do |t|
    t.integer  "fitbit_profile_id"
    t.integer  "minutes_asleep"
    t.integer  "minutes_awake"
    t.integer  "number_awakenings"
    t.integer  "minutes_to_sleep"
    t.date     "date_logged"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "genome_gov_papers", :force => true do |t|
    t.text     "first_author"
    t.text     "title"
    t.text     "pubmed_link"
    t.text     "pub_date"
    t.text     "journal"
    t.text     "trait"
    t.float    "pvalue"
    t.text     "pvalue_description"
    t.text     "confidence_interval"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "genotypes", :force => true do |t|
    t.string   "filetype",              :default => "23andme"
    t.integer  "user_id",                                      :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "md5sum"
    t.string   "genotype_file_name"
    t.string   "genotype_content_type"
    t.integer  "genotype_file_size"
    t.datetime "genotype_updated_at"
  end

  create_table "homepages", :force => true do |t|
    t.text     "url"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
  end

  create_table "mendeley_papers", :force => true do |t|
    t.text     "first_author"
    t.text     "title"
    t.text     "mendeley_url"
    t.text     "doi"
    t.integer  "pub_year"
    t.string   "uuid"
    t.boolean  "open_access"
    t.integer  "reader"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "messages", :force => true do |t|
    t.text     "subject"
    t.integer  "user_id"
    t.text     "body"
    t.boolean  "sent"
    t.boolean  "user_has_seen"
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "pgp_annotations", :force => true do |t|
    t.text     "gene"
    t.text     "qualified_impact"
    t.text     "inheritance"
    t.text     "summary"
    t.text     "trait"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "snp_id"
  end

  create_table "phenotype_comments", :force => true do |t|
    t.text     "comment_text"
    t.text     "subject"
    t.integer  "user_id"
    t.integer  "phenotype_id"
    t.integer  "reply_to_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "phenotype_sets", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "phenotype_sets_phenotypes", :id => false, :force => true do |t|
    t.integer "phenotype_set_id"
    t.integer "phenotype_id"
  end

  create_table "phenotypes", :force => true do |t|
    t.string   "characteristic"
    t.text     "known_phenotypes"
    t.integer  "number_of_users",  :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.text     "description"
  end

  create_table "picture_phenotype_comments", :force => true do |t|
    t.text     "comment_text"
    t.text     "subject"
    t.integer  "user_id"
    t.integer  "picture_phenotype_id"
    t.integer  "reply_to_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "picture_phenotypes", :force => true do |t|
    t.string   "characteristic"
    t.text     "description"
    t.integer  "number_of_users", :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "plos_papers", :force => true do |t|
    t.text     "first_author"
    t.text     "title"
    t.text     "doi"
    t.datetime "pub_date"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "reader"
  end

  create_table "snp_comments", :force => true do |t|
    t.text     "comment_text"
    t.text     "subject"
    t.integer  "user_id"
    t.integer  "snp_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "reply_to_id"
  end

  create_table "snp_references", :id => false, :force => true do |t|
    t.integer "snp_id",     :null => false
    t.integer "paper_id",   :null => false
    t.string  "paper_type", :null => false
  end

  add_index "snp_references", ["paper_id", "paper_type"], :name => "index_snp_references_on_paper_id_and_paper_type"
  add_index "snp_references", ["snp_id"], :name => "index_snp_references_on_snp_id"

  create_table "snpedia_papers", :force => true do |t|
    t.string   "url"
    t.text     "summary"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "revision",   :default => 0
  end

  create_table "snps", :force => true do |t|
    t.string   "name"
    t.string   "position"
    t.string   "chromosome"
    t.string   "genotype_frequency"
    t.string   "allele_frequency"
    t.integer  "ranking"
    t.integer  "number_of_users",    :default => 0
    t.datetime "mendeley_updated",   :default => '2014-05-23 08:01:14'
    t.datetime "plos_updated",       :default => '2014-05-23 08:01:14'
    t.datetime "snpedia_updated",    :default => '2014-05-23 08:01:14'
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "user_snps_count"
  end

  add_index "snps", ["chromosome", "position"], :name => "index_snps_chromosome_position"
  add_index "snps", ["id"], :name => "index_snps_on_id", :unique => true
  add_index "snps", ["name"], :name => "index_snps_on_name"
  add_index "snps", ["ranking"], :name => "index_snps_ranking"

  create_table "user_achievements", :force => true do |t|
    t.integer  "user_id"
    t.integer  "achievement_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "user_phenotypes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "phenotype_id"
    t.string   "variation"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "user_picture_phenotypes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "picture_phenotype_id"
    t.string   "variation"
    t.string   "phenotype_picture_file_name"
    t.string   "phenotype_picture_content_type"
    t.integer  "phenotype_picture_file_size"
    t.datetime "phenotype_picture_updated_at"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "user_snps", :force => true do |t|
    t.string   "local_genotype"
    t.integer  "genotype_id"
    t.integer  "user_id"
    t.integer  "snp_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "snp_name"
  end

  add_index "user_snps", ["snp_name", "user_id"], :name => "index_user_snps_on_user_id_and_snp_name"
  add_index "user_snps", ["snp_name"], :name => "index_user_snps_on_snp_name"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_salt"
    t.string   "crypted_password"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.boolean  "has_sequence",                       :default => false
    t.string   "sequence_link"
    t.text     "description"
    t.boolean  "finished_snp_parsing",               :default => false
    t.integer  "phenotype_creation_counter",         :default => 0
    t.integer  "phenotype_additional_counter",       :default => 0
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "help_one",                           :default => false
    t.boolean  "help_two",                           :default => false
    t.boolean  "help_three",                         :default => false
    t.string   "sex",                                :default => "rather not say"
    t.string   "yearofbirth",                        :default => "rather not say"
    t.boolean  "message_on_message",                 :default => true
    t.boolean  "message_on_snp_comment_reply",       :default => true
    t.boolean  "message_on_phenotype_comment_reply", :default => true
    t.boolean  "message_on_newsletter",              :default => true
    t.boolean  "message_on_new_phenotype",           :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token", :unique => true

end

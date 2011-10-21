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

ActiveRecord::Schema.define(:version => 20111018040633) do

  create_table "achievements", :force => true do |t|
    t.text     "award"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genotypes", :force => true do |t|
    t.datetime "uploadtime",                              :null => false
    t.string   "filetype",         :default => "23andme"
    t.string   "originalfilename",                        :null => false
    t.integer  "user_id",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "homepages", :force => true do |t|
    t.text     "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "snp_id"
  end

  create_table "messages", :force => true do |t|
    t.text     "subject"
    t.integer  "user_id"
    t.text     "body"
    t.boolean  "sent"
    t.boolean  "user_has_seen"
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phenotype_comments", :force => true do |t|
    t.text     "comment_text"
    t.text     "subject"
    t.integer  "user_id"
    t.integer  "phenotype_id"
    t.integer  "reply_to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phenotypes", :force => true do |t|
    t.string   "characteristic"
    t.string   "known_phenotypes"
    t.integer  "number_of_users",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "plos_papers", :force => true do |t|
    t.text     "first_author"
    t.text     "title"
    t.text     "doi"
    t.datetime "pub_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reader"
    t.integer  "snp_id"
  end

  create_table "snp_comments", :force => true do |t|
    t.text     "comment_text"
    t.text     "subject"
    t.integer  "user_id"
    t.integer  "snp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_to_id"
  end

  create_table "snpedia_papers", :force => true do |t|
    t.string   "url"
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "snp_id"
  end

  create_table "snps", :force => true do |t|
    t.string   "name"
    t.string   "position"
    t.string   "chromosome"
    t.string   "genotype_frequency"
    t.string   "allele_frequency"
    t.integer  "ranking"
    t.integer  "number_of_users",    :default => 0
    t.datetime "mendeley_updated",   :default => '2011-08-27 16:54:19'
    t.datetime "plos_updated",       :default => '2011-08-27 16:54:19'
    t.datetime "snpedia_updated",    :default => '2011-08-27 16:54:19'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "snps", ["id"], :name => "index_snps_on_id", :unique => true
  add_index "snps", ["ranking"], :name => "index_snps_ranking"

  create_table "user_achievements", :force => true do |t|
    t.integer  "user_id"
    t.integer  "achievement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_phenotypes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "phenotype_id"
    t.string   "variation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_snps", :force => true do |t|
    t.string   "local_genotype"
    t.integer  "genotype_id"
    t.integer  "user_id"
    t.integer  "snp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "snp_name"
  end

  add_index "user_snps", ["snp_name", "user_id"], :name => "index_user_snps_on_user_id_and_snp_name"

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
    t.datetime "created_at"
    t.datetime "updated_at"
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

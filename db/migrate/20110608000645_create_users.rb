class CreateUsers < ActiveRecord::Migration
  def self.up
	  create_table :users do |t|
		  t.string :name
		  t.string :email, :unique => true
		  t.string :password_salt
		  t.string :crypted_password
		  t.string :persistence_token  # to stay logged in
		  t.string :perishable_token   # for password-reset
		  t.boolean :has_sequence, :default => false
		  t.string :sequence_link
		  t.text :description
		  t.boolean :finished_snp_parsing, :default => false
			t.integer :phenotype_creation_counter, :default => 0
			t.integer :phenotype_additional_counter, :default => 0
		  
		  t.timestamps
	  end

	  add_index :users, ["email"], :name => "index_users_on_email", :unique => true 
	  add_index :users, ["persistence_token"], :name => "index_users_on_persistence_token", :unique => true
  end

  def self.down
  	drop_table :users
  end
end

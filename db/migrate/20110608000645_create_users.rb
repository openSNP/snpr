class CreateUsers < ActiveRecord::Migration
  def self.up
	  create_table :users do |t|
		  t.string :name
		  t.string :email, :unique => true
		  t.string :password_salt
		  t.string :crypted_password
		  t.string :persistence_token  # to stay logged in
		  t.string :perishable_token   # for password-reset
		  t.boolean :has_sequence
		  t.string :sequence_link
		  
		  t.timestamps
	  end

	  add_index :users, ["name"], :name => "index_users_on_login", :unique => true
	  add_index :users, ["email"], :name => "index_users_on_email", :unique => true 
	  add_index :users, ["persistence_token"], :name => "index_users_on_persistence_token", :unique => true
  end

  def self.down
  	drop_table :users
  end
end

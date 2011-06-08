class CreateUsers < ActiveRecord::Migration
  def self.up
	  create_table :users do |t|
		  t.string :name
		  t.string :email, :unique => true
		  t.string :salt
		  t.string :encrypted_password
		  t.boolean :has_sequence
		  t.string :sequence_link
		  
		  t.timestamps
	  end
  end

  def self.down
  	drop_table :users
  end
end
